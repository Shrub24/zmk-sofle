{
  description = "ZMK Sofle local build dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs }:
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
          python = pkgs.python3.withPackages (
            ps: with ps; [
              west
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
              zephyr-sdk
              python
            ];

            ZEPHYR_TOOLCHAIN_VARIANT = "zephyr";
            ZEPHYR_SDK_INSTALL_DIR = "${pkgs.zephyr-sdk}";

            shellHook = ''
              export ZMK_CONFIG="$PWD/config"
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
