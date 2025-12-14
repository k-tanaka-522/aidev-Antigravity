# DD-INF001: Terraformスタック設計書 - network-vpc

---

## 📋 文書情報

| 項目 | 内容 |
|------|------|
| **文書番号** | DD-INF001-001 |
| **文書名** | Terraformスタック設計書 - network-vpc |
| **プロジェクト名** | Antigravity ECサイト |
| **スタック名** | network-vpc |
| **作成者** | 鈴木次郎（インフラチーム） |
| **作成日** | 2025/12/15 |
| **最終更新日** | 2025/12/15 |
| **ステータス** | Approved |
| **レビュアー** | 山田太郎（アプリチーム）、佐藤三郎（セキュリティ） |

---

## 📖 目次

1. [概要](#1-概要)
2. [設計判断](#2-設計判断)
3. [セキュリティ考慮](#3-セキュリティ考慮)
4. [コスト考慮](#4-コスト考慮)
5. [環境間の差分](#5-環境間の差分)
6. [依存関係](#6-依存関係)
7. [運用考慮](#7-運用考慮)
8. [変更履歴](#8-変更履歴)

---

## 1. 概要

### 1.1 このスタックの目的

**このスタックが管理するリソース**:
- VPC（Virtual Private Cloud）
- サブネット（パブリック×3AZ、プライベート×3AZ）
- インターネットゲートウェイ
- NAT Gateway（各AZ）
- ルートテーブル
- VPCエンドポイント（S3, DynamoDB）

**このスタックの責務**:
- Antigravityプロジェクト全体のネットワーク基盤を提供
- マルチAZ構成により高可用性を実現
- パブリック/プライベートサブネットの分離によりセキュリティを確保

**対象環境**:
- [x] Production
- [x] Staging
- [x] Development

### 1.2 関連文書

| 文書番号 | 文書名 | 参照箇所 |
|---------|--------|---------|
| BD001 | システム方式設計書 | 2.3 ネットワーク構成 |
| BD009 | IaC設計書 | 3.1 Terraformスタック分割方針 |
| SEC-001 | セキュリティ要件定義書 | 4.2 ネットワークセキュリティ |

### 1.3 スタック配置

**ディレクトリ構成**:
```
terraform/
├── modules/
│   └── vpc/                    # VPC再利用モジュール
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── stacks/
    └── network-vpc/            # このスタック
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── terraform.tfvars.prod
        ├── terraform.tfvars.stg
        └── terraform.tfvars.dev
```

**コードリポジトリ**: https://github.com/example/antigravity-infrastructure

---

## 2. 設計判断

### 2.1 アーキテクチャ選定

**採用構成**:
- **マルチAZ（3AZ）構成** + **パブリック/プライベートサブネット分離**

**判断理由**:
- **可用性要件**: 99.9% の稼働率を満たすため、3AZ構成を採用
  - 単一AZ障害時も2AZで稼働継続
  - ALBのヘルスチェックにより自動フェイルオーバー
- **セキュリティ**: 外部公開リソース（ALB）と内部リソース（ECS, RDS）を物理的に分離
  - パブリックサブネット: ALB, NAT Gateway のみ配置
  - プライベートサブネット: ECSタスク, RDS を配置し、外部から直接アクセス不可
- **コスト最適化**: NAT Gatewayを各AZに配置し、クロスAZ通信コスト（$0.01/GB）を削減

**検討した他の選択肢**:

| 選択肢 | メリット | デメリット | 不採用理由 |
|--------|---------|-----------|-----------|
| シングルAZ構成 | コスト削減（NAT Gateway 1台） | 可用性要件を満たせない | 99.9%要件を満たせないため不採用 |
| NAT Gateway 1台共有 | コスト削減（月額$64削減） | クロスAZ通信コスト増加、単一障害点 | NAT Gateway障害時に全環境影響のため不採用 |
| NAT Instance | コスト削減（$20/月程度） | 運用負荷増加、可用性低下 | 運用コストを考慮し不採用 |

### 2.2 CIDR設計

**CIDR選定理由**:
- **Production**: `10.0.0.0/16`（65,536アドレス）
  - 将来的な拡張（マイクロサービス分割）を見越して大きめに確保
  - サブネット: `/20`（4,096アドレス/AZ）× 6サブネット（パブリック3 + プライベート3）
- **Staging**: `10.1.0.0/16`
- **Development**: `10.2.0.0/16`

**サブネット分割方針**:
```
Production (10.0.0.0/16)
├── ap-northeast-1a
│   ├── Public:  10.0.0.0/20   (10.0.0.1 - 10.0.15.254)
│   └── Private: 10.0.16.0/20  (10.0.16.1 - 10.0.31.254)
├── ap-northeast-1c
│   ├── Public:  10.0.32.0/20
│   └── Private: 10.0.48.0/20
└── ap-northeast-1d
    ├── Public:  10.0.64.0/20
    └── Private: 10.0.80.0/20
```

**理由**:
- `/20`（4,096アドレス）あれば、ECSタスク最大3,000台まで対応可能
- 各AZで均等に分割し、将来的なAZ追加にも対応可能

### 2.3 リソース分割方針

**このスタックに含めるリソース**:
- ✅ VPC, Subnet, RouteTable（理由: ネットワーク基盤として一体管理）
- ✅ Internet Gateway, NAT Gateway（理由: VPCに紐づくため）
- ✅ VPCエンドポイント（理由: ネットワークコスト最適化のため）

**このスタックに含めないリソース**:
- ❌ Security Group（理由: アプリケーションごとに管理するため、別スタック `security-sg` で管理）
- ❌ RDS, ECS（理由: ライフサイクルが異なるため、別スタックで管理）

### 2.4 State管理方針

**State保存先**:
- Backend: S3 + DynamoDB
- Bucket: `antigravity-terraform-state-prod`
- Key: `network-vpc/terraform.tfstate`
- Lock Table: `antigravity-terraform-lock`

**State分離戦略**:
- 環境ごとに完全に独立したStateファイルを管理
  - prod: `s3://antigravity-terraform-state-prod/network-vpc/terraform.tfstate`
  - stg: `s3://antigravity-terraform-state-stg/network-vpc/terraform.tfstate`
  - dev: `s3://antigravity-terraform-state-dev/network-vpc/terraform.tfstate`
- **理由**: prod環境への誤操作を防ぐため、Stateを物理的に分離

**Workspace使用有無**:
- [ ] Workspace使用
- [x] Workspace不使用（理由: 環境ごとに別ディレクトリ + 別S3バケットで管理する方針）

### 2.5 モジュール設計

**自作モジュール使用**:
- [x] 自作モジュール使用（モジュール名: `vpc`）

**モジュール化判断**:
- 3環境（prod/stg/dev）で同じVPC構成を再利用するため、`modules/vpc` を作成
- 環境ごとの差分は変数（`availability_zone_count`, `nat_gateway_count`）で吸収

**モジュール構成**:
```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name            = "antigravity"
  environment             = "prod"
  vpc_cidr                = "10.0.0.0/16"
  availability_zone_count = 3
  nat_gateway_count       = 3
  enable_vpc_flow_logs    = true
}
```

**使用する外部モジュール**:

| モジュール名 | ソース | バージョン | 使用理由 |
|------------|--------|-----------|---------|
| なし | - | - | VPCはシンプルなため自作モジュールのみ使用 |

---

## 3. セキュリティ考慮

### 3.1 アクセス制御

**IAMロール/ポリシー**:
- Terraform実行用のIAMロール: `TerraformExecutionRole`
- 最小権限の原則に従い、VPC関連のリソースのみ操作可能

**推奨IAMポリシー**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcAttribute",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:DescribeSubnets",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:CreateInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:AllocateAddress",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3.2 ネットワークセキュリティ

**セキュリティ設計のポイント**:
- **パブリックサブネット**: インターネットゲートウェイへのルート設定、外部公開リソース（ALB, NAT Gateway）のみ配置
- **プライベートサブネット**: NAT Gatewayへのルート設定、外部から直接アクセス不可
- **Security Groupは別スタックで管理**（このスタックではSGを作成しない）

**VPCエンドポイント**:
- S3エンドポイント: S3へのアクセスをインターネット経由せず、AWS内部ネットワークで完結
- DynamoDBエンドポイント: 同様にDynamoDBアクセスを最適化
- **理由**: NAT Gateway経由の通信コストを削減（特にS3へのログ保存時）

### 3.3 監査・ログ

**有効化するログ**:
- [x] VPCフローログ（保存先: CloudWatch Logs）
- [x] CloudTrail（API操作の記録）
- [ ] Config（リソース構成変更の記録）← ネットワーク変更は頻繁でないため無効

**ログ保持期間**:
- VPCフローログ: 90日間（コンプライアンス要件により）
- CloudTrail: 1年間（セキュリティ監査のため）

**フローログ設定**:
```hcl
resource "aws_flow_log" "vpc" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"  # ACCEPT/REJECT/ALL
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
}
```

---

## 4. コスト考慮

### 4.1 コスト見積もり

**主要リソースの月額コスト（想定）**:

| リソース | 数量 | 単価（概算） | 月額コスト |
|---------|------|-------------|-----------|
| NAT Gateway × 3 | 3台 | $32/台/月 | $96 |
| NAT Gateway データ処理 | 500GB/月 | $0.045/GB | $22.5 |
| EIP × 3 | 3個（NAT Gateway用） | $0 | $0（NAT Gatewayに関連付けるため無料） |
| VPCフローログ（CloudWatch Logs） | 100GB/月 | $0.50/GB | $50 |
| **合計** | - | - | **$168.5/月** |

**コスト最適化のポイント**:
1. **NAT Gateway最適化**: 各AZに配置することで、クロスAZ通信コスト（$0.01/GB）を削減
   - 試算: 月間10TB通信の場合、NAT Gateway 1台共有だと $100/月のクロスAZ通信コスト
   - 3台分散により、クロスAZ通信コストほぼゼロ → 差額で追加NAT Gateway費用を相殺
2. **VPCエンドポイント活用**: S3/DynamoDBエンドポイントにより、NAT Gateway経由の通信を削減
   - 試算: S3へのログ保存 1TB/月 → $45/月のNAT Gateway通信コスト削減
3. **不要なEIP削除**: 未使用のEIPは課金対象（$3.6/月）のため、必ず削除

### 4.2 環境別コスト

| 環境 | 月額コスト（想定） | 備考 |
|------|------------------|------|
| Production | $168.5 | 3AZ、NAT Gateway × 3、VPCフローログ有効 |
| Staging | $84 | 2AZ、NAT Gateway × 2、VPCフローログ有効 |
| Development | $32 | 1AZ、NAT Gateway × 1、VPCフローログ無効 |

**コスト削減施策**:
- dev環境: NAT Gateway 1台に集約し、**コストを80%削減**（$168.5 → $32）
- stg環境: 2AZ構成とし、**コストを50%削減**（$168.5 → $84）

---

## 5. 環境間の差分

### 5.1 環境パラメーター一覧

| 項目 | Production | Staging | Development | 差分理由 |
|------|-----------|---------|-------------|---------|
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 | 環境分離 |
| **AZ数** | 3 | 2 | 1 | コスト最適化 |
| **NAT Gateway数** | 3 | 2 | 1 | 可用性 vs コスト |
| **VPCフローログ** | 有効 | 有効 | 無効 | 監査要件（本番/STGのみ） |
| **VPCエンドポイント** | 有効 | 有効 | 有効 | コスト削減（全環境で有効） |

### 5.2 環境ごとの設計判断

**Production環境の特別な考慮事項**:
- 3AZ構成により単一AZ障害時も稼働継続
- VPCフローログ有効化により、不正アクセス検知

**Staging環境の特別な考慮事項**:
- 2AZ構成により、本番と同じマルチAZ動作を検証可能
- コストは本番の50%に抑制

**Development環境の簡略化ポイント**:
- 1AZ構成により、NAT Gateway 1台に集約
- VPCフローログ無効化により、ログ保存コストを削減
- **コストを80%削減**（$168.5 → $32）

---

## 6. 依存関係

### 6.1 前提条件

**このスタックをデプロイする前に必要なリソース**:

| リソース | 作成方法 | 確認コマンド |
|---------|---------|-------------|
| Terraform State保存用S3バケット | 手動作成（初回のみ） | `aws s3 ls s3://antigravity-terraform-state-prod` |
| Terraform State Lock用DynamoDBテーブル | 手動作成（初回のみ） | `aws dynamodb describe-table --table-name antigravity-terraform-lock` |
| IAMロール `TerraformExecutionRole` | 手動作成（初回のみ） | `aws iam get-role --role-name TerraformExecutionRole` |

**初回セットアップ手順**:
```bash
# 1. S3バケット作成（バージョニング有効化）
aws s3api create-bucket \
  --bucket antigravity-terraform-state-prod \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-versioning \
  --bucket antigravity-terraform-state-prod \
  --versioning-configuration Status=Enabled

# 2. DynamoDBテーブル作成（State Lock用）
aws dynamodb create-table \
  --table-name antigravity-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 6.2 このスタックが提供するOutput

**他のスタックから参照されるOutput**:

| Output名 | 内容 | 参照するスタック |
|---------|------|----------------|
| `vpc_id` | VPC ID | security-sg, application-ecs, data-rds |
| `public_subnet_ids` | パブリックサブネットIDリスト | security-sg（ALB用） |
| `private_subnet_ids` | プライベートサブネットIDリスト | application-ecs, data-rds |
| `availability_zones` | 使用しているAZリスト | application-ecs, data-rds |

**Output定義例**:
```hcl
output "vpc_id" {
  description = "VPC ID for other stacks"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for ECS and RDS"
  value       = module.vpc.private_subnet_ids
}
```

### 6.3 このスタックが参照するData Source

**他のスタックから取得する値**:
- なし（このスタックは最初にデプロイされるため、他スタックへの依存なし）

---

## 7. 運用考慮

### 7.1 デプロイ手順

**初回デプロイ**:
```bash
cd terraform/stacks/network-vpc

# 1. Backend初期化
terraform init

# 2. Plan確認
terraform plan -var-file="terraform.tfvars.prod"

# 3. Apply実行（レビュー後）
terraform apply -var-file="terraform.tfvars.prod"
```

**変更デプロイ**:
```bash
# 1. Plan確認（必須）
terraform plan -var-file="terraform.tfvars.prod" -out=tfplan

# 2. Plan内容をレビュー（破壊的変更がないか確認）
# 3. Slackで通知（本番環境の場合）
# 4. Apply実行
terraform apply tfplan
```

### 7.2 変更管理

**変更時の注意事項**:
- **VPC CIDRの変更**: 既存リソースの再作成を伴うため、**絶対に実施しない**
- **NAT Gatewayの追加/削除**: 通信断が発生する可能性があるため、計画的なメンテナンス時に実施
- **サブネット追加**: ルートテーブルへの影響を確認

**破壊的変更リスクのあるリソース**:

| リソース | 変更内容 | 影響範囲 | 対策 |
|---------|---------|---------|------|
| VPC CIDR | CIDR変更 | VPC全体再作成 | **変更禁止**（新規VPC作成して移行） |
| NAT Gateway | AZ変更 | 通信断（数分） | メンテナンス時に実施、事前通知 |
| Subnet CIDR | CIDR変更 | サブネット再作成 | **変更禁止**（新規サブネット追加） |

### 7.3 State管理ルール

**State操作時の注意**:
- ❌ **State直接編集禁止**（やむを得ない場合はバックアップ必須）
- ✅ **State lock確認**（他のメンバーがApply中でないか確認）
- ✅ **State import時は事前にPlan確認**

**State破損時の復旧手順**:
1. S3バケットのバージョニングから復元
   ```bash
   aws s3api list-object-versions --bucket antigravity-terraform-state-prod --prefix network-vpc/terraform.tfstate
   aws s3api get-object --bucket antigravity-terraform-state-prod --key network-vpc/terraform.tfstate --version-id {VERSION_ID} terraform.tfstate.backup
   ```
2. `terraform state list` で整合性確認
3. 必要に応じて `terraform import` で再構築

### 7.4 モニタリング

**監視項目**:
- VPCフローログの異常トラフィック検知（CloudWatch Logs Insightsで分析）
- NAT Gatewayの帯域使用率（CloudWatch Metrics）
- NAT Gatewayのエラー率（PacketsDropCount）

**アラート設定**:
- NAT Gatewayの帯域が80%を超えたら通知（Slack）
- VPCフローログでREJECTが急増したら通知（セキュリティアラート）

**CloudWatch Alarm例**:
```hcl
resource "aws_cloudwatch_metric_alarm" "nat_gateway_bytes_out" {
  alarm_name          = "nat-gateway-high-bandwidth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Average"
  threshold           = 8000000000  # 8GB/5min = 80%の帯域使用率
  alarm_description   = "NAT Gateway bandwidth usage is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

---

## 8. 変更履歴

| バージョン | 日付 | 作成者 | 変更内容 |
|-----------|------|--------|---------|
| 1.0 | 2025/12/15 | 鈴木次郎 | 初版作成 |
| 1.1 | 2025/12/16 | 鈴木次郎 | レビュー指摘事項を反映（VPCエンドポイント追加） |

---

## 📝 補足事項

### このサンプルの使い方

このファイルは、DD-INF001テンプレートの記入例です。

**実際にプロジェクトで使用する際**:
1. このファイルをコピー
2. プレースホルダ（`{}`）を実際の値に置換
3. プロジェクト固有の設計判断を記載

**ポイント**:
- パラメーター一覧は記載していません（Terraformコード参照）
- 設計判断の「理由」を重点的に記載
- コスト見積もりを明示し、環境間の差分を説明
