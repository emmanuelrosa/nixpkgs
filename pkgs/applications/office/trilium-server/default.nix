{ stdenv, fetchurl, p7zip, patchelf, buildEnv, zlib, glibc }:

stdenv.mkDerivation rec {
  name = "trilium-server-${version}";
  version = "0.24.5";

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  src = fetchurl {
    url = "https://github.com/zadam/trilium/releases/download/v${version}/trilium-linux-x64-server-${version}.7z";
    sha256 = "0ra2bjhy7hdjmqmp5dw4cb0zcfnh1a8l76z9vr1p4fnfc9kc6fay";
  };

  unpackCmd = ''
    ${p7zip}/bin/7zr x $curSrc
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/usr/share/trilium

    cp -r ./* $out/usr/share/trilium
  '';

  postInstallPhase = ''
    rm $out/usr/share/trilium/node_modules/spawn-rx/vendor/jobber/Jobber.exe
    rm $out/usr/share/trilium/node_modules/rcedit/bin/rcedit.exe
    rm $out/usr/share/trilium/node/lib/node_modules/npm/node_modules/term-size/vendor/windows/term-size.exe
    rm $out/usr/share/trilium/node_modules/term-size/vendor/windows/term-size.exe
    rm $out/usr/share/trilium/node_modules/sqlite3/bin/linux-ia32-64/sqlite3.node
    rm $out/usr/share/trilium/node_modules/sqlite3/lib/binding/electron-v4.0-linux-ia32/node_sqlite3.node

    ln -s $out/usr/share/trilium/trilium.sh $out/bin/trilium
  '';

  dontPatchELF = true; 

  postFixup = ''
    for f in $out/usr/share/trilium/node/bin/node $out/usr/share/trilium/node_modules/mozjpeg/vendor/cjpeg
    do
      echo $f
      ${patchelf}/bin/patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath $libs/lib \
        $f
        ldd $f
    done

    substituteInPlace $out/usr/share/trilium/trilium.sh \
      --replace "./node" $out/usr/share/trilium/node \
      --replace "src/www" $out/usr/share/trilium/src/www
  '';

  libs = buildEnv {
    name = "trilium-server-libs-env";
    pathsToLink = [ "/lib" ];

    paths = [
      stdenv.cc.cc.lib
      zlib
      glibc
    ];
  };

  meta = with stdenv.lib; {
    description = "Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases.";
    longDescription = "This package provides the Trilium Notes server.";
    homepage = https://github.com/zadam/trilium;
    license = licenses.agpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
