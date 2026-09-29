# Konrad XIAO RP2040 split keymap

QMK firmware for a 40-key split KLOR Konrad using one Seeed Studio XIAO RP2040
on each half. Both controllers use the same UF2. The left half is the fixed
master and must be the half connected to the host by USB.

The inter-half connector uses VBUS, GND, and crossed GP0/GP1 full-duplex serial.
It is a split link only, not a USB data connection.

## Build

### Requirements

- Git
- Docker with the Docker daemon running
- Internet access for the first source checkout and Docker image pull

No local QMK toolchain is required. Start in this package directory:

    cd konrad-keymaps

### Build targets

The runner accepts one optional positional argument. With no argument it builds
the recommended Vial firmware:

| Command | Target | Configuration |
| --- | --- | --- |
| ./build.sh | vial | Vial-QMK with an embedded Vial definition |
| ./build.sh default | default | Explicit form of the standard QMK build |
| ./build.sh via | via | QMK with VIA dynamic keymap support |
| ./build.sh vial | vial | Explicit form of the Vial build |

To build every variant:

    for target in default via vial; do
        ./build.sh "$target"
    done

Any other positional argument exits with:

    usage: ./build.sh [default|via|vial]

The script only builds firmware and copies the UF2; it does not flash a
controller.

### Build outputs

| Target | Output |
| --- | --- |
| default | build/handwired_konrad_xiao_default.uf2 |
| via | build/handwired_konrad_xiao_via.uf2 |
| vial | build/handwired_konrad_xiao_vial.uf2 |

The QMK keyboard path is handwired/konrad_xiao. Every artifact contains both
halves. Flash one selected target to both XIAOs; do not mix targets between
halves.

### Source caches and updates

Default and VIA builds use current upstream QMK master cached in
.qmk_firmware. Vial builds use the current Vial-QMK vial branch cached in
.vial-qmk. On every build, the runner:

1. Clones the selected source tree and its submodules when the cache is absent.
2. Otherwise performs a fast-forward-only pull and updates submodules.
3. Pulls the selected Docker image.
4. Mounts this keyboard definition read-only into the firmware tree.
5. Runs qmk compile and copies the resulting UF2 into the output directory.

The first build is substantially slower because it downloads the firmware
source, submodules, toolchain image, and dependencies. Later builds reuse the
caches.

### Environment options

All configuration is optional:

| Variable | Default | Purpose |
| --- | --- | --- |
| QMK_DIR | .qmk_firmware | Upstream QMK source/cache directory |
| QMK_REPO | https://github.com/qmk/qmk_firmware.git | Upstream QMK repository |
| VIAL_QMK_DIR | .vial-qmk | Vial-QMK source/cache directory |
| VIAL_QMK_REPO | https://github.com/vial-kb/vial-qmk.git | Vial-QMK repository |
| VIAL_QMK_BRANCH | vial | Branch cloned for Vial builds |
| QMK_IMAGE | ghcr.io/qmk/qmk_cli:latest | Docker build image |
| OUTPUT_DIR | build | Destination for the generated UF2 |

Examples:

Build Vial into a temporary output directory:

    OUTPUT_DIR=/tmp/konrad-build ./build.sh vial

Use existing source checkouts:

    QMK_DIR=/path/to/qmk_firmware ./build.sh via
    VIAL_QMK_DIR=/path/to/vial-qmk ./build.sh vial

Pin a specific Docker image or Vial branch:

    QMK_IMAGE=my-registry/qmk-cli:version ./build.sh default
    VIAL_QMK_BRANCH=my-vial-branch ./build.sh vial

Environment overrides apply to one invocation unless exported by the shell.

## Flash both halves

Flash the exact same UF2 to both XIAOs:

1. Disconnect host USB and the inter-half cable.
2. Put one XIAO in its bootloader by holding BOOT while connecting USB, or by
   double-tapping RESET after QMK is installed.
3. Copy the selected UF2 to the RPI-RP2 drive.
4. Repeat with the other XIAO using the same UF2.
5. Disconnect USB, connect the inter-half cable, then connect host USB to the
   left half.

The left half is the fixed master. Connecting host USB to the right half will
not produce the intended handedness.

