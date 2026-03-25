import 'dart:io';

bool shouldForceMultiLineStartupImpl() {
  if (!Platform.isLinux) {
    return false;
  }

  try {
    final contents = File('/etc/os-release').readAsStringSync();
    final isUbuntu =
        contents.contains('ID=ubuntu') || contents.contains('ID="ubuntu"');
    return isUbuntu;
  } catch (_) {
    return false;
  }
}
