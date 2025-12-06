# aidev-antigravity (PMBOK-Compliant Agent Team Core)

**PMを司令塔とする9名の自律エージェントチーム（自己進化型）** の構成定義リポジトリです。
PMBOK（Project Management Body of Knowledge）に準拠した堅牢な開発プロセスを、あなたのプロジェクトに即座にインストールします。

## 特徴 (Features)

*   **PMBOK準拠のSDLC**: 要件定義から設計、実装、テスト、運用まで、全工程をカバーする標準プロセス。
*   **詳細設計の徹底**: 内部設計フェーズを標準化し、手戻りを防ぐ高品質な開発フロー。
*   **完全日本語対応**: プロセス定義からドキュメントテンプレートまで、全て日本語環境に最適化。
*   **Antigravity Native**: Antigravity Geminiの強力なツール群（Browser Subagent, Shell Command）を前提とした役割定義。
*   **自己進化 (Kaizen)**: プロジェクト終了ごとにCKOがプロセスを改善し、チームが賢くなる仕組み。

## クイックスタート (Quick Start)

### パターンA: 新規プロジェクトとして開始
このリポジトリをテンプレートとして、新しいプロジェクトを開始する場合の手順です。

```bash
# 1. リポジトリをクローン
git clone https://github.com/k-tanaka-522/aidev-antigravity.git my-project
cd my-project

# 2. 新規プロジェクト初期化スクリプトを実行（重要！）
# Windows
scripts\init-new-project.bat

# Mac/Linux
./scripts/init-new-project.sh

# 3. エディタで開く
code .
```

**重要**: `init-new-project` を実行することで、Git履歴がリセットされ、クリーンな状態で開発をスタートできます。

---

### パターンB: 既存プロジェクトに追加
すでに進行中のプロジェクトに、Antigravityチームを招聘する場合の手順です。

```bash
# Windows (PowerShell)
cd your-existing-project
git clone https://github.com/k-tanaka-522/aidev-antigravity.git .antigravity-temp
Copy-Item -Path ".\.antigravity-temp\.agent_config" -Destination "." -Recurse
Copy-Item -Path ".\.antigravity-temp\PROJECT_STRUCTURE.md" -Destination "."
Remove-Item -Path ".\.antigravity-temp" -Recurse -Force
```

---

## チーム構成 (The Team)

「エージェンティック・モード」をONにし、PMエージェントに指示を出してください。

1.  **PM (Project Manager)**: 統合管理。全ての司令塔。
2.  **Consultant**: 要件定義。スコープ管理。
3.  **Architect**: システム基本設計。
4.  **Coder**: 詳細設計および実装。
5.  **QA**: テスト計画・実行（Browserテスト対応）。
6.  **Security**: セキュリティ監査。
7.  **UI/UX**: デザイン・ユーザビリティ評価。
8.  **DevOps**: インフラ・運用マニュアル作成。
9.  **CKO**: プロセス改善（Kaizen）。

## エージェント・オーケストレーション (Agent Orchestration)

本チームは、**PMを中心としたスター型トポロジー**と、**ドキュメント駆動のリレー型ワークフロー**を組み合わせて自律的に動作します。

### 1. 司令塔 (Hub): Project Manager
あなた（ユーザー）が直接会話するのは**PMエージェントのみ**です。
PMはユーザーの抽象的な要望を具体的なタスクに分解し、最適な専門エージェント（Spoke）を選択してプロンプト（指示）を発行します。これにより、ユーザーは個々のエージェントをマイクロマネジメントする手間から解放されます。

### 2. 専門家 (Spokes): Specialists
Consultant, Architect, Coderなどの各エージェントは、PMからの指示に従って自律的に作業を行います。
彼ら同士が直接会話することはありません。全ての成果と報告は一度PMに集約され、PMが品質をチェックした上で次の工程のエージェントに渡されます。

### 3. ドキュメント指向 (Artifact-Driven)
エージェント間の連携は、「会話」ではなく**「成果物（Markdownファイル）」**を介して行われます。
*   Architectが書いた `04_基本設計書` を正として、Coderがコードを書く。
*   Coderが書いたコードを正として、QAがテストする。
これにより、AI特有の「幻覚（Hallucination）」や「文脈の喪失」を防ぎ、大規模プロジェクトでも整合性を維持し続けます。

## 使い方 (Detailed Usage)

### 1. プロジェクトの開始 (Initiation)
まず、エージェント（PM）に**「プロジェクトを開始したい」**と伝えてください。
PMは `01_プロジェクトマネジメント計画書テンプレート.md` を作成し、あなた（ユーザー）にプロジェクトのゴール、予算、納期などの制約条件をヒアリングします。

### 2. 要件定義と基本設計 (Planning & Design)
計画が承認されると、ConsultantとArchitectが動き出します。
*   **要件定義**: Consultantがあなたの要望を深掘りし、`02_要件定義書テンプレート.md` を作成します。
*   **基本設計**: Architectがシステム構成を決定し、`04_基本設計書テンプレート.md` を作成します。

**【重要】**: ここでしっかりレビューを行い、不明点は質問してください。

### 3. 詳細設計と実装 (Detailed Design & Implementation)
ここが品質担保の肝となるフェーズです。
*   **詳細設計**: Coderが `05_詳細設計書テンプレート.md` を記述します。これは「実装する前に書く」ことで、論理的な誤りを未然に防ぎます。
*   **実装**: 詳細設計書が承認された後、Coderが実際にコードを書きます。

### 4. 検証 (Verification)
QAエージェントやSecurityエージェントが、実装されたコードを監査します。
*   **テスト**: `06_テスト計画書テンプレート.md` に基づき、QAがブラウザ等を操作してテストを行います。
*   **セキュリティ**: Securityエージェントが脆弱性診断を行います。

### 5. 自己進化 (Kaizen)
全ての作業が完了したら、CKOエージェントが**「今回のプロジェクトの教訓」**をまとめます。
テンプレートの使いにくかった点や、プロセスの無駄を洗い出し、`.agent_config` をアップデートします。これを次回のプロジェクトに引き継ぐことで、チームはどんどん賢くなります。

```bash
# Kaizen結果の反映コマンド (例)
cp -r .agent_config ../aidev-antigravity/
cd ../aidev-antigravity
git add .
git commit -m "Kaizen: Update from Project X"
```
