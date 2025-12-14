# CloudFormation セキュリティチェックリスト

**最終更新**: 2025-12-15
**対象**: AWS CloudFormation

---

## 使用方法

このチェックリストは、CloudFormationテンプレート作成時・レビュー時に使用してください：

- **設計時**: インフラ設計前に確認
- **実装時**: テンプレート作成後に確認
- **変更セット作成時**: Change Sets確認時にレビュー
- **デプロイ前**: スタック適用前の最終検証

---

## 1. IAM（Identity and Access Management）

### 必須チェック項目（Critical）

- [ ] **ワイルドカード禁止**: ポリシーで `Resource: "*"` を使用していないか
- [ ] **全アクション禁止**: `Action: "*"` を使用していないか
- [ ] **最小権限の原則**: 必要最小限の権限のみ付与しているか
- [ ] **ManagedPolicyArns**: AWS管理ポリシーよりカスタムポリシーを優先しているか
- [ ] **AssumeRolePolicyDocument**: 信頼ポリシーで適切なプリンシパルのみ許可しているか
- [ ] **条件の使用**: Conditionキーで制約を追加しているか

### Good / Bad Example

#### Good ✅
```yaml
# 最小権限のIAMロール
S3ReadOnlyRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: S3ReadOnlyRole
    Description: Allows read-only access to specific S3 bucket
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ec2.amazonaws.com
          Action: sts:AssumeRole
          Condition:
            StringEquals:
              sts:ExternalId: !Ref ExternalId
    Policies:
      - PolicyName: S3ReadOnly
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:GetObject
                - s3:ListBucket
              Resource:
                - !Sub 'arn:aws:s3:::${BucketName}'
                - !Sub 'arn:aws:s3:::${BucketName}/*'
    Tags:
      - Key: Environment
        Value: !Ref Environment
```

#### Bad ❌
```yaml
# 過剰な権限（NG）
AdminRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: '*'  # NG! 全サービス許可
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - arn:aws:iam::aws:policy/AdministratorAccess  # NG! 管理者権限
```

---

## 2. ネットワークセキュリティ

### 必須チェック項目（Critical）

- [ ] **0.0.0.0/0禁止**: SecurityGroupIngressで全開放していないか
- [ ] **SSH/RDP制限**: ポート22, 3389が特定IPに制限されているか
- [ ] **ポート範囲**: 必要最小限のポートのみ開放しているか
- [ ] **プライベートサブネット**: DBがプライベートサブネットに配置されているか
- [ ] **VPCフローログ**: 有効化されているか
- [ ] **GroupDescription**: 各ルールに説明が記載されているか

### Good / Bad Example

#### Good ✅
```yaml
# セキュリティグループ（適切に制限）
WebServerSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupName: web-server-sg
    GroupDescription: Security group for web servers
    VpcId: !Ref VPC
    SecurityGroupIngress:
      # HTTPSのみ許可（ALBから）
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        SourceSecurityGroupId: !Ref ALBSecurityGroup
        Description: HTTPS from ALB
    SecurityGroupEgress:
      # アウトバウンドも制限
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        CidrIp: 0.0.0.0/0
        Description: HTTPS to internet
    Tags:
      - Key: Name
        Value: web-server-sg
```

#### Bad ❌
```yaml
# セキュリティグループ（全開放・NG）
InsecureSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Insecure security group
    VpcId: !Ref VPC
    SecurityGroupIngress:
      # 全ポート全開放（NG!）
      - IpProtocol: -1
        CidrIp: 0.0.0.0/0  # NG!
```

---

## 3. 暗号化

### 必須チェック項目（Critical）

- [ ] **EBS暗号化**: EC2のEBSボリュームが暗号化されているか
- [ ] **S3暗号化**: BucketEncryptionが設定されているか
- [ ] **RDS暗号化**: StorageEncryptedがtrueか
- [ ] **KMS使用**: カスタマーマネージドキーを使用しているか
- [ ] **通信の暗号化**: SSL/TLSが強制されているか
- [ ] **スナップショット暗号化**: バックアップが暗号化されているか

### Good / Bad Example

#### Good ✅
```yaml
# S3バケット暗号化
SecureBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub '${ProjectName}-secure-bucket'
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms
            KMSMasterKeyID: !GetAtt KMSKey.Arn
    VersioningConfiguration:
      Status: Enabled
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
    Tags:
      - Key: Environment
        Value: !Ref Environment

# RDS暗号化
Database:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: !Sub '${ProjectName}-db'
    Engine: postgres
    EngineVersion: '15.4'
    DBInstanceClass: db.t3.micro
    StorageEncrypted: true  # ✅ 暗号化
    KmsKeyId: !GetAtt KMSKey.Arn
    MasterUsername: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:username}}'
    MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:password}}'
```

