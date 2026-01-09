curl -s http://localhost:8355/v1/models | head -c 2000
echo

curl -s http://localhost:8355/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role":"user","content":"Say hi in one sentence."}],
    "max_tokens": 64
  }' | head -c 2000
echo
