{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages = with pkgs; [
    gmp
    gmp.dev
    mpfr
    mpfr.dev
    libmpc
    flex
    dejagnu
    wget
    texinfo
    gnumake
    clang-tools
    bear
  ];

  languages.c.enable = true;
  languages.cplusplus.enable = true;

  env.LIBRARY_PATH = lib.makeSearchPath "lib" [ pkgs.gmp pkgs.mpfr pkgs.libmpc ];
  env.C_INCLUDE_PATH = lib.makeSearchPath "include" [ pkgs.gmp.dev pkgs.mpfr.dev pkgs.libmpc ];
  env.CPLUS_INCLUDE_PATH = lib.makeSearchPath "include" [ pkgs.gmp.dev pkgs.mpfr.dev pkgs.libmpc ];

  scripts.gcc-build.exec = ''
    mkdir -p "$(pwd)/../gcc-build"
    docker run -it -v "$(pwd)":/src -v "$(pwd)/../gcc-build":/build -w /src --platform linux/arm64 arm64v8/gcc bash -c '
      apt-get update && apt-get install -y flex dejagnu wget libgmp-dev libmpfr-dev libmpc-dev texinfo bear > /dev/null 2>&1
      echo "GCC build environment ready. Source at /src, build at /build"
      echo "  cd /build && /src/configure --disable-bootstrap --enable-languages=c,c++ --disable-multilib && bear -- make -j$(nproc)"
      exec bash
    '
  '';

  scripts.gcc-fix-compiledb.exec = ''
    SRC="$(pwd)"
    BUILD="$(pwd)/../gcc-build"
    sed -e "s|/src/|$SRC/|g" -e "s|/build/|$BUILD/|g" "$BUILD/compile_commands.json" > "$SRC/compile_commands.json"
    echo "Fixed compile_commands.json written to $SRC/compile_commands.json"
  '';

  enterShell = ''
    echo "GCC dev environment ready"
    echo "  Native build: ./configure && make"
    echo "  Docker build: gcc-build"
  '';
}
