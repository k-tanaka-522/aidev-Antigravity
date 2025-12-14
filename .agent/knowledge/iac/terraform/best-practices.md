# Terraform ベストプラクティス

**最終更新**: 2025-12-15
**対象**: Terraform 1.0以降

---

## 目次

1. [コード構成](#1-コード構成)
2. [モジュール設計](#2-モジュール設計)
3. [状態管理](#3-状態管理)
4. [変数とOutput](#4-変数とoutput)
5. [命名規則](#5-命名規則)
6. [セキュリティ](#6-セキュリティ)
7. [CI/CD統合](#7-cicd統合)
8. [ドキュメント](#8-ドキュメント)

---

## 1. コード構成

### ディレクトリ構造

**推奨**: 環境別ディレクトリ + 再利用可能モジュール

```
terraform/
├── environments/              # 環境別設定
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── stg/
│   └── prod/
├── modules/                   # 再利用可能モジュール
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   └── database/
└── README.md
```

### ファイル分割の原則

```hcl
# main.tf - リソース定義のメイン
terraform {
  required_version = "~> 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }
}

# variables.tf - 入力変数定義
variable "environment" {
  description = "Environment name (dev/stg/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Environment must be dev, stg, or prod."
  }
}

# outputs.tf - 出力値定義
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# backend.tf - バックエンド設定（環境ごと）
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "prod/infrastructure/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

## 2. モジュール設計

### モジュールの粒度

**Good**: 単一責任の原則

```hcl
# modules/network/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-public-${count.index + 1}"
    Tier = "Public"
  })
}
```

### モジュールのインターフェース

**明確な入力・出力定義**

```hcl
# modules/network/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones required for HA."
  }
}

# modules/network/outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}
```

### モジュールのREADME

```markdown
# Network Module

VPC、サブネット、ルートテーブルを作成するモジュール

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  project            = "myproject"
  environment        = "prod"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

  common_tags = {
    Project = "MyProject"
    Owner   = "TeamA"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_cidr | CIDR block for VPC | string | - | yes |
| availability_zones | List of AZs | list(string) | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| public_subnet_ids | List of public subnet IDs |
```

---

## 3. 状態管理

### リモートバックエンド（必須）

```hcl
# S3 + DynamoDB
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "prod/infrastructure/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:ap-northeast-1:123456789:key/..."
    dynamodb_table = "terraform-state-lock"
  }
}
```

### State分割戦略

**ライフサイクルで分割**

```
prod/
├── network/terraform.tfstate      # ほぼ変わらない
├── security/terraform.tfstate     # たまに変わる
├── application/terraform.tfstate  # よく変わる
└── monitoring/terraform.tfstate   # 独立
```

### Data Sourceで参照

```hcl
# application層からnetwork層のVPC IDを参照
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "mycompany-terraform-state"
    key    = "prod/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
  # ...
}
```

---

## 4. 変数とOutput

### 変数の定義

**型指定と検証**

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must be t3 series."
  }
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All elements must be valid CIDR blocks."
  }
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
```

### 変数ファイルの使い分け

```hcl
# terraform.tfvars（共通設定）
project     = "myproject"
region      = "ap-northeast-1"
common_tags = {
  ManagedBy = "Terraform"
  Project   = "MyProject"
}

# dev.tfvars（環境固有）
environment   = "dev"
instance_type = "t3.micro"
min_size      = 1
max_size      = 2

# prod.tfvars（環境固有）
environment   = "prod"
instance_type = "t3.medium"
min_size      = 3
max_size      = 10
```

### Output の活用

```hcl
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true  # 機密情報はsensitive指定
}

output "vpc_info" {
  description = "VPC information"
  value = {
    vpc_id     = aws_vpc.main.id
    cidr_block = aws_vpc.main.cidr_block
    subnets    = aws_subnet.public[*].id
  }
}
```

---

## 5. 命名規則

### リソース命名

**パターン**: `{project}-{environment}-{resource_type}-{purpose}`

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.environment}-subnet-public-${count.index + 1}"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.project}-${var.environment}-sg-web"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.environment}-sg-web"
  }
}
```

### Terraform 命名規則

```hcl
# リソース名: snake_case
resource "aws_instance" "web_server" {}

# 変数名: snake_case
variable "instance_type" {}

# モジュール名: kebab-case（ディレクトリ名）
module "network" {
  source = "../../modules/network"
}

# ファイル名: snake_case
# main.tf, variables.tf, outputs.tf
```

---

## 6. セキュリティ

### シークレット管理

**Bad**: ハードコード
```hcl
# NG!
resource "aws_db_instance" "main" {
  username = "admin"
  password = "P@ssw0rd123"  # NG!
}
```

**Good**: Secrets Manager参照
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  username = "admin"
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

### 最小権限の原則

```hcl
# IAMポリシー: 必要最小限
resource "aws_iam_policy" "s3_specific_bucket" {
  name = "S3SpecificBucketAccess"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.data.arn}/*"
        ]
      }
    ]
  })
}
```

---

## 7. CI/CD統合

### terraform planの自動化

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init
        working-directory: ./environments/prod

      - name: Terraform Validate
        run: terraform validate
        working-directory: ./environments/prod

      - name: Terraform Plan
        run: terraform plan -no-color
        working-directory: ./environments/prod
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: 'Terraform plan completed successfully!'
            })
```

### Pre-commit hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
```

---

## 8. ドキュメント

### コメントの書き方

```hcl
# VPC設定
# 本番環境では最低2つのAZにまたがるHA構成とする
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Route53プライベートホストゾーン用
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name        = "${var.project}-${var.environment}-vpc"
    Description = "Main VPC for ${var.environment} environment"
  })
}
```

### terraform-docsの活用

```bash
# モジュールのREADME自動生成
terraform-docs markdown table --output-file README.md modules/network/
```

---

## まとめ

### 必須事項
- [ ] リモートバックエンド使用
- [ ] 変数の型指定とバリデーション
- [ ] シークレットをハードコードしない
- [ ] タグを全リソースに付与
- [ ] CI/CDでplan自動実行

### 推奨事項
- [ ] モジュール化で再利用性向上
- [ ] terraform-docs等でドキュメント自動生成
- [ ] Pre-commit hooksで品質維持
- [ ] 定期的なtfsec/Checkovスキャン

---

## 参考資料

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [HashiCorp Terraform Style Guide](https://developer.hashicorp.com/terraform/language/syntax/style)
- [AWS Provider Best Practices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
