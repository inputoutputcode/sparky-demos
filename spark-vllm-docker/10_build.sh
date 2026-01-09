#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/spark-vllm-docker"

# Repo quick start for single node build
./build-and-copy.sh --use-wheels

echo "Build done. Next: ./20_download_model.sh"
