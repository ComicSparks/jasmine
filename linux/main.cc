#include "my_application.h"
#include "rust.h"
#include <pwd.h>
#include <stdio.h>

#include "rust1.h"

int main(int argc, char** argv) {
  struct passwd *pw = getpwuid(getuid());
  printf("PW_DIR : %s\n",pw->pw_dir);
  init_ffi(pw->pw_dir);
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
