# Terraform アンチパターン集

**最終更新**: 2025-12-15
**対象**: やってはいけないこと・よくある失敗パターン

---

## このドキュメントの目的

Terraformで**絶対にやってはいけないこと**と、**よくある失敗パターン**をまとめました。
コードレビュー時やセルフチェック時に参照してください。

---

## 1. セキュリティ関連のアンチパターン

### ❌ シークレットをハードコード

**Bad**:
```hcl
resource "aws_db_instance" "main" {
  username = "admin"
  password = "P@ssw0rd123"  # NG! Gitにコミットされる
}

variable "api_key" {
  default = "sk-1234567890abcdef"  # NG!
}
```

**Why Bad**: Git履歴に機密情報が残り、漏洩リスク大

**Good**:
```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  username = "admin"
  password = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"]
}
```

---

### ❌ IAMで過剰な権限

**Bad**:
```hcl
resource "aws_iam_policy" "app" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"           # NG! 全アクション許可
      Resource = "*"           # NG! 全リソース許可
    }]
  })
}
```

**Why Bad**: セキュリティリスク、意図しない操作の可能性

**Good**:
```hcl
resource "aws_iam_policy" "app" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "${aws_s3_bucket.data.arn}/*"
    }]
  })
}
```

---

### ❌ tfstateをGitにコミット

**Bad**:
```bash
# .gitignore に terraform.tfstate がない状態
git add terraform.tfstate  # NG!
git commit -m "Update state"
```

**Why Bad**: tfstateに機密情報が含まれる可能性、競合のリスク

**Good**:
```bash
# .gitignore
*.tfstate
*.tfstate.backup
.terraform/
```

---

## 2. 設計関連のアンチパターン

### ❌ すべてを1つのファイルに書く

**Bad**:
```hcl
# main.tf（5000行）
resource "aws_vpc" "main" { ... }
resource "aws_subnet" "public_1" { ... }
resource "aws_subnet" "public_2" { ... }
# ... 延々と続く
resource "aws_instance" "web_1" { ... }
# ...
resource "aws_db_instance" "main" { ... }
# ...
```

**Why Bad**: 可読性低下、保守困難、チーム開発で競合多発

**Good**:
```
environments/prod/
├── main.tf          # リソース呼び出し
├── variables.tf     # 変数定義
├── outputs.tf       # 出力定義
└── backend.tf       # バックエンド設定

modules/
├── network/         # ネットワークモジュール
├── compute/         # コンピュートモジュール
└── database/        # データベースモジュール
```

---

### ❌ モジュール化しない・コピペコード

**Bad**:
```hcl
# dev環境
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  # 50行のVPC設定...
}

# stg環境（コピペ）
resource "aws_vpc" "stg" {
  cidr_block = "10.1.0.0/16"
  # 50行の同じ設定をコピペ...
}

# prod環境（コピペ）
resource "aws_vpc" "prod" {
  cidr_block = "10.2.0.0/16"
  # 50行の同じ設定をコピペ...
}
```

**Why Bad**: メンテナンス負荷大、修正漏れのリスク

**Good**:
```hcl
# モジュール化
module "network_dev" {
  source   = "../../modules/network"
  vpc_cidr = "10.0.0.0/16"
  environment = "dev"
}

module "network_stg" {
  source   = "../../modules/network"
  vpc_cidr = "10.1.0.0/16"
  environment = "stg"
}
```

---

### ❌ 巨大な単一スタック

**Bad**:
```hcl
# 1つのスタックに全部詰め込む
resource "aws_vpc" "main" { ... }
resource "aws_ec2" "app" { ... }
resource "aws_rds" "db" { ... }
resource "aws_elasticache" "cache" { ... }
# ... 数百リソース
```

**Why Bad**: apply時間が長い、影響範囲が大きい、ロールバック困難

**Good**: ライフサイクルで分割
```
prod/
├── network/          # ほぼ変わらない
├── security/         # たまに変わる
├── application/      # よく変わる
└── monitoring/       # 独立
```

---

## 3. 状態管理のアンチパターン

### ❌ ローカルバックエンド使用（チーム開発）

**Bad**:
```hcl
# チーム開発でローカルbackend
terraform {
  # backend設定なし
}

# または
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

**Why Bad**: チームで状態共有できない、競合リスク、バックアップなし

**Good**:
```hcl
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

### ❌ state lockなし

**Bad**:
```hcl
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    # dynamodb_table なし → ロックなし
  }
}
```

**Why Bad**: 同時実行で状態が壊れる可能性

**Good**:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock"  # ロック機構
  }
}
```

---

## 4. 変数・設定のアンチパターン

### ❌ 変数の型指定なし

**Bad**:
```hcl
variable "instance_count" {}  # 型指定なし

variable "tags" {}  # 型指定なし
```

**Why Bad**: 予期しない値が入る、エラーがわかりにくい

**Good**:
```hcl
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
```

---

### ❌ マジックナンバー・マジックストリング

**Bad**:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # 何のAMI？
  instance_type = "t3.medium"

  tags = {
    Name = "web-server-1"  # 環境やプロジェクトが不明
  }
}
```

