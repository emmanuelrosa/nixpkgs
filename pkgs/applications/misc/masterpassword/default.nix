{ stdenv, fetchurl, makeWrapper, writeScript, makeDesktopItem, buildFHSUserEnv, jre, xorg }:

let
  desktopItem = makeDesktopItem {
    name = "masterpassword";
    exec = "masterpassword";
    icon = "masterpassword";
    desktopName = "Master Password";
    categories = "Security";
  };

  package = stdenv.mkDerivation rec {
    name = "masterpassword-${version}";
    version = "2.7";

    src = fetchurl {
      url = https://masterpassword.app/masterpassword-gui.jar;
      sha256 = "126nmqg6nnx5fl0gks2an7jl8krmpqnac6jrcbwnnd296zqbpvhk";
    };

    icon = fetchurl {
      url = https://masterpassword.app/img/favicon.png;
      sha256 = "0znvkdvpb8hpd6pndbbviz44fp6ksfl1snq7w0287yf36qw3lbpv";
    };

    buildInputs = [ makeWrapper ];

    builder = writeScript "builder.sh" ''  
      source $stdenv/setup
      mkdir -p $out/bin
      mkdir -p $out/share/icons/hicolor/32x32

      makeWrapper ${jre}/bin/java $out/bin/masterpassword \
        --add-flags "-jar $src" \

      ln -s ${desktopItem}/share/applications $out/share/applications
      ln -s ${icon} $out/share/icons/hicolor/32x32/masterpassword.png
    '';

    meta = with stdenv.lib; {
      description = "A stateless password management solution.";
      longDescription = "The platform-independent GUI client implemented in Java.";
      homepage = https://masterpassword.app;
      license = licenses.gpl3;
      maintainers = with maintainers; [ emmanuelrosa ];
      platforms = platforms.all;
    };
};
in buildFHSUserEnv {
    name = "masterpassword-fhs";
    targetPkgs = pkgs: [ pkgs.xorg.libX11 ];
    runScript = "${package}/bin/masterpassword";
  } // { inherit (package) meta name; }
