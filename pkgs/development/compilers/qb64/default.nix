{ stdenv, fetchFromGitHub, writeScript, libGLU, xorg, binutils }:
let 
  version = "0978";

  # The executable expects to be executed from the source directory.
  launcher = writeScript "qb64-${version}" ''
    #!${stdenv.shell}

    cd ${platform}/share/qb64
    ./qb64
  '';

  platform = stdenv.mkDerivation rec {
    # This is the real package, but the executable expects the source code to be available.
    # That's why the final derivation combines this with a launcher script.
     
    inherit version;
    name = "qb64-platform-${version}";
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ libGLU xorg.libX11 xorg.libXi ];
  
    src = fetchFromGitHub {
      owner = "Galleondragon";
      repo = "qb64";
      rev = "35e3ada8339ab9154a36b4f2916cec91114652bf";
      sha256 = "0qq9bz9s4m2nmhrvrrl681cb30cmqyrkgwy63gk9xy5ps0z3hh3a";
    };
  
    buildPhase = ''
      echo "Building library 'LibQB'"
      pushd internal/c/libqb/os/lnx
      g++ -c -w -Wall ../../../libqb.cpp -D DEPENDENCY_LOADFONT -D FREEGLUT_STATIC -o libqb_setup.o
      popd
  
      echo "Building library 'FreeType'"
      pushd internal/c/parts/video/font/ttf/os/lnx
      g++ -s -c -w -Wall ../../src/freetypeamalgam.c -o src.o
      popd
  
      echo "Building library 'Core:FreeGLUT'"
      pushd internal/c/parts/core/os/lnx
      gcc -s -O2 -c ../../src/freeglut_callbacks.c -o temp/freeglut_callbacks.o
      gcc -s -O2 -c ../../src/freeglut_cursor.c -o temp/freeglut_cursor.o
      gcc -s -O2 -c ../../src/freeglut_display.c -o temp/freeglut_display.o
      gcc -s -O2 -c ../../src/freeglut_ext.c -o temp/freeglut_ext.o
      gcc -s -O2 -c ../../src/freeglut_font.c -o temp/freeglut_font.o
      gcc -s -O2 -c ../../src/freeglut_font_data.c -o temp/freeglut_font_data.o
      gcc -s -O2 -c ../../src/freeglut_gamemode.c -o temp/freeglut_gamemode.o
      gcc -s -O2 -c ../../src/freeglut_geometry.c -o temp/freeglut_geometry.o
      gcc -s -O2 -c ../../src/freeglut_glutfont_definitions.c -o temp/freeglut_glutfont_definitions.o
      gcc -s -O2 -c ../../src/freeglut_init.c -o temp/freeglut_init.o
      gcc -s -O2 -c ../../src/freeglut_input_devices.c -o temp/freeglut_input_devices.o
      gcc -s -O2 -c ../../src/freeglut_joystick.c -o temp/freeglut_joystick.o
      gcc -s -O2 -c ../../src/freeglut_main.c -o temp/freeglut_main.o
      gcc -s -O2 -c ../../src/freeglut_menu.c -o temp/freeglut_menu.o
      gcc -s -O2 -c ../../src/freeglut_misc.c -o temp/freeglut_misc.o
      gcc -s -O2 -c ../../src/freeglut_overlay.c -o temp/freeglut_overlay.o
      gcc -s -O2 -c ../../src/freeglut_spaceball.c -o temp/freeglut_spaceball.o
      gcc -s -O2 -c ../../src/freeglut_state.c -o temp/freeglut_state.o
      gcc -s -O2 -c ../../src/freeglut_stroke_mono_roman.c -o temp/freeglut_stroke_mono_roman.o
      gcc -s -O2 -c ../../src/freeglut_stroke_roman.c -o temp/freeglut_stroke_roman.o
      gcc -s -O2 -c ../../src/freeglut_structure.c -o temp/freeglut_structure.o
      gcc -s -O2 -c ../../src/freeglut_videoresize.c -o temp/freeglut_videoresize.o
      gcc -s -O2 -c ../../src/freeglut_window.c -o temp/freeglut_window.o
      gcc -s -O2 -c ../../src/freeglut_xinput.c -o temp/freeglut_xinput.o
      popd
  
      echo "Building 'QB64'"
      cp internal/source/* internal/temp
      pushd internal/c
      g++ -w qbx.cpp libqb/os/lnx/libqb_setup.o parts/video/font/ttf/os/lnx/src.o parts/core/os/lnx/temp/*.o -lGL -lGLU -lX11 -lpthread -ldl -lrt -D FREEGLUT_STATIC -o ../../qb64
      popd
    '';
  
    installPhase = ''
      mkdir -p $out/share/qb64/internal
  
      cp -r internal/help internal/source internal/temp $out/share/qb64/internal/
      cp qb64 $out/share/qb64
    '';
  };
in stdenv.mkDerivation {
  inherit version;

  name = "qb64-${version}";

  builder = writeScript "builder.sh" ''
    #!${stdenv.shell}
    source $stdenv/setup

    mkdir -p $out/bin
    ln -s ${launcher} $out/bin/qb64
  '';
}
