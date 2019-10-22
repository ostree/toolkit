#!/usr/bin/env bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

set -e -u -o pipefail

# Get build artifacts from CLIP OS CI

readonly SELFNAME="${BASH_SOURCE[0]##*/}"
readonly SELFPATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# The absolute path to the repo source tree root (this line depends on the
# location of the script within the repo source tree):
readonly REPOROOT="$(realpath "${SELFPATH}/../..")"

main() {
    if [[ "${#}" -ne 1 ]]; then
        >&2 echo "[!] You must specify the URL from which artifacts will be fetched!"
        return 1
    fi

    local -r url="${1}"
    echo "[*] Retrieving artifacts from: ${url}"

    # Make sure that we are at the repo root
    cd "${REPOROOT}"

    # List of artifacts to retrieve (SDKs, Core & EFIboot packages)
    artifacts=(
        'sdk.tar.zst'
        'sdk_debian.tar.zst'
        'core_pkgs.tar.zst'
        'efiboot_pkgs.tar.zst'
    )

    # Retrieve artifacts
    for a in "${artifacts[@]}"; do
        echo "[*] Downloading ${a}..."
        curl --proto '=https' --tlsv1.2 -sSf -o "${a}" "${url}/${a}"
    done

    # Retrieve the SHA256SUMS file and check artifacts integrity
    curl --proto '=https' --tlsv1.2 -sSf -o 'SHA256SUMS' "${url}/SHA256SUMS"
    echo "[*] Verifying artifacts integrity..."
    sha256sum -c --ignore-missing 'SHA256SUMS'

    # Extract artifacts
    for a in "${artifacts[@]}"; do
        echo "[*] Extracting ${a}..."
        tar --extract --file "${a}" --warning=no-unknown-keyword
    done

    echo "[*] You may now remove all downloaded artifacts with:"
    echo "    $ rm ./sdk*.tar.zst ./*_pkgs.tar.zst"

    echo "[*] Success!"
}

main "$@"

# vim: set ts=4 sts=4 sw=4 et ft=sh: