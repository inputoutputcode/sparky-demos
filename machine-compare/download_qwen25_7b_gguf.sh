#!/usr/bin/env bash
set -euo pipefail

MODEL_REPO="Qwen/Qwen2.5-7B-Instruct-GGUF"
OUT_DIR="${OUT_DIR:-$HOME/models/Qwen2.5-7B-Instruct-GGUF}"
QUANT="${QUANT:-q4_k_m}"  # q4_k_m is a good baseline for 24GB Macs

mkdir -p "$OUT_DIR"

# Requires: python3 + pip

hf download "$MODEL_REPO" \
  --local-dir "$OUT_DIR" \
  --include "*${QUANT}-*.gguf"

echo
echo "Downloaded files:"
ls -lh "$OUT_DIR" | sed -n '1,200p'

echo
echo "Model entrypoint file (pass this to llama-cli -m):"
echo "$OUT_DIR/qwen2.5-7b-instruct-${QUANT}-00001-of-00002.gguf"
