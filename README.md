# Antigravity - IPA準拠SDLC支援システム

IPA Common Frame 2013に準拠した、要件定義から詳細設計までを**AIオーケストレーター**が支援するシステムです。

---

## 🤖 基本動作原則（重要）

Antigravityは、従来の「質問に答えるAI」ではなく、**システム開発プロジェクトのAIファシリテーター**として動作します。

### 1. 提案型オーケストレーション

**ワークフローを提案し、ユーザーの承認を得てから実行**します。

```
❌ 勝手に実行: 「要件定義書を作成しました」
✅ 提案と確認: 「📍 現在位置：【要件定義フェーズ】
                → /requirements を実行しますか？」
```

### 2. 一問一答形式の質問

ユーザーを疲れさせないよう、**1つの質問に対して回答を待ってから次の質問**をします。

```
✅ 良い例（一問一答）:
AI: 「どのような課題を解決したいですか？」
ユーザー: 「在庫管理が手作業で大変です」
AI: 「対象となる商品の種類はどのくらいありますか？」
ユーザー: 「約500種類です」
AI: 「在庫確認の頻度はどのくらいですか？」

❌ 避けるべき例（質問の羅列）:
AI: 「以下について教えてください。
1. どのような課題がありますか？
2. 対象商品の種類は？
3. 在庫確認の頻度は？
4. 現在のシステムは？
5. 予算は？」
```

### 3. フェーズ認識

会話の内容から現在の開発フェーズを推定し、**常にフェーズを意識した応答**を行います。

| フェーズ | トリガーワード | 提案するワークフロー |
|---------|--------------|-------------------|
| 企画 | 新規、作りたい、構想、予算、ROI | `/planning` |
| 要件定義 | 機能、要件、ユースケース、〜できる | `/requirements` |
| 基本設計 | アーキテクチャ、構成、設計、インフラ | `/basic-design` |
| 詳細設計 | クラス、API、DB設計、実装方法 | `/detailed-design` |
| 製造 | 実装、コーディング、開発、コード | `/implementation` |
| 試験 | テスト、検証、バグ、品質 | `/testing` |
| リリース | デプロイ、本番、移行、公開 | `/release` |
| 保守運用 | 運用、監視、障害、保守 | `/maintenance` |

### 4. 成果物駆動

各フェーズで**IPA標準に準拠した成果物**を `/docs/` 配下に生成します。

詳細: [GEMINI.md](GEMINI.md)

---

## 📖 システムドキュメント（重要）

**このプロジェクトは、システム開発プロセス（SDLC）をAIエージェントで自動オーケストレーションするシステムです。**

ワークフロー・テンプレート・ナレッジベースがどのように連携してIPA準拠の成果物を生成するか、詳細は以下をご覧ください：

| ドキュメント | 内容 |
|------------|------|
| **[docs/README.md](docs/README.md)** | 📘 **システム全体の概要**<br>- AIオーケストレーションの仕組み<br>- 3層アーキテクチャの説明<br>- ワークフロー・テンプレート・ナレッジの関係 |
| **[docs/architecture.md](docs/architecture.md)** | 🏗️ **アーキテクチャ詳細**<br>- Layer 1: オーケストレーション層<br>- Layer 2: ワークフロー実行層<br>- Layer 3: テンプレート層とナレッジ層 |
| **[docs/agent-workflow-matrix.md](docs/agent-workflow-matrix.md)** | 📊 **完全マトリクス**<br>- 6種類のエージェント詳細<br>- エージェント×ワークフロー×テンプレート×ナレッジの対応表<br>- 依存関係とフロー |

**セッションをまたいでもシステムを理解できるよう、必ず上記ドキュメントを参照してください。**

---

## 🎯 特徴

- ✅ **IPA Common Frame 2013完全準拠**: 要件定義（RD001-007）、基本設計（BD001-009）、詳細設計（DD001-004, DD-INF001/002）
- ✅ **大規模システム対応**: 文書分割ガイドラインにより、100クラス超のシステムにも対応
- ✅ **チーム分離サポート**: アプリチーム/インフラチームの並行作業を完全サポート
- ✅ **IaC設計テンプレート**: Terraform/CloudFormationの軽量設計書テンプレート（設計判断重視、パラメーター一覧不要）
- ✅ **Best Practices統合**: AWS、セキュリティ、DB、UI/UXなど11種類のベストプラクティス
- ✅ **柔軟な質問生成**: 状況に応じて5-10個の質問に絞り、ユーザー負担を軽減

---

## 📦 構成

