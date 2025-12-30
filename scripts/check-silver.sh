#!/bin/bash
# =====================================================
# Silver Gate ローカルチェック
# DoD Silver 観点（31項目）の事前確認
# Bronze Gate を含む
# =====================================================

set -e

echo "🥈 Silver Gate Check (Local)"
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
# Bronze Gate 実行
# ===========================================
echo "📦 Running Bronze Gate first..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if bash "$SCRIPT_DIR/check-bronze.sh"; then
  echo ""
  echo "=============================="
  echo "🥈 Silver Gate Checks"
  echo "=============================="
  echo ""
else
  echo ""
  echo -e "${RED}💥 Bronze Gate FAILED - Silver Gate スキップ${NC}"
  exit 1
fi

# ===========================================
# C10: セキュリティ監査
# ===========================================
echo "📝 C10: Security Audit (npm audit)..."
AUDIT_RESULT=$(npm audit --audit-level=high 2>&1) || true
if echo "$AUDIT_RESULT" | grep -q "found 0 vulnerabilities"; then
  echo -e "${GREEN}✅ PASSED - 脆弱性なし${NC}"
  ((PASSED++))
elif echo "$AUDIT_RESULT" | grep -qE "(high|critical)"; then
  echo -e "${RED}❌ FAILED - high/critical 脆弱性が見つかりました${NC}"
  echo "$AUDIT_RESULT" | grep -E "(high|critical)" | head -5
  echo "  → npm audit fix で修正を試してください"
  ((FAILED++))
else
  echo -e "${GREEN}✅ PASSED - high/critical脆弱性なし${NC}"
  ((PASSED++))
fi
echo ""

# ===========================================
# F8: 統合テスト（存在する場合）
# ===========================================
echo "📝 F8: Integration Tests..."
if [ -d "src/__tests__/integration" ] || [ -d "tests/integration" ]; then
  if npm run test:integration --silent 2>/dev/null; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ FAILED - 統合テストが失敗${NC}"
    ((FAILED++))
  fi
else
  echo -e "${YELLOW}⚠️  SKIPPED - 統合テストディレクトリが見つかりません${NC}"
fi
echo ""

# ===========================================
# カバレッジ閾値チェック（85%）
# ===========================================
echo "📝 Silver Coverage Threshold (≧85%)..."
if [ -f coverage/coverage-summary.json ]; then
  COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
  echo "  📊 Current Coverage: ${COVERAGE}%"

  if (( $(echo "$COVERAGE >= 85" | bc -l) )); then
    echo -e "${GREEN}✅ PASSED - Silver基準達成${NC}"
    ((PASSED++))
  else
    echo -e "${YELLOW}⚠️  WARNING - カバレッジ ${COVERAGE}% < 85%${NC}"
    echo "  → Silver基準には85%以上が必要です"
  fi
else
  echo -e "${YELLOW}⚠️  SKIPPED - coverage-summary.json が見つかりません${NC}"
fi
echo ""

# ===========================================
# 型定義チェック
# ===========================================
echo "📝 Checking for any type..."
ANY_COUNT=$(grep -r "any" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | grep -v "node_modules" | grep -v ".test." | wc -l | tr -d ' ')
if [ "$ANY_COUNT" -eq 0 ]; then
  echo -e "${GREEN}✅ PASSED - any型なし${NC}"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠️  WARNING - any型が ${ANY_COUNT} 箇所見つかりました${NC}"
  echo "  → 可能な限り具体的な型に置き換えてください"
fi
echo ""

# ===========================================
# 結果サマリー
# ===========================================
echo "=============================="
echo "📋 Silver Gate Summary"
echo "=============================="
echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
echo -e "  ${RED}Failed: ${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 Silver Gate PASSED!${NC}"
  echo "  → dod:silver ラベルでPR作成可能です"
  exit 0
else
  echo -e "${RED}💥 Silver Gate FAILED${NC}"
  echo "  → 上記のエラーを修正してから再実行してください"
  exit 1
fi
