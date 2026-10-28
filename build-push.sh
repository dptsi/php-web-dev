#!/usr/bin/env bash
# Build dan push image dptsi/php-web-dev per tag (menggantikan Docker Hub autobuild).
# Konteks build = folder bernama sama dengan tag; tag 8.5 juga dipush sebagai latest.
#
# Pemakaian: ./build-push.sh [--dry-run] <tag> [<tag> ...]
set -euo pipefail

IMAGE="dptsi/php-web-dev"
PLATFORM="linux/amd64"
ACTIVE_TAGS=(5.6 5.6-nginx 5.6-siakad 7.0 7.0-mysql 7.4 7.4-mysql
    8.0 8.0-mysql 8.1 8.1-mysql 8.2 8.2-mysql 8.3 8.3-mysql 8.4 8.4-mysql 8.5 8.5-mysql)
LATEST_FROM="8.5"

cd "$(dirname "$0")"

usage() {
    echo "Pemakaian: $0 [--dry-run] <tag> [<tag> ...]" >&2
    echo "Tag aktif: ${ACTIVE_TAGS[*]}" >&2
    exit 1
}

is_active() {
    local t
    for t in "${ACTIVE_TAGS[@]}"; do
        [[ "$t" == "$1" ]] && return 0
    done
    return 1
}

dry_run=0
tags=()
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1 ;;
        -h|--help) usage ;;
        -*) echo "Opsi tidak dikenal: $arg" >&2; usage ;;
        *) tags+=("$arg") ;;
    esac
done

[[ ${#tags[@]} -gt 0 ]] || usage

# Validasi semua tag dulu supaya tidak ada yang terpush sebagian.
for tag in "${tags[@]}"; do
    if ! is_active "$tag"; then
        echo "Tag '$tag' tidak ada di daftar tag aktif." >&2
        usage
    fi
    if [[ ! -f "$tag/Dockerfile" ]]; then
        echo "Folder '$tag' tidak berisi Dockerfile." >&2
        exit 1
    fi
done

for tag in "${tags[@]}"; do
    cmd=(docker buildx build --platform "$PLATFORM" -t "$IMAGE:$tag")
    [[ "$tag" == "$LATEST_FROM" ]] && cmd+=(-t "$IMAGE:latest")
    cmd+=(--push "./$tag")

    if (( dry_run )); then
        printf '%q ' "${cmd[@]}"
        echo
    else
        echo ">> Build & push $IMAGE:$tag"
        "${cmd[@]}"
    fi
done
