# Ruleset 標準設定

## 概要

GitHub Rulesetsを使用してブランチ保護ルールを標準化します。

> **注意**: GitHub Teamプランでは Organization-wide Rulesets は利用できません。
> 各リポジトリで個別に設定するか、`scripts/setup-rulesets.sh` を使用して一括適用します。

## ブランチ別ルール

### main ブランチ

本番環境にデプロイされるブランチ。最も厳格なルールを適用。

| ルール | 設定 | 理由 |
|--------|------|------|
| **PR必須** | Yes | 直接pushを禁止 |
| **承認必要数** | 1 | 最低1名のレビュー |
| **CODEOWNERS承認** | Yes | 該当チームの承認必須 |
| **古いレビュー却下** | Yes | 追加コミット後は再承認 |
| **必須ステータスチェック** | CI, 品質ゲート | 全チェック通過必須 |
| **最新ブランチ必須** | Yes | mainと同期済みであること |
| **Force push禁止** | Yes | 履歴改変禁止 |
| **削除禁止** | Yes | ブランチ削除禁止 |
| **線形履歴** | Yes | マージコミットなし |

### develop ブランチ

開発中のコードを統合するブランチ。mainより緩いルール。

| ルール | 設定 | 理由 |
|--------|------|------|
| **PR必須** | Yes | 直接pushを禁止 |
| **承認必要数** | 1 | 最低1名のレビュー |
| **CODEOWNERS承認** | No | 任意の開発者で可 |
| **古いレビュー却下** | No | 効率重視 |
| **必須ステータスチェック** | CI | 基本チェックのみ |
| **最新ブランチ必須** | No | 効率重視 |
| **Force push禁止** | Yes | 履歴改変禁止 |

### release/* ブランチ

リリース準備用ブランチ。mainと同等の厳格さ。

| ルール | 設定 | 理由 |
|--------|------|------|
| **PR必須** | Yes | 直接pushを禁止 |
| **承認必要数** | 2 | 複数レビュー必須 |
| **CODEOWNERS承認** | Yes | 該当チームの承認必須 |
| **必須ステータスチェック** | CI, 品質ゲート, E2E | 全テスト通過必須 |
| **削除禁止** | Yes | 誤削除防止 |

## 必須ステータスチェック

### main / release ブランチ

| チェック名 | 説明 | 必須 |
|-----------|------|------|
| `CI` | Lint, 型チェック, テスト, ビルド | Yes |
| `品質ゲート / DoD判定` | DoD基準の自動判定 | Yes |
| `E2E / e2e-tests` | E2Eテスト（release時） | release/* のみ |

### develop ブランチ

| チェック名 | 説明 | 必須 |
|-----------|------|------|
| `CI` | Lint, 型チェック, テスト, ビルド | Yes |

## 設定方法

### 方法1: GitHub UI

1. Repository → Settings → Rules → Rulesets
2. New ruleset → New branch ruleset
3. 上記ルールを設定

### 方法2: スクリプト

```bash
# PROLE-ISLAND/.github/scripts/setup-rulesets.sh
./scripts/setup-rulesets.sh <repo-name>
```

### 方法3: GitHub CLI

```bash
# main ブランチ保護
gh api repos/PROLE-ISLAND/<repo>/rulesets \
  --method POST \
  -f name="main-protection" \
  -f target="branch" \
  -f enforcement="active" \
  -F 'conditions[ref_name][include][]=refs/heads/main' \
  -F 'rules[][type]=pull_request' \
  -F 'rules[0][parameters][required_approving_review_count]=1' \
  -F 'rules[0][parameters][dismiss_stale_reviews_on_push]=true' \
  -F 'rules[0][parameters][require_code_owner_review]=true' \
  -F 'rules[][type]=required_status_checks' \
  -F 'rules[1][parameters][required_status_checks][][context]=CI' \
  -F 'rules[][type]=non_fast_forward'
```

## バイパス設定

### バイパス可能なアクター

| アクター | main | develop | release |
|---------|------|---------|---------|
| Organization Admin | Yes | Yes | Yes |
| Repository Admin | No | Yes | No |
| Deploy Key | No | No | No |
| GitHub Actions | No | No | No |

### 緊急時の対応

本番障害等の緊急時は Organization Admin のみバイパス可能。
その場合も以下を遵守:

1. Slackで事前通知
2. 変更内容のPRを事後作成
3. インシデントレポートを作成

## 既存リポジトリへの適用

### 確認事項

適用前に以下を確認:

- [ ] 現在のブランチ保護設定をエクスポート
- [ ] 進行中のPRへの影響を確認
- [ ] チームへの事前通知

### 適用手順

```bash
# 1. 現在の設定を確認
gh api repos/PROLE-ISLAND/<repo>/rulesets

# 2. スクリプトで適用
./scripts/setup-rulesets.sh <repo>

# 3. 適用結果を確認
gh api repos/PROLE-ISLAND/<repo>/rulesets
```

## トラブルシューティング

### Q: PRがマージできない

確認事項:
1. 必須ステータスチェックが全て通過しているか
2. 必要な承認数を満たしているか
3. CODEOWNERSの承認があるか
4. mainと同期されているか

### Q: Rulesetが適用されない

確認事項:
1. Ruleset の enforcement が "active" か
2. conditions の ref_name が正しいか
3. リポジトリへの権限があるか

## 参考リンク

- [GitHub Docs: About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [scripts/setup-rulesets.sh](../scripts/setup-rulesets.sh)
