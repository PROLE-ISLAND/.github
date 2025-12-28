# PROLE-ISLAND 開発ルール

## Issue駆動開発（Claude Code向け）

### 開発開始時の必須手順

**Step 1: 対応可能なIssue確認**
```bash
gh issue list -l "ready-to-develop" --json number,title,labels -q '.[] | "\(.number): \(.title)"'
```

**Step 2: 優先度判断**
- P0 (Critical) → 最優先で即対応
- P1 (High) → 今週中に対応
- P2 (Medium) → スプリント内で対応
- P3 (Low) → バックログ

**Step 3: Issue詳細確認**
```bash
gh issue view {番号}
```

**Step 4: ブランチ作成**
```bash
git checkout -b feature/issue-{番号}-{簡潔な説明}
# 例: git checkout -b feature/issue-42-add-pdf-export
```

**Step 5: 開発完了後のPR作成**
```bash
gh pr create --title "feat: {説明}" --body "closes #{番号}"
```

---

## ラベル体系

| ラベル | 意味 | Claude Codeの対応 |
|--------|------|------------------|
| `ready-to-develop` | 開発可能 | このラベルのIssueを優先的に取得 |
| `in-progress` | 作業中 | 他が作業中なのでスキップ |
| `blocked` | ブロック中 | 依存解決まで待機 |
| `needs-triage` | 要トリアージ | 人間の判断待ち |

---

## 品質基準 (DoD)

| レベル | カバレッジ | 用途 |
|-------|-----------|------|
| Bronze | 80%以上 | プロトタイプ |
| Silver | 85%以上 | 開発版（推奨） |
| Gold | 95%以上 | 本番品質 |

---

## ブランチ命名規則

```
feature/issue-{番号}-{説明}   # 新機能
bugfix/issue-{番号}-{説明}    # バグ修正
hotfix/issue-{番号}-{説明}    # 緊急修正
```

---

## コミットメッセージ規則

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント
refactor: リファクタリング
test: テスト追加
ci: CI/CD変更
chore: その他
```

---

## PR規約

- タイトル: `feat:`, `fix:` 等のプレフィックス必須
- 本文: `closes #番号` でIssue紐付け必須
- レビュー: 最低1名の承認必須
