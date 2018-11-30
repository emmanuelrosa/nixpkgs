{ stdenv, fetchurl, makeWrapper, writeScript, jre }:

stdenv.mkDerivation rec {
  name = "masterpassword-${version}";
  version = "2.7";

  src = fetchurl {
    url = https://masterpassword.app/masterpassword-gui.jar;
    sha256 = "126nmqg6nnx5fl0gks2an7jl8krmpqnac6jrcbwnnd296zqbpvhk";
  };

  buildInputs = [ makeWrapper ];

  builder = writeScript "builder.sh" ''  
    source $stdenv/setup
    mkdir -p $out/bin

    makeWrapper ${jre}/bin/java $out/bin/masterpassword \
      --add-flags "-jar $src" \
  '';

  meta = with stdenv.lib; {
    description = "A stateless password management solution.";
    longDescription = "The platform-independent GUI client implemented in Java.";
    homepage = https://masterpassword.app;
    license = licenses.gpl3;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = platforms.all;
  };
}
