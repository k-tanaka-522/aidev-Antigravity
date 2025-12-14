# Terraform セキュリティチェックリスト

**最終更新**: 2025-12-15
**対象**: Terraform 1.0以降

---

## 使用方法

このチェックリストは、Terraformコード作成時・レビュー時に使用してください：

- **設計時**: インフラ設計前に確認
- **実装時**: コード生成後に確認
- **PR作成前**: マージ前の最終確認
- **terraform plan後**: 適用前の検証

---

## 1. IAM（Identity and Access Management）

### 必須チェック項目（Critical）

- [ ] **ワイルドカード禁止**: `Resource: "*"` を使用していないか
- [ ] **全アクション禁止**: `Action: "*"` を使用していないか
- [ ] **最小権限の原則**: 必要最小限のアクションのみ許可しているか
- [ ] **ポリシーのドキュメント化**: 各ポリシーの目的がコメントで記載されているか
- [ ] **AssumeRoleポリシーの制限**: 信頼ポリシーで適切なプリンシパルのみ許可しているか
- [ ] **MFA必須化**: 管理者権限にMFAを要求しているか
- [ ] **ルートユーザー禁止**: ルートアカウントの認証情報を使用していないか

### 推奨チェック項目（Recommended）

- [ ] ポリシーにConditionを使用して、IPアドレス等で制限しているか
- [ ] SCPで組織レベルの保護を実装しているか

### Good / Bad Example

#### Good ✅
```hcl
# 最小権限のIAMポリシー
resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnlyPolicy"
  description = "Allows read-only access to specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-specific-bucket",
          "arn:aws:s3:::my-specific-bucket/*"
        ]
      }
    ]
  })
}
```

#### Bad ❌
```hcl
# 過剰な権限（NG）
resource "aws_iam_policy" "admin_policy" {
  name = "AdminPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"           # NG! すべてのアクション
        Resource = "*"           # NG! すべてのリソース
      }
    ]
  })
}
```

---

## 2. ネットワークセキュリティ（VPC・セキュリティグループ）

### 必須チェック項目（Critical）

- [ ] **0.0.0.0/0禁止**: インバウンドで `0.0.0.0/0` を許可していないか
- [ ] **SSH/RDP制限**: ポート22, 3389が全体に公開されていないか
- [ ] **最小限のポート**: 必要最小限のポートのみ開放しているか
- [ ] **プライベートサブネット**: データベース等がプライベートサブネットに配置されているか
- [ ] **NACLの設定**: Network ACLで追加の保護があるか
- [ ] **VPCフローログ**: 有効化されているか
- [ ] **セキュリティグループの説明**: 各ルールに説明が記載されているか

### Good / Bad Example

#### Good ✅
```hcl
# セキュリティグループ（適切に制限）
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # HTTPSのみ許可（特定のALBから）
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # アウトバウンドは制限
  egress {
    description = "HTTPS to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}
```

#### Bad ❌
```hcl
# セキュリティグループ（全開放・NG）
resource "aws_security_group" "insecure" {
  name   = "insecure-sg"
  vpc_id = aws_vpc.main.id

  # 全ポート全開放（NG!）
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # NG!
  }

  # SSH全体に公開（NG!）
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # NG!
  }
}
```

---

## 3. シークレット・認証情報管理

### 必須チェック項目（Critical）

- [ ] **ハードコード禁止**: パスワード、APIキー等がコードにハードコードされていないか
- [ ] **変数の使用**: 機密情報は変数から読み込んでいるか
- [ ] **Secrets Manager使用**: AWS Secrets Managerを使用しているか
- [ ] **tfstateの暗号化**: S3バックエンドで暗号化が有効か
- [ ] **tfstate保護**: tfstateファイルが`.gitignore`に含まれているか
- [ ] **ローテーション**: シークレットのローテーションが設定されているか

### Good / Bad Example

#### Good ✅
```hcl
# Secrets Managerから取得
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  identifier     = "main-db"
  engine         = "postgres"
  instance_class = "db.t3.micro"

  username = var.db_username
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]

  # 暗号化有効
  storage_encrypted = true
  kms_key_id        = aws_kms_key.db.arn
}

# tfstate暗号化（backend設定）
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true                    # ✅ 暗号化
    kms_key_id     = "arn:aws:kms:..."      # ✅ KMS使用
    dynamodb_table = "terraform-lock"        # ✅ ロック機構
  }
}
```

