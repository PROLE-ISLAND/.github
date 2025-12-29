# 開発参加ガイド

PROLE-ISLAND プロジェクトへの貢献ありがとうございます。

## 開発哲学

> **GitHubはコード管理ツールではなく、思考・責任・意思決定を構造化するOS**

この考えに基づき、以下のルールを設けています。

---

## Pull Request ルール

### Why必須ポリシー

**「Whyが書いてないPRはレビューしない」**

PRを作成する際、以下は**必須**です：

| セクション | 必須度 | 説明 |
|-----------|--------|------|
| 変更理由（Why） | ⚠️ 必須 | なぜこの変更が必要なのか |
| 目的（What） | 推奨 | 何を実現するか |
| 影響範囲 | 推奨 | どこに影響するか |
| リスク評価 | 推奨 | リスクと対策 |

```markdown
## 2. 変更理由（Why）⚠️ 必須
認証処理のレスポンスタイムが平均3秒を超え、
ユーザーからの苦情が増加しているため、
キャッシュ機構を導入してパフォーマンスを改善する。
```

### マージ戦略

**Squash Merge を標準とする**

- コミット履歴がクリーンになる
- 1PR = 1コミットで追跡しやすい
- Revertが簡単

---

## Issue の使い方

### Issueは「議論」ではなく「決定ログ」

Issueの本来の価値：
- なぜこの仕様にしたか
- なぜこの選択肢を捨てたか
- どこが未解決か

### ADR (Architecture Decision Record)

重要な技術的決定を行う場合、**Decision Record** テンプレートを使用してください。

---

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
npm run type-check  # TypeScript（npx tsc --noEmit）
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

**PRテンプレートに従って記入してください。特に「Why」は必須です。**

---

## コミットメッセージ規則

```
<type>(<scope>): <subject>
```

### Type

| Type | 説明 |
|------|------|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `docs` | ドキュメント |
| `style` | フォーマット（機能変更なし） |
| `refactor` | リファクタリング |
| `perf` | パフォーマンス改善 |
| `test` | テスト追加・修正 |
| `ci` | CI/CD変更 |
| `chore` | ビルド・補助ツール |

**例:**
```
feat(auth): add OAuth2 login support
fix(dashboard): resolve chart rendering issue on Safari
```

---

## コードレビュー

### レビュアーの責任

1. **Whyの確認**: 変更理由が妥当か
2. **影響範囲の確認**: 意図しない副作用がないか
3. **リスクの評価**: 適切なリスク対策がされているか
4. **コード品質**: 可読性・保守性・パフォーマンス

### レビュー承認基準

- [ ] 変更理由（Why）が明確
- [ ] テストが追加/更新されている
- [ ] 破壊的変更がある場合、移行ガイドがある
- [ ] セキュリティ上の懸念がない

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
