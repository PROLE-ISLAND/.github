# PROLE-ISLAND/.github

組織共通のGitHub設定・テンプレート・ワークフローを管理するリポジトリ。

## 構成

```
.github/
├── CLAUDE.md                    # Claude Code向け開発ルール
├── DoD_STANDARDS.md             # Definition of Done 品質基準
├── ISSUE_TEMPLATE/              # Issue作成テンプレート
│   ├── feature_request.yml      # 機能要望
│   ├── bug_report.yml           # バグ報告
│   └── config.yml               # テンプレート設定
├── PULL_REQUEST_TEMPLATE.md     # PRテンプレート
├── workflow-templates/          # 再利用可能ワークフロー
│   ├── ci.yml                   # CI（lint/test/build）
│   └── pr-check.yml             # PR規約チェック
└── profile/
    └── README.md                # 組織プロフィール
```

## 使い方

### DoD（Definition of Done）基準

[DoD_STANDARDS.md](./DoD_STANDARDS.md) は組織全体の品質基準を定義しています。

| Level | 用途 | 観点数 |
|-------|------|--------|
| Bronze | PR最低基準 | 27観点 |
| Silver | マージ可能基準 | 31観点 |
| Gold | 本番リリース基準 | 19観点 |

PRレビュー時にDoD Levelを確認し、該当レベルの基準を満たしているか検証してください。

### Issue/PRテンプレート

組織内のリポジトリで独自のテンプレートを持たない場合、このリポジトリのテンプレートが自動的に適用されます。

### ワークフローテンプレート

新規リポジトリで Actions → New workflow から組織テンプレートを選択できます。

### Claude Code設定

`CLAUDE.md` の内容は各リポジトリの `CLAUDE.md` に含めるか、`@PROLE-ISLAND/.github/CLAUDE.md` で参照できます。

## カスタマイズ

リポジトリ固有の設定が必要な場合は、各リポジトリの `.github/` に同名ファイルを配置することでオーバーライドできます。
