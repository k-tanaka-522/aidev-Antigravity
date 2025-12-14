# REST API設計ベストプラクティス

**最終更新**: 2025-12-15
**対象**: RESTful API設計・実装全般

---

## 使用方法

このドキュメントは、REST APIの設計・実装時に参照してください：

- **設計フェーズ**: エンドポイント設計の指針
- **実装フェーズ**: コーディング規約の確認
- **レビューフェーズ**: API設計の妥当性検証
- **ドキュメント作成**: API仕様書作成の参考

---

## RESTful API 設計の原則

### 6つの基本原則

1. **リソース指向**: URLはリソースを表現し、動詞ではなく名詞を使用
2. **統一インターフェース**: HTTPメソッドを正しく使用
3. **ステートレス**: 各リクエストは独立し、セッション状態を持たない
4. **キャッシュ可能**: キャッシュ制御を適切に設定
5. **階層化**: レイヤー構造で責任を分離
6. **コードオンデマンド**: 必要に応じてクライアントコードを提供（オプション）

---

## 1. URL設計とリソース命名

### ✅ Good Practices

#### 名詞を使用し、動詞を避ける

**Good**:
```
GET    /api/users              # ユーザー一覧取得
GET    /api/users/123          # 特定ユーザー取得
POST   /api/users              # ユーザー作成
PUT    /api/users/123          # ユーザー更新
DELETE /api/users/123          # ユーザー削除
```

**Bad**:
```
GET    /api/getUsers           # NG: 動詞を使用
POST   /api/createUser         # NG: 動詞を使用
POST   /api/users/delete/123   # NG: DELETEメソッドを使うべき
GET    /api/user?action=list   # NG: アクションパラメータ
```

---

#### 複数形を使用する（一貫性）

**Good**:
```
/api/users              # 一貫して複数形
/api/users/123
/api/users/123/orders
/api/orders
```

**Bad**:
```
/api/user               # NG: 単数形と複数形が混在
/api/users/123
/api/user/123/order     # NG: 一貫性なし
```

---

#### ネストは2階層まで

**Good**:
```
GET /api/users/123/orders           # OK: 1階層ネスト
GET /api/orders?userId=123          # Better: クエリパラメータ推奨
```

**Bad**:
```
GET /api/users/123/orders/456/items/789  # NG: 深すぎるネスト
```

**推奨**: 深いネストは避け、クエリパラメータやリソース直接指定を使用
```
GET /api/order-items/789?orderId=456
```

---

#### ケバブケース使用

**Good**:
```
/api/user-profiles
/api/order-items
/api/payment-methods
```

**Bad**:
```
/api/userProfiles      # NG: キャメルケース
/api/user_profiles     # NG: スネークケース（URLでは非推奨）
```

---

## 2. HTTPメソッドの正しい使用

### メソッド一覧と用途

| メソッド | 用途 | 冪等性 | 安全性 | レスポンス |
|---------|------|--------|--------|-----------|
| **GET** | リソース取得 | ✅ | ✅ | 200, 404 |
| **POST** | リソース作成 | ❌ | ❌ | 201, 400 |
| **PUT** | リソース全体更新 | ✅ | ❌ | 200, 204 |
| **PATCH** | リソース部分更新 | ❌ | ❌ | 200, 204 |
| **DELETE** | リソース削除 | ✅ | ❌ | 204, 404 |

### Good / Bad Examples

#### GET - リソース取得

**Good**:
```javascript
// 一覧取得
GET /api/users?page=1&limit=20&sort=createdAt:desc
Response: 200 OK
{
  "data": [
    { "id": 1, "name": "John Doe", "email": "john@example.com" },
    { "id": 2, "name": "Jane Smith", "email": "jane@example.com" }
  ],
  "meta": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}

// 詳細取得
GET /api/users/123
Response: 200 OK
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

**Bad**:
```javascript
// NG: GETで状態変更
GET /api/users/123/activate    # GETは副作用を持つべきでない

