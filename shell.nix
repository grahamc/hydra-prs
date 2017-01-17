let
  pkgs = import <nixpkgs> {};


  unstable = import (pkgs.stdenv.mkDerivation {
    name = "nixpkgs";
    src = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "e9109b1b979d8ce9385431b38d0f2eda693cbaf3";
      sha256 = "06yjrzmlmgnxfr1xihazbk5n4jrkh1inwgwxyzgr9ggsx8fdd5qj";
    };
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [
      (pkgs.fetchpatch {
        name = "add-packet.patch";
        url = https://github.com/NixOS/nixpkgs/commit/9d92df154905ff60aeef15ae5d8670a2a800f765.patch;
        sha256 = "0vz029bpghk32abcwl7gi4ydrlvlf0ari0kzla74xaqm4g4ihdw2";
      })
    ];
    installPhase = ''
      cp -r . $out
    '';
  }) {};


  inherit (pkgs) stdenv;

in stdenv.mkDerivation rec {
  name = "nixops-hydra-prs";
  version = "0.1";

  src = "./";

  buildInputs = [
    unstable.packet
    pkgs.nixops
  ];

  shellHook = ''
    mod_root=$(pwd "${src}")
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export NIXOS_EXTRA_MODULE_PATH=$mod_root/modules/default.nix
    export NIXOPS_DEPLOYMENT="hydra-prs"
    export HISTFILE=$(pwd)/.bash_hist
  '';
}
