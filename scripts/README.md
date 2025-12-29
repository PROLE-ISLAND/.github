# Organization Scripts

開発者が使用できる共通スクリプト集。
**どのAIツール（Claude, Cursor, Copilot等）からでも使用可能。**

## v0 UI Generation

### セットアップ

```bash
# 1. APIキーを取得
# https://v0.dev/chat/settings/keys

# 2. 環境変数に設定（.zshrc や .bashrc に追加推奨）
export V0_API_KEY=v1:xxxxx:xxxxx
```

### 使い方

```bash
# 基本
./scripts/v0-generate.sh "空状態コンポーネント作成。shadcn/ui使用"

# JSONに保存
./scripts/v0-generate.sh "ユーザーテーブル" --save output.json
```

### 出力例

```
🚀 Generating UI with v0...

✅ Generation complete!

📱 Demo:  https://demo-xxx.vusercontent.net
💬 Chat:  https://v0.app/chat/xxx

📁 Generated Files:
  - components/empty-state.tsx
  - app/page.tsx
```

### プロンプトのコツ

**必須要素（毎回含める）：**
- `shadcn/uiコンポーネント使用`
- `Tailwind CSS`
- `ダークモード対応`
- `日本語テキスト`
- `TypeScript対応`

**例：空状態**
```
空状態コンポーネント作成。
- shadcn/uiのCard使用
- Tailwind CSS
- ダークモード対応
- 日本語テキスト
- アイコン: Users（Lucide、48px）
- タイトル: 「データがありません」
- 説明: 「新しいデータを追加してください」
```

**例：テーブル**
```
ユーザー一覧テーブル作成。
- shadcn/uiのTable, Badge使用
- Tailwind CSS
- ダークモード対応
- 日本語ヘッダー
- 列: 名前、メール、ステータス（Badge）、操作
- ソート可能
- 行ホバーエフェクト
```

### GitHub Actions から使用

```yaml
- name: Generate UI with v0
  env:
    V0_API_KEY: ${{ secrets.V0_API_KEY }}
  run: |
    ./scripts/v0-generate.sh "プロンプト" --save v0-output.json
```

### 生成コードの取り出し

```bash
# JSONから最初のコンポーネントを取り出す
cat v0-output.json | jq -r '.latestVersion.files[0].content' > component.tsx
```

## ライセンス

Internal use only.
