{
  description = "ZMK Sofle local build dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      zephyr-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          zephyr = zephyr-nix.packages.${system};
          # ZMK v0.3.x (Zephyr 3.x) expects Zephyr SDK 0.16.x
          zephyrSdk = zephyr.sdk-0_16.override {
            targets = [
              "arm-zephyr-eabi"
              "x86_64-zephyr-elf"
            ];
          };
          python = pkgs.python3.withPackages (
            ps: with ps; [
              west
              setuptools
              pyelftools
              pykwalify
              pyyaml
              pyserial
            ]
          );
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              cmake
              ninja
              gperf
              dtc
              wget
              xz
              file
              zephyr.hosttools-0_16
              python
              zephyrSdk
            ];

            shellHook = ''
              export ZMK_CONFIG="$PWD/config"
              export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
              export ZEPHYR_SDK_INSTALL_DIR="${zephyrSdk}"
              echo "ZMK dev shell ready"
              echo "Run once: west init -l config && west update && west zephyr-export"
              echo "Build left:  west build -d build/left  -s zmk/app -b eyelash_sofle_left  -- -DZMK_CONFIG=$ZMK_CONFIG"
              echo "Build right: west build -d build/right -s zmk/app -b eyelash_sofle_right -- -DZMK_CONFIG=$ZMK_CONFIG"
            '';
          };
        }
      );
    };
}
