#!/usr/bin/env bash
# Remove libwayland-* from the Linux AppImage after tauri-bundler built it.
# Why: the AppImage's AppRun puts its own usr/lib first in LD_LIBRARY_PATH. The bundled
# libwayland-client (from the ubuntu-22.04 build host) shadows the system one, so a newer Mesa's
# libEGL_mesa.so.0 fails to load (undefined symbol wl_fixes_interface, wl_display_create_queue_with_name,
# wl_display_dispatch_queue_timeout). WebKitWebProcess then aborts with
# "Could not create default EGL display: EGL_BAD_PARAMETER" and the window stays blank.
# See docs/issues/appimage-libwayland/README.md.
# Usage: scripts/strip-appimage-libwayland.sh path/to/Comail_x.y.z_amd64.AppImage
set -euo pipefail
img=$(readlink -f "$1")
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
cd "$work"
"$img" --appimage-extract >/dev/null
rm -fv squashfs-root/usr/lib/libwayland-*.so*
curl -fsSL -o appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool
ARCH=x86_64 ./appimagetool --appimage-extract-and-run squashfs-root "$img"
