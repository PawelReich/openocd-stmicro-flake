# openocd-stmicro-flake

A Nix flake packaging [OpenOCD](https://openocd.org/) from [STMicroelectronics' fork](https://github.com/STMicroelectronics/OpenOCD),
which adds the STM32 flash programming drivers (`stm32x`, `stm32lx`, `stm32f2x`, `stm32h7x`, …) to upstream OpenOCD.

## Usage

```nix
{
  inputs.openocd-st.url = "github:PawelReich/openocd-stmicro-flake";

  outputs =
    { nixpkgs, openocd-st, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            # Pull in the package built against this configuration's nixpkgs.
            nixpkgs.overlays = [ openocd-st.overlays.default ];
          }
        ];
      };
    };
}
```

Then install it with `environment.systemPackages = [ pkgs.openocd-st ];`

## Patching notes

The ST tarball ships without a generated `configure` script and without its
`jimtcl` and `libjaylink` submodule contents:

- `configure` is regenerated with `autoreconf -vfi` in `prePatch`.
- `jimtcl` is fetched at the revision the fork pins and copied over the empty
  submodule directory in `postPatch`.
- `libjaylink` comes from `nixpkgs`, which carries the version the fork pins.

When bumping the fork revision, run `nix build` and update the `jimtcl` `hash`
if the fork's pin moved.

## License

The packaged software is GPL-2.0-or-later. The ST fork's driver sources carry additional restrictions — see the upstream [README](https://github.com/STMicroelectronics/OpenOCD) for details.
