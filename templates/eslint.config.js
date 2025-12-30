// =============================================================================
// ESLint 設定テンプレート (Flat Config)
// DoD Bronze A2 Lint通過対応 + セキュリティルール
// =============================================================================

import js from '@eslint/js';
import typescript from '@typescript-eslint/eslint-plugin';
import typescriptParser from '@typescript-eslint/parser';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import importPlugin from 'eslint-plugin-import';

export default [
  // 基本設定
  js.configs.recommended,

  // グローバル除外
  {
    ignores: [
      'node_modules/**',
      '.next/**',
      'dist/**',
      'coverage/**',
      '*.config.js',
      '*.config.ts',
    ],
  },

  // TypeScript ファイル
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
    plugins: {
      '@typescript-eslint': typescript,
      react,
      'react-hooks': reactHooks,
      'jsx-a11y': jsxA11y,
      import: importPlugin,
    },
    rules: {
      // ===========================================
      // TypeScript ルール
      // ===========================================

      // any 型禁止（DoD A1）
      '@typescript-eslint/no-explicit-any': 'error',

      // 未使用変数エラー（DoD A3）
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],

      // 非 null アサーション警告
      '@typescript-eslint/no-non-null-assertion': 'warn',

      // ===========================================
      // React ルール
      // ===========================================

      // React Hooks ルール
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',

      // JSX キー必須
      'react/jsx-key': 'error',

      // ===========================================
      // アクセシビリティ
      // ===========================================

      // alt 属性必須
      'jsx-a11y/alt-text': 'error',

      // ボタンにタイプ必須
      'jsx-a11y/button-has-type': 'error',

      // ===========================================
      // セキュリティ（DoD C1-C11）
      // ===========================================

      // eval 禁止
      'no-eval': 'error',

      // implied eval 禁止
      'no-implied-eval': 'error',

      // new Function 禁止
      'no-new-func': 'error',

      // ===========================================
      // コード品質
      // ===========================================

      // console.log 警告（本番では削除推奨）
      'no-console': ['warn', { allow: ['warn', 'error'] }],

      // debugger 禁止
      'no-debugger': 'error',

      // import 順序
      'import/order': [
        'error',
        {
          groups: [
            'builtin',
            'external',
            'internal',
            'parent',
            'sibling',
            'index',
          ],
          'newlines-between': 'always',
          alphabetize: { order: 'asc' },
        },
      ],
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
  },

  // テストファイル（緩和ルール）
  {
    files: ['**/*.test.ts', '**/*.test.tsx', '**/*.spec.ts'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
      'no-console': 'off',
    },
  },

  // E2E テストファイル
  {
    files: ['e2e/**/*.ts'],
    rules: {
      // waitForTimeout 禁止（DoD レースコンディション防止）
      'no-restricted-syntax': [
        'error',
        {
          selector: "CallExpression[callee.property.name='waitForTimeout']",
          message:
            'waitForTimeout() は禁止です。waitForData() または waitForPageReady() を使用してください。',
        },
      ],
    },
  },
];

// =============================================================================
// package.json scripts 例
// =============================================================================
/*
{
  "scripts": {
    "lint": "eslint src --ext .ts,.tsx",
    "lint:fix": "eslint src --ext .ts,.tsx --fix"
  }
}
*/
