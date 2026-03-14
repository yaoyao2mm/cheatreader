import 'platform_window_controller_base.dart';
import 'platform_window_controller_stub.dart'
    if (dart.library.io) 'platform_window_controller_desktop.dart';

PlatformWindowController createPlatformWindowController() =>
    createPlatformWindowControllerImpl();
