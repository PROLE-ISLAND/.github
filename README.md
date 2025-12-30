# PROLE-ISLAND/.github

組織共通のGitHub設定・テンプレート・ワークフロー・ガバナンス基盤を管理するリポジトリ。

## 構成

```
.github/
├── CLAUDE.md                        # Claude Code向け開発ルール
├── DoD_STANDARDS.md                 # Definition of Done 品質基準
├── CODEOWNERS_TEMPLATE.md           # CODEOWNERSテンプレート
├── dependabot.yml.template          # Dependabot設定テンプレート
├── ISSUE_TEMPLATE/                  # Issue作成テンプレート
│   ├── feature_request.yml          # 機能要望
│   ├── bug_report.yml               # バグ報告
│   └── config.yml                   # テンプレート設定
├── PULL_REQUEST_TEMPLATE.md         # PRテンプレート
├── workflow-templates/              # 再利用可能ワークフロー
│   ├── ci.yml                       # CI（lint/test/build）
│   ├── pr-check.yml                 # PR規約チェック
│   ├── dependabot-auto-merge.yml    # Dependabot自動マージ
│   └── sync-templates.yml           # テンプレート自動同期
├── docs/                            # ガイドライン
│   ├── CODEOWNERS_GUIDE.md          # CODEOWNERSガイド
│   ├── DEPENDABOT_POLICY.md         # Dependabot運用ポリシー
│   ├── RULESET_STANDARDS.md         # ブランチ保護標準
│   └── TEMPLATE_SYNC_GUIDE.md       # テンプレート同期ガイド
├── scripts/                         # 自動化スクリプト
│   └── setup-rulesets.sh            # Ruleset一括適用
└── profile/
    └── README.md                    # 組織プロフィール
```

## クイックスタート

### 新規リポジトリのセットアップ

```bash
# 1. CODEOWNERSをコピー
curl -o .github/CODEOWNERS \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/CODEOWNERS_TEMPLATE.md

# 2. Dependabot設定をコピー
curl -o .github/dependabot.yml \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/dependabot.yml.template

# 3. Dependabot自動マージワークフローをコピー
curl -o .github/workflows/dependabot-auto-merge.yml \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/workflow-templates/dependabot-auto-merge.yml

# 4. ブランチ保護ルールを適用
./scripts/setup-rulesets.sh <repo-name>
```

## ガバナンス

### DoD（Definition of Done）基準

[DoD_STANDARDS.md](./DoD_STANDARDS.md) は組織全体の品質基準を定義しています。

| Level | 用途 | 観点数 |
|-------|------|--------|
| Bronze | PR最低基準 | 27観点 |
| Silver | マージ可能基準 | 31観点 |
| Gold | 本番リリース基準 | 19観点 |

### CODEOWNERS

[CODEOWNERS_TEMPLATE.md](./CODEOWNERS_TEMPLATE.md) でチーム別の責任分担を標準化。

| チーム | 担当領域 |
|--------|----------|
| `@PROLE-ISLAND/developers` | デフォルト |
| `@PROLE-ISLAND/devops` | CI/CD・インフラ |
| `@PROLE-ISLAND/frontend` | UI・デザインシステム |
| `@PROLE-ISLAND/backend` | API・DB |
| `@PROLE-ISLAND/qa` | テスト |

詳細: [docs/CODEOWNERS_GUIDE.md](./docs/CODEOWNERS_GUIDE.md)

### Dependabot

[dependabot.yml.template](./dependabot.yml.template) で依存関係更新を自動化。

| 更新タイプ | 対応 |
|-----------|------|
| Minor/Patch | 自動マージ（CI通過時） |
| Major | 手動レビュー必須 |

詳細: [docs/DEPENDABOT_POLICY.md](./docs/DEPENDABOT_POLICY.md)

### ブランチ保護

[docs/RULESET_STANDARDS.md](./docs/RULESET_STANDARDS.md) でブランチ保護ルールを標準化。

| ブランチ | 必須レビュー | 必須チェック |
|---------|-------------|-------------|
| main | 1名 + CODEOWNERS | CI, 品質ゲート |
| develop | 1名 | CI |
| release/* | 2名 + CODEOWNERS | CI, 品質ゲート, E2E |

スクリプト: [scripts/setup-rulesets.sh](./scripts/setup-rulesets.sh)

## テンプレート

### Issue/PRテンプレート

組織内のリポジトリで独自のテンプレートを持たない場合、このリポジトリのテンプレートが自動的に適用されます。

### ワークフローテンプレート

新規リポジトリで Actions → New workflow から組織テンプレートを選択できます。

### Claude Code設定

`CLAUDE.md` の内容は各リポジトリの `CLAUDE.md` に含めるか、`@PROLE-ISLAND/.github/CLAUDE.md` で参照できます。

## カスタマイズ

リポジトリ固有の設定が必要な場合は、各リポジトリの `.github/` に同名ファイルを配置することでオーバーライドできます。

### テンプレート同期（推奨）

組織テンプレートとリポジトリ固有設定を自動マージする仕組み。

```
組織テンプレート + リポジトリ固有設定 = 最終設定
```

#### セットアップ

```bash
# 1. 同期ワークフローを配置
curl -o .github/workflows/sync-templates.yml \
  https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/workflow-templates/sync-templates.yml

# 2. リポジトリ固有ルールを追加（任意）
# .github/CODEOWNERS.local
# .github/dependabot.local.yml
```

#### 動作

| ファイル | 内容 |
|---------|------|
| `CODEOWNERS.local` | リポジトリ固有の所有者ルール |
| `dependabot.local.yml` | リポジトリ固有のグループ・エコシステム |

毎週月曜に自動同期し、差分があればPRを作成。

詳細: [docs/TEMPLATE_SYNC_GUIDE.md](./docs/TEMPLATE_SYNC_GUIDE.md)

## 参考リンク

- [DoD_STANDARDS.md](./DoD_STANDARDS.md) - 品質基準
- [CLAUDE.md](./CLAUDE.md) - 開発ルール
- [docs/](./docs/) - ガイドライン集
