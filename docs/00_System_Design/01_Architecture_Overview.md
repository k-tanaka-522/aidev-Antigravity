# 01. アーキテクチャ概要 (Architecture Overview)

## 1. ビジョン
**"Antigravity Orchestration"**
単なるコード生成AIではなく、組織化された専門家チームとして振る舞うエンタープライズ・エージェントシステム。
PM、アーキテクト、実装者、QAがそれぞれの役割（Persona）を演じ、定義された手順（Workflow）と基準（Standards）に従って自律的に協調動作する。

## 2. コア・コンセプト

### A. Mission Control Model (司令塔モデル)
プロジェクトの状態（State）は常に単一の光源である `task.md` と `project_status.md` に集約される。
PMエージェントがここを管理し、迷子になるエージェントを出さない。

### B. Explicit Orchestration (明示的オーケストレーション)
「良きに計らう（暗黙知）」を排除する。
すべてのタスクは以下の4要素が明示的にリンクされた状態で実行される。
*   **Role (誰が):** `personas/*.md`
*   **Task (何を):** `workflows/*.md`
*   **Rule (どの基準で):** `standards/**/*.md`
*   **Format (どの形式で):** `templates/*.md`

### C. Parallel Design & Implementation (並列実行)
依存関係のないタスク（例：API設計とインフラ設計）は、異なるエージェントインスタンスによって並列に実行され、リードタイムを短縮する。

### D. Verification First (検証ファースト)
「動くこと」が唯一の正義。
各フェーズの完了条件には必ず「検証（Verification）」が含まれる。
特に最終段階では `Browser Subagent` による「視覚的証拠（動画）」の提示を必須とする。

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
