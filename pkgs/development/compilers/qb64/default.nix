{ stdenv, fetchFromGitHub, libGLU, xorg, binutils }:
stdenv.mkDerivation rec {
  name = "qb64-${version}";
  version = "0978";

  src = fetchFromGitHub {
    owner = "Galleondragon";
    repo = "qb64";
    rev = "35e3ada8339ab9154a36b4f2916cec91114652bf";
    sha256 = "0qq9bz9s4m2nmhrvrrl681cb30cmqyrkgwy63gk9xy5ps0z3hh3a";
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  buildInputs = [ libGLU xorg.libX11 xorg.libXi ];

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
    g++ -w qbx.cpp libqb/os/lnx/libqb_setup.o parts/video/font/ttf/os/lnx/src.o parts/core/os/lnx/temp/*.txt -lGL -lGLU -lX11 -lpthread -ldl -lrt -D FREEGLUT_STATIC -o ../../qb64
    popd
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp qb64 $out/bin
  '';
}
