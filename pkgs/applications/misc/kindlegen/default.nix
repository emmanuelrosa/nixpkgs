{ stdenv, fetchurl, writeScript }:

let
  versionMajor = "2";
  versionMinor = "9";
  package = "kindlegen";

in stdenv.mkDerivation rec {
  name = "${package}-${version}";
  version = "${versionMajor}-${versionMinor}";
  src = fetchurl {
    url = "http://${package}.s3.amazonaws.com/${package}_linux_2.6_i386_v${versionMajor}_${versionMinor}.tar.gz";
    sha256 = "9828db5a2c8970d487ada2caa91a3b6403210d5d183a7e3849b1b206ff042296";
  };

  builder = writeScript "builder.sh" "";

}