#### Bad ❌
```hcl
# パスワードをハードコード（NG!）
resource "aws_db_instance" "main" {
  identifier     = "main-db"
  engine         = "postgres"
  instance_class = "db.t3.micro"

  username = "admin"
  password = "P@ssw0rd123"  # NG! ハードコード

  storage_encrypted = false  # NG! 暗号化なし
}

# ローカルバックエンド（NG!）
terraform {
  backend "local" {
    path = "terraform.tfstate"  # NG! ローカル保存
  }
}
```

---

## 4. 暗号化

### 必須チェック項目（Critical）

- [ ] **EBS暗号化**: EC2のEBSボリュームが暗号化されているか
- [ ] **S3暗号化**: バケットのデフォルト暗号化が有効か
- [ ] **RDS暗号化**: データベースの暗号化が有効か
- [ ] **KMS使用**: カスタマーマネージドキーを使用しているか
- [ ] **通信の暗号化**: TLS/SSLが強制されているか
- [ ] **バックアップの暗号化**: スナップショットが暗号化されているか

### Good / Bad Example

#### Good ✅
```hcl
# S3バケット暗号化
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# EBS暗号化
resource "aws_ebs_volume" "secure_volume" {
  availability_zone = "ap-northeast-1a"
  size              = 100

  encrypted  = true
  kms_key_id = aws_kms_key.ebs.arn

  tags = {
    Name = "SecureVolume"
  }
}
```

#### Bad ❌
```hcl
# 暗号化なし（NG!）
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-insecure-bucket"
  # 暗号化設定なし
}

resource "aws_ebs_volume" "insecure_volume" {
  availability_zone = "ap-northeast-1a"
  size              = 100
  encrypted         = false  # NG!
}
```

---

## 5. ロギング・監視

### 必須チェック項目（Critical）

- [ ] **CloudTrail有効**: 全リージョンで有効化されているか
- [ ] **VPCフローログ**: 有効化されているか
- [ ] **S3アクセスログ**: 重要なバケットで有効か
- [ ] **ALBアクセスログ**: 有効化されているか
- [ ] **ログの保持期間**: 適切な保持期間が設定されているか（推奨: 90日以上）
- [ ] **ログの暗号化**: ログが暗号化されているか
- [ ] **CloudWatch Alarms**: セキュリティイベントのアラームがあるか

### Good / Bad Example

#### Good ✅
```hcl
# CloudTrail設定
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Name = "main-cloudtrail"
  }
}

# VPCフローログ
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn

  tags = {
    Name = "vpc-flow-log"
  }
}
```

#### Bad ❌
```hcl
# ロギング設定なし（NG!）
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  # VPCフローログなし
}

resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
  # アクセスログなし
}
```

---

## 6. パブリックアクセス制御

### 必須チェック項目（Critical）

- [ ] **S3パブリックアクセス**: ブロック設定が有効か
- [ ] **RDSパブリック禁止**: `publicly_accessible = false` になっているか
- [ ] **EC2パブリックIP**: 不要なパブリックIPが割り当てられていないか
- [ ] **APIゲートウェイ**: 認証が必要か
- [ ] **ELBスキーム**: 内部向けはinternalになっているか

### Good / Bad Example

#### Good ✅
```hcl
# S3パブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "secure" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# RDSはプライベート
resource "aws_db_instance" "main" {
  identifier     = "main-db"
  engine         = "postgres"
  instance_class = "db.t3.micro"

  publicly_accessible = false  # ✅ パブリックアクセス禁止

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.private.name
}
```

#### Bad ❌
```hcl
# S3が全世界に公開（NG!）
resource "aws_s3_bucket" "public" {
  bucket = "my-public-bucket"
  acl    = "public-read"  # NG!
}

# RDSがパブリック（NG!）
resource "aws_db_instance" "public_db" {
  identifier     = "public-db"
  engine         = "postgres"
  instance_class = "db.t3.micro"

  publicly_accessible = true  # NG!
}
```

