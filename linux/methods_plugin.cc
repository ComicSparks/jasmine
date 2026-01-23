#include "methods_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "rust.h"

#define METHODS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), methods_plugin_get_type(), \
                              MethodsPlugin))

struct _MethodsPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(MethodsPlugin, methods_plugin, g_object_get_type())

// Structure to hold data for async method call
struct InvokeTaskData {
  FlMethodCall* method_call;
  gchar* params;
};

// Cleanup function for task data
static void invoke_task_data_free(InvokeTaskData* data) {
  if (data->params) {
    g_free(data->params);
  }
  if (data->method_call) {
    g_object_unref(data->method_call);
  }
  g_free(data);
}

// Background thread task
static void invoke_task_run(GTask* task, gpointer source_object,
                           gpointer task_data, GCancellable* cancellable) {
  InvokeTaskData* data = static_cast<InvokeTaskData*>(task_data);
  
  // Execute the FFI call in background thread
  char* rs = invoke_ffi(data->params);
  
  // Return the result
  g_task_return_pointer(task, rs, nullptr);
}

// Callback when task completes (runs on main thread)
static void invoke_task_complete(GObject* source_object, GAsyncResult* result,
                                gpointer user_data) {
  GTask* task = G_TASK(result);
  InvokeTaskData* data = static_cast<InvokeTaskData*>(g_task_get_task_data(task));
  
  GError* error = nullptr;
  char* rs = static_cast<char*>(g_task_propagate_pointer(task, &error));
  
  g_autoptr(FlMethodResponse) response = nullptr;
  
  if (error != nullptr) {
    response = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "INVOKE_ERROR", error->message, nullptr));
    g_error_free(error);
  } else {
    g_autoptr(FlValue) result = fl_value_new_string(rs);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    free_str_ffi(rs);
  }
  
  fl_method_call_respond(data->method_call, response, nullptr);
}

// Called when a method call is received from Flutter.
static void methods_plugin_handle_method_call(
    MethodsPlugin* self,
    FlMethodCall* method_call) {

  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "invoke") == 0) {
        // Prepare task data
        InvokeTaskData* data = g_new0(InvokeTaskData, 1);
      data->method_call = static_cast<FlMethodCall*>(g_object_ref(method_call));
        
        FlValue *value = fl_method_call_get_args(method_call);
        const char* params = fl_value_get_string(value);
        data->params = g_strdup(params);
        
        // Create and run task in background thread
        GTask* task = g_task_new(self, nullptr, invoke_task_complete, nullptr);
        g_task_set_task_data(task, data, (GDestroyNotify)invoke_task_data_free);
        g_task_run_in_thread(task, invoke_task_run);
        g_object_unref(task);
  } else if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
  }

}

static void methods_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(methods_plugin_parent_class)->dispose(object);
}

static void methods_plugin_class_init(MethodsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = methods_plugin_dispose;
}

static void methods_plugin_init(MethodsPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  MethodsPlugin* plugin = METHODS_PLUGIN(user_data);
  methods_plugin_handle_method_call(plugin, method_call);
}

void methods_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  MethodsPlugin* plugin = METHODS_PLUGIN(
      g_object_new(methods_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "methods",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
