# 外部インターフェース設計書

## ドキュメント情報

| 項目 | 内容 |
|------|------|
| ドキュメントID | BD005 |
| ドキュメント名 | 外部インターフェース設計書 |
| システム名 | {システム名} |
| サブシステム名 | {サブシステム名} |
| 版数 | {版数} |
| ステータス | {作成中/レビュー中/承認済み} |
| 作成日 | {YYYY/MM/DD} |
| 作成者 | {作成者名} |
| 承認日 | {YYYY/MM/DD} |
| 承認者 | {承認者名} |

## 変更履歴

| 版数 | 変更日 | 変更者 | 変更内容 | 承認者 |
|------|--------|--------|----------|--------|
| 1.0 | {YYYY/MM/DD} | {変更者名} | 新規作成 | {承認者名} |
| {版数} | {YYYY/MM/DD} | {変更者名} | {変更内容} | {承認者名} |

## 目次

1. [概要](#概要)
2. [インターフェース一覧](#インターフェース一覧)
3. [API仕様](#api仕様)
4. [データ連携仕様](#データ連携仕様)
5. [エラーハンドリング](#エラーハンドリング)

---

## 概要

### 目的

{この外部インターフェース設計書の目的を記述}

### 適用範囲

{この外部インターフェース設計書が適用される範囲を記述}

### インターフェース種別

| 種別 | 説明 | プロトコル |
|------|------|------------|
| REST API | RESTful API による同期通信 | HTTP/HTTPS |
| GraphQL API | GraphQL による柔軟なデータ取得 | HTTP/HTTPS |
| WebSocket | リアルタイム双方向通信 | WebSocket |
| ファイル連携 | ファイルベースのデータ連携 | SFTP/S3/共有フォルダ |
| メッセージング | 非同期メッセージング | Kafka/RabbitMQ/SQS |
| データベース連携 | データベース直接接続 | JDBC/ODBC |

---

## インターフェース一覧

### 外部システム連携一覧

| IF ID | インターフェース名 | 連携先システム | 連携方向 | IF種別 | プロトコル | 頻度 | 優先度 | 備考 |
|-------|-------------------|----------------|----------|--------|------------|------|--------|------|
| {IF-XXX} | {IF名} | {システム名} | {送信/受信/双方向} | {種別} | {プロトコル} | {頻度} | {高/中/低} | {備考} |
| IF-001 | 決済API | 決済代行サービス | 送信 | REST API | HTTPS | リアルタイム | 高 | |
| IF-002 | 在庫照会API | 在庫管理システム | 受信 | REST API | HTTPS | リアルタイム | 高 | |
| IF-003 | 顧客情報同期 | CRMシステム | 双方向 | REST API | HTTPS | 15分毎 | 中 | |
| IF-004 | 売上データ連携 | 会計システム | 送信 | ファイル連携 | SFTP | 日次 | 高 | CSV形式 |
| IF-005 | メール送信 | メール配信サービス | 送信 | REST API | HTTPS | イベント駆動 | 中 | |
| IF-006 | SMS送信 | SMS送信サービス | 送信 | REST API | HTTPS | イベント駆動 | 中 | |
| IF-007 | 物流連携 | 物流システム | 送信 | REST API | HTTPS | 注文確定時 | 高 | |
| IF-008 | 位置情報取得 | 地図API | 受信 | REST API | HTTPS | リアルタイム | 低 | |

---

## API仕様

### API仕様テンプレート

各APIについて以下の形式で詳細を記述します。

---

#### API ID: {IF-XXX}

##### 基本情報

| 項目 | 内容 |
|------|------|
| API ID | {IF-XXX} |
| API名 | {API名} |
| 連携先システム | {システム名} |
| 連携方向 | {送信/受信} |
| エンドポイント | {URL} |
| HTTPメソッド | {GET/POST/PUT/DELETE/PATCH} |
| 認証方式 | {API Key/OAuth 2.0/JWT/Basic認証} |
| データ形式 | {JSON/XML/Form Data} |
| タイムアウト | {秒数}秒 |
| リトライ | {回数}回（{間隔}秒間隔） |
| 関連機能ID | {F-XX-YY-ZZ} |

##### リクエスト仕様

**HTTPヘッダー**

| ヘッダー名 | 必須 | 値 | 説明 |
|------------|------|-----|------|
| {ヘッダー名} | {○/×} | {値} | {説明} |

**リクエストパラメータ**

| パラメータ名 | 配置 | 必須 | 型 | 形式 | 説明 | 例 |
|--------------|------|------|-----|------|------|-----|
| {パラメータ名} | {Path/Query/Body} | {○/×} | {型} | {形式} | {説明} | {例} |

**リクエストボディ（JSON形式の場合）**

```json
{
  "field1": "value1",
  "field2": 123,
  "field3": {
    "nested_field": "value"
  }
}
```

##### レスポンス仕様

**成功時（200 OK）**

```json
{
  "status": "success",
  "data": {
    "field1": "value1",
    "field2": 123
  }
}
```

**レスポンス項目**

| 項目名 | 型 | 必須 | 説明 | 例 |
|--------|-----|------|------|-----|
| {項目名} | {型} | {○/×} | {説明} | {例} |

**エラー時**

| HTTPステータス | エラーコード | エラーメッセージ | 説明 | 対処方法 |
|----------------|--------------|------------------|------|----------|
| {ステータスコード} | {コード} | {メッセージ} | {説明} | {対処方法} |

---

### IF-001: 決済API

##### 基本情報

| 項目 | 内容 |
|------|------|
| API ID | IF-001 |
| API名 | 決済実行API |
| 連携先システム | Stripe決済サービス |
| 連携方向 | 送信 |
| エンドポイント | https://api.stripe.com/v1/payment_intents |
| HTTPメソッド | POST |
| 認証方式 | API Key（Bearer Token） |
| データ形式 | JSON |
| タイムアウト | 30秒 |
| リトライ | 3回（5秒間隔） |
| 関連機能ID | F-03-03-01 |

##### リクエスト仕様

**HTTPヘッダー**

| ヘッダー名 | 必須 | 値 | 説明 |
|------------|------|-----|------|
| Authorization | ○ | Bearer {API_KEY} | API認証キー |
| Content-Type | ○ | application/json | リクエストボディ形式 |
| Idempotency-Key | ○ | {UUID} | 冪等性キー（重複防止） |

**リクエストボディ**

```json
{
  "amount": 10000,
  "currency": "jpy",
  "payment_method": "pm_card_visa",
  "customer": "cus_xxxxxxxxxxxxx",
  "description": "注文ID: ORD-2024010001",
  "metadata": {
    "order_id": "ORD-2024010001",
    "customer_id": "CUST-001"
  }
}
```

**リクエストパラメータ**

| パラメータ名 | 配置 | 必須 | 型 | 形式 | 説明 | 例 |
|--------------|------|------|-----|------|------|-----|
| amount | Body | ○ | Integer | 最小通貨単位 | 決済金額（円の場合は1円単位） | 10000 |
| currency | Body | ○ | String | ISO 4217 | 通貨コード | "jpy" |
| payment_method | Body | ○ | String | - | 決済方法ID | "pm_card_visa" |
| customer | Body | ○ | String | - | 顧客ID | "cus_xxxxxxxxxxxxx" |
| description | Body | × | String | 最大1000文字 | 決済の説明 | "注文ID: ORD-001" |
| metadata | Body | × | Object | - | メタデータ（キーバリュー） | {"order_id": "ORD-001"} |

##### レスポンス仕様

**成功時（200 OK）**

```json
{
  "id": "pi_xxxxxxxxxxxxx",
  "object": "payment_intent",
  "amount": 10000,
  "currency": "jpy",
  "status": "succeeded",
  "client_secret": "pi_xxxxxxxxxxxxx_secret_xxxxxxxxxxxxx",
  "created": 1704067200,
  "customer": "cus_xxxxxxxxxxxxx",
  "description": "注文ID: ORD-2024010001",
  "metadata": {
    "order_id": "ORD-2024010001",
    "customer_id": "CUST-001"
  }
}
```

**レスポンス項目**

| 項目名 | 型 | 必須 | 説明 | 例 |
|--------|-----|------|------|-----|
| id | String | ○ | PaymentIntent ID | "pi_xxxxxxxxxxxxx" |
| object | String | ○ | オブジェクト種別 | "payment_intent" |
| amount | Integer | ○ | 決済金額 | 10000 |
| currency | String | ○ | 通貨コード | "jpy" |
| status | String | ○ | ステータス（succeeded/processing/requires_action） | "succeeded" |
| client_secret | String | ○ | クライアントシークレット | "pi_xxx_secret_xxx" |
| created | Integer | ○ | 作成日時（Unixタイムスタンプ） | 1704067200 |

**エラー時**

| HTTPステータス | エラーコード | エラーメッセージ | 説明 | 対処方法 |
|----------------|--------------|------------------|------|----------|
| 400 | invalid_request_error | Invalid amount | 金額が不正 | 金額を確認して再実行 |
| 402 | card_error | Your card was declined | カード決済が拒否された | 別の決済方法を試す |
| 401 | authentication_error | Invalid API Key | API Key が無効 | API Keyを確認 |
| 429 | rate_limit_error | Too many requests | レート制限超過 | 時間を置いて再実行 |
| 500 | api_error | Internal server error | サーバーエラー | 時間を置いて再実行 |

##### データマッピング

| システム項目 | 外部API項目 | 変換ルール |
|--------------|-------------|------------|
| orders.total_amount | amount | 円→最小通貨単位（円の場合そのまま） |
| orders.order_id | metadata.order_id | 文字列変換 |
| customers.customer_code | customer | Stripe顧客IDに変換 |
| payment_methods.payment_method_id | payment_method | Stripe決済方法IDに変換 |

---

### IF-002: 在庫照会API

##### 基本情報

| 項目 | 内容 |
|------|------|
| API ID | IF-002 |
| API名 | 在庫照会API |
| 連携先システム | 在庫管理システム |
| 連携方向 | 受信 |
| エンドポイント | https://inventory.example.com/api/v1/stock/{product_id} |
| HTTPメソッド | GET |
| 認証方式 | OAuth 2.0（Client Credentials） |
| データ形式 | JSON |
| タイムアウト | 10秒 |
| リトライ | 2回（3秒間隔） |
| 関連機能ID | F-03-02-01 |

##### リクエスト仕様

**HTTPヘッダー**

| ヘッダー名 | 必須 | 値 | 説明 |
|------------|------|-----|------|
| Authorization | ○ | Bearer {ACCESS_TOKEN} | OAuth 2.0 アクセストークン |
| Accept | ○ | application/json | レスポンス形式 |

**リクエストパラメータ**

| パラメータ名 | 配置 | 必須 | 型 | 形式 | 説明 | 例 |
|--------------|------|------|-----|------|------|-----|
| product_id | Path | ○ | String | - | 商品ID | "PROD-001" |
| warehouse_id | Query | × | String | - | 倉庫ID（省略時は全倉庫） | "WH-001" |

##### レスポンス仕様

**成功時（200 OK）**

```json
{
  "product_id": "PROD-001",
  "product_name": "商品A",
  "total_quantity": 150,
  "available_quantity": 120,
  "reserved_quantity": 30,
  "warehouses": [
    {
      "warehouse_id": "WH-001",
      "warehouse_name": "東京倉庫",
      "quantity": 80
    },
    {
      "warehouse_id": "WH-002",
      "warehouse_name": "大阪倉庫",
      "quantity": 40
    }
  ],
  "last_updated": "2024-01-15T10:30:00Z"
}
```

**レスポンス項目**

| 項目名 | 型 | 必須 | 説明 | 例 |
|--------|-----|------|------|-----|
| product_id | String | ○ | 商品ID | "PROD-001" |
| product_name | String | ○ | 商品名 | "商品A" |
| total_quantity | Integer | ○ | 総在庫数 | 150 |
| available_quantity | Integer | ○ | 利用可能在庫数 | 120 |
| reserved_quantity | Integer | ○ | 引当済み在庫数 | 30 |
| warehouses | Array | ○ | 倉庫別在庫情報 | [...] |
| last_updated | String | ○ | 最終更新日時（ISO 8601） | "2024-01-15T10:30:00Z" |

---

## データ連携仕様

### ファイル連携仕様

#### IF-004: 売上データ連携

##### 基本情報

| 項目 | 内容 |
|------|------|
| IF ID | IF-004 |
| IF名 | 売上データ連携 |
| 連携先システム | 会計システム |
| 連携方向 | 送信 |
| ファイル形式 | CSV |
| 文字コード | UTF-8 with BOM |
| 連携方式 | SFTP |
| 連携頻度 | 日次（毎日2:00） |
| ファイル名規則 | sales_YYYYMMDD.csv |
| 配置先 | /upload/sales/ |

##### ファイル仕様

**ヘッダー行**

```csv
売上日,伝票番号,顧客コード,顧客名,商品コード,商品名,数量,単価,金額,消費税,合計金額
```

**データ行例**

```csv
2024-01-15,INV-001,CUST-001,株式会社A,PROD-001,商品A,10,1000,10000,1000,11000
2024-01-15,INV-002,CUST-002,株式会社B,PROD-002,商品B,5,2000,10000,1000,11000
```

**項目定義**

| 項目No | 項目名 | 型 | 桁数 | 必須 | 形式 | 説明 |
|--------|--------|-----|------|------|------|------|
| 1 | 売上日 | Date | 10 | ○ | YYYY-MM-DD | 売上が発生した日付 |
| 2 | 伝票番号 | String | 20 | ○ | - | 売上伝票番号 |
| 3 | 顧客コード | String | 20 | ○ | - | 顧客コード |
| 4 | 顧客名 | String | 100 | ○ | - | 顧客名 |
| 5 | 商品コード | String | 20 | ○ | - | 商品コード |
| 6 | 商品名 | String | 200 | ○ | - | 商品名 |
| 7 | 数量 | Integer | 10 | ○ | 数値のみ | 販売数量 |
| 8 | 単価 | Decimal | 12,2 | ○ | 小数点以下2桁 | 販売単価 |
| 9 | 金額 | Decimal | 12,2 | ○ | 小数点以下2桁 | 売上金額（数量×単価） |
| 10 | 消費税 | Decimal | 12,2 | ○ | 小数点以下2桁 | 消費税額 |
| 11 | 合計金額 | Decimal | 12,2 | ○ | 小数点以下2桁 | 合計金額（金額+消費税） |

##### データマッピング

| システムテーブル.カラム | ファイル項目 | 変換ルール |
|-------------------------|--------------|------------|
| sales.sales_date | 売上日 | YYYY-MM-DD形式 |
| sales.sales_number | 伝票番号 | そのまま |
| customers.customer_code | 顧客コード | そのまま |
| customers.customer_name | 顧客名 | そのまま |
| products.product_code | 商品コード | そのまま |
| products.product_name | 商品名 | そのまま |
| sales_details.quantity | 数量 | 数値のみ |
| sales_details.unit_price | 単価 | 小数点以下2桁 |
| sales_details.amount | 金額 | 小数点以下2桁 |
| sales_details.tax | 消費税 | 小数点以下2桁 |
| sales_details.total_amount | 合計金額 | 小数点以下2桁 |

##### エラー処理

| エラー種別 | 検出タイミング | 対処方法 |
|------------|----------------|----------|
| ファイル作成失敗 | バッチ実行時 | エラーログ出力、管理者通知 |
| SFTP接続失敗 | アップロード時 | 3回リトライ、失敗時は管理者通知 |
| データ不正 | ファイル作成時 | エラーログ出力、該当データをスキップ |

---

### メッセージング仕様

#### IF-009: 注文イベント通知

##### 基本情報

| 項目 | 内容 |
|------|------|
| IF ID | IF-009 |
| IF名 | 注文イベント通知 |
| メッセージングシステム | Apache Kafka |
| トピック名 | order.events |
| パーティション数 | 3 |
| レプリケーション数 | 2 |
| メッセージ形式 | JSON |
| 送信側 | 注文サービス |
| 受信側 | 在庫サービス、物流サービス、通知サービス |

##### メッセージ仕様

**メッセージキー**

```
{order_id}
```

**メッセージバリュー（JSON）**

```json
{
  "event_id": "evt_xxxxxxxxxxxxx",
  "event_type": "order.created",
  "event_timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "order_id": "ORD-2024010001",
    "customer_id": "CUST-001",
    "order_date": "2024-01-15",
    "total_amount": 11000,
    "items": [
      {
        "product_id": "PROD-001",
        "product_name": "商品A",
        "quantity": 10,
        "unit_price": 1000,
        "amount": 10000
      }
    ],
    "shipping_address": {
      "postal_code": "123-4567",
      "prefecture": "東京都",
      "city": "千代田区",
      "address": "丸の内1-1-1"
    }
  }
}
```

##### イベント種別

| イベントタイプ | 説明 | トリガー |
|----------------|------|----------|
| order.created | 注文作成 | 注文登録完了時 |
| order.updated | 注文更新 | 注文情報変更時 |
| order.cancelled | 注文キャンセル | 注文キャンセル時 |
| order.shipped | 注文出荷 | 出荷完了時 |
| order.delivered | 注文配達完了 | 配達完了時 |

---

## エラーハンドリング

### エラー分類

| エラー分類 | 説明 | 対処方針 |
|------------|------|----------|
| ネットワークエラー | タイムアウト、接続失敗 | リトライ実行 |
| 認証エラー | 認証失敗、トークン期限切れ | トークン再取得後リトライ |
| バリデーションエラー | リクエストパラメータ不正 | エラーログ記録、ユーザーへエラー通知 |
| ビジネスエラー | 在庫不足、重複登録など | エラーログ記録、ユーザーへエラー通知 |
| システムエラー | 外部システム障害 | エラーログ記録、管理者通知、リトライ |

### リトライポリシー

| API ID | リトライ回数 | リトライ間隔 | リトライ対象エラー |
|--------|--------------|--------------|-------------------|
| IF-001 | 3回 | 5秒 | ネットワークエラー、5xx系エラー |
| IF-002 | 2回 | 3秒 | ネットワークエラー、5xx系エラー |
| IF-003 | 3回 | 10秒（指数バックオフ） | ネットワークエラー、429エラー、5xx系エラー |

### ロギング仕様

| ログレベル | 出力内容 |
|------------|----------|
| INFO | API呼び出し開始、API呼び出し成功 |
| WARN | リトライ実行、タイムアウト警告 |
| ERROR | API呼び出し失敗、認証エラー、システムエラー |

**ログ出力項目**

- タイムスタンプ
- ログレベル
- API ID
- リクエストID（トレーシング用）
- HTTPメソッド
- エンドポイント
- リクエストパラメータ（機密情報はマスク）
- レスポンスステータス
- レスポンスボディ（機密情報はマスク）
- エラーメッセージ
- 処理時間

---

## 承認

| 役割 | 氏名 | 承認日 | 署名 |
|------|------|--------|------|
| 作成者 | {作成者名} | {YYYY/MM/DD} | |
| レビュー担当者 | {レビュー担当者名} | {YYYY/MM/DD} | |
| 承認者 | {承認者名} | {YYYY/MM/DD} | |

---

## 参照

### 関連ドキュメント

- [機能設計書] BD002_機能設計書
- [ソフトウェア構成図] BD001-03_ソフトウェア構成図
- [データベース設計書] BD006-XX_データベース設計書

### 外部参照

- {参照先タイトル}: {URL}
