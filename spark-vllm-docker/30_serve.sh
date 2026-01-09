#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/spark-vllm-docker"

# Start the vLLM OpenAI-compatible server inside the container.
# This follows the repo's gpt-oss-120b example that uses:
# --trust_remote_code, --swap-space, -tp, ray backend, and fastsafetensors load format.
docker run \
  --privileged \
  --gpus all \
  -it --rm \
  --network host --ipc=host \
  -v  ~/.cache/huggingface:/root/.cache/huggingface \
  -e HF_HUB_OFFLINE=1 \
  vllm-node \
  bash -lc 'vllm serve openai/gpt-oss-120b \
    --port 8000 --host 0.0.0.0 \
    --trust_remote_code \
    --swap-space 16 \
    --gpu-memory-utilization 0.7 \
    -tp 1 \
    --distributed-executor-backend ray \
    --load-format fastsafetensors'
