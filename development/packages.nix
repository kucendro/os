pkgs:

with pkgs;
[
  nodejs
  pnpm
  cargo
  rustc
  rust-analyzer
  clippy
  rustfmt
  gcc
  clang
  gnumake
  python315
  autoconf
  automake
  libtool
  pkg-config
  nixfmt
  inetutils
  just
  lefthook
  sqlx-cli
  # mysql-workbench
  jdk25
]
++ lib.optionals stdenv.hostPlatform.isLinux [ gccgo15 ]
