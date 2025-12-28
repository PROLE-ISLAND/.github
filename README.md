# PROLE-ISLAND/.github

組織共通のGitHub設定・テンプレート・ワークフローを管理するリポジトリ。

## 構成

```
.github/
├── CLAUDE.md                    # Claude Code向け開発ルール
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

### Issue/PRテンプレート

組織内のリポジトリで独自のテンプレートを持たない場合、このリポジトリのテンプレートが自動的に適用されます。

### ワークフローテンプレート

新規リポジトリで Actions → New workflow から組織テンプレートを選択できます。

### Claude Code設定

`CLAUDE.md` の内容は各リポジトリの `CLAUDE.md` に含めるか、`@PROLE-ISLAND/.github/CLAUDE.md` で参照できます。

## カスタマイズ

リポジトリ固有の設定が必要な場合は、各リポジトリの `.github/` に同名ファイルを配置することでオーバーライドできます。
