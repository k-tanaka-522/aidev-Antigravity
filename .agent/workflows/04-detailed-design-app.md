---
description: アプリケーション詳細設計フェーズ - ソフトウェア詳細設計（IPA共通フレーム2013 2.3.4準拠）
---

# アプリケーション詳細設計フェーズワークフロー

## 概要
IPA共通フレーム2013「2.3.4 ソフトウェア詳細設計」に準拠し、アプリケーションの詳細設計を行います。

## 入力確認
`templates/02_基本設計/実成果物/` の成果物を読み込んでください。

特に以下を重点的に参照：
- BD001_システム方式設計書.md
- BD002_アプリケーション方式設計書.md
- BD003_データベース方式設計書.md
- BD005_セキュリティ設計書.md

---

## ⚠️ 重要：大規模システム対応

### 文書分割の判断

**質問**: システムの規模はどのくらいですか？

- **クラス数10以下、ページ数50以下**:
  - 単一ファイルで作成（DD001-01_クラス設計書.md など）

- **クラス数10超、または ページ数50超**:
  - モジュール単位または機能単位で分割
  - DD000_詳細設計総括.md で索引を管理

参照: [ipa-detailed-design-scaling.md](../knowledge/documentation/ipa-detailed-design-scaling.md)

---

## 生成する成果物

### 出力先
`templates/04_詳細設計/実成果物/01_アプリ/`

### 小規模システム（単一ファイル）

```
実成果物/01_アプリ/
├── DD001-01_クラス設計書.md
├── DD002_データベース物理設計書.md
├── DD003_API設計書.md
└── DD004_単体テスト仕様書.md
```

### 大規模システム（モジュール分割）

```
実成果物/01_アプリ/
├── ユーザー管理/
│   ├── DD001-01_クラス設計書_認証モジュール.md
│   ├── DD001-02_クラス設計書_権限管理モジュール.md
│   ├── DD002_データベース物理設計書_ユーザーテーブル.md
│   ├── DD003_API設計書_ユーザー管理API.md
│   └── DD004_単体テスト仕様書_ユーザー管理.md
│
└── 注文管理/
    ├── DD001-01_クラス設計書_注文処理モジュール.md
    ├── DD002_データベース物理設計書_注文テーブル.md
    └── ...
```

---

## 必須成果物（IPA準拠）

テンプレートを使用して以下を作成してください：

### DD001-01_クラス設計書_template.md
- クラス図（Mermaid記法）
- メソッド定義
- 責務・制約

**ナレッジ参照**:
- `knowledge/application/backend/error-handling-patterns.md`
- `knowledge/application/backend/api-design-principles.md`

### DD002_データベース物理設計書_template.md
- テーブル定義（DDL含む）
- インデックス設計
- 制約定義

**ナレッジ参照**:
- `knowledge/database/index-strategy.md`
- `knowledge/database/schema-design-patterns.md`

### DD003_API設計書_template.md
- API一覧
- エンドポイント仕様（OpenAPI 3.0形式推奨）
- リクエスト/レスポンス

**ナレッジ参照**:
- `knowledge/application/backend/api-design-principles.md`
- `knowledge/security/authentication-patterns.md`

### DD004_単体テスト仕様書_template.md
- テストケース
- カバレッジ目標
- テストデータ

**ナレッジ参照**:
- `knowledge/testing/test-strategy.md`

---

## 完了条件

- [ ] すべてのアプリケーション詳細設計書（DD001-DD004）が作成完了
- [ ] クラス図、シーケンス図がMermaid記法で作成されている
- [ ] データベーステーブルのDDLが記載されている
- [ ] API仕様がOpenAPI形式で記載されている
- [ ] 設計レビュー完了（必要に応じて）

## 次フェーズ

### チーム分離がある場合
インフラチームが並行して作業中の場合、両チームの成果物が揃ったら：

→ /implementation を実行しますか？

### チーム分離がない場合
→ /detailed-design-infra を実行しますか？

---

## 参考資料

- [DD001-01_クラス設計書_template.md](../templates/04_詳細設計/DD001-01_クラス設計書_template.md)
- [DD002_データベース物理設計書_template.md](../templates/04_詳細設計/DD002_データベース物理設計書_template.md)
- [DD003_API設計書_template.md](../templates/04_詳細設計/DD003_API設計書_template.md)
- [DD004_単体テスト仕様書_template.md](../templates/04_詳細設計/DD004_単体テスト仕様書_template.md)
- [ipa-detailed-design-scaling.md](../knowledge/documentation/ipa-detailed-design-scaling.md)
- [team-separation-app-infra.md](../knowledge/documentation/team-separation-app-infra.md)
