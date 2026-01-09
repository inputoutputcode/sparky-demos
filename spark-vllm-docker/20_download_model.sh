#!/usr/bin/env bash
set -euo pipefail

: "${HF_TOKEN:?Set HF_TOKEN first, for example export HF_TOKEN=hf_...}"

cd "$(dirname "$0")/spark-vllm-docker"

# Uses the repo's hf-download.sh helper
# It uses uvx and huggingface-cli under the hood.
./hf-download.sh openai/gpt-oss-120b

echo "Model download done. Next: ./30_serve.sh"
