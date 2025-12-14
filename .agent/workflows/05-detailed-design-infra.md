---
description: インフラ詳細設計フェーズ - IaCスタック設計（IPA共通フレーム2013 2.3.4準拠）
---

# インフラ詳細設計フェーズワークフロー

## 概要
IPA共通フレーム2013「2.3.4 ソフトウェア詳細設計」に準拠し、インフラストラクチャの詳細設計（IaCスタック設計）を行います。

## 入力確認
`templates/02_基本設計/実成果物/` の成果物を読み込んでください。

特に以下を重点的に参照：
- BD004_ネットワーク構成設計書.md
- BD005_セキュリティ設計書.md
- BD009_IaC設計書.md ⭐（スタック分割方針、State管理方針）

---

## ⚠️ 重要：IaC設計書の方針

### 軽量設計書アプローチ

**従来の課題**:
- ❌ パラメーター一覧になりがち（100ページ超）
- ❌ コードと重複した情報

**Antigravityの方針**:
- ✅ **設計判断（Why）のみ記載**（10-15ページ）
- ✅ パラメーター値はコード参照
- ✅ コスト見積もり、環境間差分、セキュリティ考慮を重点化

---

## 生成する成果物

### 出力先
`templates/04_詳細設計/実成果物/02_インフラ/`

### IaCツール選択

**質問**: IaCツールは何を使用しますか？

- **Terraform**: DD-INF001_Terraformスタック設計書_template.md を使用
- **CloudFormation**: DD-INF002_CloudFormationスタック設計書_template.md を使用
- **両方**: 両方のテンプレートを使用

### ディレクトリ構造

```
実成果物/02_インフラ/
├── network/
│   └── DD-INF001_Terraformスタック設計書_VPC.md
│
├── security/
│   └── DD-INF001_Terraformスタック設計書_SecurityGroup.md
│
├── application-platform/
│   ├── DD-INF001_Terraformスタック設計書_ECS.md
│   └── DD-INF001_Terraformスタック設計書_RDS.md
│
└── monitoring/
    └── DD-INF001_Terraformスタック設計書_CloudWatch.md
```

---

## 必須成果物（IPA準拠）

テンプレートを使用して以下を作成してください：

### DD-INF001_Terraformスタック設計書_template.md

または

### DD-INF002_CloudFormationスタック設計書_template.md

各スタックについて、以下を記載：

#### 1. スタック概要
- スタック名
- 責務範囲
- 依存関係

#### 2. 設計判断（Why）⭐
- **採用構成**: なぜこの構成を選んだか
- **判断理由**: 非機能要件との紐付け
- **代替案**: 検討した他の選択肢と却下理由
- **コスト**: 月額コスト見積もり

#### 3. 環境間差分
- dev/stg/prodの差分
- パラメーター化する項目

#### 4. セキュリティ考慮
- セキュリティグループ設計
- IAMロール設計
- 暗号化方針

#### 5. リソース一覧（概要のみ）
- パラメーター詳細はコード参照

**ナレッジ参照**:
- `knowledge/iac/terraform-best-practices.md`
- `knowledge/iac/cloudformation-patterns.md`
- `knowledge/security/authentication-patterns.md`

---

## スタック分割の判断

### 推奨分割単位

| スタック | 含まれるリソース | 変更頻度 |
|---------|----------------|---------|
| network | VPC、サブネット、IGW、NAT | 低 |
| security | SecurityGroup、NACLs、IAMロール | 中 |
| application-platform | ECS、RDS、ElastiCache | 高 |
| monitoring | CloudWatch、SNS | 中 |

**判断基準**:
- 変更頻度が異なるリソースは分割
- ライフサイクルが異なるリソースは分割
- 依存関係が複雑な場合は分割

参照: [BD009_IaC設計書_template.md](../templates/02_基本設計/BD009_IaC設計書_template.md)

---

## 完了条件

- [ ] すべてのIaCスタック設計書が作成完了
- [ ] 各スタックで設計判断（Why）が明確に記載されている
- [ ] コスト見積もりが記載されている
- [ ] 環境間差分が明確になっている
- [ ] セキュリティ考慮が記載されている
- [ ] スタック間の依存関係が明確になっている
- [ ] 設計レビュー完了（必要に応じて）

## 次フェーズ

### チーム分離がある場合
アプリチームが並行して作業中の場合、両チームの成果物が揃ったら：

→ /implementation を実行しますか？（IaCコード作成）

### チーム分離がない場合
→ /implementation を実行しますか？

---

## 参考資料

- [DD-INF001_Terraformスタック設計書_template.md](../templates/04_詳細設計/DD-INF001_Terraformスタック設計書_template.md)
- [DD-INF002_CloudFormationスタック設計書_template.md](../templates/04_詳細設計/DD-INF002_CloudFormationスタック設計書_template.md)
- [BD009_IaC設計書_template.md](../templates/02_基本設計/BD009_IaC設計書_template.md)
- [terraform-best-practices.md](../knowledge/iac/terraform-best-practices.md)
- [cloudformation-patterns.md](../knowledge/iac/cloudformation-patterns.md)
- [team-separation-app-infra.md](../knowledge/documentation/team-separation-app-infra.md)
