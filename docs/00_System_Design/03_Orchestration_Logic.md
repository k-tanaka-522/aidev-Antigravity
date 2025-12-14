# 03. オーケストレーション・ロジック (Orchestration Logic)

## 1. 動作原理: The Chain of Command (指揮系統)

Antigravityエージェントは、以下の連鎖反応（Chain）によって、曖昧な指示を具体的な成果物に変換する。

`Workflow (指示書)` -> `Persona (誰が)` -> `Standard (基準)` + `Template (型)` -> `Artifact (成果物)`

### ステップ詳細

1.  **Trigger (指示)**
    *   ユーザー: 「フェーズ1を開始して」
    *   PM: `workflows/full_dev_process_ja.md` をロードし、現在地を特定する。

2.  **Context Loading (役割定義の読み込み)**
    *   PM: 「次は要件定義だ。担当はコンサルタントだな」
    *   System: `workflows` に記述されたパス `personas/consultant.md` を読み込む。
    *   Agent: **System Consultant** にモードを切り替える。

3.  **Constraint Loading (制約事項の適用)**
    *   Consultant: 「作業を開始する。ルールとフォーマットは？」
    *   System: `workflows` に記述された `standards/tech/app/*` と `templates/02_requirements.md` を読み込む。
    *   Agent: これら以外のアウトプットを**禁止**された状態で思考する。

4.  **Execution (実行)**
    *   Consultant: ユーザーと対話し、テンプレートの空欄を埋める。
    *   Consultant: 書いた内容が標準（Standards）に違反していないか自己チェックする。

5.  **Handoff (引継ぎ)**
    *   Consultant: 「完了しました」
    *   PM: 成果物を確認し、次のステップ（1.2 計画策定）へ進む。

## 2. 重要な「遵守事項」 (Constraints)

オーケストレーションを機能させるための絶対ルール。

1.  **Direct Path Reference (絶対パス参照)**
    *   ワークフローファイルには、必ずペルソナ、標準、テンプレートの**ファイルパス**を明記しなければならない。「一任する（良きに計らう）」は禁止。

2.  **Explicit N/A (明示的除外)**
    *   テンプレートの項目を埋められない場合、勝手に削除せず `N/A` と記載し理由を書くこと。

3.  **Cross-Review Gate (クロスレビュー・ゲート)**
    *   次のフェーズに進むトリガーは、単なる「作業完了報告」ではなく、検証エビデンス（ログ/動画）に基づいた「クロスレビューの承認」でなければならない。
