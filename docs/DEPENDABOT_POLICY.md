# Dependabot 運用ポリシー

## 概要

PROLE-ISLAND組織では、セキュリティと開発効率のバランスを取るため、以下のDependabotポリシーを採用します。

## 更新スケジュール

| エコシステム | 頻度 | 曜日 | 時間 |
|------------|------|------|------|
| npm | 週次 | 月曜 | 09:00 JST |
| GitHub Actions | 週次 | 月曜 | 09:00 JST |
| Docker | 週次 | 月曜 | 09:00 JST |
| pip (Python) | 週次 | 月曜 | 09:00 JST |

## 自動マージ条件

### 自動マージ対象

以下の条件を**すべて**満たす場合、自動マージされます:

| 条件 | 説明 |
|------|------|
| Minor/Patch更新 | `x.Y.z → x.Y+1.z` または `x.y.Z → x.y.Z+1` |
| CI全通過 | Lint, 型チェック, テスト, ビルドがすべて成功 |
| セキュリティ更新 | Dependabot Security Alertsへの対応 |

### 手動レビュー必須

以下の場合は自動マージ**されません**:

| 条件 | 理由 |
|------|------|
| Major更新 | 破壊的変更（Breaking Changes）の可能性 |
| フレームワーク更新 | Next.js, React等のメジャーバージョン |
| セキュリティ関連 | 認証・暗号化ライブラリのメジャー更新 |
| CI失敗 | 何らかのチェックが失敗 |

## グループ化戦略

### なぜグループ化するか

1. **PR数の削減**: 個別PRだと週に数十件になる可能性
2. **互換性確保**: 関連パッケージの一括更新でバージョン齟齬を防止
3. **peer dependency**: React + @types/react 等は同時更新が必要

### グループ分類

| グループ名 | 含まれるパッケージ | 更新タイプ |
|-----------|------------------|-----------|
| `nextjs` | next*, @next/* | minor, patch |
| `react` | react, react-dom, @types/react* | minor, patch |
| `supabase` | @supabase/* | minor, patch |
| `ui-components` | @radix-ui/*, tailwind*, lucide-react | minor, patch |
| `testing` | vitest*, playwright*, @testing-library/* | minor, patch |
| `linting` | eslint*, prettier*, @typescript-eslint/* | minor, patch |
| `types` | @types/* (react除く) | minor, patch |
| `build-tools` | typescript, vite*, esbuild* | minor, patch |

## セキュリティアラート対応SLA

| 重大度 | 対応期限 | 担当 |
|--------|---------|------|
| **Critical** | 24時間以内 | DevOps + 当番開発者 |
| **High** | 3営業日以内 | DevOps |
| **Medium** | 1週間以内 | 定期更新で対応 |
| **Low** | 次回定期更新 | 定期更新で対応 |

### 対応フロー

1. **アラート検知**: GitHub Security Alerts または Slack通知
2. **影響評価**: 該当コードパスの確認
3. **更新PR作成**: Dependabotが自動作成、または手動
4. **テスト実行**: CI + 必要に応じて手動テスト
5. **マージ**: Critical/Highは即時、他は通常フロー

## 新規リポジトリへの適用

### セットアップ手順

```bash
# 1. テンプレートをコピー
curl -o .github/dependabot.yml \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/dependabot.yml.template

# 2. 不要なエコシステムを削除
# npm以外（Docker, Python等）を使わない場合は該当セクションを削除

# 3. リポジトリ固有のグループを追加（任意）
# 例: SurveyJS等のプロジェクト固有ライブラリ

# 4. 自動マージワークフローを追加
curl -o .github/workflows/dependabot-auto-merge.yml \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/workflow-templates/dependabot-auto-merge.yml
```

### 組織設定（管理者向け）

Organization → Settings → Code security and analysis:

- ✓ Dependabot alerts: Enabled for all repositories
- ✓ Dependabot security updates: Enabled for all repositories
- ✓ Dependabot version updates: 各リポジトリの dependabot.yml で管理

## Major更新の対応手順

Major更新（破壊的変更）が検出された場合:

### 1. 変更内容の確認

```bash
# CHANGELOGを確認
gh pr view <PR番号> --comments

# または直接パッケージのリリースノートを確認
```

### 2. 影響範囲の評価

- [ ] Breaking Changes一覧を確認
- [ ] 該当するコードパスを検索
- [ ] 型エラーの有無を確認

### 3. 対応方針の決定

| 方針 | 条件 |
|------|------|
| 即時更新 | 影響が軽微、または重要なセキュリティ修正 |
| 計画的更新 | 影響が大きい、専用のIssue/PRで対応 |
| 保留 | 現バージョンで問題なし、次のマイルストーンで検討 |

### 4. 更新実施

```bash
# ローカルでテスト
npm install <package>@latest
npm run lint && npm run type-check && npm run test:run

# 問題なければPRをマージ
gh pr merge <PR番号> --squash
```

## トラブルシューティング

### Q: Dependabot PRが作成されない

確認事項:
1. `.github/dependabot.yml` が正しく配置されているか
2. YAML構文エラーがないか
3. Organization設定でDependabotが有効か

### Q: 自動マージが動作しない

確認事項:
1. `dependabot-auto-merge.yml` ワークフローが存在するか
2. `pull_request_target` トリガーになっているか
3. 必要な権限（`pull-requests: write`, `contents: write`）があるか

### Q: グループ化が機能しない

確認事項:
1. `groups` セクションの構文が正しいか
2. `patterns` が実際のパッケージ名にマッチしているか
3. `update-types` が適切に設定されているか

## 参考リンク

- [dependabot.yml.template](../dependabot.yml.template)
- [GitHub Docs: Dependabot](https://docs.github.com/en/code-security/dependabot)
- [workflow-templates/dependabot-auto-merge.yml](../workflow-templates/dependabot-auto-merge.yml)
