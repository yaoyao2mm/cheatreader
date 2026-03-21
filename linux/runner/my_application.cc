#include "my_application.h"

#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static gboolean os_release_contains_value(const gchar* contents,
                                         const gchar* key,
                                         const gchar* value) {
  g_autofree gchar* quoted_pattern =
      g_strdup_printf("%s=\"%s\"", key, value);
  g_autofree gchar* plain_pattern = g_strdup_printf("%s=%s", key, value);
  return g_strstr_len(contents, -1, quoted_pattern) != nullptr ||
         g_strstr_len(contents, -1, plain_pattern) != nullptr;
}

static gboolean should_force_software_renderer() {
  const gchar* renderer = g_getenv("FLUTTER_LINUX_RENDERER");
  if (renderer != nullptr && renderer[0] != '\0') {
    return FALSE;
  }

  g_autofree gchar* os_release_contents = nullptr;
  if (!g_file_get_contents("/etc/os-release", &os_release_contents, nullptr,
                           nullptr)) {
    return FALSE;
  }

  const gboolean is_ubuntu =
      os_release_contains_value(os_release_contents, "ID", "ubuntu");
  const gboolean is_focal =
      os_release_contains_value(os_release_contents, "VERSION_ID", "20.04") ||
      os_release_contains_value(os_release_contents, "UBUNTU_CODENAME",
                                "focal");
  if (!is_ubuntu || !is_focal) {
    return FALSE;
  }

  const gchar* session_type = g_getenv("XDG_SESSION_TYPE");
  return session_type == nullptr || g_strcmp0(session_type, "x11") == 0;
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Create the Linux window as undecorated up front. This preserves the same
  // frameless visual style while avoiding runtime decoration toggles that are
  // unreliable on Ubuntu 20.04 X11/GNOME combinations.
  gtk_window_set_title(window, "cheatreader");
  gtk_window_set_decorated(window, false);

  gtk_window_set_default_size(window, 1280, 720);

  if (should_force_software_renderer()) {
    g_setenv("FLUTTER_LINUX_RENDERER", "software", TRUE);
    g_message("Ubuntu 20.04 detected, forcing Flutter Linux software renderer "
              "to avoid libepoxy/OpenGL startup crashes.");
  }

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
