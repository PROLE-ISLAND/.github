// =============================================================================
// Vitest 設定テンプレート
// DoD Bronze/Silver/Gold カバレッジ閾値対応
// =============================================================================

import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },

  test: {
    // テスト環境
    environment: 'jsdom',

    // グローバル設定（describe, it, expect をインポート不要に）
    globals: true,

    // セットアップファイル
    setupFiles: ['./src/test/setup.ts'],

    // テストファイルのパターン
    include: ['src/**/*.test.{ts,tsx}'],

    // 除外パターン
    exclude: ['node_modules', 'dist', '.next', 'e2e'],

    // タイムアウト（5秒）
    testTimeout: 5000,

    // カバレッジ設定
    coverage: {
      // カバレッジプロバイダー
      provider: 'v8',

      // カバレッジ対象
      include: [
        'src/lib/**/*.{ts,tsx}',
        'src/components/**/*.{ts,tsx}',
        'src/hooks/**/*.{ts,tsx}',
        'src/app/**/*.{ts,tsx}',
      ],

      // 除外
      exclude: [
        'src/**/*.test.{ts,tsx}',
        'src/**/*.stories.{ts,tsx}',
        'src/test/**',
        'src/types/**',
        '**/*.d.ts',
      ],

      // レポーター
      reporter: ['text', 'text-summary', 'json-summary', 'html', 'lcov'],

      // カバレッジ閾値（DoD Bronze: 80%）
      // Silver: 85%, Gold: 95% に必要に応じて変更
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },

    // モック設定
    mockReset: true,
    restoreMocks: true,
  },
});

// =============================================================================
// セットアップファイルの例（src/test/setup.ts）
// =============================================================================
/*
import '@testing-library/jest-dom';
import { vi } from 'vitest';

// グローバルモック
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
  useSearchParams: () => new URLSearchParams(),
  usePathname: () => '/',
}));

// ResizeObserver モック
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}));
*/
