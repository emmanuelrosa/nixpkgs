{ stdenv, fetchurl, dpkg, makeWrapper, buildEnv,
  gtk, atk, glib, cairo, pango, gdk_pixbuf, freetype, fontconfig, gtkglext, xorg, nss, nspr, 
  gconf, alsaLib, dbus, cups, mesa_glu, systemd, expat, pciutils 
}:

let
  version = "4_2_153_0_tkzkho5lhz15j08q";

  platform = {
    x86_64-linux = {
      inherit version;

      src = fetchurl {
        url = "https://updates-desktopapp.upwork.com/binaries/v${version}/upwork_amd64.deb";
        sha256 = "19ya2s1aygxsz5mhrix991sz6alpxkwjkz2rxqlpblab95hiikw0";
      };
    };

    i686-linux = {
      inherit version;

      src = fetchurl {
        url = "https://updates-desktopapp.upwork.com/binaries/v${version}/upwork_i386.deb";
        sha256 = "1r2hqzdd4s1kmpji1yn4ihs135yiaq4a8zxl6anyhzlyqmz63sj0";
      };
    };
  };

in with builtins.getAttr builtins.currentSystem platform; stdenv.mkDerivation {
  name = "upwork-${version}";
  inherit version src alsaLib nss nspr gconf; 

  buildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg -x $src ./
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    cp -ar ./usr/share/* $out/share
    rm $out/share/upwork/chrome-sandbox

    makeWrapper $out/share/upwork/upwork $out/bin/upwork
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/share/upwork/upwork
    patchelf --set-rpath $libs/lib:$out/share/upwork $out/share/upwork/upwork
    patchelf --set-rpath $libs/lib:$out/share/upwork $out/share/upwork/libcef.so

    function soCheck {
        echo "Checking $1 for missing linked libraries..."
        ! ldd $1 | grep -v "libGL" | grep "not found"
    }

    soCheck $out/share/upwork/upwork
    soCheck $out/share/upwork/libcef.so
  '';

  libs = buildEnv {
    name = "upwork-libs-env";
    pathsToLink = [ "/lib" ];

    paths = [
      cups.lib
      dbus.lib
      systemd.lib
      stdenv.cc.cc.lib
      xorg.libX11
      xorg.libXtst
      xorg.libXScrnSaver
      xorg.libXi
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXext
      xorg.libXfixes
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXrandr
      xorg.libXrender
      gtk
      atk
      glib
      pango.out
      cairo
      gdk_pixbuf
      freetype
      fontconfig.lib
      gtkglext
      dbus
      mesa_glu
      expat
      nss
      nspr
      alsaLib
      gconf
      pciutils
    ];
  };

  meta = {
    homepage = https://www.upwork.com/downloads;
    description = "Desktop application for Upwork freelancers to track time and connect with clients.";
    license = stdenv.lib.licenses.unfree;
    platforms = builtins.attrNames platform;
  };
}
