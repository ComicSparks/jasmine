#include "my_application.h"
#include "rust.h"
#include <glib.h>
#include <pwd.h>
#include <stdio.h>
#include <unistd.h>

#include "rust1.h"

int main(int argc, char** argv) {
  struct passwd *pw = getpwuid(getuid());

  const gchar* xdg_data_home = g_getenv("XDG_DATA_HOME");
  g_autofree gchar* data_home = nullptr;
  if (xdg_data_home != nullptr && xdg_data_home[0] != '\0') {
    data_home = g_strdup(xdg_data_home);
  } else {
    data_home = g_build_filename(pw->pw_dir, ".local", "share", nullptr);
  }

  g_autofree gchar* jasmine_data_dir = g_build_filename(data_home, "jasmine", nullptr);
  g_mkdir_with_parents(jasmine_data_dir, 0700);

  printf("DATA_DIR : %s\n", jasmine_data_dir);
  init_ffi(jasmine_data_dir);
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
