#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$(cd -- "$script_dir/.." && pwd)"
image_name="${1:-vda5050-robot-simulator:latest}"

docker build --file "$script_dir/Dockerfile" --tag "$image_name" "$package_dir"