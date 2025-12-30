#!/bin/bash
# =====================================================
# Bronze Gate ローカルチェック
# DoD Bronze 観点（27項目）の事前確認
# =====================================================

set -e

echo "🥉 Bronze Gate Check (Local)"
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
# A1: 型チェック
# ===========================================
echo "📝 A1: Type Check (tsc --noEmit)..."
if npx tsc --noEmit 2>/dev/null; then
  check_result
else
  echo -e "${RED}❌ FAILED - 型エラーがあります${NC}"
  ((FAILED++))
fi
echo ""

# ===========================================
# A2: Lint
# ===========================================
echo "📝 A2: Lint (eslint)..."
if npm run lint --silent 2>/dev/null; then
  check_result
else
  echo -e "${RED}❌ FAILED - Lintエラーがあります${NC}"
  echo "  → npm run lint -- --fix で自動修正を試してください"
  ((FAILED++))
fi
echo ""

# ===========================================
# B1-B9: 単体テスト + カバレッジ
# ===========================================
echo "📝 B1-B9: Unit Tests with Coverage..."
if npm run test:coverage --silent 2>/dev/null; then
  echo -e "${GREEN}✅ テスト通過${NC}"
  ((PASSED++))
else
  echo -e "${RED}❌ FAILED - テストが失敗しました${NC}"
  ((FAILED++))
fi
echo ""

# ===========================================
# B2: カバレッジ閾値チェック
# ===========================================
echo "📝 B2: Coverage Threshold (≧80%)..."
if [ -f coverage/coverage-summary.json ]; then
  COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
  echo "  📊 Current Coverage: ${COVERAGE}%"

  if (( $(echo "$COVERAGE >= 80" | bc -l) )); then
    echo -e "${GREEN}✅ PASSED - カバレッジ基準達成${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ FAILED - カバレッジ ${COVERAGE}% < 80%${NC}"
    echo "  → coverage/index.html を確認してテストを追加してください"
    ((FAILED++))
  fi
else
  echo -e "${YELLOW}⚠️  SKIPPED - coverage-summary.json が見つかりません${NC}"
  echo "  → npm run test:coverage を実行してください"
fi
echo ""

# ===========================================
# K1: ビルド
# ===========================================
echo "📝 K1: Build..."
if npm run build --silent 2>/dev/null; then
  echo -e "${GREEN}✅ PASSED - ビルド成功${NC}"
  ((PASSED++))
else
  echo -e "${RED}❌ FAILED - ビルドエラー${NC}"
  ((FAILED++))
fi
echo ""

# ===========================================
# 結果サマリー
# ===========================================
echo "=============================="
echo "📋 Summary"
echo "=============================="
echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
echo -e "  ${RED}Failed: ${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 Bronze Gate PASSED!${NC}"
  echo "  → PR作成可能です"
  exit 0
else
  echo -e "${RED}💥 Bronze Gate FAILED${NC}"
  echo "  → 上記のエラーを修正してから再実行してください"
  exit 1
fi
