# Linux AppImage: blank window with newer Mesa (bundled libwayland shadows the system one)

**Symptom:** the window opens but stays empty/dark. Log: `Could not create default EGL display: EGL_BAD_PARAMETER. Aborting...` from WebKitWebProcess, then `main window still hidden after 10s; forcing show`. Seen with Comail 0.2.42 and 0.2.44, run through nixpkgs `appimageTools.wrapType2` (nix Mesa 26.1.8 via `/run/opengl-driver`, X11, AMD RX 6800 XT) on a Pop!_OS host. Not reproduced in a plain AppImage run on another distro.

**Cause (measured):** `LD_LIBRARY_PATH=<AppDir>/usr/lib ldd -r libEGL_mesa.so.0` reports `undefined symbol: wl_fixes_interface`, `wl_display_create_queue_with_name`, `wl_display_dispatch_queue_timeout`; without the AppDir libs it reports none. The bundled `usr/lib/libwayland-client.so.0` exports none of those three symbols (`nm -D --defined-only` count: 0). Where the bundled copy comes from was not checked. glvnd then has no usable EGL vendor.

**Workaround verified by eye, inside the nixpkgs wrapper only:** deleting `usr/lib/libwayland-{client,cursor,egl,server}` from the AppDir (the wrapper then supplies wayland 1.25). Before: [before-blank.webp](before-blank.webp), after: [after-fixed.webp](after-fixed.webp) (Welcome screen + inbox).

**Status of this PR:** `scripts/strip-appimage-libwayland.sh` is NOT run in CI and NOT wired into `release.yml`. Wiring it needs, after tauri-action: repack, re-sign the updater artifact with the updater key, re-upload the AppImage and regenerate `latest.json` - none of that can be tested without the `release` environment and signing key. Only the manual deletion of the four libraries was verified (before/after screenshots).
