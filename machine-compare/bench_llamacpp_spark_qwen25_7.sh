#!/usr/bin/env bash
set -euo pipefail

LLAMA_DIR="${LLAMA_DIR:-$HOME/src/llama.cpp}"
BUILD_DIR="${BUILD_DIR:-$LLAMA_DIR/build-cuda}"

MODEL_DIR="${MODEL_DIR:-$HOME/models/Qwen2.5-7B-Instruct-GGUF}"
QUANT="${QUANT:-q4_k_m}"
MODEL_GGUF="${MODEL_GGUF:-$MODEL_DIR/qwen2.5-7b-instruct-${QUANT}-00001-of-00002.gguf}"

OUT_DIR="${OUT_DIR:-$HOME/llama_bench_results}"
RUNS="${RUNS:-3}"

PROMPT="${PROMPT:-Write a concise explanation of why the sky is blue.}"
CTX="${CTX:-4096}"
N_PREDICT="${N_PREDICT:-256}"
SEED="${SEED:-0}"
THREADS="${THREADS:-0}"
NGPU_LAYERS="${NGPU_LAYERS:-999}"  # offload as many layers as possible

mkdir -p "$OUT_DIR"

if [ ! -d "$LLAMA_DIR" ]; then
  git clone https://github.com/ggml-org/llama.cpp "$LLAMA_DIR"
fi

if [ ! -f "$MODEL_GGUF" ]; then
  echo "ERROR: Model not found:"
  echo "  $MODEL_GGUF"
  exit 1
fi

cd "$LLAMA_DIR"
mkdir -p "$BUILD_DIR"

echo "Configuring llama.cpp (CUDA) with CMake"
cmake -S . -B "$BUILD_DIR" -DGGML_CUDA=ON -DCMAKE_BUILD_TYPE=Release -DLLAMA_CURL=OFF

echo "Building llama.cpp (CUDA)"
cmake --build "$BUILD_DIR" --config Release -j

LLAMA_CLI="$BUILD_DIR/bin/llama-cli"
if [ ! -x "$LLAMA_CLI" ]; then
  echo "ERROR: llama-cli not found at:"
  echo "  $LLAMA_CLI"
  exit 1
fi

echo "Model: $MODEL_GGUF"
echo "Runs:  $RUNS  |  CTX: $CTX  |  Tokens: $N_PREDICT"
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi | head -n 12 || true

for i in $(seq 1 "$RUNS"); do
  TS="$(date +%Y%m%d_%H%M%S)"
  OUT="$OUT_DIR/spark_qwen25_7b_${QUANT}_run${i}_${TS}.log"

  echo
  echo "Run $i → $OUT"

  "$LLAMA_CLI" \
    -m "$MODEL_GGUF" \
    -p "$PROMPT" \
    -c "$CTX" \
    -n "$N_PREDICT" \
    --seed "$SEED" \
    --threads "$THREADS" \
    -ngl "$NGPU_LAYERS" \
    --timings \
    2>&1 | tee "$OUT"
done

echo
echo "Done. Logs in $OUT_DIR"
