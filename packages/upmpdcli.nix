{
  curl,
  fetchurl,
  jsoncpp,
  lib,
  libmicrohttpd,
  libmpdclient,
  libupnpp,
  meson,
  ninja,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "upmpdcli";
  version = "1.9.5";

  src = fetchurl {
    url = "https://www.lesbonscomptes.com/upmpdcli/downloads/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-M2S3jW+h0jKJSJKvXZ90O8W1Sys0Qs7DZ3PYZ+C+ZLs=";
  };

  buildInputs = [
    curl
    jsoncpp
    libmpdclient
    libmicrohttpd
    libupnpp
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "/etc" "$out/etc"
  '';

  installPhase = ''
    mkdir -p $out
    mv * $out/
  '';

  meta = with lib; {
    homepage = "https://www.lesbonscomptes.com/upmpdcli/index.html";
    description = "UPnP Renderer front-end to MPD";
    mainProgram = "upmpdcli";
    license = licenses.lgpl21;
  };
})
