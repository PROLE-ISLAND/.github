# 開発参加ガイド

PROLE-ISLAND プロジェクトへの貢献ありがとうございます。

## ローカル環境セットアップ

### 必要なツール

```bash
# Node.js (バージョンは .nvmrc に従う)
nvm install
nvm use

# 依存関係インストール
npm ci

# Git hooks セットアップ
npm run prepare  # husky インストール
```

### 推奨エディタ

- **VSCode** (推奨)
  - プロジェクトを開くと推奨拡張機能がインストールされます
- EditorConfig 対応エディタ

### 開発前チェック

```bash
npm run lint        # ESLint
npm run type-check  # TypeScript
npm run test        # 単体テスト
```

---

## Issue駆動開発フロー

### 1. Issue確認

```bash
# 開発可能なIssueを確認
gh issue list -l "ready-to-develop" --json number,title -q '.[] | "\(.number): \(.title)"'

# Issue詳細を確認
gh issue view {番号}
```

### 2. ブランチ作成

```bash
# 必ずこの形式で作成
git checkout -b feature/issue-{番号}-{簡潔な説明}
git checkout -b bugfix/issue-{番号}-{説明}
git checkout -b hotfix/issue-{番号}-{説明}
```

### 3. 開発

- コミットはこまめに
- lint/type-check を通してからコミット
- テストを追加・更新

### 4. PR作成

```bash
gh pr create --title "feat: {説明}" --body "closes #{番号}"
```

**PRテンプレートに従って記入してください。**

---

## コミットメッセージ規則

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント変更
refactor: リファクタリング
test: テスト追加・修正
ci: CI/CD変更
chore: その他（ビルド設定等）
```

**例:**
```
feat: add PDF export for assessment reports
fix: resolve login redirect loop on Safari
```

---

## コードレビュー

- PR作成後、CI（lint/test/build）が自動実行されます
- CI通過後、レビュアーをアサインしてください
- 最低1名の承認が必要です

---

## 品質基準 (DoD)

| レベル | カバレッジ | 用途 |
|-------|-----------|------|
| Bronze | 80%+ | プロトタイプ・実験 |
| Silver | 85%+ | 開発版（推奨） |
| Gold | 95%+ | 本番リリース |

Issue作成時に適切なDoD Levelを選択してください。

---

## 困ったら

- [Discussions](https://github.com/orgs/PROLE-ISLAND/discussions) で質問
- CLAUDE.md を確認（各プロジェクトの開発ルール）
