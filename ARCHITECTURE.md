# Architecture Mapping: aidev-Antigravity

本ドキュメントでは、`aidev` の構成ファイル群が、Antigravity Geminiの「エージェント機能」とどのようにマッピングされ、動作しているかを解説します。

## 1. 概念マッピング (Conceptual Mapping)

| aidev File / Dir | Antigravity Feature | 役割・機能 |
| :--- | :--- | :--- |
| `.agent_config/` | **Context Memory** | エージェントチームの共有知識ベース（脳）。会話履歴を超えて保持される長期記憶として機能します。 |
| `roles.md` | **System Instructions / Persona** | 各エージェントの振る舞い、権限、制約を定義するシステムプロンプトの基礎となります。<br>例: `PM` の定義は、PMエージェントがユーザーの指示をどう解釈し、誰に振るかを決定づけます。 |
| `workflow.md` | **SOP (Standard Operating Procedure)** | エージェントがタスクを実行する際の手順書。Antigravityはこれを参照して「次は誰が何をするべきか」を自律的に判断します。 |
| `templates/` | **Structured Output Schema** | エージェントが生成する成果物のフォーマット定義。自由記述による品質のばらつきを防ぎ、構造化されたデータを強制します。 |

## 2. ツール機能マッピング (Tool Mapping)

各役割のエージェントは、以下のAntigravityツール（ネイティブ機能）を主に使用するように設計されています。

### 2-1. Analysis & Planning
*   **PM / Consultant / Architect**
    *   `search_web`: 最新技術動向やライブラリの調査に使用。
    *   `codebase_search` / `grep_search`: 既存コードベースの仕様調査に使用。
    *   `task_boundary`: タスクの区切り管理、コンテキストの整理に使用。

### 2-2. Implementation
*   **Coder**
    *   `view_file`: 設計書や既存コードの読み込み。
    *   `write_to_file` / `replace_file_content`: ファイルの新規作成・編集。
    *   `run_command`: Linter/Formatterの実行、ビルド確認。

### 2-3. Verification & Operations
*   **QA / UIUX**
    *   `browser_subagent`: **ブラウザ操作の自動化**。実際のChromeを起動し、クリックや入力を行ってE2EテストやUI確認を行う強力な機能です。
    *   `generate_image`: UIモックアップやアイコン生成に使用可能。
*   **DevOps / Security**
    *   `run_command`: Dockerコマンド実行、セキュリティスキャンツールの実行。
    *   `read_terminal`: 長時間実行されるプロセスの出力監視。

## 3. ワークフローの流れ (Execution Flow)

1.  **Instruction**: ユーザーが PM に指示（自然言語）。
2.  **Routing**: PM が `workflow.md` を参照し、現在のフェーズ（例: 要件定義）を特定。担当エージェント（Consultant）を呼び出す。
3.  **Generation**: Consultant が `roles.md` のペルソナに従い、`templates/02_要件定義書...` のフォーマットで成果物を生成 (`write_to_file`)。
4.  **Review**: PM が生成されたファイルを読み込み (`view_file`)、ユーザーの指示と矛盾がないかチェック。
5.  **Next Step**: OKなら次のフェーズのエージェントへバトンタッチ。

---
このアーキテクチャにより、Antigravity Geminiは単なるチャットボットではなく、**「定義されたプロセスに従ってツールを使いこなす自律型チーム」** として機能します。
