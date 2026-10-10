{
  description = "OpenOCD with STMicroelectronics' STM32 flash drivers";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      overlayFor = final: _prev: {
        openocd-st = final.callPackage ./package.nix { };
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          openocd-st = (pkgsFor system).callPackage ./package.nix { };
        in
        {
          inherit openocd-st;
          default = openocd-st;
        }
      );

      overlays = {
        default = overlayFor;
      };

      checks = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          openocd-st = pkgs.callPackage ./package.nix { };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt
              pkgs.deadnix
              pkgs.statix
            ];
          };
        }
      );
    };
}