#### Bad ❌
```yaml
# 暗号化なし（NG!）
InsecureBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: insecure-bucket
    # BucketEncryption設定なし

InsecureDatabase:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: insecure-db
    Engine: postgres
    DBInstanceClass: db.t3.micro
    StorageEncrypted: false  # NG!
    MasterUsername: admin
    MasterUserPassword: P@ssw0rd123  # NG! ハードコード
```

---

## 4. シークレット管理

### 必須チェック項目（Critical）

- [ ] **動的参照の使用**: Secrets Managerの動的参照を使用しているか
- [ ] **ハードコード禁止**: パスワードがハードコードされていないか
- [ ] **NoEcho**: 機密パラメータでNoEchoが設定されているか
- [ ] **DeletionPolicy**: Secretsにリテンションポリシーが設定されているか

### Good / Bad Example

#### Good ✅
```yaml
# Secrets Managerから動的参照
DBSecret:
  Type: AWS::SecretsManager::Secret
  Properties:
    Name: !Sub '${ProjectName}/db/password'
    Description: Database password
    GenerateSecretString:
      SecretStringTemplate: '{"username": "admin"}'
      GenerateStringKey: password
      PasswordLength: 32
      ExcludeCharacters: '"@/\'
    Tags:
      - Key: Environment
        Value: !Ref Environment
  DeletionPolicy: Retain
  UpdateReplacePolicy: Retain

Database:
  Type: AWS::RDS::DBInstance
  Properties:
    MasterUsername: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:username}}'
    MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:password}}'
```

#### Bad ❌
```yaml
# パスワードハードコード（NG!）
Parameters:
  DBPassword:
    Type: String
    Default: P@ssw0rd123  # NG! デフォルト値
    NoEcho: false  # NG! NoEchoがfalse

Database:
  Type: AWS::RDS::DBInstance
  Properties:
    MasterUsername: admin
    MasterUserPassword: !Ref DBPassword  # NG!
```

---

## 5. ロギング・監視

### 必須チェック項目（Critical）

- [ ] **CloudTrail**: スタック作成・更新がログ記録されているか
- [ ] **S3アクセスログ**: 重要なバケットで有効か
- [ ] **VPCフローログ**: 有効化されているか
- [ ] **CloudWatch Logs**: アプリケーションログが記録されているか
- [ ] **ログ保持期間**: RetentionInDaysが設定されているか
- [ ] **ログ暗号化**: KmsKeyIdが設定されているか

### Good / Bad Example

#### Good ✅
```yaml
# VPCフローログ
VPCFlowLog:
  Type: AWS::EC2::FlowLog
  Properties:
    ResourceType: VPC
    ResourceIds:
      - !Ref VPC
    TrafficType: ALL
    LogDestinationType: cloud-watch-logs
    LogGroupName: !Ref VPCFlowLogGroup
    DeliverLogsPermissionArn: !GetAtt VPCFlowLogRole.Arn
    Tags:
      - Key: Name
        Value: vpc-flow-log

VPCFlowLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: /aws/vpc/flowlogs
    RetentionInDays: 90  # ✅ 保持期間設定
    KmsKeyId: !GetAtt KMSKey.Arn  # ✅ 暗号化
```

#### Bad ❌
```yaml
# ロギング設定なし（NG!）
VPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: 10.0.0.0/16
    # フローログなし
```

---

## 6. パブリックアクセス制御

### 必須チェック項目（Critical）

- [ ] **S3パブリックアクセス**: PublicAccessBlockConfigurationが設定されているか
- [ ] **RDSパブリック禁止**: PubliclyAccessibleがfalseか
- [ ] **不要なパブリックIP**: MapPublicIpOnLaunchがfalseか（プライベートサブネット）
- [ ] **ALB/NLBスキーム**: 内部向けはScheme: internalか

### Good / Bad Example

#### Good ✅
```yaml
# S3パブリックアクセスブロック
SecureBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: secure-bucket
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true

# RDSプライベート
Database:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: private-db
    Engine: postgres
    PubliclyAccessible: false  # ✅
    DBSubnetGroupName: !Ref PrivateDBSubnetGroup
```

#### Bad ❌
```yaml
# S3パブリック（NG!）
PublicBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: public-bucket
    AccessControl: PublicRead  # NG!

# RDSパブリック（NG!）
PublicDatabase:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: public-db
    Engine: postgres
    PubliclyAccessible: true  # NG!
```

---

## 7. リソースタグ

### 必須チェック項目（Critical）

- [ ] **全リソースにタグ**: 全リソースに必須タグが付与されているか
  - Environment
  - Project
  - Owner
  - ManagedBy (cloudformation)
- [ ] **スタックレベルタグ**: スタック作成時にタグを指定しているか

### Good / Bad Example

