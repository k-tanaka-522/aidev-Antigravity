# CloudFormation ベストプラクティス

**最終更新**: 2025-12-15
**対象**: AWS CloudFormation を使用したインフラ構築

---

## 使用方法

このドキュメントは、CloudFormation テンプレート作成・運用時に参照してください：

- **設計フェーズ**: スタック構造の決定
- **実装フェーズ**: テンプレート作成
- **レビュー時**: ベストプラクティス準拠確認
- **運用時**: スタック更新・削除の判断

---

## CloudFormation vs Terraform

| 項目 | CloudFormation | Terraform |
|------|---------------|-----------|
| **プロバイダー** | AWS専用 | マルチクラウド |
| **状態管理** | AWS側で自動管理 | tfstate管理が必要 |
| **言語** | JSON/YAML | HCL |
| **変更管理** | Change Sets | Plan |
| **コスト** | 無料 | 無料（Enterprise版は有料） |

---

## 1. テンプレート構造

### ✅ Good Practice

**Good**: セクション分割と読みやすさ
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC and Network Infrastructure for Production Environment'

# メタデータ: パラメータのグループ化
Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: 'Network Configuration'
        Parameters:
          - VpcCidr
          - PublicSubnetCidr
          - PrivateSubnetCidr
      - Label:
          default: 'Tagging'
        Parameters:
          - Environment
          - Project

    ParameterLabels:
      VpcCidr:
        default: 'VPC CIDR Block'
      Environment:
        default: 'Environment Name'

# パラメータ: 可変値
Parameters:
  VpcCidr:
    Description: 'CIDR block for VPC'
    Type: String
    Default: '10.0.0.0/16'
    AllowedPattern: '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$'
    ConstraintDescription: 'Must be a valid CIDR block'

  Environment:
    Description: 'Environment name'
    Type: String
    Default: 'dev'
    AllowedValues:
      - dev
      - stg
      - prod

  Project:
    Description: 'Project name'
    Type: String
    Default: 'myproject'

# マッピング: 環境ごとの設定値
Mappings:
  EnvironmentConfig:
    dev:
      InstanceType: t3.small
      MinSize: 1
      MaxSize: 2
    stg:
      InstanceType: t3.medium
      MinSize: 2
      MaxSize: 4
    prod:
      InstanceType: t3.large
      MinSize: 2
      MaxSize: 10

# 条件: 環境による分岐
Conditions:
  IsProduction: !Equals [!Ref Environment, 'prod']
  CreateNatGateway: !Or
    - !Equals [!Ref Environment, 'stg']
    - !Equals [!Ref Environment, 'prod']

# リソース
Resources:
  # VPC
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${Project}-${Environment}-vpc'
        - Key: Environment
          Value: !Ref Environment
        - Key: Project
          Value: !Ref Project
        - Key: ManagedBy
          Value: CloudFormation

  # Internet Gateway
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${Project}-${Environment}-igw'

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

# 出力: 他のスタックで参照
Outputs:
  VpcId:
    Description: 'VPC ID'
    Value: !Ref VPC
    Export:
      Name: !Sub '${AWS::StackName}-VpcId'

  VpcCidr:
    Description: 'VPC CIDR Block'
    Value: !GetAtt VPC.CidrBlock
    Export:
      Name: !Sub '${AWS::StackName}-VpcCidr'

  InternetGatewayId:
    Description: 'Internet Gateway ID'
    Value: !Ref InternetGateway
    Export:
      Name: !Sub '${AWS::StackName}-IgwId'
```

**Bad**:
```yaml
# NG: 構造化されていない、コメントなし
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16  # ハードコード
  Subnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24  # ハードコード
      # タグなし
```

---

## 2. スタック分割戦略

### ライフサイクルによる分割

**Good**: 変更頻度で分割
```yaml
# 1. network-stack.yaml（ほぼ変わらない）
Resources:
  VPC:
    Type: AWS::EC2::VPC
    DeletionPolicy: Retain  # 削除保護
    UpdateReplacePolicy: Retain
    # ...

# 2. security-stack.yaml（たまに変わる）
Resources:
  AppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    # ...

# 3. application-stack.yaml（よく変わる）
Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    # ...
```

**スタック間の依存関係**:
```yaml
# application-stack.yaml
Parameters:
  NetworkStackName:
    Type: String
    Description: 'Name of the network stack'
    Default: 'network-stack'

Resources:
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Subnets:
        - Fn::ImportValue: !Sub '${NetworkStackName}-PublicSubnet1'
        - Fn::ImportValue: !Sub '${NetworkStackName}-PublicSubnet2'
      SecurityGroups:
        - Fn::ImportValue: !Sub '${NetworkStackName}-AlbSecurityGroup'
