# PROLE-ISLAND 開発ルール

> **すべての実装は [DoD_STANDARDS.md](https://github.com/PROLE-ISLAND/.github/blob/main/DoD_STANDARDS.md) に従う。**

---

## 言語ルール

| 対象 | 言語 |
|-----|------|
| UI テキスト | 日本語 |
| ユーザー向けドキュメント | 日本語 |
| Issue・PR | 日本語 |
| コミットメッセージ | 日本語（プレフィックスは英語） |
| 変数名・関数名 | 英語 |
| コメント | 日本語 |
| ファイル名 | 英語（kebab-case） |

---

## Issue駆動開発

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

**Step 5: 実装計画をIssueコメントに追加** ⚠️必須
```bash
gh issue comment {番号} --body "## 実装計画

### 変更ファイル
- \`path/to/file.ts\` - 変更内容

### 実装ステップ
1. xxx
2. xxx

### テスト方法
- [ ] 単体テスト追加
- [ ] E2Eテスト確認
"
```

**Step 6: 開発完了後のPR作成**
```bash
gh pr create --title "feat: {説明}" --body "closes #{番号}"
```

---

## ラベル体系

| ラベル | 意味 |
|--------|------|
| `ready-to-develop` | 開発可能 |
| `in-progress` | 作業中 |
| `blocked` | ブロック中 |
| `needs-triage` | 要トリアージ |
| `design-review` | デザインレビュー待ち |
| `design-approved` | デザイン承認済み |
| `no-ui` | UI変更なし |

---

## DoD (Definition of Done)

**詳細は [DoD_STANDARDS.md](https://github.com/PROLE-ISLAND/.github/blob/main/DoD_STANDARDS.md) を参照。**

| Level | 観点数 | 用途 | 必須タイミング |
|-------|--------|------|---------------|
| Bronze | 27 | PR最低基準 | PRオープン時 |
| Silver | 31 | マージ可能基準 | マージ前 |
| Gold | 19 | 本番リリース基準 | 本番デプロイ前 |

### 成熟度計算

```
総合成熟度 = (Bronze完了率 × 40%) + (Silver完了率 × 30%) + (Gold完了率 × 30%)

Gold:   90%以上 - 本番リリース可能
Silver: 70%以上 - マージ可能
Bronze: 40%以上 - レビュー可能
```

---

## ブランチ命名規則

```
feature/issue-{番号}-{説明}   # 新機能
bugfix/issue-{番号}-{説明}    # バグ修正
hotfix/issue-{番号}-{説明}    # 緊急修正
```

### 自動承認対象

以下のプレフィックスは自動承認（軽微な変更）：
- `chore/`
- `deps/`
- `docs/`
- `ci/`
- `fix/sync`

---

## 並行開発ガイドライン

複数のIssueを同時に開発する場合のルール。

### 基本方針
- **別ブランチで作業**: 各Issueは独立したブランチで開発
- **mainから分岐**: 必ずmainブランチから新規ブランチを作成
- **早めにPR**: 作業完了したらすぐPR作成

### Git Worktree による並行開発（推奨）

複数のClaude Codeセッションで並行開発する場合は、**git worktree** を使用して物理的にワーキングディレクトリを分離する。

**ツール**: [git-worktree-runner (gtr)](https://github.com/coderabbitai/git-worktree-runner)

```bash
# 新しいworktree作成（Issue用）
git gtr new feature/issue-21-example

# Claude Codeを起動
git gtr ai feature/issue-21-example

# エディタで開く
git gtr editor feature/issue-21-example

# 一覧表示
git gtr list

# 作業完了後に削除
git gtr rm feature/issue-21-example
```

**なぜworktreeが必要か:**
- 同じリポジトリでも**ローカルファイルは1セット**しかない
- 別セッションが `git checkout` すると、未コミット変更が消える
- worktreeなら**物理的に別ディレクトリ**なので安全

### コンフリクト防止

| 状況 | 対応 |
|------|------|
| 同じファイルを編集する複数Issue | 1つずつ順番に対応（先にマージされた方を優先） |
| 依存関係がある | 依存元を先にマージ、依存先はその後にリベース |
| 独立したIssue | worktreeで並行開発OK |
| 複数セッション同時開発 | **必ずworktree使用** |

### コンフリクト発生時

```bash
# 1. mainを最新化
git checkout main && git pull

# 2. 作業ブランチをリベース
git checkout feature/issue-xxx
git rebase main

# 3. コンフリクト解消後
git add . && git rebase --continue

# 4. 強制プッシュ（自分のブランチのみ）
git push --force-with-lease
```

### 関連Issueの判断基準

以下の場合は**1ブランチにまとめることを検討**:
- 同一ファイルの異なる箇所を修正
- 機能的に密結合（一方が他方に依存）
- 同一PRでレビューした方が理解しやすい

---

## コミットメッセージ規則

### 形式

```
{type}: {日本語で説明}

{詳細説明（任意）}
```

### プレフィックス（type）

| type | 用途 | 例 |
|------|------|-----|
| `feat` | 新機能 | `feat: ユーザー登録機能を追加` |
| `fix` | バグ修正 | `fix: ログインエラーを修正` |
| `docs` | ドキュメント | `docs: READMEを更新` |
| `style` | フォーマット | `style: コードフォーマットを適用` |
| `refactor` | リファクタリング | `refactor: 認証ロジックを整理` |
| `test` | テスト | `test: ユーザー登録のテストを追加` |
| `chore` | 雑務 | `chore: 依存関係を更新` |
| `ci` | CI/CD | `ci: GitHub Actions を修正` |
| `perf` | パフォーマンス | `perf: クエリを最適化` |

---

## PR規約

- タイトル: 日本語、プレフィックス付き（例: `feat: 〇〇機能を追加`）
- 本文: 日本語、`closes #番号` でIssue紐付け必須
- レビュー: 最低1名の承認必須

### 必須項目

- [ ] 変更概要
- [ ] 影響範囲
- [ ] テスト方法
- [ ] スクリーンショット（UI変更時）

---

## Figma-First ワークフロー

**UI/UX変更を含む機能は、Issue作成前にFigmaでデザインを作成する。**

```
1. デザイン作成（Figma または v0.dev）
   ↓
2. Issue作成（デザインリンク込み）→ `design-review` ラベル自動付与
   ↓
3. デザインレビュー・承認 → `design-approved` に変更
   ↓
4. 実装開始 → `ready-to-develop` ラベル付与
   ↓
5. PR作成 → CI → マージ
```

**重要**: デザインリンクのない UI機能 Issue は `design-review` で保留。

### バックエンドのみの機能

UI変更がない場合:
1. Issueテンプレートで「バックエンドのみ」にチェック
2. `no-ui` ラベルを付与
3. Figmaリンクは不要

---

## v0 によるAIデザイン生成

[v0.dev](https://v0.dev) を使用して、UIコンポーネントをAIで生成。

### v0プロンプトの必須要素

```markdown
- shadcn/uiコンポーネント使用
- Tailwind CSS
- ダークモード対応（dark:クラス使用）
- 日本語テキスト
- TypeScript対応
```

### v0コード使用時の必須チェック

1. **ハードコード色の置換**: プロジェクトのデザインシステムに合わせる
2. **型安全性**: Props interfaceを追加
3. **テスト追加**: 単体テストを作成
4. **出典記録**: コンポーネント冒頭にv0 URLをコメントで記載

---

## デザイン品質チェックリスト

UI機能の実装前に確認:

- [ ] モバイルレスポンシブ対応
- [ ] ダークモード対応
- [ ] アクセシビリティ（コントラスト、フォントサイズ、ARIA）
- [ ] 既存デザインとの整合性
- [ ] ローディング状態
- [ ] エラー状態
- [ ] 空状態（データがない場合）

---

## 関連ドキュメント

- [DoD_STANDARDS.md](https://github.com/PROLE-ISLAND/.github/blob/main/DoD_STANDARDS.md) - 品質基準（77観点）
- [組織Wiki](https://github.com/PROLE-ISLAND/.github/wiki) - 詳細ガイドライン
