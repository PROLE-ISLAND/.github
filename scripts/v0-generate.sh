#!/bin/bash
# v0 UI Generation Script
# Usage: ./v0-generate.sh "プロンプト"
# Requires: V0_API_KEY environment variable
#
# Works with any AI tool (Claude, Cursor, Copilot, etc.)
# Just set V0_API_KEY and run this script

set -e

if [ -z "$V0_API_KEY" ]; then
  echo "Error: V0_API_KEY not set"
  echo ""
  echo "Get your key from: https://v0.dev/chat/settings/keys"
  echo "Then: export V0_API_KEY=your_key_here"
  exit 1
fi

if [ -z "$1" ]; then
  echo "v0 UI Generation Script"
  echo ""
  echo "Usage: $0 \"プロンプト\" [--save output.json]"
  echo ""
  echo "Examples:"
  echo "  $0 \"空状態コンポーネント作成。shadcn/ui使用、ダークモード対応\""
  echo "  $0 \"ユーザーテーブル作成。ソート可能、日本語\" --save table.json"
  echo ""
  echo "Prompt Tips:"
  echo "  - Always include: shadcn/ui, Tailwind CSS, ダークモード対応"
  echo "  - Specify: 日本語テキスト for Japanese UI"
  echo "  - Add: TypeScript対応 for proper types"
  exit 1
fi

PROMPT="$1"

echo "🚀 Generating UI with v0..."
echo "   Prompt: ${PROMPT:0:60}..."
echo ""

RESPONSE=$(curl -s -X POST "https://api.v0.dev/v1/chats" \
  -H "Authorization: Bearer $V0_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"message\": $(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}")

# Check for errors
if echo "$RESPONSE" | grep -q '"error"'; then
  echo "❌ Error from v0 API:"
  echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error', {}).get('message', 'Unknown error'))"
  exit 1
fi

# Extract URLs
WEB_URL=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('webUrl', ''))" 2>/dev/null || echo "")
DEMO_URL=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('latestVersion', {}).get('demoUrl', ''))" 2>/dev/null || echo "")

echo "✅ Generation complete!"
echo ""
echo "📱 Demo:  $DEMO_URL"
echo "💬 Chat:  $WEB_URL"
echo ""

# Extract and display generated files
echo "📁 Generated Files:"
echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    files = data.get('latestVersion', {}).get('files', [])
    for f in files:
        name = f.get('name', '')
        if name.endswith('.tsx') or name.endswith('.ts'):
            print(f'  - {name}')
except:
    pass
"

# Option to save response
if [ "$2" == "--save" ]; then
  OUTPUT_FILE="${3:-v0-response.json}"
  echo "$RESPONSE" | python3 -m json.tool > "$OUTPUT_FILE"
  echo ""
  echo "💾 Full response saved to: $OUTPUT_FILE"
  echo "   Extract code: cat $OUTPUT_FILE | jq '.latestVersion.files[0].content'"
fi

# Output code extraction hint
echo ""
echo "💡 To extract component code:"
echo "   curl -s $WEB_URL | jq '.files[0].content'"
