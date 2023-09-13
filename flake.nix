{
  description = "Haskell-Nix interop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix.url = "github:tweag/nix/nix-c-bindings";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs@{ self, nix, nixpkgs, flake-utils, pre-commit-hooks, ... }:
    let systems = builtins.attrNames nix.packages;
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nix = inputs.nix.packages.${system}.default;
      in
      {
        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;

          buildInputs = with pkgs; [
            nix # from flake input
            pkg-config
            cabal-install
            ghc
            haskell-language-server
            ormolu
          ];
        };

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              cabal-fmt.enable = true;
              nixpkgs-fmt.enable = true;
              ormolu.enable = true;
            };
          };
        };
      });
}
