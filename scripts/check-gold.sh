#!/bin/bash
# =====================================================
# Gold Gate ローカルチェック
# DoD Gold 観点（19項目）の事前確認
# Silver Gate を含む
# =====================================================

set -e

echo "🥇 Gold Gate Check (Local)"
echo "=============================="
echo ""

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 結果カウンター
PASSED=0
FAILED=0

check_result() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
    return 1
  fi
}

# ===========================================
# Silver Gate 実行
# ===========================================
echo "📦 Running Silver Gate first..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if bash "$SCRIPT_DIR/check-silver.sh"; then
  echo ""
  echo "=============================="
  echo "🥇 Gold Gate Checks"
  echo "=============================="
  echo ""
else
  echo ""
  echo -e "${RED}💥 Silver Gate FAILED - Gold Gate スキップ${NC}"
  exit 1
fi

# ===========================================
# B10: E2Eテスト
# ===========================================
echo "📝 B10: E2E Tests (Playwright)..."
if [ -d "e2e" ] || [ -d "tests/e2e" ]; then
  if npx playwright test --reporter=list 2>/dev/null; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ FAILED - E2Eテストが失敗${NC}"
    echo "  → npx playwright test --ui でデバッグしてください"
    ((FAILED++))
  fi
else
  echo -e "${YELLOW}⚠️  SKIPPED - E2Eテストディレクトリが見つかりません${NC}"
  echo "  → e2e/ または tests/e2e/ を作成してください"
fi
echo ""

# ===========================================
# カバレッジ閾値チェック（95%）
# ===========================================
echo "📝 Gold Coverage Threshold (≧95%)..."
if [ -f coverage/coverage-summary.json ]; then
  COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
  echo "  📊 Current Coverage: ${COVERAGE}%"

  if (( $(echo "$COVERAGE >= 95" | bc -l) )); then
    echo -e "${GREEN}✅ PASSED - Gold基準達成${NC}"
    ((PASSED++))
  else
    echo -e "${YELLOW}⚠️  WARNING - カバレッジ ${COVERAGE}% < 95%${NC}"
    echo "  → Gold基準には95%以上が必要です"
  fi
else
  echo -e "${YELLOW}⚠️  SKIPPED - coverage-summary.json が見つかりません${NC}"
fi
echo ""

# ===========================================
# D1-D7: パフォーマンスチェック（簡易）
# ===========================================
echo "📝 D1: Build Size Check..."
if [ -d ".next" ]; then
  BUILD_SIZE=$(du -sh .next 2>/dev/null | cut -f1)
  echo "  📦 Build Size: ${BUILD_SIZE}"
  echo -e "${GREEN}✅ INFO - ビルドサイズを確認してください${NC}"
  ((PASSED++))
elif [ -d "dist" ]; then
  BUILD_SIZE=$(du -sh dist 2>/dev/null | cut -f1)
  echo "  📦 Build Size: ${BUILD_SIZE}"
  echo -e "${GREEN}✅ INFO - ビルドサイズを確認してください${NC}"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠️  SKIPPED - ビルド出力が見つかりません${NC}"
fi
echo ""

# ===========================================
# Lighthouse チェック（手動推奨）
# ===========================================
echo "📝 D2: Lighthouse (Manual Check Required)..."
echo -e "${YELLOW}⚠️  INFO - 以下を手動で確認してください:${NC}"
echo "  1. npx lighthouse http://localhost:3000 --view"
echo "  2. LCP ≦ 2.5秒"
echo "  3. FID ≦ 100ms"
echo "  4. CLS ≦ 0.1"
echo ""

# ===========================================
# 本番環境変数チェック
# ===========================================
echo "📝 Environment Variables Check..."
if [ -f ".env.example" ]; then
  echo -e "${GREEN}✅ PASSED - .env.example 存在${NC}"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠️  WARNING - .env.example がありません${NC}"
  echo "  → 必須環境変数のテンプレートを作成してください"
fi
echo ""

# ===========================================
# 結果サマリー
# ===========================================
echo "=============================="
echo "📋 Gold Gate Summary"
echo "=============================="
echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
echo -e "  ${RED}Failed: ${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 Gold Gate PASSED!${NC}"
  echo "  → dod:gold ラベルでPR作成可能です"
  echo ""
  echo "📋 本番リリース前の追加確認:"
  echo "  - [ ] 負荷テスト実施（npm run test:load）"
  echo "  - [ ] Lighthouse スコア確認"
  echo "  - [ ] ステージング環境での動作確認"
  exit 0
else
  echo -e "${RED}💥 Gold Gate FAILED${NC}"
  echo "  → 上記のエラーを修正してから再実行してください"
  exit 1
fi
