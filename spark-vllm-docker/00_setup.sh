#!/usr/bin/env bash
set -euo pipefail

# 1) Get the repo
if [[ ! -d spark-vllm-docker ]]; then
  git clone https://github.com/eugr/spark-vllm-docker.git
fi

cd spark-vllm-docker

# 2) Make scripts executable
chmod +x build-and-copy.sh launch-cluster.sh hf-download.sh autodiscover.sh run-cluster-node.sh || true

# 3) Hugging Face token
# Set HF_TOKEN in your shell before running other scripts.
# Example:
# export HF_TOKEN="hf_..."
echo "Repo ready. Next: export HF_TOKEN, then run ./10_build.sh"
