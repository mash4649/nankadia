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
| Edge Functions／サーバー | Supabase標準の `SUPABASE_URL`、`SUPABASE_SECRET_KEYS`。追加の外部API等を使う場合だけFunction固有secretを追加 | 標準値はSupabaseが自動注入。追加secretはSupabase Functions Secretsへ登録し、クライアント、Git、ログへ出さない。 |
| CLI 管理 API | `SUPABASE_ACCESS_TOKEN` または `supabase login` | 開発者マシン／CI の秘密ストア。Gitへ保存しない。 |
| DB 接続 | `SUPABASE_DB_PASSWORD`（`supabase link` 等） | ルート `.env.local`（Git対象外、権限 `600`）。ログへ出さない。 |

## 現在の確認結果

- `supabase secrets list --project-ref uqkvntykubpbqzazlxpi` の結果は空。現時点でFunctionコードがないため、追加secretは未定義。
- Supabaseの標準環境変数（`SUPABASE_URL`、`SUPABASE_SECRET_KEYS`等）はEdge Functionsへ自動注入されるため、手動登録不要。
- EASの `development`／`preview`／`production` への公開値登録は、ExpoアプリプロジェクトとEAS project ID／owner／slugが確定してから実施する。現リポジトリには `package.json`、`app.json`、`app.config.*`、`eas.json` がないため、対象を推測して登録しない。

## 次に実行するコマンド（対象確定後）

追加secretが必要になった場合（Functionコードの `Deno.env.get('CUSTOM_NAME')` と一致させる）:

```bash
supabase secrets set --project-ref uqkvntykubpbqzazlxpi CUSTOM_NAME='<secret-value>'
supabase secrets list --project-ref uqkvntykubpbqzazlxpi
```

Expoプロジェクト確定後、公開値をEASの各環境へ登録する:

```bash
eas env:set --environment development --name EXPO_PUBLIC_SUPABASE_URL --value '<project-url>' --visibility plaintext
eas env:set --environment development --name EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY --value '<publishable-key>' --visibility plaintext
```

`preview`／`production`も同じ2変数を登録する。公開値はアプリへ埋め込まれるため、service role／secret key／DB passwordはEASへ登録しない。

## 接続開始のゲート

CLI接続は次の順序で完了済み。

```bash
supabase login
supabase link --project-ref uqkvntykubpbqzazlxpi
supabase db push
```

`supabase link` と、作成済みmigrationの `supabase db push` は完了済み。以後のmigration追加時は差分確認後にpushする。

## 参照

- Supabase CLI config: <https://supabase.com/docs/guides/local-development/cli/config>
- API keys: <https://supabase.com/docs/guides/getting-started/api-keys>
- Edge Functions secrets: <https://supabase.com/docs/guides/functions/secrets>
- Expo environment variables: <https://docs.expo.dev/guides/environment-variables/>
