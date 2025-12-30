# テンプレート同期ガイド

## 概要

組織テンプレート（PROLE-ISLAND/.github）とリポジトリ固有設定を自動マージするシステム。

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                    テンプレート同期フロー                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PROLE-ISLAND/.github          各リポジトリ                 │
│  ┌─────────────────────┐       ┌─────────────────────┐     │
│  │ CODEOWNERS_TEMPLATE │──┐    │ CODEOWNERS.local    │     │
│  │ dependabot.yml.template│  │    │ dependabot.local.yml│     │
│  └─────────────────────┘  │    └──────────┬──────────┘     │
│                           │               │                 │
│                           ▼               ▼                 │
│                    ┌──────────────────────────┐             │
│                    │   sync-templates.yml     │             │
│                    │   (GitHub Actions)       │             │
│                    └───────────┬──────────────┘             │
│                                │                            │
│                                ▼                            │
│                    ┌──────────────────────────┐             │
│                    │  CODEOWNERS (最終)       │             │
│                    │  dependabot.yml (最終)   │             │
│                    └──────────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## メリット

| 課題 | 従来 | テンプレート同期 |
|------|------|-----------------|
| 組織ルール更新 | 各リポで手動更新 | 自動PR作成 |
| 固有ルール追加 | 直接編集（同期不可） | .local ファイルで分離 |
| 設定の一貫性 | バラバラ | 組織標準 + 固有拡張 |

## セットアップ

### 1. ワークフロー配置

```bash
curl -o .github/workflows/sync-templates.yml \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/workflow-templates/sync-templates.yml
```

### 2. ローカル拡張ファイル作成（任意）

#### CODEOWNERS.local

リポジトリ固有のコード所有者を追加：

```bash
# .github/CODEOWNERS.local

# プロジェクト固有のパス
/src/lib/survey/ @project-lead
/src/features/assessment/ @assessment-team
```

#### dependabot.local.yml

リポジトリ固有のグループやエコシステムを追加：

```yaml
# .github/dependabot.local.yml

# 追加グループ（npmのgroupsにマージされる）
groups:
  surveyjs:
    patterns:
      - "survey-*"
    update-types:
      - "minor"
      - "patch"

# 追加エコシステム
updates:
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 3. 初回同期実行

```bash
# GitHub Actions から手動実行
gh workflow run sync-templates.yml

# または dry-run で確認
gh workflow run sync-templates.yml -f dry_run=true
```

## ファイル構成

同期後のリポジトリ構造：

```
.github/
├── workflows/
│   └── sync-templates.yml    # 同期ワークフロー
├── CODEOWNERS               # 自動生成（編集禁止）
├── CODEOWNERS.local         # 固有ルール（手動編集）
├── dependabot.yml           # 自動生成（編集禁止）
└── dependabot.local.yml     # 固有設定（手動編集）
```

## 運用ルール

### 編集ポリシー

| ファイル | 編集者 | 編集方法 |
|---------|--------|---------|
| `CODEOWNERS` | 🚫 自動生成 | 直接編集禁止 |
| `CODEOWNERS.local` | ✅ 開発者 | 固有ルール追加 |
| `dependabot.yml` | 🚫 自動生成 | 直接編集禁止 |
| `dependabot.local.yml` | ✅ 開発者 | 固有設定追加 |

### 同期タイミング

| トリガー | 頻度 | 説明 |
|---------|------|------|
| スケジュール | 毎週月曜 09:00 JST | 定期同期 |
| 手動実行 | 任意 | Actions から実行 |
| 組織テンプレート更新時 | 推奨 | 手動で同期実行 |

### PRマージ

同期PRは以下を確認してマージ：

- [ ] CODEOWNERS のチーム名が存在するか
- [ ] dependabot.yml の構文エラーがないか
- [ ] CIが通過しているか

## 例: hy-assessment の設定

### CODEOWNERS.local

```bash
# プロジェクト固有の所有者

# SurveyJS 関連
/src/lib/survey/ @PROLE-ISLAND/backend
/src/components/survey/ @PROLE-ISLAND/frontend

# 検査分析
/src/lib/analysis/ @PROLE-ISLAND/backend
/src/components/analysis/ @PROLE-ISLAND/frontend

# デザインシステム（プロジェクト固有）
/src/lib/design-system/ @PROLE-ISLAND/frontend
```

### dependabot.local.yml

```yaml
# プロジェクト固有のグループ

groups:
  # SurveyJS（peer dependency があるため一括更新）
  surveyjs:
    patterns:
      - "survey-*"
    update-types:
      - "minor"
      - "patch"

  # Recharts（グラフライブラリ）
  recharts:
    patterns:
      - "recharts*"
    update-types:
      - "minor"
      - "patch"
```

## トラブルシューティング

### Q: 同期PRが作成されない

確認事項：
1. Actions → Sync Templates が有効か
2. `secrets.GITHUB_TOKEN` の権限があるか
3. 差分がない場合はPR作成されない

### Q: マージ結果が期待と異なる

確認事項：
1. `.local` ファイルの構文エラー
2. YAML のインデントが正しいか
3. dry-run で事前確認

```bash
gh workflow run sync-templates.yml -f dry_run=true
```

### Q: 組織テンプレートを上書きしたい

`.local` ファイルでは上書きではなく追加のみ可能。
完全に上書きが必要な場合は、同期ワークフローを使用せず直接管理。

## 参考リンク

- [CODEOWNERS_TEMPLATE.md](../CODEOWNERS_TEMPLATE.md)
- [dependabot.yml.template](../dependabot.yml.template)
- [workflow-templates/sync-templates.yml](../workflow-templates/sync-templates.yml)