**Why Bad**: 意図が不明、環境ごとの変更が困難

**Good**:
```hcl
locals {
  ami_id = data.aws_ami.amazon_linux_2.id
}

resource "aws_instance" "web" {
  ami           = local.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project}-${var.environment}-web-${count.index + 1}"
  }
}
```

---

## 5. リソース管理のアンチパターン

### ❌ countではなく同じリソースを複数定義

**Bad**:
```hcl
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "public_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
}
```

**Why Bad**: 冗長、保守性低下

**Good**:
```hcl
variable "availability_zones" {
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
```

---

### ❌ タグがない

**Bad**:
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  # タグなし
}
```

**Why Bad**: リソース識別困難、コスト配分不可、運用困難

**Good**:
```hcl
locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-web"
  })
}
```

---

## 6. 運用関連のアンチパターン

### ❌ planせずにapply

**Bad**:
```bash
# いきなりapply（NG!）
terraform apply -auto-approve
```

**Why Bad**: 意図しない変更、削除リスク

**Good**:
```bash
# 必ずplanで確認
terraform plan -out=tfplan

# planの内容を確認してからapply
terraform apply tfplan
```

---

### ❌ バージョン固定しない

**Bad**:
```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # バージョン指定なし
    }
  }
}
```

**Why Bad**: 予期しないバージョンアップで挙動変化

**Good**:
```hcl
terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"  # バージョン固定
    }
  }
}
```

---

### ❌ terraform importを忘れる

**Bad**:
```bash
# 手動でリソース作成後、Terraformで同じリソースを定義
terraform apply  # エラー: リソースが既に存在
```

**Why Bad**: 既存リソースとの競合

**Good**:
```bash
# 既存リソースをimport
terraform import aws_instance.web i-1234567890abcdef0

# その後、コードで管理
terraform plan
```

---

## 7. コーディングスタイルのアンチパターン

### ❌ フォーマットしない

**Bad**:
```hcl
resource "aws_instance" "web" {
ami="ami-12345"
  instance_type=  "t3.micro"
    tags={
Name="web-server"
    }
}
```

**Why Bad**: 可読性低下、diff確認困難

**Good**:
```bash
# terraform fmt で自動フォーマット
terraform fmt -recursive

# またはPre-commit hookで自動化
```

---

### ❌ 説明的なコメントなし

**Bad**:
```hcl
resource "aws_security_group" "app" {
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}
```

**Why Bad**: なぜこのポートを開けるのか不明

**Good**:
```hcl
# アプリケーションサーバー用セキュリティグループ
# 社内ネットワーク（10.0.0.0/8）からのみアクセス許可
resource "aws_security_group" "app" {
  name        = "app-server-sg"
  description = "Security group for application servers"

  ingress {
    description = "Allow application port from internal network"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}
```

---

## 8. データソースのアンチパターン

### ❌ ハードコードされたAMI ID

**Bad**:
```hcl
resource "aws_instance" "web" {
  ami = "ami-0c55b159cbfafe1f0"  # 古いAMI、他リージョンで動かない
}
```

**Why Bad**: リージョンごとに異なる、古くなる

**Good**:
```hcl
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux_2.id
}
```

---

## 9. depends_onの誤用

### ❌ 不要なdepends_on

**Bad**:
```hcl
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id

  depends_on = [aws_subnet.public]  # 不要！
}
```

**Why Bad**: Terraformは自動で依存関係を解決する

**Good**:
```hcl
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id
  # depends_onは不要（自動で依存関係を認識）
}
```

**必要なケース**: 暗黙的な依存関係
```hcl
resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "app" {
  # IAMポリシーのアタッチが完了してから作成
  depends_on = [aws_iam_role_policy_attachment.lambda]
}
```

---

## チェックリスト

コードレビュー時に以下を確認：

### セキュリティ
- [ ] シークレットがハードコードされていないか
- [ ] IAM権限が過剰でないか
- [ ] リモートバックエンドを使用しているか

### 設計
- [ ] 適切にモジュール化されているか
- [ ] スタックが適切に分割されているか
- [ ] コピペコードがないか

### 変数・設定
- [ ] 変数に型指定があるか
- [ ] マジックナンバーがないか
- [ ] 全リソースにタグがあるか

### 運用
- [ ] Terraformバージョンが固定されているか
- [ ] terraform fmtが実行されているか
- [ ] 適切なコメントがあるか

---

## まとめ

このアンチパターン集で紹介した**やってはいけないこと**を避けることで：

- ✅ セキュリティリスク削減
- ✅ 保守性向上
- ✅ チーム開発の円滑化
- ✅ 運用トラブル防止

コードレビュー時やセルフチェック時に、ぜひこのリストを参照してください。

---

## 参考資料

- [Terraform Anti-Patterns](https://www.hashicorp.com/resources/terraform-anti-patterns-and-pitfalls)
- [Common Terraform Mistakes](https://blog.gruntwork.io/5-lessons-learned-from-writing-over-300-000-lines-of-infrastructure-code-36ba7fadeac1)