// NG: GETでデータ送信（ボディは無視される）
GET /api/users
Body: { "filter": "active" }   # クエリパラメータを使うべき
```

---

#### POST - リソース作成

**Good**:
```javascript
POST /api/users
Content-Type: application/json

Request:
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response: 201 Created
Location: /api/users/124
{
  "id": 124,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2025-12-15T10:00:00Z"
}
```

**Bad**:
```javascript
// NG: POSTで更新（PUTかPATCHを使うべき）
POST /api/users/123/update

// NG: POSTでリソース指定
POST /api/users/123            # IDはサーバーが割り当てるべき
```

---

#### PUT - リソース全体更新

**Good**:
```javascript
PUT /api/users/123
Content-Type: application/json

Request:
{
  "name": "John Updated",
  "email": "john.updated@example.com",
  "phone": "+81-90-1234-5678"
}

Response: 200 OK
{
  "id": 123,
  "name": "John Updated",
  "email": "john.updated@example.com",
  "phone": "+81-90-1234-5678",
  "updatedAt": "2025-12-15T11:00:00Z"
}
```

**Bad**:
```javascript
// NG: 部分更新にPUTを使用（PATCHを使うべき）
PUT /api/users/123
{
  "name": "John Updated"
  // email等のフィールドが欠けている
}
```

---

#### PATCH - リソース部分更新

**Good**:
```javascript
PATCH /api/users/123
Content-Type: application/json

Request:
{
  "name": "John Partially Updated"
  // 他のフィールドは変更しない
}

Response: 200 OK
{
  "id": 123,
  "name": "John Partially Updated",
  "email": "john@example.com",  # 変更されていない
  "updatedAt": "2025-12-15T12:00:00Z"
}
```

---

#### DELETE - リソース削除

**Good**:
```javascript
DELETE /api/users/123

Response: 204 No Content
// または
Response: 200 OK
{
  "message": "User deleted successfully",
  "deletedId": 123
}
```

**Bad**:
```javascript
// NG: DELETEでボディを期待
DELETE /api/users
Body: { "id": 123 }            # リソースはURLで指定すべき

// 正しくは
DELETE /api/users/123
```

---

## 3. ステータスコードの適切な使用

### 成功レスポンス (2xx)

| コード | 意味 | 使用場面 |
|-------|------|---------|
| **200 OK** | 成功 | GET, PUT, PATCH成功時 |
| **201 Created** | 作成成功 | POST成功時、Locationヘッダー付与 |
| **204 No Content** | 成功（ボディなし） | DELETE成功時 |

### クライアントエラー (4xx)

| コード | 意味 | 使用場面 |
|-------|------|---------|
| **400 Bad Request** | リクエスト不正 | バリデーションエラー |
| **401 Unauthorized** | 認証失敗 | トークン不正・期限切れ |
| **403 Forbidden** | 権限不足 | アクセス権限なし |
| **404 Not Found** | リソース不在 | 存在しないリソース |
| **409 Conflict** | 競合 | 重複データ、楽観的ロック失敗 |
| **422 Unprocessable Entity** | 処理不可 | ビジネスロジック違反 |
| **429 Too Many Requests** | レート制限 | リクエスト過多 |

### サーバーエラー (5xx)

| コード | 意味 | 使用場面 |
|-------|------|---------|
| **500 Internal Server Error** | サーバーエラー | 予期しないエラー |
| **502 Bad Gateway** | ゲートウェイエラー | 外部API障害 |
| **503 Service Unavailable** | サービス停止 | メンテナンス中 |

### Good / Bad Examples

**Good**:
```javascript
// バリデーションエラー
POST /api/users
Response: 400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ]
  }
}

// 認証エラー
GET /api/users/profile
Response: 401 Unauthorized
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Authentication token is invalid or expired"
  }
}

// リソース不在
GET /api/users/99999
Response: 404 Not Found
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User with ID 99999 not found"
  }
}