```

---

## 3. パラメータとマッピング

### パラメータの活用

**Good**: バリデーション付きパラメータ
```yaml
Parameters:
  InstanceType:
    Description: 'EC2 instance type'
    Type: String
    Default: t3.small
    AllowedValues:
      - t3.micro
      - t3.small
      - t3.medium
      - t3.large

  KeyPairName:
    Description: 'EC2 Key Pair for SSH access'
    Type: AWS::EC2::KeyPair::KeyName
    ConstraintDescription: 'Must be an existing EC2 KeyPair'

  DBPassword:
    Description: 'Database password'
    Type: String
    NoEcho: true  # パスワードを隠す
    MinLength: 8
    MaxLength: 41
    AllowedPattern: '[a-zA-Z0-9]*'
    ConstraintDescription: 'Must contain only alphanumeric characters'

  AvailabilityZones:
    Description: 'Availability Zones for subnets'
    Type: List<AWS::EC2::AvailabilityZone::Name>

  SSHAllowedCIDR:
    Description: 'CIDR block allowed to SSH'
    Type: String
    Default: '0.0.0.0/0'
    AllowedPattern: '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$'
```

---

### マッピングの活用

**Good**: AMI IDをリージョンごとに定義
```yaml
Mappings:
  RegionMap:
    us-east-1:
      AMI: ami-0c55b159cbfafe1f0
    us-west-2:
      AMI: ami-0d1cd67c26f5fca19
    ap-northeast-1:
      AMI: ami-0f9ae750e8274075b
    eu-west-1:
      AMI: ami-0bbc25e23a7640b9b

Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
      InstanceType: !Ref InstanceType
```

---

## 4. 組み込み関数の活用

### 主要な関数

```yaml
# Ref: パラメータ・リソースの参照
!Ref VPC

# GetAtt: リソースの属性取得
!GetAtt VPC.CidrBlock

# Sub: 文字列置換
!Sub '${Project}-${Environment}-vpc'
!Sub 'arn:aws:s3:::${BucketName}/*'

# Join: 配列を文字列に結合
!Join [',', ['a', 'b', 'c']]  # 'a,b,c'

# Split: 文字列を配列に分割
!Split [',', 'a,b,c']  # ['a', 'b', 'c']

# Select: 配列から要素取得
!Select [0, !GetAZs '']  # 最初のAZ

# If: 条件分岐
!If [IsProduction, 'm5.large', 't3.small']

# Equals: 等価判定
!Equals [!Ref Environment, 'prod']

# And/Or/Not: 論理演算
!And
  - !Equals [!Ref Environment, 'prod']
  - !Equals [!Ref Region, 'us-east-1']

# Base64: エンコード
UserData:
  Fn::Base64: !Sub |
    #!/bin/bash
    echo "Environment: ${Environment}"

# ImportValue: 他スタックのExport参照
!ImportValue NetworkStack-VpcId

# Cidr: CIDR計算
!Cidr [!Ref VpcCidr, 6, 8]
```

---

## 5. Change Sets活用

### 安全な更新フロー

**Good**: Change Sets で変更確認
```bash
# 1. Change Set 作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset-$(date +%Y%m%d%H%M%S) \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=prod

# 2. Change Set 確認
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset-20251215100000

# 出力例:
# Changes:
#   - Action: Modify
#     ResourceType: AWS::EC2::SecurityGroup
#     Replacement: False
#     Details:
#       - Target: Properties.SecurityGroupIngress
#         Evaluation: Static
#         ChangeSource: DirectModification

# 3. Change Set 実行
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name my-changeset-20251215100000

# 4. スタック状態確認
aws cloudformation wait stack-update-complete \
  --stack-name my-stack
```

---

## 6. カスタムリソース

### Lambda-backed カスタムリソース

**Good**: カスタムロジック実装
```yaml
Resources:
  # カスタムリソース用Lambda
  CustomResourceFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub '${AWS::StackName}-custom-resource'
      Runtime: python3.11
      Handler: index.lambda_handler
      Role: !GetAtt CustomResourceRole.Arn
      Code:
        ZipFile: |
          import json
          import cfnresponse
          import boto3

          def lambda_handler(event, context):
              try:
                  request_type = event['RequestType']
                  properties = event['ResourceProperties']

                  if request_type == 'Create':
                      # 作成処理
                      result = create_resource(properties)
                  elif request_type == 'Update':
                      # 更新処理
                      result = update_resource(properties)
                  elif request_type == 'Delete':
                      # 削除処理
                      result = delete_resource(properties)

                  cfnresponse.send(event, context, cfnresponse.SUCCESS, result)
              except Exception as e:
                  cfnresponse.send(event, context, cfnresponse.FAILED, {'Error': str(e)})

          def create_resource(properties):
              # カスタムロジック実装
              return {'ResourceId': 'custom-123'}

  # カスタムリソース
  MyCustomResource:
    Type: Custom::MyCustomResource
    Properties:
      ServiceToken: !GetAtt CustomResourceFunction.Arn
      CustomProperty: 'value'

