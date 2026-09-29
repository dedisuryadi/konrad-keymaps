#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
qmk_dir="${QMK_DIR:-${script_dir}/.qmk_firmware}"
vial_qmk_dir="${VIAL_QMK_DIR:-${script_dir}/.vial-qmk}"
output_dir="${OUTPUT_DIR:-${script_dir}/build}"
qmk_repo="${QMK_REPO:-https://github.com/qmk/qmk_firmware.git}"
vial_qmk_repo="${VIAL_QMK_REPO:-https://github.com/vial-kb/vial-qmk.git}"
vial_qmk_branch="${VIAL_QMK_BRANCH:-vial}"
qmk_image="${QMK_IMAGE:-ghcr.io/qmk/qmk_cli:latest}"
keyboard_name="handwired/konrad_xiao"
keyboard_dir="${script_dir}/keyboards/handwired/konrad_xiao"
keymap_name="${1:-vial}"

case "${keymap_name}" in
    default|via)
        firmware_dir="${qmk_dir}"
        firmware_repo="${qmk_repo}"
        firmware_branch=""
        firmware_source="QMK firmware"
        ;;
    vial)
        firmware_dir="${vial_qmk_dir}"
        firmware_repo="${vial_qmk_repo}"
        firmware_branch="${vial_qmk_branch}"
        firmware_source="Vial-QMK"
        ;;
    *)
        echo "usage: $0 [default|via|vial]" >&2
        exit 2
        ;;
esac

firmware_name="handwired_konrad_xiao_${keymap_name}.uf2"

if ! command -v docker >/dev/null 2>&1; then
    echo "error: Docker is required but was not found in PATH" >&2
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "error: Docker is installed, but the Docker daemon is not running" >&2
    exit 1
fi

if [[ ! -d "${firmware_dir}/.git" ]]; then
    echo "Cloning the latest ${firmware_source} source..."
    clone_options=(
        --depth 1
        --recurse-submodules
        --shallow-submodules
    )
    if [[ -n "${firmware_branch}" ]]; then
        clone_options+=(--branch "${firmware_branch}")
    fi
    git clone "${clone_options[@]}" "${firmware_repo}" "${firmware_dir}"
else
    echo "Updating ${firmware_source} source..."
    git -C "${firmware_dir}" pull --ff-only
    git -C "${firmware_dir}" submodule update --init --recursive --depth 1
fi

mkdir -p "${output_dir}"

echo "Building ${keyboard_name}:${keymap_name} with ${qmk_image}..."
docker run --rm --pull=always \
    --user "$(id -u):$(id -g)" \
    --workdir /qmk_firmware \
    --volume "${firmware_dir}:/qmk_firmware" \
    --volume "${keyboard_dir}:/qmk_firmware/keyboards/${keyboard_name}:ro" \
    --env SKIP_GIT=1 \
    "${qmk_image}" \
    qmk compile --keyboard "${keyboard_name}" --keymap "${keymap_name}"

source_firmware="${firmware_dir}/${firmware_name}"
if [[ ! -f "${source_firmware}" ]]; then
    echo "error: build completed without producing ${firmware_name}" >&2
    exit 1
fi

cp "${source_firmware}" "${output_dir}/${firmware_name}"
echo "Firmware: ${output_dir}/${firmware_name}"
