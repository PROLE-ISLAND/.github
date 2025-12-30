# =====================================================
# CODEOWNERS テンプレート
# 各リポジトリで .github/CODEOWNERS としてコピー・カスタマイズ
# =====================================================

# ---------------------------------------------------
# 使用方法
# ---------------------------------------------------
# 1. このテンプレートをリポジトリの .github/CODEOWNERS にコピー
# 2. リポジトリ固有のパスを追加・削除
# 3. チーム名を実際のGitHub Teamに置き換え
#
# 参考: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

# ---------------------------------------------------
# チーム一覧（PROLE-ISLAND組織）
# ---------------------------------------------------
# @PROLE-ISLAND/developers   - 全開発者（デフォルトオーナー）
# @PROLE-ISLAND/devops       - DevOps/インフラ/CI担当
# @PROLE-ISLAND/frontend     - フロントエンド担当
# @PROLE-ISLAND/backend      - バックエンド/DB担当
# @PROLE-ISLAND/qa           - QA/テスト担当

# =====================================================
# 基本設定（すべてのリポジトリ共通）
# =====================================================

# デフォルトオーナー（すべてのファイル）
* @PROLE-ISLAND/developers

# ---------------------------------------------------
# CI/CD・インフラ設定
# ---------------------------------------------------
/.github/ @PROLE-ISLAND/devops
/.github/workflows/ @PROLE-ISLAND/devops
/.github/CODEOWNERS @PROLE-ISLAND/devops
Dockerfile @PROLE-ISLAND/devops
docker-compose*.yml @PROLE-ISLAND/devops
vercel.json @PROLE-ISLAND/devops

# ---------------------------------------------------
# ドキュメント
# ---------------------------------------------------
*.md @PROLE-ISLAND/developers
CLAUDE.md @PROLE-ISLAND/devops
docs/ @PROLE-ISLAND/developers

# ---------------------------------------------------
# 設定ファイル
# ---------------------------------------------------
*.config.js @PROLE-ISLAND/devops
*.config.ts @PROLE-ISLAND/devops
tsconfig*.json @PROLE-ISLAND/devops

# =====================================================
# Next.js / React プロジェクト用
# =====================================================

# ---------------------------------------------------
# フロントエンド
# ---------------------------------------------------
/src/components/ @PROLE-ISLAND/frontend
/src/app/ @PROLE-ISLAND/frontend @PROLE-ISLAND/backend
/src/hooks/ @PROLE-ISLAND/frontend
/src/styles/ @PROLE-ISLAND/frontend
*.css @PROLE-ISLAND/frontend
*.scss @PROLE-ISLAND/frontend

# UIコンポーネント・デザインシステム
/src/components/ui/ @PROLE-ISLAND/frontend
/src/lib/design-system/ @PROLE-ISLAND/frontend

# ---------------------------------------------------
# バックエンド/API
# ---------------------------------------------------
/src/app/api/ @PROLE-ISLAND/backend
/api/ @PROLE-ISLAND/backend
/src/lib/api/ @PROLE-ISLAND/backend
/src/server/ @PROLE-ISLAND/backend

# ---------------------------------------------------
# データベース
# ---------------------------------------------------
/supabase/ @PROLE-ISLAND/backend
/prisma/ @PROLE-ISLAND/backend
/migrations/ @PROLE-ISLAND/backend
**/schema.sql @PROLE-ISLAND/backend

# 認証
/src/lib/supabase/ @PROLE-ISLAND/backend
/src/lib/auth/ @PROLE-ISLAND/backend

# =====================================================
# テスト
# =====================================================

# E2Eテスト
/e2e/ @PROLE-ISLAND/qa
/playwright.config.ts @PROLE-ISLAND/qa @PROLE-ISLAND/devops
playwright-report/ @PROLE-ISLAND/qa

# 単体テスト
**/*.test.ts @PROLE-ISLAND/qa
**/*.test.tsx @PROLE-ISLAND/qa
**/*.spec.ts @PROLE-ISLAND/qa
/vitest.config.ts @PROLE-ISLAND/qa @PROLE-ISLAND/devops

# =====================================================
# パッケージ管理
# =====================================================
package.json @PROLE-ISLAND/devops
package-lock.json @PROLE-ISLAND/devops
pnpm-lock.yaml @PROLE-ISLAND/devops
yarn.lock @PROLE-ISLAND/devops

# =====================================================
# Python プロジェクト用（該当する場合のみ使用）
# =====================================================
# requirements.txt @PROLE-ISLAND/backend
# pyproject.toml @PROLE-ISLAND/backend
# /src/api/ @PROLE-ISLAND/backend
# /tests/ @PROLE-ISLAND/qa
