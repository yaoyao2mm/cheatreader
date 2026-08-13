#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <package.deb>" >&2
  exit 2
fi

package_path="$1"
package_root="$(mktemp -d)"
trap 'rm -rf "$package_root"' EXIT

depends="$(dpkg-deb --field "$package_path" Depends)"
if [[ "$depends" != *"libayatana-appindicator3-1"* ]]; then
  echo "Package does not require libayatana-appindicator3-1: $depends" >&2
  exit 1
fi
if [[ "$depends" == *"libappindicator3-1"* ]]; then
  echo "Package incorrectly treats libappindicator3-1 as interchangeable: $depends" >&2
  exit 1
fi
if [[ "$depends" != *"libkeybinder-3.0-0"* ]]; then
  echo "Package does not require libkeybinder-3.0-0: $depends" >&2
  exit 1
fi

dpkg-deb --extract "$package_path" "$package_root"
tray_plugin="$package_root/opt/cheatreader/lib/libtray_manager_plugin.so"
if [ ! -f "$tray_plugin" ]; then
  echo "Packaged tray plugin was not found." >&2
  exit 1
fi
if ! readelf -d "$tray_plugin" | grep -F 'libayatana-appindicator3.so.1' >/dev/null; then
  echo "Packaged tray plugin does not link to libayatana-appindicator3.so.1." >&2
  exit 1
fi

hotkey_plugin="$package_root/opt/cheatreader/lib/libhotkey_manager_linux_plugin.so"
if [ ! -f "$hotkey_plugin" ]; then
  echo "Packaged hotkey plugin was not found." >&2
  exit 1
fi
if ! readelf -d "$hotkey_plugin" | grep -F 'libkeybinder-3.0.so.0' >/dev/null; then
  echo "Packaged hotkey plugin does not link to libkeybinder-3.0.so.0." >&2
  exit 1
fi

echo "Linux package dependencies match the tray and hotkey plugin SONAMEs."
