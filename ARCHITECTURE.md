# アーキテクチャマッピング: aidev-Antigravity

本ドキュメントでは、`aidev` の構成ファイル群が、Antigravity Geminiの「エンタープライズ・エージェント・オーケストレーション」とどのようにマッピングされ、動作しているかを解説します。

## 1. 概念マッピング (Conceptual Mapping)

| aidev File / Dir | Antigravity Feature | 役割・機能 |
| :--- | :--- | :--- |
| `.agent_config/` | **ミッションコントロール (Mission Control)** | エージェントチームの共有知識ベース (`task.md`, `project_status.md`)。コンテキストの断絶を防ぎ、プロジェクト全体の状態を管理する**司令塔**として機能します。<br><br>**行動規範**: `pm_manifesto.md` に従い、PMは決してコードを書かず、一問一答の原則を遵守します。 |
| `roles.md` | **エージェントペルソナ (Agent Personas)** | 各エージェントの専門性、権限、および使用可能なツールセット（スキル）を定義します。ADK（Agent Development Kit）的な厳密な定義への移行を目指します。 |
| `workflow.md` | **ワークフローと並列化 (Workflow & Parallelism)** | エージェントがタスクを実行する際の**並列実行可能な**手順書。Antigravityはこれを参照し、依存関係のないタスク（例：バックエンド実装とフロントエンド実装）を同時に進行させます。 |
| `templates/` | **構造化成果物 (Structured Artifacts)** | エージェントが生成する成果物の厳格なフォーマット。自由記述による品質のばらつきを防ぎ、後続のエージェント（例：QA）が機械的に検証可能な状態を保証します。 |
| `.agent/skills/` | **実行可能スキル (Executable Skills)** | （新設）特定のタスク（例：ブラウザ検証、セキュリティスキャン）を実行するための具体的な手順とツールチェーンの定義。 |

## 2. ツール機能マッピング (Tool Mapping)

各役割のエージェントは、以下のAntigravityツール（ネイティブ機能）を主に使用するように設計されています。

### 2-1. 分析と計画 (Mission Control)
*   **PM / アーキテクト**
    *   `task_boundary`: **必須**。詳細なタスク分割とステータス管理。これがプロジェクトの進行状況の唯一の正解となります。
    *   `search_web`: 最新技術動向やライブラリの調査。
    *   `codebase_search` / `grep_search`: 既存コードベースの仕様調査。

### 2-2. 実装 (Parallel Workers)
*   **コーダー (バックエンド / フロントエンド)**
    *   `view_file`: 設計書や既存コードの読み込み。
    *   `write_to_file` / `replace_file_content`: ファイルの新規作成・編集。
    *   `run_command`: Linter/Formatterの実行、ビルド確認。

### 2-3. 検証と運用 (Quality Gate)
*   **QA / UIUX**
    *   `browser_subagent`: **必須 (厳格検証)**。実際のChromeを起動し、ユーザーフロー（ログイン、クリック、遷移）を再現・録画し、**視覚的な証拠**として残します。
    *   `generate_image`: UIモックアップやアイコン生成。
*   **DevOps / セキュリティ**
    *   `run_command`: Dockerコマンド実行、セキュリティスキャンツールの実行。
    *   `read_terminal`: 長時間実行されるプロセスの出力監視。

## 3. ワークフローの流れ (Execution Flow: Enterprise Model)

1.  **指示 (Mission Start)**: ユーザーが PM に指示。PMは `task.md` を初期化。
2.  **ルーティングと並列化**: PM がワークフローを分析し、**並列実行可能なタスク**（例：BE設計とFE設計）に分解。
3.  **実行 (Sub-agents)**: 各専門エージェントが `.agent/skills/` で定義されたスキルを用いて実装を行う。
4.  **検証 (Quality Gate)**:
    *   **自動テスト**: Linter / Unit Test (run_command)。
    *   **視覚的検証**: Browser Agent が E2E シナリオを実行し、スクリーンショット/動画を記録。
5.  **レビュー (Human-in-the-Loop)**: ユーザーはコードだけでなく、**検証動画**を確認して承認を行う。
6.  **次ステップ**: 全ての承認が完了次第、次のフェーズへ移行。

---
このアーキテクチャにより、Antigravity Geminiは単なるチャットボットではなく、**「並列処理と自律検証を行うエンタープライズ開発チーム」** として機能します。
