# /ui-generate - UI生成スキル

## 概要

v0 Platform APIを使用してUIコンポーネントを生成し、Feature Flagsで複数バリアントを管理するスキル。
既存デザインシステムと統一されたUIを自動生成し、Vercel Toolbarでレビュー可能な状態にする。

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

## 実行フロー

### Phase 1: 情報収集

```
1. Issue #{番号} の要件を読み取り
2. 既存UIパターンを分析
   - src/components/ のコンポーネント構造
   - Design System Registry (registry.json)
   - 既存デザイントークン
3. 配置場所を特定
```

### Phase 2: v0生成

```
1. Design System Registryをv0に登録
2. v0 Platform APIでコンポーネント生成
   - 各バリアントごとに生成
   - 既存デザインシステムに準拠
3. data-testid属性を自動付与
```

### Phase 3: コード管理

```
1. ui/issue-{番号} ブランチ作成
2. Feature Flags定義を追加 (lib/flags.ts)
3. バリアント切り替えコンポーネントを実装
4. Toolbar用APIエンドポイントを追加
5. GitHub Push
```

### Phase 4: 完了通知

```
1. Preview URLを生成
2. Issueにコメント投稿
   - v0リンク
   - Preview URL
   - Feature Flags操作方法
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

## Issueコメントテンプレート

```markdown
## UI生成完了 🎨

**Issue**: #{番号}
**コンポーネント**: {ComponentName}
**バリアント数**: {N}

---

### v0リンク

| バリアント | v0 Link |
|-----------|---------|
| パターンA | https://v0.dev/chat/xxx-a |
| パターンB | https://v0.dev/chat/xxx-b |
| パターンC | https://v0.dev/chat/xxx-c |

---

### Preview URL

**URL**: https://ui-issue-{番号}.xxx.vercel.app

---

### Vercel Toolbar操作ガイド

1. Preview URLにアクセス
2. `Ctrl` キーでToolbar起動
3. **Flags** → バリアント切り替え
4. **Comments** → ピクセル位置でフィードバック
5. **Accessibility** → a11y監査確認
6. **Layout shifts** → CLS検出確認

---

### 決定後のアクション

1. 採用バリアントを決定
2. 不要バリアントのコード削除
3. Feature Flag定義を整理
4. PRをマージ
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

## 更新履歴

| 日付 | 内容 |
|-----|------|
| 2025-12-31 | 初版作成（v0 + Vercel Toolbar + Feature Flags統合） |
