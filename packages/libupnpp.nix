{
  curl,
  expat,
  fetchurl,
  lib,
  libnpupnp,
  meson,
  ninja,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libupnpp";
  version = "1.0.2";

  src = fetchurl {
    url = "https://www.lesbonscomptes.com/upmpdcli/downloads/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-9LHLaWRd4YaKnHlAY7CgG9EU6YUtfvaFLoQ+KHD9H7I=";
  };

  buildInputs = [
    curl
    expat
    libnpupnp
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = with lib; {
    homepage = "https://www.lesbonscomptes.com/upmpdcli/libupnpp-refdoc/libupnpp-ctl.html";
    description = "Libupnpp provides a higher level C++ API over libnpupnp or libupnp";
    license = licenses.lgpl21;
  };
})
