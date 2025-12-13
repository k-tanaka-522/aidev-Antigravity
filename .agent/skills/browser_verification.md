# スキル: ブラウザ検証 (Browser Verification)

## 概要 (Overview)
`browser_subagent` を使用して、Webアプリケーションの動作を視覚的かつ機能的に検証するための標準手順です。
単なるHTML解析ではなく、実際のユーザー操作（クリック、入力、スクロール）をシミュレートし、その結果を「証拠」として記録します。

## 適用条件 (Trigger)
*   UI/UXに変更を加えた場合。
*   新しい画面や機能を実装した場合。
*   「E2Eテスト」タスクまたは「視覚的チェック」タスクが割り当てられた場合。

## 必要な入力 (Inputs)
1.  **対象URL**: テスト対象のURL (例: `http://localhost:3000/login`)
2.  **シナリオ**: 検証するユーザーフローの箇条書き (例: ログイン -> ダッシュボード確認 -> ログアウト)
3.  **期待される結果**: 期待される結果 (例: "Welcome" メッセージが表示されること)

## 実行手順 (Execution Steps)

1.  **環境準備 (Prepare Environment)**:
    *   サーバーが起動していることを `run_command` (curl等) で確認する。
    *   起動していない場合は `npm run dev` 等でバックグラウンド起動する。

2.  **Browser Agentの起動**:
    *   `browser_subagent` ツールを呼び出す。
    *   **タスク名**: `Verifying [Feature Name]`
    *   **タスク**: シナリオに基づいた具体的な操作指示を与える。
        *   "Navigate to [URL]" (URLへ移動)
        *   "Type [username] into #email" (Emailを入力)
        *   "Click [Login Button]" (ボタンをクリック)
        *   "Wait for navigation" (遷移を待機)
        *   "Verify text 'Dashboard' exists" (テキストの存在を確認)

3.  **証拠の記録 (Record Evidence)**:
    *   ブラウザ操作は自動的に録画されるが、重要な検証ポイントでは明示的にスクリーンショットを撮るよう指示することもある。

4.  **結果分析 (Analyze Result)**:
    *   エージェントの実行ログを確認し、すべてのステップが成功したか判断する。
    *   失敗した場合は、エラーメッセージとスクリーンショット（あれば）を分析する。

## 成果物 (Outputs)
*   **検証ログ (Verification Log)**: 実行したステップと結果のテキスト記録。
*   **視覚的証拠 (Visual Proof)**: (システム生成) ブラウザ操作の録画ビデオアーティファクト。

## トラブルシューティング (Error Handling)
*   **タイムアウト**: 要素が見つからない場合、セレクタが正しいか、非同期読み込みが完了しているか確認する。
*   **サーバーエラー**: ブラウザ画面に 500 エラーが出ている場合、サーバーログ (`read_terminal`) を確認する。
