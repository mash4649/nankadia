# Supabase 接続設定

## 現在の状態

- Supabase CLI: `2.117.0`（Homebrew）
- `SUPABASE_TELEMETRY_DISABLED=1 supabase init`: 成功
- ローカル設定: [`supabase/config.toml`](../../supabase/config.toml)
- 匿名サインイン: 有効（P0 方針 D-03 に合わせた）
- リモートプロジェクト: **未接続**（`supabase link` 未実行）

## 値の種類と保管場所

| 用途 | 値／環境変数 | 保管境界 |
| --- | --- | --- |
| Expo クライアント | `EXPO_PUBLIC_SUPABASE_URL`、`EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | EAS の各環境またはローカル `.env.local`。アプリへ埋め込まれるため公開値のみ。 |
| Edge Functions／サーバー | `SUPABASE_URL`、`SUPABASE_SECRET_KEYS`（必要な secret key を選択） | Supabase Functions Secrets。クライアント、Git、ログへ出さない。 |
| CLI 管理 API | `SUPABASE_ACCESS_TOKEN` または `supabase login` | 開発者マシン／CI の秘密ストア。Gitへ保存しない。 |
| DB 接続 | `SUPABASE_DB_PASSWORD`（`supabase link` のプロンプト回避時のみ） | 一時的な環境変数または秘密ストア。ファイルへ保存しない。 |

## 未確定（推測で埋めない）

1. Supabase の組織と対象プロジェクト
2. 対象プロジェクトの `project_ref`（Dashboard URL の `/project/<project-ref>`）
3. リモート DB の major version（`SHOW server_version;`）。`config.toml` の `db.major_version = 17` は CLI 初期値であり、リモート確認前に確定しない
4. リモートリージョンが Tokyo（`ap-northeast-1`）であること
5. リモートで匿名認証が有効であること、および発行済み publishable／secret key
6. リモート DB パスワード（チャットやリポジトリへ貼り付けない）

## 接続開始のゲート

上記 1〜6 を確認してから、次の順序で実行する。

```bash
supabase login
supabase link --project-ref <project-ref>
supabase db push
```

`project-ref` と認証情報が未確定の間は `supabase link`／`supabase db push` を実行しない。リモート作成・選択や秘密値の提示が必要になった時点で、別途ユーザー確認を取る。

## 参照

- Supabase CLI config: <https://supabase.com/docs/guides/local-development/cli/config>
- API keys: <https://supabase.com/docs/guides/getting-started/api-keys>
- Edge Functions secrets: <https://supabase.com/docs/guides/functions/secrets>
- Expo environment variables: <https://docs.expo.dev/guides/environment-variables/>
