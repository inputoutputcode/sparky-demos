#!/usr/bin/env bash
set -euo pipefail

: "${HF_TOKEN:?Set HF_TOKEN first, for example export HF_TOKEN=hf_...}"

MODEL_HANDLE="${MODEL_HANDLE:-openai/gpt-oss-120b}"
PORT="${PORT:-8355}"
HF_CACHE_DIR="${HF_CACHE_DIR:-$HOME/.cache/huggingface}"

IMAGE="${IMAGE:-nvcr.io/nvidia/tensorrt-llm/release:spark-single-gpu-dev}"
CONTAINER_NAME="${CONTAINER_NAME:-trtllm_gptoss120b}"

echo "Model: ${MODEL_HANDLE}"
echo "Image: ${IMAGE}"
echo "Port:  ${PORT}"
echo "Cache: ${HF_CACHE_DIR}"

mkdir -p "${HF_CACHE_DIR}"

docker pull "${IMAGE}"

docker run \
  --name "${CONTAINER_NAME}" \
  --rm -it \
  --gpus all \
  --ipc host \
  --network host \
  -p ${PORT}:${PORT} \
  -e "HF_TOKEN=${HF_TOKEN}" \
  -e "MODEL_HANDLE=${MODEL_HANDLE}" \
  -v "${HF_CACHE_DIR}:/root/.cache/huggingface" \
  "${IMAGE}" \
  bash -lc "
    set -euo pipefail

    export TIKTOKEN_ENCODINGS_BASE=/tmp/harmony-reqs
    mkdir -p \"\${TIKTOKEN_ENCODINGS_BASE}\"

    wget -q -P \"\${TIKTOKEN_ENCODINGS_BASE}\" https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken
    wget -q -P \"\${TIKTOKEN_ENCODINGS_BASE}\" https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken

    hf download \"${MODEL_HANDLE}\"

    cat > /tmp/extra-llm-api-config.yml <<'EOF'
print_iter_log: false
kv_cache_config:
  dtype: \"auto\"
cuda_graph_config:
  enable_padding: true
disable_overlap_scheduler: true
EOF

    trtllm-serve \"${MODEL_HANDLE}\" \
      --max_batch_size 64 \
      --trust_remote_code \
      --host 0.0.0.0\
      --port \"${PORT}\" \
      --extra_llm_api_options /tmp/extra-llm-api-config.yml
  "
