# DD-INF002: CloudFormationスタック設計書 - {スタック名}

---

## 📋 文書情報

| 項目 | 内容 |
|------|------|
| **文書番号** | DD-INF002-{連番} |
| **文書名** | CloudFormationスタック設計書 - {スタック名} |
| **プロジェクト名** | {プロジェクト名} |
| **スタック名** | {スタック名}（例: NetworkVPC, SecuritySG, ApplicationECS） |
| **作成者** | {作成者名} |
| **作成日** | {YYYY/MM/DD} |
| **最終更新日** | {YYYY/MM/DD} |
| **ステータス** | Draft / Review / Approved |
| **レビュアー** | {レビュアー名} |

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
- {主要なリソースタイプ}（例: VPC, Subnet, RouteTable, NatGateway）

**このスタックの責務**:
- {このスタックが何を実現するか}（例: ネットワーク基盤の提供、セキュリティグループの一元管理）

**対象環境**:
- [ ] Production
- [ ] Staging
- [ ] Development

### 1.2 関連文書

| 文書番号 | 文書名 | 参照箇所 |
|---------|--------|---------|
| BD001 | システム方式設計書 | 2.3 ネットワーク構成 |
| BD009 | IaC設計書 | 3.2 CloudFormationスタック分割方針 |
| {文書番号} | {文書名} | {参照箇所} |

### 1.3 スタック配置

**ディレクトリ構成**:
```
cloudformation/
├── nested/
│   └── {nested_stack_name}.yaml    # 再利用可能なネストスタック
└── stacks/
    └── {stack_name}/               # このスタック
        ├── template.yaml
        ├── parameters-prod.json
        ├── parameters-stg.json
        └── parameters-dev.json
```

**コードリポジトリ**: {GitHubリポジトリURL}

---

## 2. 設計判断

> **重要**: このセクションは「なぜその設計にしたか」を記載します。パラメーター一覧は記載しません（コードを参照）。

### 2.1 アーキテクチャ選定

**採用構成**:
- {採用したアーキテクチャパターン}（例: マルチAZ（3AZ） + パブリック/プライベートサブネット）

**判断理由**:
- **可用性要件**: {可用性要件}（例: 99.9% の稼働率を満たすため、マルチAZ構成を採用）
- **コスト最適化**: {コスト最適化の観点}（例: NAT Gatewayは各AZに配置し、クロスAZ通信コストを削減）
- **セキュリティ**: {セキュリティ上の理由}（例: 外部公開リソースと内部リソースを物理的に分離）

**検討した他の選択肢**:

| 選択肢 | メリット | デメリット | 不採用理由 |
|--------|---------|-----------|-----------|
| {選択肢1} | {メリット} | {デメリット} | {不採用理由} |
| {選択肢2} | {メリット} | {デメリット} | {不採用理由} |

### 2.2 リソース分割方針

**スタック分割の考え方**:
- {なぜこの単位でスタックを分割したか}（例: ライフサイクルが異なるため、Network / Security / Application で分離）

**このスタックに含めるリソース**:
- ✅ {リソースタイプ1}（理由: {理由}）
- ✅ {リソースタイプ2}（理由: {理由}）

**このスタックに含めないリソース**:
- ❌ {リソースタイプ3}（理由: {別スタックで管理する理由}）

### 2.3 ネストスタック使用方針

**ネストスタック使用有無**:
- [ ] ネストスタック使用（ネストスタック名: `{nested_stack_name}`）
- [ ] ネストスタック不使用

**ネストスタック化判断**:
- {なぜネストスタック化したか／しなかったか}（例: 複数環境で同じVPC構成を再利用するため、VPCネストスタックを作成）

**ネストスタック構成**:

| ネストスタック名 | 管理リソース | 再利用理由 |
|---------------|-------------|-----------|
| {nested_stack} | {リソース} | {理由} |

### 2.4 Parameter設計

**Parameter使用方針**:
- {どのようにParameterを設計したか}（例: 環境ごとに変わる値のみParameterとし、固定値はハードコーディング）

**主要Parameter**（詳細はコード参照）:

| Parameter名 | 用途 | なぜParameterにしたか |
|------------|------|---------------------|
| {ParameterName} | {用途} | {理由} |

---

## 3. セキュリティ考慮

### 3.1 アクセス制御

**IAMロール/ポリシー**:
- {どのような権限設計にしたか}（例: CloudFormation実行用のIAMロールは最小権限の原則に従い、必要なリソースのみに絞る）

