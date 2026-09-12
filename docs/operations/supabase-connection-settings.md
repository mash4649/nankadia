# Supabase 接続設定

## 現在の状態

- Supabase CLI: `2.117.0`（Homebrew）
- `SUPABASE_TELEMETRY_DISABLED=1 supabase init`: 成功
- ローカル設定: [`supabase/config.toml`](../../supabase/config.toml)
- 匿名サインイン: 有効（P0 方針 D-03 に合わせた）
- Organization: `mash4649` (`vxsokgtxeykcjqgqnsoe`)
- リモートプロジェクト: `nankadia-main` (`uqkvntykubpbqzazlxpi`)
- リージョン: Northeast Asia (Tokyo) (`ap-northeast-1`)
- DB: PostgreSQL `17.6.1.166`（`config.toml` の major version `17` と一致）
- CLI link: 完了。`status=ACTIVE_HEALTHY`
- 料金プラン: `Free` を Dashboard で確認。Compute は `nano`（`t4g.nano`）
- 作成時: `--size` と `--high-availability` を指定せず、Free Plan の共有リソースで作成

## 値の種類と保管場所

| 用途 | 値／環境変数 | 保管境界 |
| --- | --- | --- |
| Expo クライアント | `EXPO_PUBLIC_SUPABASE_URL`、`EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | EAS の各環境またはローカル `.env.local`。アプリへ埋め込まれるため公開値のみ。 |
| Edge Functions／サーバー | `SUPABASE_URL`、`SUPABASE_SECRET_KEYS`（必要な secret key を選択） | Supabase Functions Secrets。クライアント、Git、ログへ出さない。 |
| CLI 管理 API | `SUPABASE_ACCESS_TOKEN` または `supabase login` | 開発者マシン／CI の秘密ストア。Gitへ保存しない。 |
| DB 接続 | `SUPABASE_DB_PASSWORD`（`supabase link` 等） | ルート `.env.local`（Git対象外、権限 `600`）。ログへ出さない。 |

## 未確定（推測で埋めない）

1. Edge Functions 用 secret key を Functions Secrets に登録すること（クライアント／Gitへ出さない）
2. EAS の `development`／`preview`／`production` 環境へ公開値を登録すること（アプリ実装時）

## 接続開始のゲート

上記の未確定事項を確認してから、次の順序で実行する。

```bash
supabase login
supabase link --project-ref uqkvntykubpbqzazlxpi
supabase db push
```

`supabase link` は完了済み。migration が作成されるまで `supabase db push` は実行しない。

## 参照

- Supabase CLI config: <https://supabase.com/docs/guides/local-development/cli/config>
- API keys: <https://supabase.com/docs/guides/getting-started/api-keys>
- Edge Functions secrets: <https://supabase.com/docs/guides/functions/secrets>
- Expo environment variables: <https://docs.expo.dev/guides/environment-variables/>