```
Antigravity/
├── GEMINI.md                        # ⭐ AIオーケストレーターの動作原則（必読）
├── README.md                        # 本ファイル（使い方ガイド）
│
├── docs/                            # 📖 システムドキュメント（重要）
│   ├── README.md                   # AIオーケストレーション概要
│   ├── architecture.md             # 3層アーキテクチャ詳細
│   └── agent-workflow-matrix.md    # エージェント×ワークフロー×テンプレート×ナレッジ マトリクス
│
└── .agent/                          # SDLC支援システム本体
    ├── agents.json                 # 6種類のエージェント定義
    ├── README.md                   # システム詳細ドキュメント
    ├── knowledge/                  # ナレッジベース（47ファイル）
    │   ├── documentation/         # IPA標準、スケーリング、チーム分離
    │   ├── workflows/             # 質問ガイダンス
    │   ├── architecture/          # アーキテクチャパターン
    │   ├── application/           # アプリ設計パターン
    │   ├── database/              # DB設計パターン
    │   ├── iac/                   # Terraform/CloudFormation
    │   ├── security/              # セキュリティ
    │   ├── testing/               # テスト
    │   └── ui-ux/                 # UI/UXパターン
    ├── templates/                  # IPA準拠テンプレート
    │   ├── 01_要件定義/           # RD001-007
    │   ├── 02_基本設計/           # BD001-009
    │   └── 04_詳細設計/           # DD001-004, DD-INF001/002
    └── workflows/                  # ワークフロー定義
        └── sdlc-master-workflow.md
```

---

## 🚀 使い方

### 1. このリポジトリをclone

```bash
git clone https://github.com/k-tanaka-522/aidev-Antigravity.git
cd Antigravity
```

### 2. 自分のプロジェクトに.agentディレクトリをコピー

```bash
# 自分のプロジェクトディレクトリに移動
cd /path/to/your-project

# .agentディレクトリをコピー
cp -r /path/to/Antigravity/.agent .

# 確認
ls .agent
# → agents.json, knowledge/, templates/, workflows/
```

### 3. エージェントを実行

#### パターンA: ゼロから完全SDLC（要件定義→基本設計→詳細設計）

```bash
# 1. 要件定義
claude-agent run requirements-analyst
# → 対話形式でヒアリング
# → RD001-RD007（要件定義書）を生成

# 2. 基本設計
claude-agent run system-architect
# → BD001-BD009（基本設計書）を生成

# 3. 詳細設計（アプリ）
claude-agent run detailed-designer-app
# → DD001-DD004（クラス設計、DB設計、API設計、テスト仕様）を生成

# 4. 詳細設計（インフラ）- 並行実行可能
claude-agent run detailed-designer-infra
# → DD-INF001/002（Terraform/CloudFormationスタック設計）を生成

# 5. 設計レビュー
claude-agent run design-reviewer
# → IPA準拠性、セキュリティ、パフォーマンス、コストをレビュー
```

#### パターンB: 既存の基本設計から詳細設計のみ

```bash
# 基本設計書（BD001-BD009）が既にある場合

# アプリチーム
claude-agent run detailed-designer-app --input .agent/templates/02_基本設計/実成果物/

# インフラチーム（同時実行可能）
claude-agent run detailed-designer-infra --input .agent/templates/02_基本設計/実成果物/
```

#### パターンC: 要件定義のみ

```bash
# 新規プロジェクトの要件定義、追加機能の要件定義など
claude-agent run requirements-analyst
```

---

## 📚 主要ドキュメント

| ドキュメント | 内容 |
|------------|------|
| [.agent/README.md](.agent/README.md) | システム全体の詳細説明 |
| [.agent/workflows/sdlc-master-workflow.md](.agent/workflows/sdlc-master-workflow.md) | マスターワークフロー（全体の流れ） |
| [.agent/knowledge/documentation/ipa-detailed-design-scaling.md](.agent/knowledge/documentation/ipa-detailed-design-scaling.md) | 大規模システム対応ガイド |
| [.agent/knowledge/documentation/team-separation-app-infra.md](.agent/knowledge/documentation/team-separation-app-infra.md) | アプリ/インフラチーム分離ガイド |

---

## 🎓 エージェント一覧

| エージェント | 役割 | 主要成果物 |
|------------|------|-----------|
| **requirements-analyst** | 要件定義アナリスト | RD001-RD007（要件定義書） |
| **system-architect** | システムアーキテクト | BD001-BD009（基本設計書） |
| **detailed-designer-app** | 詳細設計者（アプリ） | DD001-DD004（クラス設計、DB設計、API設計、テスト仕様） |
| **detailed-designer-infra** | 詳細設計者（インフラ） | DD-INF001/002（IaCスタック設計） |
| **documentation-assistant** | ドキュメント統括 | DD000（詳細設計総括） |
| **design-reviewer** | 設計レビュアー | レビューレポート |

詳細は [.agent/agents.json](.agent/agents.json) を参照してください。

---

## 📝 成果物の配置

エージェント実行後、以下のディレクトリに成果物が配置されます：

```
your-project/
├── .agent/                          # コピーしたSDLC支援システム
│
└── templates/                       # エージェントが生成した成果物
    ├── 01_要件定義/
    │   └── 実成果物/
    │       ├── RD001_システム化要求定義書.md
    │       ├── RD002_業務要件定義書.md
    │       └── ...
    │
    ├── 02_基本設計/
    │   └── 実成果物/
    │       ├── BD001_システム方式設計書.md
    │       ├── BD009_IaC設計書.md
    │       └── ...
    │
    └── 04_詳細設計/
        ├── DD000_詳細設計総括.md
        └── 実成果物/
            ├── 00_全体俯瞰/
            ├── 01_アプリ/              # アプリチームの成果物
            │   ├── ユーザー管理/
            │   │   ├── DD001-01_クラス設計書_認証モジュール.md
            │   │   ├── DD002_データベース物理設計書_ユーザーテーブル.md
            │   │   └── ...
            │   └── 注文管理/
            │
            └── 02_インフラ/            # インフラチームの成果物
                ├── network/
                │   └── DD-INF001_Terraformスタック設計書_VPC.md
                ├── security/
                └── application-platform/
```

