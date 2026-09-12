# ADR-0002: P0 コホートの障害対応とログ運用を固定する

## Status

Accepted

## Date

2026-09-12

## Context

P0 の Product Proof は、D-03 が定める `event_log` と同意記録で再構成できなければならない。一方、Supabase の運用ログの保持期間は契約プランに依存するため、Product Proof の保管先にはできない。

小規模・招待制の Calibration-1 と Proof A/B に、第三者監視、ログdrain、外部長期保管を追加すると、費用と新しいデータ境界だけが増える。障害を見逃さず、禁止情報をログに残さない最小運用を定める。

## Decision

- 一次証跡は `event_log` と同意記録だけとし、保持は D-03 の `cohort.closed_at + 18 months` に従う。Supabase 運用ログは一次証跡に使わない。
- 運用ログは Supabase の契約プラン既定の保持のみとする。P0 では Log Drain、外部保管、第三者分析、第三者クラッシュ収集を導入しない。実効保持期間はプロジェクト作成時に確認し、runbook に記録する。
- アクティブなコホート中は、読み取り専用ヘルス確認を1時間ごとに実行する。毎日、migration、ACTIVE config、RELEASED core、権限とデータ整合性も確認する。
- 通知先はこの Codex タスクのプロダクトオーナーとする。外部通知チャネルは P0 に追加しない。
- 次のいずれかを一件でも検出したら、該当コホートを停止して調査し、解決と再検証まで再開しない: proof-critical command の 5xx、transaction/constraint failure、server authorization failure、state/event reconciliation mismatch、禁止フィールドのログ出力。
- 利用者起因の validation error または invalid transition は日次確認対象とし、単独では停止条件にしない。
- Edge Function の運用ログは allowlist のみを記録する: `request_id`、command name、status class、error code、config/policy version、server timestamp。email、phone、DOB、exact location、private reflection、secret、token、生リクエスト本文は記録しない。
- Calibration-1 の前に、合成失敗を一件発生させ、停止条件・通知・調査画面が禁止情報なしで機能することを確認する。1時間ごとの監視を実行できない状態ではコホートを開始しない。

## Consequences

- A11 は1時間ごとの読み取り専用チェック、日次runbook、停止条件、合成失敗ドリルを実装・検証する。
- Supabase のプロジェクト設定と監視APIへの読み取り専用認証情報が未設定の間は、コホートを開始できない。
- 長期の運用ログ調査や外部通知が必要になった場合は、新しいADRでデータ移転・保持期間・費用を決めてから追加する。

## Alternatives considered

### provider 運用ログを18か月の Product Proof とする

却下。保持期間がプラン依存であり、D-03 の保持契約を満たさない。

### P0 から Log Drain / Sentry / Datadog / S3 を導入する

却下。P0の小規模コホートに対し、追加の費用、データ移転、アクセス境界を増やす。

### 日次の手動確認だけにする

却下。proof-critical failure の検出が最大24時間遅れる。アクティブコホートでは1時間ごとの読み取り専用確認を必要とする。

## References

- `docs/decisions/0001-p0-runtime-binding.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/08_SECURITY_RELIABILITY_GUARDRAILS.md`
- https://supabase.com/docs/guides/observability/logs
- https://supabase.com/docs/guides/observability
