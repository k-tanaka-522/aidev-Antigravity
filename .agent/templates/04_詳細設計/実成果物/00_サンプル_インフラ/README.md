# サンプル: インフラ詳細設計（IaC）

このディレクトリは、インフラチームがIaCスタック設計書を作成する際の参考サンプルです。

---

## 📁 このディレクトリの構成

```
00_サンプル_インフラ/
├── README.md                                               # 本ファイル
└── DD-INF001_Terraformスタック設計書_VPC_sample.md         # VPCスタック設計のサンプル
```

---

## 🎯 IaCスタック設計書の特徴

### ✅ 設計判断を記載（Why）

このテンプレートは、**パラメーター一覧ではなく、設計判断の理由**を記載します。

**Good（設計判断）**:
```markdown
### 2.1 アーキテクチャ選定

**採用構成**: マルチAZ（3AZ） + パブリック/プライベートサブネット

**判断理由**:
- 可用性要件 99.9% を満たすため、3AZ構成を採用
- 単一AZ障害時も2AZで稼働継続
```

**Bad（パラメーター一覧）**:
```markdown
### パラメーター

| パラメーター | 値 |
|------------|-----|
| vpc_cidr | 10.0.0.0/16 |
| subnet_count | 6 |
| nat_gateway_count | 3 |
...（以下延々と続く）
```

### ✅ コードとの分業

| 文書 | 記載内容 |
|------|---------|
| **IaCスタック設計書**（この文書） | 設計判断（Why）、理由、トレードオフ |
| **Terraformコード** | 実装（What）、パラメーター |

**重複させない**: パラメーター値はコード参照

### ✅ 10-15ページに収める

- 設計判断と理由に絞る
- パラメーター一覧は記載しない
- 「なぜその設計にしたか」を重点的に記載

---

## 🚀 使用方法

### Step 1: サブシステムディレクトリの作成

インフラスタックごとにディレクトリを作成します：

```bash
cd ".agent/templates/04_詳細設計/実成果物"
mkdir "02_インフラ"
cd "02_インフラ"
mkdir "network"
mkdir "security"
mkdir "application-platform"
```

### Step 2: テンプレートからコピー

```bash
# VPCスタック設計書を作成
cp "../../DD-INF001_Terraformスタック設計書_template.md" \
   "02_インフラ/network/DD-INF001_Terraformスタック設計書_VPC.md"

# セキュリティグループスタック設計書を作成
cp "../../DD-INF001_Terraformスタック設計書_template.md" \
   "02_インフラ/security/DD-INF001_Terraformスタック設計書_SecurityGroup.md"
```

### Step 3: プレースホルダを置換

エディタで以下を一括置換：

```
{プロジェクト名} → Antigravity
{スタック名} → network-vpc
{作成者名} → 鈴木次郎
{YYYY/MM/DD} → 2025/12/15
```

### Step 4: 設計判断を記載

**サンプルファイル** `DD-INF001_Terraformスタック設計書_VPC_sample.md` を参考に、以下を記載します：

1. **設計判断（Why）**
   - なぜその構成を選んだか
   - 検討した他の選択肢と不採用理由

2. **セキュリティ考慮**
   - セキュリティ設計のポイント
   - IAMポリシー、VPCフローログ

3. **コスト考慮**
   - 主要リソースの月額コスト見積もり
   - コスト最適化のポイント

4. **環境間の差分**
   - prod/stg/dev の差分とその理由

---

## 📝 実際の運用フロー

### 1. インフラチームの作業

```mermaid
graph LR
    A[基本設計完了] --> B[スタック分割決定]
    B --> C[DD-INF001作成]
    C --> D[アプリチームへレビュー依頼]
    D --> E[レビュー反映]
    E --> F[承認]
```

### 2. スタック分割の考え方

| スタック名 | 管理リソース | ライフサイクル |
|----------|------------|--------------|
| network-vpc | VPC, Subnet, NAT Gateway | ほぼ不変 |
| security-sg | Security Group | アプリリリース時に更新 |
| application-ecs | ECS, ALB | 頻繁に更新 |
| data-rds | RDS | データ移行時のみ更新 |

