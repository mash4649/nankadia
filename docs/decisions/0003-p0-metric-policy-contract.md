# ADR-0003: P0 の計測・運用ポリシーを version 1 として固定する

## Status

Accepted

## Date

2026-09-12

## Context

P0 の計測、入場、推薦、Seed release は、未決のまま実装するとコホート間の比較ができない。D-01〜D-05 で個別に承認した値と境界を、実装が参照する一つの版付き契約へ統合する。

この契約の material change は、既存の active config を書き換えず、新しい policy version、config、cohort を作成して適用する。

## Decision

### 計測分母と最初の対象Moment

- Qualifying User は ACTIVE config に紐づく proof_enrollment を持つ利用者である。
- First Qualifying Moment は `cohort_entered_at` 以後にサーバーが受理した最初の `explicitly_started` Moment である。
- 分母から除けるのは、append-only `measurement_exclusion` の `technical_only=true` だけである。Skip、No Match、BAD、no-action、Baseline Keep、scope expansion は除外しない。
- 対象Momentの順序はサーバー時刻で決め、D14 は既存のローカル日付規則を使う。

### 実行開始と結果

- 現実の行動を始めた後の明示的な利用者申告だけが `start_execution` を呼び、`ACCEPTED` から `STARTED` へ遷移させる。
- recommendation acceptance と external open は開始を意味しない。URLや経過時間から開始を推測しない。
- 開始申告の許可済み method/UI version、サーバー時刻、idempotency を記録する。開始済み記録は削除せず、必要なら `ABORTED` を追記する。
- GAL の開始証跡は、このサーバー遷移だけである。

### 入場と保持

- 日本P0の対象は、18歳以上を自己申告した利用者に限る。DOB、email、phone、exact location は収集しない。
- Proof enrollment の前に、`adult_attested_at`、privacy-notice version/timestamp、proof-consent version/timestamp を不変記録する。
- Proof event と consent evidence は `cohort.closed_at + 18 months` まで保持し、その後は利用者を再識別できない集計だけを残す。withdrawal 後は将来の収集・参加を止め、既受理記録はこの期間保持する。
- 匿名IDを失っても fingerprinting・推測リンク・復元を行わない。新しいIDは以前のProof分母に戻らない。

### 初期推薦・診断ポリシー

- `max_cards_per_moment=3`。
- optional Skip reason は Skip の25%で表示し、無回答を選べる。
- Calibration 中の completed execution では、optional discovery question を1問、100%で表示する。
- context は30分経過または利用者による明示 correction で再確認する。
- Fit Receipt は毎回、粗い理由を1〜3件示す。
- Skip と discovery は診断専用で、primary outcome を変えない。

### Seed release gate

- Human GO は30件以上。
- 各 Bootstrap Archetype の CORE は3件以上、各 Archetype Semantic Cluster も3件以上。
- Weighted Bootstrap Coverage は80%以上、unresolved REVIEW は0、metadata/hash は完全であること。
- synthetic fixture は5つの Moment Mode のうち少なくとも4つと、meal/rest case を含む。
- detour は数値化せず、NONE は現位置・計画をほぼ変えない、SMALL は小さな寄り道または予定調整、OPEN は寄り道量が主制約ではない、とする。

## Consequences

- 初期値と計算は versioned policy/config から解決し、runtime code に未版管理の定数を置かない。
- この契約を変える場合、既存 cohort の比較を継続せず、新しい policy/config/cohort を作成する。
- A1、A6、A9、A10 はこのADRをテストの期待値として参照する。

## References

- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/02_SLICE_A_IMPLEMENTATION_SOT_v2.0.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/03_CONTEXT_AND_RECOMMENDATION_POLICY.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/04_EVENT_AND_MEASUREMENT_CONTRACT.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/06_SEED_CORE_MIGRATION_CONTRACT.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/09_DEFERRED_AND_PROVISIONAL_REGISTER.md`
- `docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/12_API_COMMAND_CONTRACT.md`
