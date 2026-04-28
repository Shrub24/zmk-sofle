set shell := ["bash", "-cu"]

zmk_config := env_var_or_default("ZMK_CONFIG", "./config")
zmk_shield := env_var_or_default("ZMK_SHIELD", "nice_view")
zmk_gha_image := env_var_or_default("ZMK_GHA_IMAGE", "docker.io/zmkfirmware/zmk-build-arm:3.5")

setup:
    if [ ! -d .west ]; then west init -l config; fi
    west update
    west zephyr-export

build-left:
    west build -p always -d build/left -s zmk/app -b eyelash_sofle_left -S studio-rpc-usb-uart -- -DZMK_CONFIG={{zmk_config}} -DSHIELD="{{zmk_shield}}" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n

build-right:
    west build -p always -d build/right -s zmk/app -b eyelash_sofle_right -S studio-rpc-usb-uart -- -DZMK_CONFIG={{zmk_config}} -DSHIELD="{{zmk_shield}}" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n

build: build-left build-right

pristine-left:
    west build -p always -d build/left -s zmk/app -b eyelash_sofle_left -S studio-rpc-usb-uart -- -DZMK_CONFIG={{zmk_config}} -DSHIELD="{{zmk_shield}}" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n

pristine-right:
    west build -p always -d build/right -s zmk/app -b eyelash_sofle_right -S studio-rpc-usb-uart -- -DZMK_CONFIG={{zmk_config}} -DSHIELD="{{zmk_shield}}" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n

clean:
    rm -rf build/left build/right

setup-gha:
    docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/work" -w /work {{zmk_gha_image}} sh -lc 'if [ ! -d .west ]; then west init -l config; fi; west update --fetch-opt=--filter=tree:0; west zephyr-export'

build-right-gha:
    docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/work" -w /work {{zmk_gha_image}} sh -lc 'west build -d build/right -s zmk/app -b eyelash_sofle_right -S studio-rpc-usb-uart -- -DZMK_CONFIG=/work/config -DSHIELD="nice_view" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n'

build-left-studio-gha:
    docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/work" -w /work {{zmk_gha_image}} sh -lc 'west build -d build/left -s zmk/app -b eyelash_sofle_left -S studio-rpc-usb-uart -- -DZMK_CONFIG=/work/config -DSHIELD="nice_view" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n'
