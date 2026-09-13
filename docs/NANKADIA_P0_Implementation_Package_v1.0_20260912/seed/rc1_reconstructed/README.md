# RC1再構成候補（2026-09-13受領）

`rc1_reconstructed_source_20260913.txt` は、ユーザー提供のRC1再構成資料を内容変更なしで保存した証拠ファイルです。

## 現時点の扱い

- CORE候補36件とPARK候補4件の本文・G3・Discovery・PARK理由を、受領資料の記載どおりに保持する。
- `human_decision` は、ユーザーの今回の一括指示により、明示変更または未記載のCORE候補を **GO** とした。SC-011・SC-027・SC-031は「別のものにして」の代替案確認待ちで **PENDING**。受領資料の「RC1候補」判定をHuman Reviewの承認結果へ読み替えない。
- 受領資料にないtrajectory / detour / immediate need / resource / safety metadataは補完しない。既存CSVの `REVIEW_REQUIRED` を維持する。
- exactな `resolutions.jsonl` 文字列、原本ハッシュ、個別レビュアー・日時は未確認事項として残す。

## 機械検証

```bash
python3 tools/verify_rc1_reconstruction.py
```

検証内容は、CORE 36件のID集合、PARK 4件のID集合、重複の有無のみです。Human Reviewの代替ではありません。
