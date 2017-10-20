{ stdenv, fetchurl, dpkg, makeWrapper,
  gtk2, atk, glib, cairo, pango, gdk_pixbuf, freetype, fontconfig, gtkglext, xorg, nss, nspr, 
  gconf, alsaLib, dbus, cups, mesa_glu, systemd, expat
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
  libXtst = xorg.libXtst;
  cupslib = cups.lib;
  dbuslib = dbus.lib;
  systemdlib = systemd.lib;
  buildInputs = [ dpkg makeWrapper ];

  unpackPhase = ''
    dpkg -x $src ./
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    cp -ar ./usr/share/* $out/share

    makeWrapper $out/share/upwork/upwork $out/bin/upwork
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/share/upwork/upwork
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/share/upwork/chrome-sandbox
    patchelf --set-rpath $out/share/upwork:$libPath $out/share/upwork/upwork
    patchelf --set-rpath $out/share/upwork:$libPath $out/share/upwork/libcef.so

    patchelf \
      --add-needed $nss/lib/libnss3.so \
      --add-needed $nss/lib/libnssutil3.so \
      --add-needed $nss/lib/libsmime3.so \
      --add-needed $nspr/lib/libnspr4.so \
      --add-needed $cupslib/lib/libcups.so.2 \
      --add-needed $(readlink -f $alsaLib/lib/libasound.so.2) \
      --add-needed $(readlink -f $gconf/lib/libgconf-2.so.4) \
      --add-needed $(readlink -f $libXtst/lib/libXtst.so.6) \
      $out/share/upwork/libcef.so

    patchelf \
      --add-needed $nss/lib/libnss3.so \
      --add-needed $nss/lib/libnssutil3.so \
      --add-needed $nss/lib/libsmime3.so \
      --add-needed $nspr/lib/libnspr4.so \
      --add-needed $cupslib/lib/libcups.so.2 \
      --add-needed $(readlink -f $alsaLib/lib/libasound.so.2) \
      --add-needed $(readlink -f $gconf/lib/libgconf-2.so.4) \
      --add-needed $(readlink -f $libXtst/lib/libXtst.so.6) \
      --add-needed $(readlink -f $dbuslib/lib/libdbus-1.so.3) \
      --add-needed $(readlink -f $systemdlib/lib/libudev.so) \
      $out/share/upwork/upwork

    function soCheck {
        echo "Checking $1 for missing linked libraries..."
        ! ldd $1 | grep -v "libGL" | grep "not found"
    }

    soCheck $out/share/upwork/upwork
    soCheck $out/share/upwork/chrome-sandbox
    soCheck $out/share/upwork/libcef.so
  '';

  libPath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc.lib
    stdenv.glibc.out
    xorg.libX11
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
    glib
    gtk2
    atk
    pango
    cairo
    gdk_pixbuf
    freetype
    fontconfig
    gtkglext
    dbus
    mesa_glu
    expat
  ];

  meta = {
    homepage = https://www.upwork.com/downloads;
    description = "Desktop application for Upwork freelancers to track time and connect with clients.";
    license = stdenv.lib.licenses.unfree;
    platforms = builtins.attrNames platform;
  };
}
