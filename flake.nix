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
          name = "pyramid-song";
          src = self;

          nativeBuildInputs = with pkgs; [
            elmPackages.elm
            nodejs_latest
            (pnpm.override { nodejs = nodejs_latest; })
            pnpmConfigHook
          ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            pname = "pyramid-song";
            src = self;
            fetcherVersion = 1;
            hash = "sha256-tc0rAEFJBZaIpZmNUBJelT5MSLNitMtEGDkviLcRZPw=";
          };

          preConfigure = pkgs.elmPackages.fetchElmDeps {
            elmPackages = import ./elm-srcs.nix;
            elmVersion = "0.19.1";
            registryDat = ./registry.dat;
          };

          buildPhase = ''
            pnpm build
          '';

          installPhase = ''
            mkdir -p $out
            cp -r dist/* $out/
          '';
        };

        dev = pkgs.writeShellApplication {
          name = "dev";
          runtimeInputs = with pkgs; [
            elmPackages.elm
            nodejs
          ];

          text = ''
            pnpm dev
          '';
        };
      });

      apps = eachSystem (pkgs: {
        type = "app";
        program = "${self.packages.${pkgs.system}.dev}/bin/dev";
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
