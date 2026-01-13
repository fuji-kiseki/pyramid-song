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
              entr
              nixfmt
              busybox
              tailwindcss_4
            ];
        };
      });
      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