// 重複エラー
POST /api/users
Response: 409 Conflict
{
  "error": {
    "code": "DUPLICATE_ENTRY",
    "message": "User with this email already exists"
  }
}
```

**Bad**:
```javascript
// NG: すべて200で返す
POST /api/users
Response: 200 OK
{
  "success": false,
  "error": "Email already exists"  # 409を使うべき
}

// NG: 不適切なステータスコード
GET /api/users/99999
Response: 500 Internal Server Error  # 404を使うべき
{
  "error": "User not found"
}
```

---

## 4. リクエスト・レスポンス設計

### JSON形式の統一

**Good**:
```javascript
// 成功レスポンス
{
  "data": { /* リソースデータ */ },
  "meta": { /* メタデータ */ }
}

// エラーレスポンス
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [ /* 詳細情報 */ ]
  }
}
```

**Bad**:
```javascript
// NG: 一貫性のないレスポンス
// 成功時
{ "user": { ... } }

// エラー時
{ "error_message": "..." }  # 構造が異なる
```

---

### フィールド命名規則

**Good**: キャメルケース（JavaScript慣習）
```json
{
  "userId": 123,
  "firstName": "John",
  "lastName": "Doe",
  "createdAt": "2025-12-15T00:00:00Z"
}
```

**Bad**:
```json
{
  "user_id": 123,        // NG: スネークケース
  "FirstName": "John",   // NG: パスカルケース
  "created-at": "..."    // NG: ケバブケース
}
```

---

### 日付フォーマット

**Good**: ISO 8601形式（UTC）
```json
{
  "createdAt": "2025-12-15T10:30:00Z",
  "updatedAt": "2025-12-15T15:45:30.123Z"
}
```

**Bad**:
```json
{
  "createdAt": "2025/12/15 10:30:00",  // NG: 独自フォーマット
  "updatedAt": 1734270330              // NG: UNIXタイムスタンプ（クライアントで変換が必要）
}
```

---

## 5. ページネーション

### オフセットベース（推奨: 小〜中規模データ）

**Good**:
```javascript
GET /api/users?page=2&limit=20

Response: 200 OK
{
  "data": [ /* 20件のユーザー */ ],
  "meta": {
    "total": 150,
    "page": 2,
    "limit": 20,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  },
  "links": {
    "first": "/api/users?page=1&limit=20",
    "prev": "/api/users?page=1&limit=20",
    "next": "/api/users?page=3&limit=20",
    "last": "/api/users?page=8&limit=20"
  }
}
```

### カーソルベース（推奨: 大規模データ・リアルタイム）

**Good**:
```javascript
GET /api/posts?cursor=eyJpZCI6MTAwfQ==&limit=20

Response: 200 OK
{
  "data": [ /* 20件の投稿 */ ],
  "meta": {
    "limit": 20,
    "hasNext": true
  },
  "links": {
    "next": "/api/posts?cursor=eyJpZCI6MTIwfQ==&limit=20"
  }
}
```

---

## 6. フィルタリング・ソート・検索

### フィルタリング

**Good**:
```javascript
// 単一条件
GET /api/users?status=active

// 複数条件
GET /api/users?status=active&role=admin&createdAfter=2025-01-01

// 範囲指定
GET /api/products?priceMin=1000&priceMax=5000
```

### ソート

**Good**:
```javascript
// 昇順
GET /api/users?sort=createdAt

// 降順
GET /api/users?sort=-createdAt

// 複数カラム
GET /api/users?sort=-createdAt,name
```

### 検索

**Good**:
```javascript
// 全文検索
GET /api/users?q=john

