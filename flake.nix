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
          buildInputs =
            with pkgs;
            with elmPackages;
            [
              elm
              elm-format
              tailwindcss_4
              nixfmt
            ];
        };
      });

      packages = eachSystem (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          name = "pyramid-song";
          src = self;

          nativeBuildInputs = with pkgs; [
            elmPackages.elm
            tailwindcss_4
          ];

          configurePhase = pkgs.elmPackages.fetchElmDeps {
            elmPackages = import ./elm-srcs.nix;
            elmVersion = "0.19.1";
            registryDat = ./registry.dat;
          };

          buildPhase = ''
            elm make src/Main.elm --output=dist/Main.js --optimize
            tailwindcss -i ./src/styles.css -o ./dist/styles.css --minify
          '';

          installPhase = ''
            mkdir -p $out
            cp -r index.html dist $out/
          '';
        };

        dev = pkgs.writeShellApplication {
          name = "dev";
          runtimeInputs = with pkgs; [
            elmPackages.elm
            tailwindcss_4
            watchexec
            serve
          ];

          text = ''
            trap 'pkill -P $$' EXIT
            mkdir -p result-dev

            cp ./index.html ./result-dev/
            serve -n -d ./result-dev &
            watchexec -e css,elm -- tailwindcss -i ./src/styles.css -o ./result-dev/dist/styles.css &
            watchexec -e elm -- elm make src/Main.elm --output=result-dev/dist/Main.js
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
