# CODEOWNERS ガイドライン

## 目的

CODEOWNERSは、コード変更時に自動的に適切なレビュアーをアサインするための仕組みです。
PRが作成されると、変更されたファイルに基づいて該当するチームが自動的にレビュアーとして追加されます。

## セットアップ手順

### 1. テンプレートをコピー

```bash
# リポジトリのルートで実行
cp /path/to/CODEOWNERS_TEMPLATE.md .github/CODEOWNERS
```

または、GitHubから直接:
```bash
curl -o .github/CODEOWNERS https://raw.githubusercontent.com/PROLE-ISLAND/.github/main/CODEOWNERS_TEMPLATE.md
```

### 2. 不要なセクションを削除

リポジトリの技術スタックに合わせて:
- Next.js以外の場合: Next.js/React用セクションを削除
- Pythonの場合: Pythonセクションのコメントを外す
- E2Eテストがない場合: テストセクションを調整

### 3. リポジトリ固有のパスを追加

```
# 例: プロジェクト固有のディレクトリ
/src/features/analytics/ @PROLE-ISLAND/backend
/src/components/admin/ @PROLE-ISLAND/developers
```

### 4. チームの存在確認

CODEOWNERSで指定するチームは、GitHubに存在し、リポジトリへのアクセス権が必要です:

1. Organization → Teams で確認
2. 各チームがリポジトリに **Write** 以上のアクセス権を持つことを確認

## チーム構成

| チーム | 用途 | 主な担当ファイル |
|--------|------|-----------------|
| `@PROLE-ISLAND/developers` | デフォルト | `*` |
| `@PROLE-ISLAND/devops` | CI/CD・インフラ | `.github/`, `Dockerfile`, 設定ファイル |
| `@PROLE-ISLAND/frontend` | UI開発 | `src/components/`, デザインシステム |
| `@PROLE-ISLAND/backend` | API・DB | `src/app/api/`, `supabase/` |
| `@PROLE-ISLAND/qa` | テスト | `e2e/`, テストファイル |

## ベストプラクティス

### やるべきこと

1. **チームを使用する**
   - 個人ユーザー（`@username`）より変更に強い
   - 異動・退職時に更新不要

2. **具体的なパスを先に記述**
   ```
   # 正しい順序（具体的 → 一般的）
   /src/lib/supabase/ @PROLE-ISLAND/backend
   /src/lib/ @PROLE-ISLAND/developers
   * @PROLE-ISLAND/developers
   ```

3. **重要ファイルには複数オーナー**
   ```
   CLAUDE.md @PROLE-ISLAND/devops @PROLE-ISLAND/developers
   ```

4. **定期的にレビュー**
   - 四半期ごとに実際のレビュー担当と一致しているか確認

### 避けるべきこと

1. **存在しないチームの指定**
   - PRが失敗する原因になる

2. **過度に細かいルール**
   - メンテナンスが困難になる
   - ファイル単位ではなくディレクトリ単位で設定

3. **1人への集中**
   - ボトルネック化を防ぐ
   - 常にチームを指定

## チーム作成方法

新しいチームが必要な場合:

1. **Organization → Teams → New team**
2. チーム設定:
   - Name: 小文字推奨（例: `frontend`, `backend`）
   - Description: 担当範囲を明記
   - Visibility: Visible
3. **メンバー追加**
4. **リポジトリへのアクセス権設定**
   - Repositories タブ → Add repository
   - Permission level: **Write** 以上

## ブランチ保護との連携

CODEOWNERSの承認を必須にするには:

1. Repository → Settings → Branches
2. Branch protection rules → main
3. ✓ Require pull request reviews before merging
4. ✓ **Require review from Code Owners**

## トラブルシューティング

### Q: CODEOWNERSが機能しない

確認事項:
1. ファイルが `.github/CODEOWNERS` に配置されているか
2. 構文エラーがないか（余分なスペース、改行など）
3. 指定したチームが存在し、リポジトリアクセス権があるか

### Q: レビュアーが自動アサインされない

確認事項:
1. チームのリポジトリ権限が **Write** 以上か
2. チームメンバーにPR作成者自身が含まれていないか（自己レビューは除外される）

### Q: 間違ったチームがアサインされる

CODEOWNERSは最後にマッチしたルールが適用されます:
```
# この場合、/src/app/api/ は backend がオーナー
* @PROLE-ISLAND/developers
/src/app/api/ @PROLE-ISLAND/backend
```

## 参考リンク

- [GitHub Docs: About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [CODEOWNERS_TEMPLATE.md](../CODEOWNERS_TEMPLATE.md)
