# /ui-generate - UI生成スキル（v0 MCP統合）

## 概要

**v0 MCP Server**を使用してUIコンポーネントを自動生成し、Feature Flagsで複数バリアントを管理するスキル。
既存デザインシステムと統一されたUIを自動生成し、**v0リンクとPreview URLを自動取得**してIssueに投稿する。

### 自動化される項目

| 項目 | 自動化 | 方法 |
|------|--------|------|
| UIコンポーネント生成 | ✅ | v0 MCP Server |
| v0チャットURL取得 | ✅ | v0 MCP レスポンス |
| Feature Flags定義 | ✅ | コード生成 |
| ブランチ作成・Push | ✅ | gh CLI |
| Preview URL取得 | ✅ | Vercel botコメント解析 |
| Issueコメント投稿 | ✅ | gh CLI |

---

## 使用タイミング

### 新機能のUI開発

```
/investigate → /ui-generate → Preview Review → PR
```

既存システムを理解した後、UIコンポーネントを生成する。

### デザインリニューアル

```
/ui-generate → 複数バリアント生成 → Toolbarで比較 → 決定 → 不要バリアント削除
```

---

## 起動方法

```bash
/ui-generate --issue {番号} --component {コンポーネント名} [--variants {数}]
```

**パラメータ**:

| パラメータ | 必須 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `--issue` | ✅ | - | 対象Issue番号 |
| `--component` | ✅ | - | 生成するコンポーネント名 |
| `--variants` | - | 1 | 生成するバリアント数（1-3） |

**例**:
```bash
/ui-generate --issue 148 --component Big5Section --variants 3
/ui-generate --issue 155 --component UserProfileCard
/ui-generate --issue 160 --component DashboardHeader --variants 2
```

---

## 実行フロー（完全自動化）

### Phase 1: 情報収集

```
1. Issue #{番号} の要件を読み取り（gh issue view）
2. 既存UIパターンを分析
   - src/components/ のコンポーネント構造
   - Design System Registry (registry.json)
   - 既存デザイントークン
3. 配置場所・データ型を特定
```

### Phase 2: v0 MCP生成（自動）

```
1. v0 MCP Serverにプロンプト送信
   - mcp__v0__generate_component ツール使用
   - Design Systemコンテキストを含める
2. 生成されたコードを受信
3. v0チャットURLを自動取得 ← 自動
4. data-testid属性を確認・追加
```

### Phase 3: コード管理

```
1. ui/issue-{番号} ブランチ作成
2. 生成コードをファイルに書き出し
3. Feature Flags定義を追加 (lib/flags/{feature}.ts)
4. バリアント切り替えコンポーネントを実装
5. GitHub Push
```

### Phase 4: URL取得・通知（自動）

```
1. Vercel Preview Deployment完了を待機
   - gh pr checks --watch
2. Vercel botコメントからPreview URLを抽出 ← 自動
3. Issueにコメント投稿
   - v0チャットURL（自動取得済み）
   - Preview URL（自動取得済み）
   - Vercel Toolbar操作ガイド
```

---

## 出力ファイル

### 1. Feature Flags定義

```typescript
// lib/flags.ts に追加
import { flag } from '@vercel/flags/next';

export const {componentName}DesignVariant = flag<'a' | 'b' | 'c'>({
  key: '{component-name}-design-variant',
  defaultValue: 'a',
  description: '{コンポーネント名}のデザインバリアント',
  options: [
    { value: 'a', label: 'パターンA' },
    { value: 'b', label: 'パターンB' },
    { value: 'c', label: 'パターンC' },
  ],
});

export const {componentName}TestMode = flag<'normal' | 'empty' | 'error' | 'loading'>({
  key: '{component-name}-test-mode',
  defaultValue: 'normal',
  description: '{コンポーネント名}のテストモード',
});
```

### 2. バリアント切り替えコンポーネント

```tsx
// src/components/{feature}/{ComponentName}.tsx
import { {componentName}DesignVariant, {componentName}TestMode } from '@/lib/flags';

export function {ComponentName}({ data }: Props) {
  const variant = {componentName}DesignVariant();
  const testMode = {componentName}TestMode();

  // テストモード処理
  if (testMode === 'loading') return <{ComponentName}Skeleton />;
  if (testMode === 'error') return <{ComponentName}Error />;
  if (testMode === 'empty') return <{ComponentName}Empty />;

  // バリアント切り替え
  switch (variant) {
    case 'a': return <{ComponentName}VariantA data={data} />;
    case 'b': return <{ComponentName}VariantB data={data} />;
    case 'c': return <{ComponentName}VariantC data={data} />;
  }
}
```