**推奨IAMポリシー**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["cloudformation:CreateStack", "ec2:Describe*", ...],
      "Resource": "*"
    }
  ]
}
```

### 3.2 ネットワークセキュリティ

**セキュリティ設計のポイント**:
- {セキュリティグループ設計の考え方}（例: 最小権限の原則、インバウンドは必要最小限のポートのみ開放）
- {プライベートサブネット設計}（例: データベースは外部から直接アクセス不可）

**暗号化方針**:
- [ ] データ保存時の暗号化（KMS使用）
- [ ] 通信時の暗号化（TLS 1.2以上）

### 3.3 スタックポリシー

**スタックポリシー設定有無**:
- [ ] スタックポリシー設定（保護対象: {リソース}）
- [ ] スタックポリシー未設定

**保護対象リソースと理由**:
- {保護リソース1}: {保護理由}（例: VPCは誤削除防止のため、更新・削除を禁止）

**スタックポリシー例**:
```json
{
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "Update:Delete",
      "Principal": "*",
      "Resource": "LogicalResourceId/VPC"
    }
  ]
}
```

### 3.4 監査・ログ

**有効化するログ**:
- [ ] VPCフローログ（保存先: {CloudWatch Logs / S3}）
- [ ] CloudTrail（API操作の記録）
- [ ] Config（リソース構成変更の記録）

**ログ保持期間**:
- {保持期間とその理由}（例: 90日間、コンプライアンス要件により）

---

## 4. コスト考慮

### 4.1 コスト見積もり

**主要リソースの月額コスト（想定）**:

| リソース | 数量 | 単価（概算） | 月額コスト |
|---------|------|-------------|-----------|
| {リソース1} | {数量} | {単価} | ${金額} |
| {リソース2} | {数量} | {単価} | ${金額} |
| **合計** | - | - | **${合計}** |

**コスト最適化のポイント**:
- {最適化施策1}（例: NAT Gatewayの数を最小限に抑え、dev環境は1AZのみ）
- {最適化施策2}（例: 不要なEIPは削除し、課金を回避）

### 4.2 環境別コスト

| 環境 | 月額コスト（想定） | 備考 |
|------|------------------|------|
| Production | ${金額} | 3AZ構成 |
| Staging | ${金額} | 2AZ構成 |
| Development | ${金額} | 1AZ構成 |

---

## 5. 環境間の差分

### 5.1 環境パラメーター一覧

**重要な差分のみ記載**（詳細はparameters-{env}.json参照）:

| Parameter | Production | Staging | Development | 差分理由 |
|-----------|-----------|---------|-------------|---------|
| **AvailabilityZoneCount** | 3 | 2 | 1 | コスト最適化 |
| **NatGatewayCount** | 3 | 2 | 1 | 可用性 vs コスト |
| **EnableVpcFlowLogs** | true | true | false | 監査要件 |
| {Parameter名} | {値} | {値} | {値} | {理由} |

### 5.2 環境ごとの設計判断

**Production環境の特別な考慮事項**:
- {本番環境特有の設計}（例: 3AZ構成により単一AZ障害時も稼働継続）

**Development環境の簡略化ポイント**:
- {開発環境での簡略化内容}（例: NAT Gateway 1台に集約し、コストを80%削減）

---

## 6. 依存関係

### 6.1 前提条件

**このスタックを作成する前に必要なリソース**:

| リソース | 作成方法 | 確認コマンド |
|---------|---------|-------------|
| {リソース1} | {作成手順} | `aws cloudformation describe-stacks --stack-name {stack}` |

### 6.2 このスタックが提供するOutput

**他のスタックから参照されるOutput（Export）**:

| Output名 | Export名 | 内容 | 参照するスタック |
|---------|---------|------|----------------|
| VpcId | `${AWS::StackName}-VpcId` | VPC ID | SecuritySG, ApplicationECS |
| PrivateSubnetIds | `${AWS::StackName}-PrivateSubnetIds` | プライベートサブネットIDリスト | ApplicationECS |
| {Output名} | {Export名} | {内容} | {参照先} |

### 6.3 このスタックが参照するImport

**他のスタックから取得する値**:

| Import名 | 取得内容 | 提供元スタック |
|---------|---------|--------------|
| `Fn::ImportValue: !Sub ${NetworkStackName}-VpcId` | VPC ID | NetworkVPC |

---

## 7. 運用考慮

### 7.1 デプロイ手順

**初回デプロイ（Change Set使用推奨）**:
```bash
# 1. Change Set作成
aws cloudformation create-change-set \
  --stack-name {stack-name} \
  --template-body file://template.yaml \
  --parameters file://parameters-prod.json \
  --change-set-name initial-deployment

# 2. Change Set確認
aws cloudformation describe-change-set \
  --stack-name {stack-name} \
  --change-set-name initial-deployment

