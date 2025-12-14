# 01. アーキテクチャ概要 (Architecture Overview)

## 1. ビジョン
**"Antigravity Orchestration"**
単なるコード生成AIではなく、組織化された専門家チームとして振る舞うエンタープライズ・エージェントシステム。
PM、アーキテクト、実装者、QAがそれぞれの役割（Persona）を担い、定義された手順（Workflow）と基準（Standards）に従って自律的に協調動作する。

## 2. コア・コンセプト

### A. Mission Control Model (司令塔モデル)
プロジェクトの進捗や状態（State）は、常に**唯一の正解情報源 (Single Source of Truth)** である `task.md` と `project_status.md` に集約・管理される。
PMエージェントがここを統括し、プロジェクト全体の状況を正確に把握する。

### B. Explicit Orchestration (明示的オーケストレーション)
「暗黙的な判断（良きに計らう）」を排除し、プロセスを標準化する。
すべてのタスクは以下の4要素が明示的にリンクされた状態で実行される。
*   **Role (誰が):** `personas/*.md`
*   **Task (何を):** `workflows/*.md`
*   **Rule (どの基準で):** `standards/**/*.md`
*   **Format (どの形式で):** `templates/*.md`

### C. Parallel Design & Implementation (並並行開発)
依存関係のないタスク（例：API設計とインフラ設計）は、異なるエージェントインスタンスによって並行して実行され、リードタイムを短縮する。

### D. Evidence-based Review (エビデンスに基づくクロスレビュー)
「動作するソフトウェア」を最優先事項とする。
各フェーズの完了条件には必ず「クロスレビュー (Cross-Review)」が含まれる。
レビューの際は、成果物そのものに加え、`Browser Subagent` 等による「動作検証エビデンス（動画/ログ）」の提示を必須とする。

## 3. システム構成図

```mermaid
graph TD
    User((User)) <-->|Order & Approval| MissionControl[Mission Control (PM)]
    
    subgraph Brain [System Knowledge (.agent)]
        Workflows[Workflows]
        Personas[Personas]
        Standards[Standards]
        Templates[Templates]
    end
    
    MissionControl -->|Orchestrate| Brain
    
    subgraph Agents [Specialist Agents]
        Con[Consultant]
        Arch[Architect]
        Dev[Coder]
        QA[QA / Tester]
    end
    
    MissionControl -->|Dispatch Task| Agents
    Brain -.->|Reference| Agents
    
    Agents -->|Create| Artifacts[Outputs (docs/, src/)]
    QA -->|Verify| Artifacts
```