Outputs:
  CustomResourceId:
    Value: !GetAtt MyCustomResource.ResourceId
```

---

## 7. ネストスタック

### 再利用可能なテンプレート

**Good**: ネストスタックで共通化
```yaml
# parent-stack.yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-templates/network.yaml
      Parameters:
        VpcCidr: !Ref VpcCidr
        Environment: !Ref Environment
      Tags:
        - Key: Name
          Value: NetworkStack

  ApplicationStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: NetworkStack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-templates/application.yaml
      Parameters:
        VpcId: !GetAtt NetworkStack.Outputs.VpcId
        PrivateSubnetIds: !GetAtt NetworkStack.Outputs.PrivateSubnetIds
      Tags:
        - Key: Name
          Value: ApplicationStack

Outputs:
  NetworkStackId:
    Value: !Ref NetworkStack

  ApplicationStackId:
    Value: !Ref ApplicationStack
```

---

## 8. DeletionPolicy と UpdateReplacePolicy

### リソース保護

**Good**: 重要リソースの保護
```yaml
Resources:
  # 本番データベース: 削除・置換時にスナップショット
  ProductionDatabase:
    Type: AWS::RDS::DBInstance
    DeletionPolicy: Snapshot
    UpdateReplacePolicy: Snapshot
    Properties:
      DBInstanceIdentifier: !Sub '${Project}-${Environment}-db'
      Engine: postgres
      # ...

  # S3バケット: 削除時に保持
  DataBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    UpdateReplacePolicy: Retain
    Properties:
      BucketName: !Sub '${Project}-${Environment}-data'
      # ...

  # ログバケット: 削除時に保持
  LogBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Retain
    UpdateReplacePolicy: Retain
    Properties:
      BucketName: !Sub '${Project}-${Environment}-logs'
      # ...

  # 開発環境EC2: 削除時に削除（デフォルト）
  DevInstance:
    Type: AWS::EC2::Instance
    DeletionPolicy: Delete
    Properties:
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
      # ...
```

---

## 9. テンプレート検証

### cfn-lint使用

```bash
# インストール
pip install cfn-lint

# 検証実行
cfn-lint template.yaml

# 出力例:
# E3001: Invalid or unsupported Type AWS::EC2::Instances for resource MyInstance
# W2001: Parameter InstanceType not used

# CI/CDでの自動検証
cfn-lint template.yaml --format junit > cfn-lint-results.xml
```

---

## 10. ドリフト検出

### スタックドリフト確認

```bash
# ドリフト検出開始
aws cloudformation detect-stack-drift --stack-name my-stack

# ドリフト検出状態確認
aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id <detection-id>

# ドリフト詳細確認
aws cloudformation describe-stack-resource-drifts \
  --stack-name my-stack

# 出力例:
# StackResourceDrift:
#   StackId: arn:aws:cloudformation:...
#   LogicalResourceId: MySecurityGroup
#   ResourceType: AWS::EC2::SecurityGroup
#   StackResourceDriftStatus: MODIFIED
#   PropertyDifferences:
#     - PropertyPath: /Properties/SecurityGroupIngress/0/CidrIp
#       ExpectedValue: 10.0.0.0/16
#       ActualValue: 0.0.0.0/0
#       DifferenceType: NOT_EQUAL
```

---

## チェックリスト

### テンプレート構造
- [ ] Description、Metadata、Parameters を記述
- [ ] パラメータにバリデーション設定
- [ ] 全リソースにタグ設定
- [ ] Outputs でエクスポート

### スタック設計
- [ ] ライフサイクルでスタック分割
- [ ] ネストスタック活用
- [ ] Change Sets で変更確認

### セキュリティ
- [ ] NoEcho でシークレット隠蔽
- [ ] IAM ロール最小権限
- [ ] セキュリティグループ適切設定

### 運用
- [ ] DeletionPolicy/UpdateReplacePolicy 設定
- [ ] cfn-lint で検証
- [ ] ドリフト検出定期実行
- [ ] バージョン管理（Git）

---

## まとめ

このベストプラクティスに従うことで：

- ✅ 保守性の高いテンプレート
- ✅ 安全な変更管理
- ✅ 再利用可能な設計
- ✅ 運用負荷軽減

CloudFormation テンプレート作成・運用時に、このガイドラインを参照してください。

---

## 参考資料

- [AWS CloudFormation Best Practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)
- [cfn-lint](https://github.com/aws-cloudformation/cfn-lint)
- [CloudFormation Template Anatomy](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html)
- [Change Sets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html)