# 3. Change Set実行
aws cloudformation execute-change-set \
  --stack-name {stack-name} \
  --change-set-name initial-deployment
```

**変更デプロイ**:
```bash
# 1. Change Set作成
aws cloudformation create-change-set \
  --stack-name {stack-name} \
  --template-body file://template.yaml \
  --parameters file://parameters-prod.json \
  --change-set-name update-$(date +%Y%m%d-%H%M%S)

# 2. Change Set確認（必須）
aws cloudformation describe-change-set \
  --stack-name {stack-name} \
  --change-set-name update-YYYYMMDD-HHMMSS

# 3. レビュー後に実行
aws cloudformation execute-change-set \
  --stack-name {stack-name} \
  --change-set-name update-YYYYMMDD-HHMMSS
```

### 7.2 変更管理

**変更時の注意事項**:
- {注意事項1}（例: VPC CIDRの変更は既存リソースの再作成を伴うため、計画的なメンテナンス時に実施）
- {注意事項2}（例: NAT Gatewayの追加/削除は通信断が発生する可能性があるため、事前通知必須）

**破壊的変更リスクのあるリソース**:

| リソース | 変更内容 | 影響範囲 | 対策 |
|---------|---------|---------|------|
| {リソース} | {変更内容} | {影響範囲} | {対策} |

**DeletionPolicy設定**:

| リソース | DeletionPolicy | 理由 |
|---------|---------------|------|
| {リソース1} | Retain | {誤削除防止} |
| {リソース2} | Snapshot | {バックアップ取得後削除} |

### 7.3 Drift検出

**Drift検出の運用**:
- {Drift検出の頻度}（例: 週次で定期実行し、手動変更を検出）

**Drift検出コマンド**:
```bash
# Drift検出開始
aws cloudformation detect-stack-drift --stack-name {stack-name}

# Drift検出結果確認
aws cloudformation describe-stack-resource-drifts --stack-name {stack-name}
```

**Drift発生時の対応**:
1. 手動変更内容を確認
2. テンプレートに反映すべきか判断
3. 必要に応じてテンプレート更新 or リソース修正

### 7.4 Rollback方針

**Rollback設定**:
- [ ] 自動Rollback有効（OnFailure: ROLLBACK）
- [ ] 自動Rollback無効（OnFailure: DO_NOTHING）

**Rollback判断基準**:
- {どのような場合にRollbackするか}（例: リソース作成失敗時は自動Rollbackし、一貫性を保つ）

### 7.5 モニタリング

**監視項目**:
- {監視項目1}（例: VPCフローログの異常トラフィック検知）
- {監視項目2}（例: NAT Gatewayの帯域使用率）

**アラート設定**:
- {アラート条件}（例: NAT Gatewayの帯域が80%を超えたら通知）

---

## 8. 変更履歴

| バージョン | 日付 | 作成者 | 変更内容 |
|-----------|------|--------|---------|
| 1.0 | {YYYY/MM/DD} | {作成者名} | 初版作成 |
| {version} | {YYYY/MM/DD} | {作成者名} | {変更内容} |

---

## 📝 補足事項

### このテンプレートの使い方

1. **プレースホルダを置換**:
   - `{スタック名}`: 実際のスタック名（例: `NetworkVPC`, `SecuritySG`）
   - `{プロジェクト名}`: プロジェクト名
   - `{作成者名}`: 作成者名
   - `{YYYY/MM/DD}`: 日付

2. **不要なセクションは削除**:
   - このスタックに関係ないセクションは削除してOK
   - 例: ネストスタックを使わない場合は「2.3 ネストスタック使用方針」を削除

3. **10-15ページに収める**:
   - パラメーター一覧は記載しない（YAMLコード参照）
   - 設計判断と理由のみ記載

4. **コードとの関係**:
   - この文書: 設計判断（Why）
   - CloudFormationテンプレート: 実装（What）
   - **重複させない**

---

## ✅ レビューチェックリスト

- [ ] 設計判断の「理由」が明確に記載されているか
- [ ] パラメーター一覧になっていないか（コードを参照する形になっているか）
- [ ] セキュリティリスクが考慮されているか
- [ ] スタックポリシーの必要性が検討されているか
- [ ] DeletionPolicyが適切に設定されているか
- [ ] Change Setを使ったデプロイフローが記載されているか
- [ ] コスト見積もりが妥当か
- [ ] 環境間の差分が明確か
- [ ] Export/Import依存関係が明確か
- [ ] Drift検出の運用方針が定義されているか
- [ ] ページ数が10-15ページ以内か
