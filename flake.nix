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
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