#### Good ✅
```yaml
# 共通タグ定義
Mappings:
  CommonTags:
    Tags:
      Project: MyProject
      Owner: TeamA
      ManagedBy: CloudFormation

Resources:
  Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Ref AMI
      InstanceType: t3.micro
      Tags:
        - Key: Name
          Value: web-server
        - Key: Environment
          Value: !Ref Environment
        - Key: Project
          Value: !FindInMap [CommonTags, Tags, Project]
        - Key: Owner
          Value: !FindInMap [CommonTags, Tags, Owner]
        - Key: ManagedBy
          Value: !FindInMap [CommonTags, Tags, ManagedBy]
```

#### Bad ❌
```yaml
# タグなし（NG!）
Instance:
  Type: AWS::EC2::Instance
  Properties:
    ImageId: !Ref AMI
    InstanceType: t3.micro
    # タグなし
```

---

## 8. スタック保護

### 必須チェック項目（Critical）

- [ ] **TerminationProtection**: 本番スタックで有効化されているか
- [ ] **StackPolicy**: 重要なリソースが保護されているか
- [ ] **DeletionPolicy**: データリソースでRetain設定されているか
- [ ] **UpdateReplacePolicy**: 置換時の動作が定義されているか

### Good / Bad Example

#### Good ✅
```yaml
# DeletionPolicy設定
Database:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: production-db
    Engine: postgres
  DeletionPolicy: Snapshot  # ✅ 削除時にスナップショット
  UpdateReplacePolicy: Snapshot

DataBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: data-bucket
  DeletionPolicy: Retain  # ✅ 削除時も保持
  UpdateReplacePolicy: Retain

# スタックポリシー（別ファイル: stack-policy.json）
{
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "Update:Delete",
      "Resource": "LogicalResourceId/Database"
    }
  ]
}
```

#### Bad ❌
```yaml
# DeletionPolicy未設定（NG!）
Database:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: important-db
    Engine: postgres
  # DeletionPolicy未設定 -> デフォルトはDelete（危険）
```

---

## 9. Change Setsの活用

### 必須チェック項目（Critical）

- [ ] **変更前確認**: 本番更新前に必ずChange Setを作成・レビューしているか
- [ ] **影響範囲確認**: Replacementが発生するリソースを確認しているか
- [ ] **ロールバック計画**: 失敗時のロールバック手順が定義されているか

### Good / Bad Example

#### Good ✅
```bash
# Change Setワークフロー

# 1. Change Set作成
aws cloudformation create-change-set \
  --stack-name production-stack \
  --template-body file://template.yaml \
  --change-set-name update-20231215 \
  --parameters file://params.json

# 2. Change Set確認
aws cloudformation describe-change-set \
  --stack-name production-stack \
  --change-set-name update-20231215

# 3. レビュー後に実行
aws cloudformation execute-change-set \
  --stack-name production-stack \
  --change-set-name update-20231215
```

---

## 10. CloudFormation自体のセキュリティ

### 必須チェック項目（Critical）

- [ ] **cfn-lint**: テンプレート検証を実行しているか
- [ ] **cfn_nag**: セキュリティスキャンを実行しているか
- [ ] **Capabilities**: CAPABILITY_IAM等が必要な場合のみ使用しているか
- [ ] **ServiceRole**: 最小権限のサービスロールを使用しているか

### Good / Bad Example

#### Good ✅
```bash
# CI/CDでセキュリティチェック

# cfn-lint（構文・ベストプラクティスチェック）
cfn-lint template.yaml

# cfn_nag（セキュリティスキャン）
cfn_nag_scan --input-path template.yaml

# taskcat（マルチリージョンテスト）
taskcat test run
```

```yaml
# 最小権限のサービスロール
CloudFormationRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: CloudFormationDeployRole
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: cloudformation.amazonaws.com
          Action: sts:AssumeRole
    Policies:
      - PolicyName: DeployPolicy
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - ec2:CreateVpc
                - ec2:CreateSubnet
                # 必要最小限のアクションのみ
              Resource: '*'
```

---

## チェックリスト完了基準

### 全項目確認
- [ ] IAM（6項目）
- [ ] ネットワーク（6項目）
- [ ] 暗号化（6項目）
- [ ] シークレット管理（4項目）
- [ ] ロギング（6項目）
- [ ] パブリックアクセス（4項目）
- [ ] タグ（2項目）
- [ ] スタック保護（4項目）
- [ ] Change Sets（3項目）
- [ ] CFn自体（4項目）

### 自動スキャン実行
```bash
# cfn-lintでスキャン
cfn-lint template.yaml

# cfn_nagでセキュリティスキャン
cfn_nag_scan --input-path template.yaml

# Checkovでスキャン
checkov -f template.yaml --framework cloudformation
```

---

## 参考資料

- **AWS CloudFormation Best Practices**: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html
- **cfn-lint**: https://github.com/aws-cloudformation/cfn-lint
- **cfn_nag**: https://github.com/stelligent/cfn_nag
- **AWS Well-Architected Framework**: https://aws.amazon.com/architecture/well-architected/

---

**このチェックリストを使用して、セキュアなCloudFormationテンプレートを作成してください。**