---

## 💡 主要な設計方針

### IaC設計書は軽量化

従来の課題:
- ❌ パラメーター一覧になりがち（100ページ超）
- ❌ コードと重複した情報

Antigravityの方針:
- ✅ **設計判断（Why）のみ記載**（10-15ページ）
- ✅ パラメーター値はコード参照
- ✅ コスト見積もり、環境間差分、セキュリティ考慮を重点化

例:
```markdown
## 設計判断
**採用構成**: マルチAZ（3AZ）

**判断理由**:
- 可用性要件 99.9% を満たすため
- 単一AZ障害時も2AZで稼働継続

**コスト**: 月額$168（NAT Gateway × 3）
```

### 大規模システムの文書分割

- **クラス数10超**: モジュール単位で分割
- **ページ数50超**: 機能単位で分割
- **DD000総括**: 全体を俯瞰する総括文書で管理

詳細: [.agent/knowledge/documentation/ipa-detailed-design-scaling.md](.agent/knowledge/documentation/ipa-detailed-design-scaling.md)

### チーム分離

アプリチームとインフラチームが並行作業可能：

```bash
# ターミナル1（アプリチーム）
cd your-project
git checkout -b feature/detailed-design/app
claude-agent run detailed-designer-app

# ターミナル2（インフラチーム）
cd your-project
git checkout -b feature/detailed-design/infra
claude-agent run detailed-designer-infra
```

詳細: [.agent/knowledge/documentation/team-separation-app-infra.md](.agent/knowledge/documentation/team-separation-app-infra.md)

---

## 🔧 カスタマイズ

### プロジェクト固有のテンプレート追加

```bash
# 1. テンプレートをコピー
cp .agent/templates/04_詳細設計/DD001-01_クラス設計書_template.md \
   .agent/templates/04_詳細設計/DD001-01_カスタムテンプレート.md

# 2. カスタマイズ
vim .agent/templates/04_詳細設計/DD001-01_カスタムテンプレート.md

# 3. agents.jsonに登録
vim .agent/agents.json
```

### プロジェクト固有のベストプラクティス追加

```bash
# ナレッジファイルを作成
vim .agent/knowledge/application/backend/my-company-coding-standards.md

# agents.jsonのknowledge_baseに追加
vim .agent/agents.json
```

---

## 📊 統計

| カテゴリ | ファイル数 |
|---------|----------|
| 要件定義テンプレート | 7 |
| 基本設計テンプレート | 9 |
| 詳細設計テンプレート | 7 |
| Best Practicesナレッジ | 11 |
| ドキュメンテーション | 13 |
| **合計** | **47ファイル** |

---

## 🛠️ トラブルシューティング

### Q: エージェントが起動しない

```bash
# agents.jsonの構文チェック
jq . .agent/agents.json

# パスの確認
ls .agent/templates/
ls .agent/knowledge/
```

### Q: 質問が多すぎる（20個以上）

通常は5-10個です。[questioning-guidance.md](.agent/knowledge/workflows/questioning-guidance.md) を確認してください。

### Q: 成果物が生成されない

以下を確認:
1. 入力ファイル（前フェーズの成果物）が存在するか
2. テンプレートファイルが存在するか
3. エージェントのログを確認

---

## 📖 詳細ドキュメント

すべてのドキュメントは [.agent/README.md](.agent/README.md) から参照できます。

---

## 🤝 コントリビューション

プロジェクト固有のカスタマイズは歓迎です：

1. テンプレートのカスタマイズ
2. ベストプラクティスの追加
3. 新しいエージェントの追加

---

## 📝 ライセンス

このシステムは、IPA Common Frame 2013に準拠しています。

---

## 🔗 関連リンク

- [IPA Common Frame 2013](https://www.ipa.go.jp/archive/english/humandev/third.html)
- [GitHub Repository](https://github.com/k-tanaka-522/aidev-Antigravity)

---

## ✨ クイックスタート例

```bash
# 1. clone & copy
git clone https://github.com/k-tanaka-522/aidev-Antigravity.git
cd your-project
cp -r /path/to/Antigravity/.agent .

# 2. 要件定義から開始
claude-agent run requirements-analyst

# 3. 基本設計
claude-agent run system-architect

# 4. 詳細設計
claude-agent run detailed-designer-app
claude-agent run detailed-designer-infra

# 5. レビュー
claude-agent run design-reviewer
```

詳細は [.agent/workflows/sdlc-master-workflow.md](.agent/workflows/sdlc-master-workflow.md) を参照してください。
