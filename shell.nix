let
  pkgs = import <nixpkgs> {};

  inherit (pkgs) stdenv;

in stdenv.mkDerivation rec {
  name = "nixops-hydra-prs";
  version = "0.1";

  src = "./";

  buildInputs = [
    pkgs.packet
    pkgs.nixops
    pkgs.jq
  ];

  shellHook = ''
    mod_root=$(pwd "${src}")
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export NIXOS_EXTRA_MODULE_PATH=$mod_root/modules/default.nix
    export NIXOPS_DEPLOYMENT="hydra-prs"
    export HISTFILE=$(pwd)/.bash_hist
  '';
}
