# Enterprise AI Orchestration (aidev-Antigravity)

**Advanced Agentic Coding** チームによって設計された、Antigravity Gemini ネイティブな**エンタープライズ対応AIオーケストレーションシステム**へようこそ。

本リポジトリは、PMBOK/IEEE標準に準拠した堅牢な開発プロセスと、Antigravity の強力なエージェント機能（Mission Control, Browser Subagent, Parallel Execution）を組み合わせ、高品質なソフトウェア開発を自律的に遂行するAIエージェントチームを提供します。

---

## 🚀 特徴 (Core Features)

### 1. ミッションコントロール (Mission Control Architecture)
従来のチャットボット形式ではなく、**中央集権的な状態管理**を行います。
PMエージェントが「ミッションコントロール」として機能し、プロジェクト全体の状態（`task.md`）とコンテキストを管理しながら、専門エージェントを動的に指揮します。

### 2. 並列実行トラック (Parallel Execution Tracks)
開発フェーズを細分化し、依存関係のないタスクを並列で実行します。
*   **アプリ設計トラック**: アプリケーションアーキテクトによるAPI/コンポーネント設計
*   **インフラ設計トラック**: インフラアーキテクトによるクラウド構成/IaC設計
*   **デザイン設計トラック**: デザイナーによるUI/UXプロトタイピング
これらが同時並行で進むことで、開発速度が飛躍的に向上します。

### 3. "Trust but Verify" (信頼せよ、されど検証せよ)
AIが生成したコードや機能を鵜呑みにしません。
*   **Browser Subagent**: QAエージェントが実際のブラウザを操作し、ユーザーフローを**録画・検証**します。
*   **静的解析**: IaCやコードは厳格なLinter/Policyチェックを通過する必要があります。
*   **承認ゲート**: 重要なマイルストーン（設計完了、リリース）では、必ず「証拠（動画/ログ）」を提示して人間の承認を求めます。

### 4. 包括的な技術標準 (Comprehensive Standards)
エンタープライズレベルの品質を担保するための詳細な技術標準を同梱しています。
*   **言語/FW**: Go, Python, TypeScript, C#, Flutter, React/Next.js
*   **インフラ**: AWS, CloudFormation, Terraform, CI/CD, Testing
*   **共通**: セキュリティ, API設計, DB設計

---

## 👥 エージェントチーム (The Team)

各エージェントは、 `.agent/personas/` に定義された役割と特定のツールセットを持っています。

| エージェント | 役割 | 主なツール |
|------------|------|------------|
| **PM (Mission Control)** | プロジェクト指揮、タスク管理、ユーザー合意形成 | `task_boundary`, `notify_user` |
| **System Consultant** | 要件定義、ビジネス分析 | `search_web`, `read_url_content` |
| **App Architect** | アプリ詳細設計、API/DB設計 | `view_file`, `grep_search` |
| **Infra Architect** | インフラ設計、ネットワーク構成 | `view_file`, `search_web` |
| **Designer** | UI/UX設計、デザインシステム構築 | `generate_image`, `view_file` |
| **Coder** | 実装、単体テスト | `write_to_file`, `run_command` |
| **QA** | テスト計画、ブラウザ検証 (E2E) | `browser_subagent` |
| **Security** | セキュリティ監査、リスク評価 | `grep_search` |
| **SRE** | デプロイ、運用設計、IaC実装 | `run_command`, `write_to_file` |

---

## 📂 ディレクトリ構造 (Structure)

本リポジトリは、**自己完結型のエージェント脳**として機能するように構成されています。

```
aidev-Antigravity/
├── .agent/                      # エージェントのコア知識ベース
│   ├── guides/                  # 行動指針 (PM Manifesto等)
│   ├── personas/                # 各エージェントの役割定義
│   ├── skills/                  # 特定タスクのスキル定義 (Browser Verification等)
│   ├── standards/               # 技術標準ドキュメント
│   │   ├── tech/                # 技術スタック別標準 (App, Infra, Common)
│   │   └── verification_protocol.md # 検証プロトコル
│   ├── templates/               # ドキュメントテンプレート
│   └── workflows/               # 開発プロセス定義 (full_dev_process_ja.md)
│
├── ARCHITECTURE.md              # システム全体のアーキテクチャ概要
└── scripts/                     # ユーティリティスクリプト
```

---

## 🚦 使い方 (Getting Started)

### 1. プロジェクトの開始
Antigravity Agent モードで、以下のように指示してください。

> 「新規開発プロジェクトを開始したい。PMエージェントとして計画を立てて。」

### 2. フェーズ進行
PMエージェントが `.agent/workflows/full_dev_process_ja.md` に基づいてプロセスを進行します。

1.  **Planning**: 要件定義とプロジェクト計画策定
2.  **Design**: アプリ/インフラ/デザインの並列設計
3.  **Implementation**: コード実装
4.  **Verification**: ブラウザ検証と品質チェック
5.  **Release**: 本番デプロイ

### 3. ユーザーの役割
あなたは**ステークホルダー（決定権者）**です。
PMからの「計画確認依頼」やQAからの「リリース承認依頼」に対して、Go/No-Go の判断を下してください。
コードの細かい修正指示よりも、ビジネス要件やゴールの提示に注力してください。

---

## ⚠️ 注意事項

このプロジェクトは **Google Deepmind Advanced Agentic Coding** チームによって設計された実験的なオーケストレーションシステムです。
`aiDev` ディレクトリ（旧システム）は参照用であり、**読み取り専用**です。すべての作業は `aidev-Antigravity` 内で行われます。
