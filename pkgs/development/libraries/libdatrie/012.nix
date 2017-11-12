{ stdenv, lib, fetchurl }:

stdenv.mkDerivation {
  name = "libdatrie-0.1.2";

  src = fetchurl {
      url = "https://linux.thai.net/pub/thailinux/software/libthai/libdatrie-0.1.2.tar.gz";
      sha256 = "17qh529rxsfmv9snxkbipz6dxpzznsh7gwh07vym8pjqfd0syhl1";
  };


  meta = with lib; {
    description = "An Implementation of Double-Array Trie";
    homepage = https://linux.thai.net/~thep/datrie/datrie.html;
    maintainers = [ maintainers.emmanuelrosa ];
    platforms = with platforms; [ linux ];
    license = licenses.lgpl21;
  };
}
