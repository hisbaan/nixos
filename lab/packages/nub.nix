{ lib, fetchurl, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "nub";
  version = "0.1.7";

  src = fetchurl {
    url = "https://github.com/nubjs/nub/releases/download/v${version}/nub-linux-x64-musl.tar.gz";
    hash = "sha256-5VY59s3nm71AWZr/c0KGstW0ojNZcZgnlCVmp5/ma/o=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R bin runtime $out/
    runHook postInstall
  '';

  meta = {
    description = "All-in-one Node.js toolkit";
    homepage = "https://nubjs.com";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
