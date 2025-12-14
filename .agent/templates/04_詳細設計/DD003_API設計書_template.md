# API設計書

## ドキュメント情報

| 項目 | 内容 |
|------|------|
| ドキュメントID | DD003-{YYYYMMDD} |
| プロジェクト名 | {プロジェクト名} |
| サブシステム名 | {サブシステム名} |
| API名 | {API名} |
| 作成日 | {YYYY/MM/DD} |
| 作成者 | {作成者名} |
| 最終更新日 | {YYYY/MM/DD} |
| 最終更新者 | {更新者名} |
| 版数 | {1.0} |
| 承認者 | {承認者名} |
| 承認日 | {YYYY/MM/DD} |

## 変更履歴

| 版数 | 日付 | 変更者 | 変更内容 |
|------|------|--------|----------|
| 1.0 | {YYYY/MM/DD} | {変更者名} | 新規作成 |

## 目次

1. [概要](#概要)
2. [API一覧](#api一覧)
3. [API詳細仕様](#api詳細仕様)
4. [データモデル定義](#データモデル定義)
5. [エラーコード定義](#エラーコード定義)
6. [認証・認可](#認証認可)
7. [OpenAPI仕様](#openapi仕様)

---

## 概要

### 目的

{このAPI設計書の目的を記述}

### スコープ

{対象となるAPIのスコープを記述}

### APIの特徴

- {特徴1}
- {特徴2}
- {特徴3}

### 前提条件

- {前提条件1}
- {前提条件2}
- {前提条件3}

### 参照ドキュメント

| ドキュメント名 | ドキュメントID | 版数 |
|----------------|----------------|------|
| {基本設計書} | {BD001-XX} | {1.0} |
| {データベース設計書} | {DD002-XX} | {1.0} |

### API基本情報

| 項目 | 内容 |
|------|------|
| APIバージョン | {v1.0} |
| ベースURL | {https://api.example.com/v1} |
| プロトコル | {HTTPS} |
| 文字コード | {UTF-8} |
| データ形式 | {JSON/XML} |
| 認証方式 | {OAuth 2.0/JWT/API Key/Basic認証} |
| レート制限 | {100リクエスト/分} |

---

## API一覧

### エンドポイント一覧

| No | メソッド | エンドポイント | 説明 | 認証 | レート制限 | 備考 |
|----|----------|----------------|------|------|------------|------|
| 1 | GET | /users | ユーザー一覧取得 | {要/不要} | {100/分} | {ページング対応} |
| 2 | GET | /users/{id} | ユーザー詳細取得 | {要/不要} | {100/分} | {-} |
| 3 | POST | /users | ユーザー作成 | {要/不要} | {10/分} | {-} |
| 4 | PUT | /users/{id} | ユーザー更新 | {要/不要} | {10/分} | {-} |
| 5 | DELETE | /users/{id} | ユーザー削除 | {要/不要} | {10/分} | {論理削除} |
| 6 | POST | /users/{id}/activate | ユーザー有効化 | {要/不要} | {10/分} | {-} |

### API分類

| 分類 | エンドポイント数 | 説明 | 備考 |
|------|------------------|------|------|
| {ユーザー管理} | {6} | {ユーザーCRUD操作} | {-} |
| {認証} | {3} | {ログイン・ログアウト} | {-} |
| {商品管理} | {5} | {商品CRUD操作} | {-} |

---

## API詳細仕様

### GET /users

#### 基本情報

| 項目 | 内容 |
|------|------|
| API ID | API-{001} |
| API名 | ユーザー一覧取得 |
| メソッド | GET |
| エンドポイント | /users |
| 概要 | {ユーザーの一覧を取得する} |
| 認証 | {要/不要} |
| 権限 | {admin/user/guest} |
| レート制限 | {100リクエスト/分} |
| タイムアウト | {30秒} |
| キャッシュ | {有効/無効} |
| キャッシュ時間 | {300秒} |

#### リクエスト

##### クエリパラメータ

| パラメータ名 | 型 | 必須 | デフォルト値 | 説明 | 制約 | 例 |
|--------------|----|----|--------------|------|------|-----|
| page | integer | 任意 | 1 | ページ番号 | >= 1 | 1 |
| limit | integer | 任意 | 20 | 1ページあたりの件数 | 1-100 | 20 |
| sort | string | 任意 | created_at | ソート項目 | {id/name/created_at} | name |
| order | string | 任意 | desc | ソート順 | {asc/desc} | asc |
| status | string | 任意 | - | ステータスフィルタ | {active/inactive/all} | active |
| keyword | string | 任意 | - | 検索キーワード | 最大100文字 | john |

##### リクエストヘッダー

| ヘッダー名 | 必須 | 説明 | 例 |
|------------|------|------|-----|
| Authorization | 必須 | 認証トークン | Bearer {token} |
| Content-Type | 任意 | コンテンツタイプ | application/json |
| Accept | 任意 | 受け入れ形式 | application/json |
| X-Request-ID | 任意 | リクエストID | uuid-string |

##### リクエスト例

```http
GET /users?page=1&limit=20&status=active&sort=name&order=asc HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
Accept: application/json
```

#### レスポンス

##### 成功レスポンス (200 OK)

###### レスポンスヘッダー

| ヘッダー名 | 説明 | 例 |
|------------|------|-----|
| Content-Type | コンテンツタイプ | application/json; charset=utf-8 |
| X-Total-Count | 総件数 | 150 |
| X-Page | 現在ページ | 1 |
| X-Per-Page | 1ページあたり件数 | 20 |
| X-Request-ID | リクエストID | uuid-string |
| Cache-Control | キャッシュ制御 | max-age=300 |

###### レスポンスボディ

```json
{
  "status": "success",
  "data": {
    "users": [
      {
        "id": 1,
        "username": "john_doe",
        "email": "john@example.com",
        "full_name": "John Doe",
        "status": "active",
        "role": "admin",
        "created_at": "2025-01-01T00:00:00Z",
        "updated_at": "2025-01-15T12:30:00Z"
      },
      {
        "id": 2,
        "username": "jane_smith",
        "email": "jane@example.com",
        "full_name": "Jane Smith",
        "status": "active",
        "role": "user",
        "created_at": "2025-01-02T00:00:00Z",
        "updated_at": "2025-01-16T10:15:00Z"
      }
    ],
    "pagination": {
      "total": 150,
      "page": 1,
      "per_page": 20,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

##### エラーレスポンス

###### 400 Bad Request

```json
{
  "status": "error",
  "error": {
    "code": "INVALID_PARAMETER",
    "message": "Invalid query parameter",
    "details": [
      {
        "field": "limit",
        "message": "limit must be between 1 and 100",
        "value": 200
      }
    ]
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

###### 401 Unauthorized

```json
{
  "status": "error",
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required",
    "details": []
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

###### 403 Forbidden

```json
{
  "status": "error",
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions",
    "details": []
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

###### 429 Too Many Requests

```json
{
  "status": "error",
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded",
    "details": [
      {
        "limit": 100,
        "remaining": 0,
        "reset_at": "2025-01-20T10:01:00Z"
      }
    ]
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

###### 500 Internal Server Error

```json
{
  "status": "error",
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "details": []
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

#### ステータスコード

| コード | 説明 | 発生条件 |
|--------|------|----------|
| 200 | OK | 正常に取得完了 |
| 400 | Bad Request | パラメータ不正 |
| 401 | Unauthorized | 認証エラー |
| 403 | Forbidden | 権限不足 |
| 429 | Too Many Requests | レート制限超過 |
| 500 | Internal Server Error | サーバーエラー |

#### ビジネスロジック

1. {クエリパラメータのバリデーション}
2. {認証・認可チェック}
3. {データベースからユーザー一覧を取得}
4. {ページング処理}
5. {レスポンス整形}

#### パフォーマンス要件

| 項目 | 目標値 | 備考 |
|------|--------|------|
| レスポンスタイム | {< 500ms} | {95パーセンタイル} |
| スループット | {100リクエスト/秒} | {-} |
| データベースクエリ数 | {1回} | {N+1問題回避} |

#### セキュリティ要件

- {SQLインジェクション対策: プリペアドステートメント使用}
- {XSS対策: 出力エスケープ}
- {CSRF対策: トークン検証}
- {個人情報マスキング: emailの一部マスキング(オプション)}

---

### POST /users

#### 基本情報

| 項目 | 内容 |
|------|------|
| API ID | API-{003} |
| API名 | ユーザー作成 |
| メソッド | POST |
| エンドポイント | /users |
| 概要 | {新規ユーザーを作成する} |
| 認証 | {要} |
| 権限 | {admin} |
| レート制限 | {10リクエスト/分} |
| タイムアウト | {30秒} |
| 冪等性 | {非冪等} |

#### リクエスト

##### リクエストヘッダー

| ヘッダー名 | 必須 | 説明 | 例 |
|------------|------|------|-----|
| Authorization | 必須 | 認証トークン | Bearer {token} |
| Content-Type | 必須 | コンテンツタイプ | application/json |
| X-Idempotency-Key | 任意 | 冪等性キー | uuid-string |

##### リクエストボディ

```json
{
  "username": "new_user",
  "email": "newuser@example.com",
  "password": "SecureP@ssw0rd",
  "full_name": "New User",
  "role": "user",
  "profile": {
    "phone": "+81-90-1234-5678",
    "address": "Tokyo, Japan",
    "birth_date": "1990-01-01"
  }
}
```

##### リクエストボディスキーマ

| フィールド名 | 型 | 必須 | 説明 | 制約 | 例 |
|--------------|----|----|------|------|-----|
| username | string | 必須 | ユーザー名 | 3-50文字、英数字とアンダースコアのみ | john_doe |
| email | string | 必須 | メールアドレス | メール形式、最大255文字 | user@example.com |
| password | string | 必須 | パスワード | 8-128文字、英大小数字記号含む | P@ssw0rd |
| full_name | string | 必須 | 氏名 | 1-100文字 | John Doe |
| role | string | 任意 | ロール | {admin/user/guest} | user |
| profile | object | 任意 | プロフィール | - | - |
| profile.phone | string | 任意 | 電話番号 | 電話番号形式 | +81-90-1234-5678 |
| profile.address | string | 任意 | 住所 | 最大500文字 | Tokyo, Japan |
| profile.birth_date | string | 任意 | 生年月日 | 日付形式(YYYY-MM-DD) | 1990-01-01 |

#### レスポンス

##### 成功レスポンス (201 Created)

```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 100,
      "username": "new_user",
      "email": "newuser@example.com",
      "full_name": "New User",
      "status": "active",
      "role": "user",
      "profile": {
        "phone": "+81-90-1234-5678",
        "address": "Tokyo, Japan",
        "birth_date": "1990-01-01"
      },
      "created_at": "2025-01-20T10:00:00Z",
      "updated_at": "2025-01-20T10:00:00Z"
    }
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

##### エラーレスポンス

###### 409 Conflict

```json
{
  "status": "error",
  "error": {
    "code": "DUPLICATE_USER",
    "message": "User already exists",
    "details": [
      {
        "field": "email",
        "message": "Email address is already registered",
        "value": "newuser@example.com"
      }
    ]
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

###### 422 Unprocessable Entity

```json
{
  "status": "error",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "password",
        "message": "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character",
        "value": "weakpassword"
      }
    ]
  },
  "timestamp": "2025-01-20T10:00:00Z"
}
```

#### バリデーションルール

| フィールド | ルール | エラーメッセージ |
|------------|--------|------------------|
| username | 必須、3-50文字、英数字とアンダースコア | "Username is required and must be 3-50 alphanumeric characters" |
| email | 必須、メール形式 | "Valid email address is required" |
| password | 必須、8-128文字、複雑性要件 | "Password must be 8-128 characters with complexity requirements" |
| full_name | 必須、1-100文字 | "Full name is required and must be 1-100 characters" |
| role | 列挙型 | "Role must be one of: admin, user, guest" |

---

## データモデル定義

### User モデル

#### スキーマ定義

```json
{
  "type": "object",
  "required": ["id", "username", "email", "full_name", "status", "role", "created_at", "updated_at"],
  "properties": {
    "id": {
      "type": "integer",
      "format": "int64",
      "description": "ユーザーID",
      "example": 1
    },
    "username": {
      "type": "string",
      "minLength": 3,
      "maxLength": 50,
      "pattern": "^[a-zA-Z0-9_]+$",
      "description": "ユーザー名",
      "example": "john_doe"
    },
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 255,
      "description": "メールアドレス",
      "example": "john@example.com"
    },
    "full_name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100,
      "description": "氏名",
      "example": "John Doe"
    },
    "status": {
      "type": "string",
      "enum": ["active", "inactive", "suspended"],
      "description": "ステータス",
      "example": "active"
    },
    "role": {
      "type": "string",
      "enum": ["admin", "user", "guest"],
      "description": "ロール",
      "example": "user"
    },
    "profile": {
      "$ref": "#/components/schemas/UserProfile"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "作成日時",
      "example": "2025-01-01T00:00:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "更新日時",
      "example": "2025-01-15T12:30:00Z"
    }
  }
}
```

### UserProfile モデル

```json
{
  "type": "object",
  "properties": {
    "phone": {
      "type": "string",
      "pattern": "^\\+?[0-9\\-]+$",
      "description": "電話番号",
      "example": "+81-90-1234-5678"
    },
    "address": {
      "type": "string",
      "maxLength": 500,
      "description": "住所",
      "example": "Tokyo, Japan"
    },
    "birth_date": {
      "type": "string",
      "format": "date",
      "description": "生年月日",
      "example": "1990-01-01"
    }
  }
}
```

### Pagination モデル

```json
{
  "type": "object",
  "required": ["total", "page", "per_page", "total_pages"],
  "properties": {
    "total": {
      "type": "integer",
      "description": "総件数",
      "example": 150
    },
    "page": {
      "type": "integer",
      "description": "現在のページ",
      "example": 1
    },
    "per_page": {
      "type": "integer",
      "description": "1ページあたりの件数",
      "example": 20
    },
    "total_pages": {
      "type": "integer",
      "description": "総ページ数",
      "example": 8
    },
    "has_next": {
      "type": "boolean",
      "description": "次ページの有無",
      "example": true
    },
    "has_prev": {
      "type": "boolean",
      "description": "前ページの有無",
      "example": false
    }
  }
}
```

---

## エラーコード定義

### エラーコード一覧

| エラーコード | HTTPステータス | 説明 | 対処方法 |
|--------------|----------------|------|----------|
| INVALID_PARAMETER | 400 | パラメータ不正 | パラメータを修正して再送信 |
| VALIDATION_ERROR | 422 | バリデーションエラー | 入力値を修正して再送信 |
| UNAUTHORIZED | 401 | 認証エラー | 認証情報を確認 |
| FORBIDDEN | 403 | 権限不足 | 必要な権限を取得 |
| NOT_FOUND | 404 | リソースが見つからない | リソースIDを確認 |
| DUPLICATE_USER | 409 | ユーザー重複 | 異なる情報で登録 |
| RATE_LIMIT_EXCEEDED | 429 | レート制限超過 | 時間をおいて再試行 |
| INTERNAL_SERVER_ERROR | 500 | サーバーエラー | 管理者に連絡 |
| SERVICE_UNAVAILABLE | 503 | サービス利用不可 | メンテナンス終了まで待機 |

### エラーレスポンス形式

```json
{
  "status": "error",
  "error": {
    "code": "{ERROR_CODE}",
    "message": "{エラーメッセージ}",
    "details": [
      {
        "field": "{フィールド名}",
        "message": "{詳細メッセージ}",
        "value": "{入力値}"
      }
    ]
  },
  "timestamp": "{ISO8601形式の日時}"
}
```

---

## 認証・認可

### 認証方式

| 方式 | 使用場所 | 説明 |
|------|----------|------|
| {OAuth 2.0/JWT/API Key/Basic認証} | {全エンドポイント} | {認証方式の説明} |

### 認証フロー

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant AuthServer

    Client->>AuthServer: ログイン要求
    AuthServer-->>Client: アクセストークン発行
    Client->>API: APIリクエスト + トークン
    API->>AuthServer: トークン検証
    AuthServer-->>API: 検証結果
    API-->>Client: APIレスポンス
```

### トークン仕様

| 項目 | 内容 |
|------|------|
| トークン形式 | {JWT} |
| 有効期限 | {3600秒(1時間)} |
| リフレッシュトークン | {有/無} |
| リフレッシュトークン有効期限 | {86400秒(24時間)} |
| トークン配置 | {Authorization ヘッダー} |
| トークン形式 | {Bearer {token}} |

### 権限管理

| ロール | 説明 | 許可API |
|--------|------|---------|
| admin | 管理者 | 全API |
| user | 一般ユーザー | 参照系API、自身のデータ更新 |
| guest | ゲスト | 公開API のみ |

---

## OpenAPI仕様

### OpenAPI 3.0 定義

```yaml
openapi: 3.0.0
info:
  title: {API名}
  description: {API説明}
  version: {1.0.0}
  contact:
    name: {API担当者}
    email: {api@example.com}
  license:
    name: {ライセンス名}
    url: {ライセンスURL}

servers:
  - url: https://api.example.com/v1
    description: 本番環境
  - url: https://api-staging.example.com/v1
    description: ステージング環境
  - url: http://localhost:8080/v1
    description: 開発環境

security:
  - BearerAuth: []

paths:
  /users:
    get:
      summary: ユーザー一覧取得
      description: ユーザーの一覧を取得する
      operationId: listUsers
      tags:
        - Users
      parameters:
        - name: page
          in: query
          description: ページ番号
          required: false
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          description: 1ページあたりの件数
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
        '400':
          description: パラメータ不正
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '401':
          description: 認証エラー
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

    post:
      summary: ユーザー作成
      description: 新規ユーザーを作成する
      operationId: createUser
      tags:
        - Users
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: 作成成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '422':
          description: バリデーションエラー
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    User:
      type: object
      required:
        - id
        - username
        - email
      properties:
        id:
          type: integer
          format: int64
        username:
          type: string
        email:
          type: string
          format: email

    UserListResponse:
      type: object
      properties:
        status:
          type: string
          example: success
        data:
          type: object
          properties:
            users:
              type: array
              items:
                $ref: '#/components/schemas/User'
            pagination:
              $ref: '#/components/schemas/Pagination'

    ErrorResponse:
      type: object
      properties:
        status:
          type: string
          example: error
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
            details:
              type: array
              items:
                type: object
```

---

## 付録

### リクエスト/レスポンス例集

{実際のリクエスト/レスポンス例を記載}

### テストケース

| テストID | API | シナリオ | 期待結果 |
|----------|-----|----------|----------|
| TC-{001} | GET /users | 正常系: ユーザー一覧取得 | 200 OK |
| TC-{002} | GET /users | 異常系: 不正なページ番号 | 400 Bad Request |
| TC-{003} | POST /users | 正常系: ユーザー作成 | 201 Created |

### 用語集

| 用語 | 説明 |
|------|------|
| {用語1} | {説明} |
| {用語2} | {説明} |

### レビュー記録

| 日付 | レビュアー | 指摘事項 | 対応状況 |
|------|------------|----------|----------|
| {YYYY/MM/DD} | {レビュアー名} | {指摘事項} | {対応済/対応中/未対応} |

### 承認記録

| 役割 | 氏名 | 承認日 | 署名 |
|------|------|--------|------|
| {設計者} | {氏名} | {YYYY/MM/DD} | {署名} |
| {レビュアー} | {氏名} | {YYYY/MM/DD} | {署名} |
| {承認者} | {氏名} | {YYYY/MM/DD} | {署名} |