---

## 7. リソースタグ

### 必須チェック項目（Critical）

- [ ] **必須タグ**: 全リソースに以下のタグが付与されているか
  - `Environment` (prod/stg/dev)
  - `Project`
  - `Owner`
  - `ManagedBy` (terraform)
- [ ] **コスト配分タグ**: `CostCenter` 等が設定されているか
- [ ] **データ分類タグ**: `DataClassification` (public/internal/confidential)

### Good / Bad Example

#### Good ✅
```hcl
# 共通タグ定義
locals {
  common_tags = {
    Project         = var.project_name
    Environment     = var.environment
    Owner           = var.owner
    ManagedBy       = "terraform"
    CostCenter      = var.cost_center
    DataClassification = "confidential"
  }
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = merge(local.common_tags, {
    Name      = "web-server"
    Component = "web"
  })
}
```

#### Bad ❌
```hcl
# タグなし（NG!）
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  # タグなし
}
```

---

## 8. tfstateファイルの保護

### 必須チェック項目（Critical）

- [ ] **リモートバックエンド**: S3等のリモートバックエンドを使用しているか
- [ ] **state暗号化**: 暗号化が有効か
- [ ] **バージョニング**: S3バケットでバージョニングが有効か
- [ ] **ロック機構**: DynamoDBでstate lockが設定されているか
- [ ] **.gitignore**: ローカルのtfstateが除外されているか
- [ ] **アクセス制限**: stateファイルへのアクセスが制限されているか

### Good / Bad Example

#### Good ✅
```hcl
# リモートバックエンド設定
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "prod/infrastructure/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:ap-northeast-1:123456789:key/..."
    dynamodb_table = "terraform-state-lock"

    # アクセス制御
    acl = "private"
  }
}

# .gitignore
# .gitignore
*.tfstate
*.tfstate.backup
*.tfvars
.terraform/
```

#### Bad ❌
```hcl
# ローカルバックエンド（NG!）
terraform {
  backend "local" {
    path = "terraform.tfstate"  # NG!
  }
}

# 暗号化なし（NG!）
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = false  # NG!
  }
}
```

---

## 9. Terraform自体のセキュリティ

### 必須チェック項目（Critical）

- [ ] **バージョン固定**: Terraformバージョンが固定されているか
- [ ] **プロバイダーバージョン固定**: AWSプロバイダー等のバージョンが固定されているか
- [ ] **検証ツール**: tfsec、Checkov等でスキャンしているか
- [ ] **コードレビュー**: plan結果のレビュープロセスがあるか
- [ ] **dry-run必須**: 本番適用前に必ずplanを実行しているか

### Good / Bad Example

#### Good ✅
```hcl
# バージョン固定
terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }
}

# CI/CDでセキュリティスキャン
# .github/workflows/terraform.yml
- name: tfsec
  uses: aquasecurity/tfsec-action@v1.0.0

- name: Checkov
  uses: bridgecrewio/checkov-action@master
```

#### Bad ❌
```hcl
# バージョン未固定（NG!）
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # バージョン指定なし
    }
  }
}
```

---

## チェックリスト完了基準

### 全項目確認
- [ ] IAM（7項目）
- [ ] ネットワーク（7項目）
- [ ] シークレット管理（6項目）
- [ ] 暗号化（6項目）
- [ ] ロギング（7項目）
- [ ] パブリックアクセス（5項目）
- [ ] タグ（3項目）
- [ ] tfstate保護（6項目）
- [ ] Terraform自体（5項目）

### 自動スキャン実行
```bash
# tfsecでスキャン
tfsec .

# Checkovでスキャン
checkov -d .

# terraform-compliance（BDD形式のポリシーテスト）
terraform-compliance -f compliance-policies/ -p plan.json
```

---

## 参考資料

- **AWS Well-Architected Framework**: https://aws.amazon.com/architecture/well-architected/
- **tfsec**: https://github.com/aquasecurity/tfsec
- **Checkov**: https://www.checkov.io/
- **Terraform Security Best Practices**: https://www.terraform.io/docs/cloud/guides/recommended-practices/

---

**このチェックリストを使用して、セキュアなインフラをコードで実現してください。**