// フィールド指定検索
GET /api/users?search=name:john,email:example.com
```

---

## 7. APIバージョニング

### URLバージョニング（推奨）

**Good**:
```
/api/v1/users
/api/v2/users
```

**理由**: 明示的でわかりやすい、ブラウザで直接アクセス可能

### ヘッダーバージョニング

**Good**:
```
GET /api/users
Accept: application/vnd.myapi.v2+json
```

**理由**: URLを変えずにバージョン管理可能

### Bad Practice

**Bad**:
```
GET /api/users?version=2   # NG: クエリパラメータは非推奨
```

---

## 8. エラーハンドリング

### 詳細なエラーレスポンス

**Good**:
```javascript
Response: 400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email format is invalid"
      },
      {
        "field": "password",
        "code": "TOO_SHORT",
        "message": "Password must be at least 8 characters",
        "minLength": 8,
        "providedLength": 5
      }
    ],
    "timestamp": "2025-12-15T10:00:00Z",
    "path": "/api/users",
    "requestId": "req-123456"
  }
}
```

**Bad**:
```javascript
// NG: 曖昧なエラー
Response: 400 Bad Request
{
  "error": "Invalid input"  // 何が悪いのか不明
}

// NG: 技術的詳細の露出
Response: 500 Internal Server Error
{
  "error": "SQLException: Duplicate entry 'john@example.com' for key 'email'"
  // DBエラーをそのまま返すのはセキュリティリスク
}
```

---

## 9. 認証・認可

### JWTトークン認証（推奨）

**Good**:
```javascript
// リクエスト
GET /api/users/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

// レスポンス
Response: 200 OK
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com"
}

// 認証エラー
Response: 401 Unauthorized
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Token is invalid or expired"
  }
}

// 権限エラー
Response: 403 Forbidden
{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "You do not have permission to access this resource",
    "requiredRole": "admin",
    "currentRole": "user"
  }
}
```

---

## 10. レート制限

### ヘッダーでの通知

**Good**:
```javascript
GET /api/users

Response: 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 950
X-RateLimit-Reset: 1734270000

// 制限超過時
Response: 429 Too Many Requests
Retry-After: 3600
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded",
    "limit": 1000,
    "resetAt": "2025-12-15T11:00:00Z"
  }
}
```

---

## 11. HATEOAS（Hypermedia）

### リンク提供による発見可能性

**Good**:
```javascript
GET /api/users/123

Response: 200 OK
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "_links": {
    "self": { "href": "/api/users/123" },
    "orders": { "href": "/api/users/123/orders" },
    "update": { "href": "/api/users/123", "method": "PUT" },
    "delete": { "href": "/api/users/123", "method": "DELETE" }
  }
}
```

---

## 12. ヘッダー活用

### 必須ヘッダー

**Good**:
```javascript
// リクエスト
Content-Type: application/json
Accept: application/json
Authorization: Bearer <token>

// レスポンス
Content-Type: application/json; charset=utf-8
Cache-Control: no-cache, no-store, must-revalidate
X-Request-ID: req-123456
```

---

## チェックリスト

### URL設計
- [ ] リソース名は名詞を使用
- [ ] 複数形で統一
- [ ] ケバブケース使用
- [ ] ネストは2階層まで

### HTTPメソッド
- [ ] GETは副作用なし
- [ ] POSTは新規作成のみ
- [ ] PUTとPATCHを適切に使い分け
- [ ] DELETEは冪等性を保証

### ステータスコード
- [ ] 適切な2xx/4xx/5xxを返却
- [ ] エラー時は詳細情報提供
- [ ] 401と403を正しく使い分け

### レスポンス設計
- [ ] JSON形式で統一
- [ ] キャメルケース使用
- [ ] ISO 8601日付形式
- [ ] ページネーション実装

### セキュリティ
- [ ] JWT認証実装
- [ ] HTTPS必須
- [ ] レート制限設定
- [ ] 入力値検証

### ドキュメント
- [ ] OpenAPI (Swagger) 仕様書
- [ ] エンドポイント一覧
- [ ] サンプルリクエスト/レスポンス
- [ ] エラーコード一覧

---

## まとめ

このベストプラクティスに従うことで：

- ✅ 一貫性のあるAPI設計
- ✅ 開発者フレンドリーなインターフェース
- ✅ 保守性・拡張性の高いAPI
- ✅ セキュアで信頼性の高いAPI

API設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [RESTful API Design Best Practices](https://restfulapi.net/)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- [Google API Design Guide](https://cloud.google.com/apis/design)
- [OpenAPI Specification](https://swagger.io/specification/)
