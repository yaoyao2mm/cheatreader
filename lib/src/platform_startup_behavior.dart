import 'platform_startup_behavior_stub.dart'
    if (dart.library.io) 'platform_startup_behavior_io.dart';

bool shouldForceMultiLineStartup() => shouldForceMultiLineStartupImpl();