**分割理由**: ライフサイクルが異なるリソースを別スタックで管理

### 3. アプリチームとの連携

**アプリチームへの情報提供**:
- VPC ID, Subnet ID（Output経由）
- セキュリティグループID
- 環境変数、接続情報

**アプリチームからの要件**:
- 必要なインフラリソース仕様（基本設計フェーズで合意）
- 非機能要件（性能、可用性）

---

## 🔍 このサンプルの使い方

### サンプルファイルの確認

`DD-INF001_Terraformスタック設計書_VPC_sample.md` には、以下の具体例が記載されています：

1. **VPC設計**: マルチAZ構成の理由、CIDR設計
2. **コスト見積もり**: NAT Gateway × 3 = $96/月 の詳細
3. **環境間差分**: prod（3AZ）/ stg（2AZ）/ dev（1AZ）の使い分け
4. **セキュリティ**: VPCフローログ、VPCエンドポイント

### 実ファイル作成時の注意点

1. **`_sample.md` は削除して構いません**
   - 実プロジェクトでは不要です

2. **ファイル名から `_sample` を除く**
   - `DD-INF001_Terraformスタック設計書_VPC.md` （sampleなし）

3. **内容を実プロジェクトに合わせて記載**
   - サンプルは参考程度に、実際の設計内容を記載してください

---

## ✅ 品質チェック

### 設計判断の記載

- [ ] 「なぜその構成を選んだか」が明確に記載されているか
- [ ] 検討した他の選択肢と不採用理由が記載されているか
- [ ] パラメーター一覧になっていないか（コード参照になっているか）

### セキュリティ考慮

- [ ] IAMポリシーが最小権限の原則に従っているか
- [ ] VPCフローログ、CloudTrailの有効化が検討されているか
- [ ] セキュリティグループ設計のポイントが明確か

### コスト考慮

- [ ] 主要リソースのコスト見積もりが記載されているか
- [ ] 環境間のコスト差分が明確か
- [ ] コスト最適化のポイントが記載されているか

### 環境間の差分

- [ ] prod/stg/dev の差分理由が明確か
- [ ] 差分が適切か（例: dev環境でのコスト削減）

### ページ数

- [ ] 10-15ページに収まっているか
- [ ] 設計判断に絞られているか

---

## 📚 参考資料

- [DD-INF001_Terraformスタック設計書_template.md](../../DD-INF001_Terraformスタック設計書_template.md)
- [DD-INF002_CloudFormationスタック設計書_template.md](../../DD-INF002_CloudFormationスタック設計書_template.md)
- [team-separation-app-infra.md](../../../../knowledge/documentation/team-separation-app-infra.md)
- [BD009_IaC設計書_template.md](../../../02_基本設計/BD009_IaC設計書_template.md)

---

## 💡 Tips

### Terraformコードとの対応

**設計書とコードの分業**:

```
DD-INF001_Terraformスタック設計書_VPC.md
↓（設計判断を記載）
terraform/stacks/network-vpc/
├── main.tf           # 実装
├── variables.tf      # パラメーター定義
└── outputs.tf        # Output定義
```

**設計書の役割**: 「なぜ3AZ構成にしたか」を説明
**コードの役割**: 実際のVPC、Subnet、NAT Gatewayを定義

### レビュー効率化

**アプリチームへのレビュー依頼**:
- 設計書のみレビュー（コードは不要）
- 「この構成でアプリ要件を満たすか？」を確認

**インフラチーム内レビュー**:
- 設計書 + コード両方をレビュー
- セキュリティ、コスト、運用性を確認

### Git運用

```bash
# インフラチーム用のブランチ
git checkout -b feature/infra/network-stack

# 設計書作成
vim .agent/templates/04_詳細設計/実成果物/02_インフラ/network/DD-INF001_Terraformスタック設計書_VPC.md

# PR作成（設計書のみ）
git add .agent/templates/04_詳細設計/実成果物/02_インフラ/
git commit -m "Add VPC stack design document"
git push origin feature/infra/network-stack

# GitHub PR作成
gh pr create --title "インフラ詳細設計: VPCスタック" --body "..."
```