### 3. 各バリアントコンポーネント

```
src/components/{feature}/
├── {ComponentName}.tsx           # メイン（バリアント切り替え）
├── {ComponentName}VariantA.tsx   # バリアントA
├── {ComponentName}VariantB.tsx   # バリアントB（variants >= 2）
├── {ComponentName}VariantC.tsx   # バリアントC（variants >= 3）
├── {ComponentName}Skeleton.tsx   # ローディング状態
├── {ComponentName}Error.tsx      # エラー状態
└── {ComponentName}Empty.tsx      # 空状態
```

---

## Issueコメントテンプレート（自動生成）

以下のコメントが**自動的にIssueに投稿**される：

```markdown
## 🎨 UI生成完了

### 📦 生成情報

| 項目 | 値 |
|------|-----|
| **Issue** | #{番号} |
| **コンポーネント** | {ComponentName} |
| **バリアント数** | {N} |
| **ブランチ** | `ui/issue-{番号}` |

---

### 🔗 自動取得URL

| 種類 | URL |
|------|-----|
| **v0チャット** | https://v0.dev/chat/{自動取得ID} |
| **Preview** | https://{自動取得}.vercel.app |

---

### 🎛️ Vercel Toolbarでレビュー

1. **Preview URLにアクセス**
2. `Ctrl` キーでToolbar起動
3. **Flags** → バリアント切り替え
   - `{component}-design-variant`: a / b / c
   - `{component}-test-mode`: normal / empty / error / loading
4. **Comments** → ピクセル位置でフィードバック
5. **Accessibility** → a11y監査確認
6. **Layout shifts** → CLS検出確認

---

### ✅ 次のステップ

1. [ ] 全バリアントをToolbarで確認
2. [ ] a11y監査パス確認
3. [ ] フィードバックコメント収集
4. [ ] 採用バリアント決定
5. [ ] 不要バリアント削除
6. [ ] PRマージ

`/ui-generate` 自動生成 🤖
```

---

## v0プロンプトテンプレート

```markdown
Create a {コンポーネント名} component for a {プロジェクト説明}.

**Context:**
This component will be added to an existing application that uses:
- shadcn/ui ({使用コンポーネントリスト})
- Recharts for charts (if needed)
- Tailwind CSS with {デザインパターン}
- Japanese UI labels

**Existing Design Pattern:**
{既存デザインの説明}

**Requirements:**
1. {要件1}
2. {要件2}
3. {要件3}
...

**Style requirements:**
- Background: {背景スタイル}
- Cards: {カードスタイル}
- Dark mode support

**data-testid attributes:**
- {component}-section
- {component}-{element1}
- {component}-{element2}

Mock data to use:
{モックデータ}
```

---

## 完了条件

- [ ] v0でコンポーネント生成完了
- [ ] Feature Flags定義追加完了
- [ ] バリアント切り替えコンポーネント実装完了
- [ ] Toolbar用APIエンドポイント追加完了
- [ ] `ui/issue-{番号}` ブランチにPush完了
- [ ] Preview URLでアクセス確認完了
- [ ] Issueにコメント投稿完了

---

## ラベル管理

| タイミング | ラベル操作 |
|-----------|-----------|
| UI生成開始 | `in-progress` 付与 |
| Preview準備完了 | `design-review` 付与 |
| デザイン決定後 | `design-review` → `design-approved` |
| 実装完了・PRマージ | `ready-to-develop` → `done` |

---

## 関連ドキュメント

- [[UI生成・レビューガイド]] - 統合ワークフロー詳細
- [[Feature Flags活用ガイド]] - Feature Flagsの活用パターン
- [[要件定義テンプレート]] - Phase 4 UI設計セクション
- [[Playwright設計ルール]] - data-testid命名規則

---

## 前提条件

### v0 MCP Server設定

```json
// .mcp.json
{
  "mcpServers": {
    "v0": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.v0.dev",
        "--header",
        "Authorization: Bearer ${V0_API_KEY}"
      ]
    }
  }
}
```

### GitHub Secrets

| Secret名 | 用途 |
|----------|------|
| `V0_API_KEY` | v0 MCP Server認証 |

---

## 更新履歴

| 日付 | 内容 |
|-----|------|
| 2025-12-31 | v0 MCP Server統合 - 完全自動化（v0リンク・Preview URL自動取得） |
| 2025-12-31 | 初版作成（v0 + Vercel Toolbar + Feature Flags統合） |
