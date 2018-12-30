let
  pkgs = import <nixpkgs> {};

  use-cloned-nixops = true;

  nixops = if use-cloned-nixops
    then (import ./nixops/release.nix {}).build.x86_64-linux
    else (pkgs.nixops.overrideAttrs (x: {
      patches = [
        (pkgs.fetchpatch {
          # Allow specifying custom nixpkgs for a machine
          url = "https://github.com/NixOS/nixops/pull/665.patch";
          sha256 = "0q7sk3fq3x7r2sh6f853hcbykm74px9i0m5bqhg2fi0s4nckj5x0";
        })
      ];
    }));

  inherit (pkgs) stdenv;

in stdenv.mkDerivation rec {
  name = "nixops-hydra-prs";
  version = "0.1";

  src = "./";

  buildInputs = [
    pkgs.packet
    nixops
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
