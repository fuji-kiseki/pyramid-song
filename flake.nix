{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      eachSystem = f: genAttrs systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            elmPackages.elm
            elmPackages.elm-format
            nodejs_latest
            pnpm
          ];
        };
      });

      packages = eachSystem (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          name = "3x3-generator";
          src = self;

          nativeBuildInputs = with pkgs; [
            elmPackages.elm
            nodejs_latest
            (pnpm.override { nodejs = nodejs_latest; })
            pnpmConfigHook
          ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            pname = "3x3-generator";
            src = self;
            fetcherVersion = 1;
            hash = "sha256-r9yPZvUddbN8ljmEjXEzYdhLnBa7dkocalIsZwoeQJg=";
          };

          preConfigure = pkgs.elmPackages.fetchElmDeps {
            elmPackages = import ./elm-srcs.nix;
            elmVersion = "0.19.1";
            registryDat = ./registry.dat;
          };

          buildPhase = ''
            pnpm build --public-url 3x3-generator
          '';

          installPhase = ''
            mkdir -p $out
            cp -r dist/* $out/
          '';
        };
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
