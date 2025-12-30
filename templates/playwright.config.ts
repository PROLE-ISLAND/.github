// =============================================================================
// Playwright E2E テスト設定テンプレート
// DoD Gold B10 E2Eテスト対応
// =============================================================================

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // テストディレクトリ
  testDir: './e2e',

  // テストファイルパターン
  testMatch: '**/*.spec.ts',

  // 並列実行設定
  // CI: 1 worker（安定性優先）, ローカル: 3 workers
  fullyParallel: true,
  workers: process.env.CI ? 1 : 3,

  // リトライ設定
  // CI: 2回リトライ, ローカル: 1回
  retries: process.env.CI ? 2 : 1,

  // レポーター
  reporter: process.env.CI
    ? [['github'], ['html', { open: 'never' }]]
    : [['list'], ['html', { open: 'on-failure' }]],

  // グローバル設定
  use: {
    // ベースURL（環境変数で上書き可能）
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:3000',

    // スクリーンショット（失敗時のみ）
    screenshot: 'only-on-failure',

    // トレース（リトライ時）
    trace: 'on-first-retry',

    // ビデオ（リトライ時）
    video: 'on-first-retry',
  },

  // タイムアウト設定
  timeout: 30000, // テスト全体: 30秒
  expect: {
    timeout: 10000, // アサーション: 10秒
  },

  // プロジェクト（ブラウザ）設定
  projects: [
    // 認証セットアップ
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },

    // Chromium（メイン）
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'e2e/.auth/user.json',
      },
      dependencies: ['setup'],
    },

    // モバイル（オプション）
    // {
    //   name: 'mobile-chrome',
    //   use: {
    //     ...devices['Pixel 5'],
    //     storageState: 'e2e/.auth/user.json',
    //   },
    //   dependencies: ['setup'],
    // },
  ],

  // 開発サーバー自動起動
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000, // 起動タイムアウト: 2分
  },
});

// =============================================================================
// E2E テストファイル構成例
// =============================================================================
/*
e2e/
├── .auth/
│   └── user.json          # 認証状態保存
├── fixtures/
│   └── index.ts           # 共通フィクスチャ
├── helpers/
│   └── wait.ts            # 決定論的待機ヘルパー
├── auth.setup.ts          # 認証セットアップ
├── 01-auth.spec.ts        # 認証テスト
├── 02-candidates.spec.ts  # 候補者管理テスト
└── 03-analysis.spec.ts    # 分析機能テスト
*/

// =============================================================================
// 決定論的待機ヘルパー例（e2e/helpers/wait.ts）
// =============================================================================
/*
import { Page } from '@playwright/test';

// データ取得完了まで待機
export async function waitForData(page: Page, endpoint: string) {
  await page.waitForResponse(
    (response) =>
      response.url().includes(endpoint) && response.status() === 200
  );
}

// ページ準備完了まで待機
export async function waitForPageReady(page: Page) {
  await page.waitForLoadState('networkidle');
}

// ❌ 禁止: waitForTimeout
// await page.waitForTimeout(1000);
*/
