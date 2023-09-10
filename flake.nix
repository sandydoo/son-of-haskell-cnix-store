{
  description = "Haskell-Nix interop";

  inputs = {
    nix.url = "github:tweag/nix/nix-c-bindings";
    nixpkgs.follows = "nix/nixpkgs";
  };

  outputs = inputs@{ self, nix, nixpkgs, flake-utils, ... }:
    let systems = builtins.attrNames nix.packages;
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nix = inputs.nix.packages.${system}.default;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix # from flake input
            pkg-config
            cabal-install
            ghc
          ];
        };
      });
}
