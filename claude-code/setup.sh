#!/bin/bash
# PROLE-ISLAND Claude Code 開発環境セットアップ
# Usage: curl -sL https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/claude-code/setup.sh | bash
#
# 必要条件:
#   - gh (GitHub CLI) がインストール・認証済み
#   - Python 3.8+

set -e

REPO="PROLE-ISLAND/.github"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
CACHE_DIR="$CLAUDE_DIR/cache"
COMMANDS_DIR="$CLAUDE_DIR/commands"

echo "🚀 PROLE-ISLAND Claude Code 開発環境セットアップ"
echo "================================================"
echo ""

# Check gh auth
if ! gh auth status &> /dev/null; then
  echo "❌ GitHub CLI が認証されていません"
  echo "   gh auth login を実行してください"
  exit 1
fi

# Create directories
echo "📁 ディレクトリ作成..."
mkdir -p "$HOOKS_DIR" "$CACHE_DIR" "$COMMANDS_DIR"

# Fetch and install hooks
echo "🔧 Hooks をインストール..."

fetch_file() {
  local path="$1"
  local dest="$2"
  local content
  content=$(gh api "repos/$REPO/contents/claude-code/$path" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null)
  if [ -n "$content" ]; then
    echo "$content" > "$dest"
    echo "  ✅ $dest"
  else
    echo "  ⚠️ $path のダウンロードに失敗"
  fi
}

# Hooks
fetch_file "hooks/gate.py" "$HOOKS_DIR/gate.py"
fetch_file "hooks/sync-guardrails.sh" "$HOOKS_DIR/sync-guardrails.sh"
chmod +x "$HOOKS_DIR/sync-guardrails.sh" 2>/dev/null || true

# Cache
fetch_file "cache/claude-guardrails.yaml" "$CACHE_DIR/claude-guardrails.yaml"

# Commands
fetch_file "commands/req.md" "$COMMANDS_DIR/req.md"
fetch_file "commands/dev.md" "$COMMANDS_DIR/dev.md"
fetch_file "commands/issue.md" "$COMMANDS_DIR/issue.md"

# Update settings.local.json
echo ""
echo "⚙️ settings.local.json を更新..."

SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

# Create or update settings
if [ -f "$SETTINGS_FILE" ]; then
  # Backup existing
  cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
  echo "  📦 バックアップ: $SETTINGS_FILE.backup"
fi

# Check if hooks already configured
if [ -f "$SETTINGS_FILE" ] && grep -q "PreToolUse" "$SETTINGS_FILE" 2>/dev/null; then
  echo "  ✅ Hooks 設定は既に存在します"
else
  # Create settings with hooks
  cat > "$SETTINGS_FILE" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(gh:*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/gate.py",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
EOF
  echo "  ✅ Hooks 設定を追加しました"
fi

echo ""
echo "✨ セットアップ完了！"
echo ""
echo "インストール済み:"
echo "  📂 $HOOKS_DIR/"
echo "     - gate.py (PreToolUse Hook)"
echo "     - sync-guardrails.sh"
echo "  📂 $CACHE_DIR/"
echo "     - claude-guardrails.yaml"
echo "  📂 $COMMANDS_DIR/"
echo "     - req.md (/req コマンド)"
echo "     - dev.md (/dev コマンド)"
echo "     - issue.md (/issue コマンド)"
echo ""
echo "使い方:"
echo "  /req  - 要件定義PR作成（Phase 1-5 バリデーション付き）"
echo "  /dev  - 実装PR作成（要件トレーサビリティ付き）"
echo "  /issue - Issue作成"
echo ""
echo "📚 ドキュメント: https://github.com/PROLE-ISLAND/.github/wiki"
