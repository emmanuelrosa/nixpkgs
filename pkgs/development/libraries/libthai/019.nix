{ stdenv, lib, fetchurl, libdatrie, pkgconfig }:

stdenv.mkDerivation {
  name = "libthai-0.1.9";

  src = fetchurl {
      url = "https://linux.thai.net/pub/thailinux/software/libthai/libthai-0.1.9.tar.gz";
      sha256 = "07fb0nkjv3cqigh3m3a0j3vmx27qibwlpnqgfqvh25bykcybga8k";
  };

  outputs = [ "out" "dev" ];
  buildInputs = [ libdatrie ];
  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ libdatrie ];

  meta = with lib; {
    description = "Thai language support routines aimed to ease developers’ tasks to incorporate Thai language support in their applications";
    homepage = https://linux.thai.net/projects/libthai;
    maintainers = [ maintainers.emmanuelrosa ];
    platforms = with platforms; [ linux ];
    license = licenses.lgpl21;
  };
}
