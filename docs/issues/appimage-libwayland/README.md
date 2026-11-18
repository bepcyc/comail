# Linux AppImage: blank window with newer Mesa (bundled libwayland shadows the system one)

**Symptom:** the window opens but stays empty/dark. Log: `Could not create default EGL display: EGL_BAD_PARAMETER. Aborting...` from WebKitWebProcess, then `main window still hidden after 10s; forcing show`. Seen with Comail 0.2.42-0.2.44 on Pop!_OS 24.04 (X11, AMD RX 6800 XT, Mesa 26.1.8).

**Cause (measured):** `LD_LIBRARY_PATH=<AppDir>/usr/lib ldd -r libEGL_mesa.so.0` reports `undefined symbol: wl_fixes_interface`, `wl_display_create_queue_with_name`, `wl_display_dispatch_queue_timeout`; without the AppDir libs it reports none. The bundled `usr/lib/libwayland-{client,cursor,egl,server}` come from the ubuntu-22.04 build host and are older than what current Mesa needs. glvnd then has no usable EGL vendor.

**Workaround verified by eye:** deleting those four files from the AppDir. Before: [before-blank.webp](before-blank.webp), after: [after-fixed.webp](after-fixed.webp) (Welcome screen + inbox).

**Status of this PR:** `scripts/strip-appimage-libwayland.sh` is NOT run in CI and NOT wired into `release.yml`. Wiring it needs, after tauri-action: repack, re-sign the updater artifact with the updater key, re-upload the AppImage and regenerate `latest.json` - none of that can be tested without the `release` environment and signing key. Only the manual deletion of the four libraries was verified (before/after screenshots).
