{
  curl,
  expat,
  fetchurl,
  lib,
  libmicrohttpd,
  meson,
  ninja,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libnpupnp";
  version = "6.2.1";

  src = fetchurl {
    url = "https://www.lesbonscomptes.com/upmpdcli/downloads/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-HMEiJRLUgIJtKSPMe5i3NhGDoq3YxrZGp/oywvNLMrM=";
  };

  buildInputs = [
    curl
    expat
    libmicrohttpd
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = with lib; {
    homepage = "https://www.lesbonscomptes.com/upmpdcli/npupnp-doc/libnpupnp.html";
    description = "A C++ base UPnP library, derived from Portable UPnP, a.k.a libupnp";
    license = licenses.bsd3;
  };
})
