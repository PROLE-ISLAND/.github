#!/bin/bash
# =====================================================
# GitHub Ruleset セットアップスクリプト
# リポジトリにブランチ保護ルールを一括適用
# =====================================================
#
# 使用方法:
#   ./setup-rulesets.sh <repo-name>
#   ./setup-rulesets.sh hy-assessment
#
# 前提条件:
#   - GitHub CLI (gh) がインストール済み
#   - gh auth login で認証済み
#   - Organization への write 権限
#
# 参考: docs/RULESET_STANDARDS.md

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 組織名
ORG="PROLE-ISLAND"

# 引数チェック
if [ -z "$1" ]; then
  echo -e "${RED}Error: リポジトリ名を指定してください${NC}"
  echo ""
  echo "使用方法: ./setup-rulesets.sh <repo-name>"
  echo "例: ./setup-rulesets.sh hy-assessment"
  exit 1
fi

REPO=$1

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Ruleset Setup for $ORG/$REPO${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# リポジトリの存在確認
echo -e "${YELLOW}[1/4] リポジトリ確認中...${NC}"
if ! gh repo view "$ORG/$REPO" > /dev/null 2>&1; then
  echo -e "${RED}Error: リポジトリ $ORG/$REPO が見つかりません${NC}"
  exit 1
fi
echo -e "${GREEN}✓ リポジトリ確認完了${NC}"
echo ""

# 既存Rulesetの確認
echo -e "${YELLOW}[2/4] 既存Ruleset確認中...${NC}"
EXISTING=$(gh api "repos/$ORG/$REPO/rulesets" --jq 'length' 2>/dev/null || echo "0")
if [ "$EXISTING" -gt 0 ]; then
  echo -e "${YELLOW}警告: 既存のRulesetが ${EXISTING} 件あります${NC}"
  read -p "続行しますか? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
  fi
fi
echo -e "${GREEN}✓ 既存Ruleset確認完了${NC}"
echo ""

# main ブランチ保護設定
echo -e "${YELLOW}[3/4] main ブランチ保護設定中...${NC}"

# main-protection Ruleset
gh api "repos/$ORG/$REPO/rulesets" \
  --method POST \
  --silent \
  -f name="main-protection" \
  -f target="branch" \
  -f enforcement="active" \
  -f 'conditions[ref_name][include][]=refs/heads/main' \
  -f 'rules[][type]=pull_request' \
  -F 'rules[0][parameters][required_approving_review_count]=1' \
  -F 'rules[0][parameters][dismiss_stale_reviews_on_push]=true' \
  -F 'rules[0][parameters][require_code_owner_review]=true' \
  -F 'rules[0][parameters][require_last_push_approval]=false' \
  -f 'rules[][type]=required_status_checks' \
  -F 'rules[1][parameters][strict_required_status_checks_policy]=true' \
  -f 'rules[1][parameters][required_status_checks][][context]=CI' \
  -f 'rules[][type]=non_fast_forward' \
  -f 'rules[][type]=deletion' \
  && echo -e "${GREEN}✓ main-protection 設定完了${NC}" \
  || echo -e "${RED}✗ main-protection 設定失敗${NC}"

echo ""

# develop ブランチ保護設定（存在する場合のみ）
echo -e "${YELLOW}[4/4] develop ブランチ保護設定中...${NC}"

# develop ブランチの存在確認
if gh api "repos/$ORG/$REPO/branches/develop" > /dev/null 2>&1; then
  gh api "repos/$ORG/$REPO/rulesets" \
    --method POST \
    --silent \
    -f name="develop-protection" \
    -f target="branch" \
    -f enforcement="active" \
    -f 'conditions[ref_name][include][]=refs/heads/develop' \
    -f 'rules[][type]=pull_request' \
    -F 'rules[0][parameters][required_approving_review_count]=1' \
    -F 'rules[0][parameters][dismiss_stale_reviews_on_push]=false' \
    -F 'rules[0][parameters][require_code_owner_review]=false' \
    -f 'rules[][type]=required_status_checks' \
    -f 'rules[1][parameters][required_status_checks][][context]=CI' \
    -f 'rules[][type]=non_fast_forward' \
    && echo -e "${GREEN}✓ develop-protection 設定完了${NC}" \
    || echo -e "${RED}✗ develop-protection 設定失敗${NC}"
else
  echo -e "${YELLOW}スキップ: develop ブランチが存在しません${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Ruleset Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "設定を確認:"
echo "  gh api repos/$ORG/$REPO/rulesets"
echo ""
echo "GitHub UIで確認:"
echo "  https://github.com/$ORG/$REPO/settings/rules"
echo ""
