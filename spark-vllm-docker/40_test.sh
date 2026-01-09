#!/usr/bin/env bash
set -euo pipefail

# Health
curl -s http://localhost:8000/health || true
echo

# List models
curl -s http://localhost:8000/v1/models | head -c 2000
echo
echo

# Chat completion
curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [
      { "role": "user", "content": "Give me three weird facts about octopuses." }
    ],
    "max_tokens": 120
  }' | head -c 2000
echo
