{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  libxkbcommon,
  wayland,
  vulkan-loader,
  glib,
  pipewire,
}:

stdenv.mkDerivation rec {
  pname = "hokum";
  version = "0.1.3";

  src = fetchurl {
    url = "https://github.com/anomalyco/hokum/releases/download/v${version}/hokum-${version}-linux-x64";
    hash = "sha256-4AyMbr0M+3xT1TXW+rfsAsL0K7JMQFfBePggElMnbUU=";
  };

  # systemd unit, D-Bus activation file and .desktop entry
  packaging = fetchFromGitHub {
    owner = "anomalyco";
    repo = "hokum";
    rev = "v${version}";
    hash = "sha256-+CS6Rq3lQsli+F7GR56vejJfkHFWRI+dJV7AnWkMs60=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    libxkbcommon
  ];
  # dlopen()ed at runtime
  runtimeDependencies = [
    wayland
    vulkan-loader
    libxkbcommon
    glib
    pipewire
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/hokum
    install -Dm644 $packaging/packaging/hokum.service $out/lib/systemd/user/hokum.service
    install -Dm644 $packaging/packaging/app.hokum.Notifications.service \
      $out/share/dbus-1/services/app.hokum.Notifications.service
    install -Dm644 $packaging/packaging/hokum.desktop $out/share/applications/hokum.desktop
    substituteInPlace \
      $out/lib/systemd/user/hokum.service \
      $out/share/dbus-1/services/app.hokum.Notifications.service \
      --replace-fail /usr/bin/hokum $out/bin/hokum
    runHook postInstall
  '';

  meta = {
    description = "Control center for Wayland: notifications, sound and Bluetooth";
    homepage = "https://hokum.app";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "hokum";
  };
}
