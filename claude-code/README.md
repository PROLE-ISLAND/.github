# Claude Code 開発環境

PROLE-ISLAND 組織の Claude Code 開発環境パッケージ。

## クイックインストール

```bash
curl -sL https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/claude-code/setup.sh | bash
```

または dev-tools 経由:

```bash
npm install -g @prole-island/dev-tools
prole claude --setup-hooks
```

## 含まれるファイル

```
claude-code/
├── hooks/                  # Claude Code Hooks
│   ├── gate.py            # PreToolUse Hook（Issue/PR検証）
│   └── sync-guardrails.sh # Guardrails 同期スクリプト
├── cache/
│   └── claude-guardrails.yaml  # バリデーションルール定義
├── commands/               # スラッシュコマンド
│   ├── req.md             # /req - 要件定義PR作成
│   ├── dev.md             # /dev - 実装PR作成
│   └── issue.md           # /issue - Issue作成
├── setup.sh               # インストールスクリプト
└── README.md              # このファイル
```

## 機能

### Hooks (gate.py)

Claude Code の PreToolUse Hook として動作し、以下を検証:

| 対象 | 検証内容 |
|:---|:---|
| `gh issue create` | 必須セクション（事前調査、優先度、DoD Level、受け入れ条件） |
| `gh pr create` (type:requirements) | **Phase 1-5 完全性チェック** |
| `gh pr create` (type:implementation) | 要件トレーサビリティ、DoDレベル |

### Phase 1-5 検証項目

| Phase | 検証セクション |
|:---|:---|
| **Phase 1** | 調査レポート、Investigation Report v1 要約 |
| **Phase 2** | 機能概要、ユースケース定義（UC-ID）、カバレッジマトリクス、入力ソース、外部整合性 |
| **Phase 3** | DoD Level、Pre-mortem（3つ以上） |
| **Phase 4** | DB設計（スコープ検出）、API設計（スコープ検出）、UI設計（スコープ検出）、変更ファイル一覧 |
| **Phase 5** | Gold E2E候補評価、トリアージ、GWT仕様、Playwright、単体テスト、トレーサビリティ、統合テスト |

### スコープ検出

Phase 4 では本文から自動的にスコープを検出:

- **DB変更検出**: `データベース設計`, `CRUD`, `RLS`, `マイグレーション` 等
- **API変更検出**: `API設計`, `エンドポイント`, `/api/` 等
- **UI変更検出**: `UI設計`, `画面一覧`, `バリアント`, `data-testid` 等

検出されたスコープに応じて、必要なセクションのみを必須化します。

## コマンド

### /req - 要件定義PR作成

```
/req
```

Phase 1-5 の全セクションを含む要件定義PRを作成。
`type:requirements` ラベル付与、`ci:skip` で CI をスキップ。

### /dev - 実装PR作成

```
/dev
```

要件トレーサビリティ付きの実装PRを作成。
`type:implementation` ラベル付与。

### /issue - Issue作成

```
/issue
```

必須セクションを含むIssueを作成。

## 設定

### settings.local.json

```json
{
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
```

### Guardrails 同期

最新の guardrails.yaml を取得:

```bash
~/.claude/hooks/sync-guardrails.sh
```

## 関連ドキュメント

- [要件定義テンプレート](https://github.com/PROLE-ISLAND/.github/wiki/要件定義テンプレート)
- [Claude-Codeルール](https://github.com/PROLE-ISLAND/.github/wiki/Claude-Codeルール)
- [オンボーディング](https://github.com/PROLE-ISLAND/.github/wiki/オンボーディング)
- [DoD_STANDARDS.md](https://github.com/PROLE-ISLAND/.github/blob/main/DoD_STANDARDS.md)

## 更新履歴

| 日付 | 内容 |
|:---|:---|
| 2026-01-01 | Phase 1-5 完全性チェック、スコープ検出機能追加 |
| 2025-12-31 | 初版 |
