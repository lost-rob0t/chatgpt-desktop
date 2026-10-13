{
  lib,
  stdenv,
  fetchurl,
  rpmextract,
  autoPatchelfHook,
  makeWrapper,
  coreutils,
  gnutar,
  xdg-utils,
  xz,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  udev,
  tpm2-tss,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt-desktop";
  version = "26.1007.21434";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/rpm/x86_64/chatgpt-26.1007.21434-1.x86_64.rpm";
    sha256 = "sha256-xFN99kH8hF6ABqHiEfanGCAaWsu/KEiCAMN4piW0MXg=";
  };

  nativeBuildInputs = [
    rpmextract
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libnotify
    libpulseaudio
    libsecret
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    mesa
    nspr
    nss
    openssl
    pango
    (lib.getLib stdenv.cc.cc)
    udev
    tpm2-tss
  ];

  unpackPhase = ''
    runHook preUnpack
    rpmextract "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib" "$out/share"
    cp -a usr/bin/chatgpt "$out/bin/chatgpt"
    cp -a usr/lib/chatgpt "$out/lib/chatgpt"
    cp -a usr/share/applications "$out/share/applications"
    cp -a usr/share/pixmaps "$out/share/pixmaps"
    cp -a usr/share/doc "$out/share/doc"

    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail "Exec=chatgpt %U" "Exec=$out/bin/chatgpt %U"

    runHook postInstall
  '';

  # Optional Qt theme shims and musl prebuilds are not used by this GTK/glibc
  # package. All other missing dependencies must fail the build.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libc.musl-x86_64.so.1"
  ];

  postFixup = ''
    # Chromium/Electron loads libpulse.so.0 with dlopen instead of declaring it
    # in DT_NEEDED. autoPatchelf therefore cannot discover it automatically.
    # Expose the PulseAudio client library explicitly so microphone/Voice input
    # can connect to either PulseAudio or a PipeWire-Pulse compatibility server.
    wrapProgram "$out/lib/chatgpt/codex-launcher" \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        gnutar
        xdg-utils
        xz
      ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libpulseaudio ]}
  '';

  meta = {
    description = "Official ChatGPT desktop app for Linux";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