## Matrix wiring

QMK pin names refer to RP2040 GPIO numbers, not the D labels printed on the
XIAO.

### Left half

| Matrix line | XIAO pin | QMK pin |
| --- | --- | --- |
| COL1 | D9 | GP4 |
| COL2 | D8 | GP2 |
| COL3 | D10 | GP3 |
| COL4 | D0 | GP26 |
| COL5 | D1 | GP27 |
| ROW1 | D2 | GP28 |
| ROW2 | D3 | GP29 |
| ROW3 | D4 | GP6 |
| ROW4 | D5 | GP7 |
| Split D- / TX | D6 | GP0 |
| Split D+ / RX | D7 | GP1 |

### Right half

| Matrix line | XIAO pin | QMK pin |
| --- | --- | --- |
| COL6 | D10 | GP3 |
| COL7 | D9 | GP4 |
| COL8 | D0 | GP26 |
| COL9 | D2 | GP28 |
| COL10 | D1 | GP27 |
| ROW1 | D8 | GP2 |
| ROW2 | D3 | GP29 |
| ROW3 | D4 | GP6 |
| ROW4 | D5 | GP7 |
| Split D+ / TX | D6 | GP0 |
| Split D- / RX | D7 | GP1 |

The firmware assumes COL2ROW diodes on both halves. Change diode_direction in
keyboard.json if the physical diodes face the other way.

QMK represents this as an 8-row × 5-column split matrix: logical rows 0–3 are
the left half and rows 4–7 are the right half.

### Assigned keys

| Left | COL1 | COL2 | COL3 | COL4 | COL5 |
| --- | --- | --- | --- | --- | --- |
| ROW1 | Q | W | K | P | B |
| ROW2 | A / Ctrl | R / Option | S / Command | T / Shift | G / Hyper |
| ROW3 | Z | X | C | D | V |
| ROW4 | Left Shift | Escape | Mouse Left | Space | Tab |

| Right | COL6 | COL7 | COL8 | COL9 | COL10 |
| --- | --- | --- | --- | --- | --- |
| ROW1 | J | L | U | Y | Quote |
| ROW2 | M / Hyper | N / Shift | E / Command | I / Option | O / Ctrl |
| ROW3 | F | H | Comma | Period | Slash |
| ROW4 | Right Shift | Semicolon | Backspace | Enter | Delete |

Hyper is Left Ctrl + Left Option + Left Command + Left Shift. The home-row
modifiers use a 200 ms tapping term, configured in each keymap's config.h.

## Split connector

The inter-half USB-C connector is a wiring convenience, not a USB host/device
connection. The two signal conductors are deliberately crossed:

| Left XIAO | Conductor | Right XIAO |
| --- | --- | --- |
| D6 / GP0 / TX | Split D- | D7 / GP1 / RX |
| D7 / GP1 / RX | Split D+ | D6 / GP0 / TX |
| VBUS | Split V | VBUS |
| GND | Split GND | GND |

Leave 3.3V unconnected. Because the link carries VBUS, it is not hot-pluggable:
disconnect host USB before connecting or disconnecting the inter-half cable.

## VIA

Flash build/handwired_konrad_xiao_via.uf2, then open the VIA web app. As
this keyboard definition is not published in VIA's keyboard repository, enable
the Design tab, select Load Draft Definition, and load via.json from this
directory. VIA provides four remappable layers by default.

The local-development USB identity is VID 0x7173, PID 0x4B4C; these values must
remain identical in keyboard.json and via.json. Obtain an assigned VID/PID
before distributing it as a commercial product.

Clear EEPROM after replacing the old left-only firmware so VIA initialises the
new 8×5 split dynamic keymap instead of retaining the previous 4×5 data.

## Vial

Flash build/handwired_konrad_xiao_vial.uf2, then open the Vial app. The
full split definition is embedded in the firmware, so it does not need to be
sideloaded.

Vial security is enabled. To unlock protected operations, select Security →
Unlock in Vial and hold the two outer left keys, Escape and Left Shift, until
the unlock completes. The Vial keyboard UID is 12:7E:CF:B6:DF:0C:58:2A.
