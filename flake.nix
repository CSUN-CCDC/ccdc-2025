{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    pkgs-vagrant.url = "github:nixos/nixpkgs/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";
  };
  outputs = { nixpkgs, pkgs-vagrant, ... }:
    let

      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "i686-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ]
          (system:
            function (import nixpkgs {
              inherit system pkgs-vagrant;
              config.allowUnfree = true;
            }));

    in
    {
      devShells = forAllSystems (pkgs: {
        default = import ./devshell.nix { inherit pkgs pkgs-vagrant; };
      });


      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
