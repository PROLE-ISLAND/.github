# 設定テンプレート

新規プロジェクトでDoD品質基準を満たすための設定テンプレート集

---

## 使い方

### 1. テンプレートをコピー

```bash
# 必要なファイルをプロジェクトにコピー
cp templates/vitest.config.ts ./vitest.config.ts
cp templates/playwright.config.ts ./playwright.config.ts
cp templates/eslint.config.js ./eslint.config.js
cp templates/.env.example ./.env.example
cp templates/openapi.yaml ./openapi.yaml
```

### 2. プロジェクトに合わせてカスタマイズ

各ファイルのコメントを参照して、プロジェクト固有の設定を追加

---

## テンプレート一覧

| ファイル | 用途 | DoD対応観点 |
|---------|------|-------------|
| `vitest.config.ts` | 単体テスト設定 | B1-B9, B2(カバレッジ80%) |
| `playwright.config.ts` | E2Eテスト設定 | B10 |
| `eslint.config.js` | Lint設定 | A2, A3, C1-C11(セキュリティ) |
| `.env.example` | 環境変数テンプレート | C11(シークレット管理) |
| `openapi.yaml` | API仕様テンプレート | F1-F8 |

---

## 各テンプレートの特徴

### vitest.config.ts

- カバレッジ閾値設定（Bronze: 80%）
- jsdom環境（React対応）
- パスエイリアス設定（`@/`）
- セットアップファイル例付き

### playwright.config.ts

- CI/ローカル切り替え設定
- リトライ・タイムアウト設定
- 認証セットアップ対応
- 決定論的待機ヘルパー例付き

### eslint.config.js

- Flat Config形式（ESLint v9対応）
- TypeScript + React + アクセシビリティ
- セキュリティルール（eval禁止など）
- waitForTimeout禁止ルール（E2E用）

### .env.example

- Supabase設定
- OpenAI設定
- メール送信設定
- テスト用設定

### openapi.yaml

- OpenAPI 3.0仕様
- RFC 7807エラー形式
- ページネーション対応
- Bearer Token認証

---

## 依存パッケージ

### Vitest

```bash
npm install -D vitest @vitejs/plugin-react @vitest/coverage-v8
npm install -D @testing-library/react @testing-library/jest-dom
```

### Playwright

```bash
npm install -D @playwright/test
npx playwright install
```

### ESLint

```bash
npm install -D eslint @eslint/js
npm install -D @typescript-eslint/eslint-plugin @typescript-eslint/parser
npm install -D eslint-plugin-react eslint-plugin-react-hooks
npm install -D eslint-plugin-jsx-a11y eslint-plugin-import
```

---

## 関連ドキュメント

- [DoD_STANDARDS.md](../DoD_STANDARDS.md) - 品質基準（77観点）
- [DoD達成ガイド](https://github.com/PROLE-ISLAND/.github/wiki/DoD達成ガイド) - 達成方法
- [テスト戦略](https://github.com/PROLE-ISLAND/.github/wiki/テスト戦略) - テスト方針
