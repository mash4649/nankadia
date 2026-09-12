# ADR-0001: P0 の最小実行基盤を Expo と Supabase に固定する

## Status

Accepted

## Date

2026-09-12

## Context

P0 Slice A は、端末で継続する匿名ID、サーバー側の認可と入力検証、状態変更と証跡追記の原子的処理、秘密情報のサーバー限定、一次証跡としての event_log を必要とする。Product contract はこれらの性質を定めるが、実装事業者は指定していない。

D-03 により、対象は日本の18歳以上を自己申告した利用者であり、メールアドレス・電話番号・正確な位置情報を収集しない。失われた匿名IDを指紋化や推測で復元してはならない。

## Decision

P0 Slice A の実装基盤を次のように固定する。

- Client: Expo managed workflow の React Native / TypeScript。共有できる契約型は TypeScript で共有する。
- Distribution: EAS internal distribution による招待制の限定配布。公開ストア配信は P0 の範囲外とする。
- Auth and database: Supabase Anonymous Auth と Supabase PostgreSQL を使用し、プロジェクトリージョンは Tokyo (`ap-northeast-1`) とする。
- Command boundary: モバイルアプリは Supabase Edge Functions の HTTPS コマンドAPIだけを呼ぶ。各 Function は JWT を検証し、スキーマ・所有者・policy/config version を検証する。
- Transaction boundary: proof-critical table はクライアントに書込み権限を与えない。Edge Function のみがサーバー専用のトランザクションSQL command を実行し、状態変更、append-only event、idempotency を一つのトランザクションで確定する。
- Migration and verification: SQL migration をリポジトリで版管理し、ローカル Supabase/PostgreSQL 環境で migration、権限、RLS、原子性、不変条件を検証する。
- Evidence and operations: NANKADIA の `event_log` を唯一の Product Proof 一次証跡とする。運用調査は Supabase の構造化サーバーログを併用するが、そこへ private reflection、正確な位置情報、秘密情報を送らない。第三者分析・第三者クラッシュ収集は P0 に導入しない。

匿名セッションを失った利用者は新しい匿名IDで利用できるが、過去の Proof cohort 分母には復帰しない。

## Consequences

- Supabase の service role、データベース接続情報、その他の秘密情報は Edge Functions のみで扱う。
- RLS は全公開テーブルで有効にし、権限を明示的に剥奪・付与する。RLS は Edge Function の認可・SQL command 内の所有者検証を置き換えない。
- 端末からの table CRUD、同期的な LLM、Supply Harness、公開Web、UGC storage、ストリーミング基盤は P0 に追加しない。
- Proof event / consent evidence の保持は D-03 の `cohort.closed_at + 18 months` に従う。運用ログの具体的な保持期間、障害通知の閾値と担当は、Cohort 開始前の運用決定として別途固定する。

## Alternatives considered

### クライアントから Supabase table/RPC を直接操作する

却下。proof-critical な認可、冪等性、状態遷移とイベント追記の信頼境界が端末側へ漏れる。

### カスタムAPI・PostgreSQLを自前運用する

却下。P0 の小規模検証に対して運用範囲が大きく、必要な PostgreSQL、認証、サーバー実行境界は managed platform で満たせる。

### 旧設計の Expo/Supabase binding を根拠なく再採用する

却下。旧設計は参考に留め、現在の Product contract と D-03 の決定を満たす構成として、この ADR で改めて採用した。

## References

- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/11_TECHNOLOGY_AND_BOUNDARY_BINDING.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/08_SECURITY_RELIABILITY_GUARDRAILS.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/12_API_COMMAND_CONTRACT.md`
- https://supabase.com/docs/guides/auth/auth-anonymous
- https://supabase.com/docs/guides/database/secure-data
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/platform/regions
- https://docs.expo.dev/build/internal-distribution/
