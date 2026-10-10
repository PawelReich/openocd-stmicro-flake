{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  pkg-config,
  tcl,
  libusb1,
  libftdi1,
  hidapi,
  libjaylink,
  capstone,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openocd-st";
  version = "0.12.0-2.2.0";

  src = fetchFromGitHub {
    owner = "STMicroelectronics";
    repo = "OpenOCD";
    rev = "openocd-cubeide-v2.2.0";
    hash = "sha256-HjyxTGg/4ALevoWbQ7tLc3KWHg2dIP1NSgv5QT0Z/qw=";
  };

  # Pinned like the fork pins it in-tree. libjaylink comes from nixpkgs, which
  # carries the version the fork pins.
  jimtclSrc = fetchFromGitHub {
    owner = "msteveb";
    repo = "jimtcl";
    rev = "1933e5457b9512d39ebbe11ed32578aada149f49";
    hash = "sha256-CDjjrxpoTbLESAbCiCjQ8+E/oJP87gDv9SedQOzH3QY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    tcl
  ];

  buildInputs = [
    libusb1
    libftdi1
    hidapi
    libjaylink
    capstone
  ];

  prePatch = ''
    # The tarball has no generated configure script; bootstrap it the same way
    # the fork's own bootstrap script does.
    autoreconf -vfi
  '';

  postPatch = ''
    # The jimtcl and libjaylink submodules are not part of the GitHub tarball.
    # jimtcl is built from the fork's pinned revision, libjaylink comes from
    # nixpkgs.
    rm -rf jimtcl
    cp -r ${finalAttrs.jimtclSrc} jimtcl
    chmod -R u+w jimtcl
    chmod +x jimtcl/configure
  '';

  configureFlags = [
    "--enable-stlink"
    "--enable-ftdi"
    "--enable-jlink"
    "--enable-cmsis-dap"
    "--enable-cmsis-dap-v2"
    "--enable-ti-icdi"
    "--enable-ulink"
    "--enable-usb-blaster"
    "--enable-usb-blaster-2"
    "--enable-xds110"
    "--enable-kitprog"
    "--enable-nulink"
    "--enable-ft232r"
    "--enable-rlink"
    "--enable-buspirate"
    "--enable-armjtagew"
    "--enable-openjtag"
    "--enable-esp-usb-jtag"
    "--enable-angie"
    "--enable-vsllink"
    "--enable-osbdm"
    "--enable-opendous"
    "--enable-remote-bitbang"
    "--enable-presto"
    "--enable-dummy"
    "--enable-sysfsgpio"
    "--with-capstone=yes"
  ];

  NIX_CFLAGS_COMPILE = "-Wno-error";

  meta = {
    description = "OpenOCD with STMicroelectronics' STM32 flash drivers";
    homepage = "https://github.com/STMicroelectronics/OpenOCD";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "openocd";
  };
})
