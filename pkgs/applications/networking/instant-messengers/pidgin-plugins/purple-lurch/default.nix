{ stdenv, fetchFromGitHub, pidgin, minixml, libxml2, sqlite, libgcrypt, cmake }:

stdenv.mkDerivation rec {
  name = "purple-lurch-0.6.7";
  src = fetchFromGitHub {
    owner = "gkdr";
    repo = "lurch";
    rev = "3156e14c2dcf9968438aceb7fda8f82eae6f552d";
    sha256 = "029jjqinsfhpv0zgji3sv1cyk54fn9qp176fwy97d1clf0vflxrz";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ pidgin minixml libxml2 sqlite libgcrypt ];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  installPhase = ''
    install -Dm755 -t $out/lib/purple-2 build/lurch.so
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/gkdr/lurch;
    description = "XEP-0384: OMEMO Encryption for libpurple.";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
