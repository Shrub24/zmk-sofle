set shell := ["bash", "-cu"]

zmk_config := env_var_or_default("ZMK_CONFIG", "./config")

setup:
    if [ ! -d .west ]; then west init -l config; fi
    west update
    west zephyr-export

build-left:
    west build -d build/left -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG={{zmk_config}}

build-right:
    west build -d build/right -s zmk/app -b eyelash_sofle_right -- -DZMK_CONFIG={{zmk_config}}

build: build-left build-right

pristine-left:
    west build -p always -d build/left -s zmk/app -b eyelash_sofle_left -- -DZMK_CONFIG={{zmk_config}}

pristine-right:
    west build -p always -d build/right -s zmk/app -b eyelash_sofle_right -- -DZMK_CONFIG={{zmk_config}}

clean:
    rm -rf build/left build/right
