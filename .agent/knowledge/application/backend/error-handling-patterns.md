# エラーハンドリングパターン

**最終更新**: 2025-12-15
**対象**: バックエンドアプリケーションのエラー処理

---

## 使用方法

このドキュメントは、エラーハンドリング設計・実装時に参照してください：

- **設計フェーズ**: エラー処理戦略の決定
- **実装フェーズ**: 統一的なエラー処理実装
- **デバッグ**: エラー原因の特定・ログ調査
- **運用**: エラー監視・アラート設定

---

## エラーハンドリングの原則

1. **予測可能**: エラーレスポンスの形式を統一
2. **情報的**: 適切なエラーメッセージとコンテキスト
3. **安全**: センシティブ情報を漏洩しない
4. **ロギング**: すべてのエラーを記録
5. **リカバリ**: 可能な限り復旧を試みる

---

## 1. エラークラス設計

### ✅ Good Practice

**Good**: カスタムエラークラスの階層化
```javascript
// 基底エラークラス
class AppError extends Error {
  constructor(message, statusCode = 500, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.timestamp = new Date().toISOString();

    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      error: {
        message: this.message,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

// クライアントエラー（4xx）
class BadRequestError extends AppError {
  constructor(message = 'Bad Request', details = null) {
    super(message, 400);
    this.details = details;
  }

  toJSON() {
    return {
      error: {
        code: 'BAD_REQUEST',
        message: this.message,
        details: this.details,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401);
  }

  toJSON() {
    return {
      error: {
        code: 'UNAUTHORIZED',
        message: this.message,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Forbidden', requiredPermission = null) {
    super(message, 403);
    this.requiredPermission = requiredPermission;
  }

  toJSON() {
    return {
      error: {
        code: 'FORBIDDEN',
        message: this.message,
        requiredPermission: this.requiredPermission,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

class NotFoundError extends AppError {
  constructor(resource, id = null) {
    super(`${resource} not found`, 404);
    this.resource = resource;
    this.id = id;
  }

  toJSON() {
    return {
      error: {
        code: 'NOT_FOUND',
        message: this.message,
        resource: this.resource,
        id: this.id,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

class ConflictError extends AppError {
  constructor(message = 'Conflict', conflictingField = null) {
    super(message, 409);
    this.conflictingField = conflictingField;
  }

  toJSON() {
    return {
      error: {
        code: 'CONFLICT',
        message: this.message,
        conflictingField: this.conflictingField,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

class ValidationError extends AppError {
  constructor(errors) {
    super('Validation failed', 422);
    this.errors = errors;
  }

  toJSON() {
    return {
      error: {
        code: 'VALIDATION_ERROR',
        message: this.message,
        details: this.errors,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

// サーバーエラー（5xx）
class InternalServerError extends AppError {
  constructor(message = 'Internal Server Error', originalError = null) {
    super(message, 500);
    this.originalError = originalError;
  }

  toJSON() {
    const response = {
      error: {
        code: 'INTERNAL_SERVER_ERROR',
        message: this.message,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };

    // 開発環境のみスタックトレース含める
    if (process.env.NODE_ENV === 'development' && this.originalError) {
      response.error.stack = this.originalError.stack;
    }

    return response;
  }
}

class ServiceUnavailableError extends AppError {
  constructor(service, retryAfter = null) {
    super(`${service} is currently unavailable`, 503);
    this.service = service;
    this.retryAfter = retryAfter;
  }

  toJSON() {
    return {
      error: {
        code: 'SERVICE_UNAVAILABLE',
        message: this.message,
        service: this.service,
        retryAfter: this.retryAfter,
        statusCode: this.statusCode,
        timestamp: this.timestamp
      }
    };
  }
}

// 使用例
throw new NotFoundError('User', 123);
throw new ValidationError([
  { field: 'email', message: 'Invalid email format' },
  { field: 'password', message: 'Password too short' }
]);
throw new ConflictError('Email already exists', 'email');
```

**Bad**:
```javascript
// NG: エラーを文字列で投げる
throw 'User not found';

// NG: 汎用Errorのみ使用
throw new Error('Something went wrong');

// NG: エラー情報が不足
res.status(500).json({ error: 'Error' });
```

---

## 2. グローバルエラーハンドラー

### Express.js

**Good**: 集中エラーハンドリング
```javascript
const logger = require('./logger');

// エラーハンドリングミドルウェア（最後に配置）
function errorHandler(err, req, res, next) {
  // リクエストIDを生成（トレーシング用）
  const requestId = req.id || generateRequestId();

  // エラーログ記録
  logger.error({
    requestId,
    error: {
      message: err.message,
      stack: err.stack,
      statusCode: err.statusCode
    },
    request: {
      method: req.method,
      url: req.url,
      headers: sanitizeHeaders(req.headers),
      body: sanitizeBody(req.body),
      ip: req.ip,
      userId: req.user?.id
    }
  });

  // Operational Error（予期されたエラー）
  if (err.isOperational) {
    return res.status(err.statusCode).json(err.toJSON());
  }

  // Programming Error（予期しないエラー）
  // 詳細を隠し、一般的なエラーメッセージを返す
  res.status(500).json({
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred',
      requestId,  // サポート問い合わせ用
      timestamp: new Date().toISOString()
    }
  });

  // クリティカルエラーの場合、プロセスを終了
  if (!err.isOperational) {
    logger.fatal('Unhandled error, shutting down gracefully', { error: err });

    // 進行中のリクエストを完了してから終了
    process.exit(1);
  }
}

// 未処理の Promise Rejection
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Promise Rejection', { reason, promise });
  throw reason;
});

// 未処理の例外
process.on('uncaughtException', (error) => {
  logger.fatal('Uncaught Exception', { error });
  process.exit(1);
});

// センシティブ情報の除去
function sanitizeHeaders(headers) {
  const sanitized = { ...headers };
  delete sanitized.authorization;
  delete sanitized.cookie;
  return sanitized;
}

function sanitizeBody(body) {
  if (!body) return null;

  const sanitized = { ...body };
  delete sanitized.password;
  delete sanitized.creditCard;
  delete sanitized.ssn;
  return sanitized;
}

function generateRequestId() {
  return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

// アプリケーション設定
const express = require('express');
const app = express();

// リクエストIDミドルウェア
app.use((req, res, next) => {
  req.id = generateRequestId();
  res.setHeader('X-Request-ID', req.id);
  next();
});

// ルーティング
app.use('/api', routes);

// 404エラーハンドリング
app.use((req, res, next) => {
  next(new NotFoundError('Route', req.path));
});

// グローバルエラーハンドラー（最後に配置）
app.use(errorHandler);

module.exports = app;
```

---

## 3. 非同期エラーハンドリング

### async/await

**Good**: try-catchまたはラッパー関数
```javascript
// パターン1: try-catch
app.get('/api/users/:id', async (req, res, next) => {
  try {
    const user = await userService.findById(req.params.id);

    if (!user) {
      throw new NotFoundError('User', req.params.id);
    }

    res.json(user);
  } catch (error) {
    next(error);
  }
});

// パターン2: asyncHandler ラッパー（推奨）
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

app.get('/api/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.findById(req.params.id);

  if (!user) {
    throw new NotFoundError('User', req.params.id);
  }

  res.json(user);
}));

// サービス層での詳細なエラー処理
class UserService {
  async findById(id) {
    try {
      const user = await db.query('SELECT * FROM users WHERE id = ?', [id]);
      return user;
    } catch (error) {
      // DBエラーをラップ
      throw new InternalServerError('Failed to fetch user', error);
    }
  }

  async create(userData) {
    try {
      const existingUser = await db.query(
        'SELECT id FROM users WHERE email = ?',
        [userData.email]
      );

      if (existingUser) {
        throw new ConflictError('User with this email already exists', 'email');
      }

      const user = await db.query(
        'INSERT INTO users (email, name) VALUES (?, ?)',
        [userData.email, userData.name]
      );

      return user;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }

      // MySQLエラーコード判定
      if (error.code === 'ER_DUP_ENTRY') {
        throw new ConflictError('Duplicate entry', extractDuplicateField(error));
      }

      throw new InternalServerError('Failed to create user', error);
    }
  }
}
```

**Bad**:
```javascript
// NG: エラーハンドリングなし
app.get('/api/users/:id', async (req, res) => {
  const user = await userService.findById(req.params.id);  // エラーで落ちる
  res.json(user);
});

// NG: エラーを握りつぶす
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await userService.findById(req.params.id);
    res.json(user);
  } catch (error) {
    console.log('Error:', error);  // ログのみ、レスポンスなし
  }
});
```

---

## 4. バリデーションエラー

### 入力値検証

**Good**: バリデーションライブラリ使用
```javascript
const { body, validationResult } = require('express-validator');

// バリデーションルール定義
const createUserValidation = [
  body('email')
    .isEmail()
    .withMessage('Invalid email format')
    .normalizeEmail(),

  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain uppercase, lowercase, and number'),

  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters')
];

// バリデーション結果確認ミドルウェア
function validate(req, res, next) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map(err => ({
      field: err.path,
      message: err.msg,
      value: err.value
    }));

    throw new ValidationError(formattedErrors);
  }

  next();
}

// 使用例
app.post('/api/users',
  createUserValidation,
  validate,
  asyncHandler(async (req, res) => {
    const user = await userService.create(req.body);
    res.status(201).json(user);
  })
);

// レスポンス例
/*
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "value": "invalid-email"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters",
        "value": "short"
      }
    ],
    "statusCode": 422,
    "timestamp": "2025-12-15T10:00:00.000Z"
  }
}
*/
```

---

## 5. 外部API呼び出しエラー

### リトライとタイムアウト

**Good**: axios + リトライロジック
```javascript
const axios = require('axios');
const axiosRetry = require('axios-retry');

// axiosインスタンス作成
const apiClient = axios.create({
  baseURL: process.env.EXTERNAL_API_URL,
  timeout: 5000,  // 5秒タイムアウト
  headers: {
    'Content-Type': 'application/json'
  }
});

// リトライ設定
axiosRetry(apiClient, {
  retries: 3,
  retryDelay: axiosRetry.exponentialDelay,  // 指数バックオフ
  retryCondition: (error) => {
    // 5xx エラーまたはネットワークエラーのみリトライ
    return axiosRetry.isNetworkOrIdempotentRequestError(error) ||
           (error.response?.status >= 500 && error.response?.status < 600);
  },
  onRetry: (retryCount, error, requestConfig) => {
    logger.warn(`Retrying API request (attempt ${retryCount})`, {
      url: requestConfig.url,
      error: error.message
    });
  }
});

// サービス層
class ExternalAPIService {
  async fetchUserData(userId) {
    try {
      const response = await apiClient.get(`/users/${userId}`);
      return response.data;
    } catch (error) {
      if (error.code === 'ECONNABORTED') {
        throw new ServiceUnavailableError('External API', 60);
      }

      if (error.response) {
        // APIからのエラーレスポンス
        const { status, data } = error.response;

        if (status === 404) {
          throw new NotFoundError('External user', userId);
        }

        if (status >= 500) {
          throw new ServiceUnavailableError('External API', 60);
        }

        throw new BadRequestError(`External API error: ${data.message}`);
      }

      // ネットワークエラー
      throw new ServiceUnavailableError('External API (network error)', 120);
    }
  }
}
```

---

## 6. データベースエラー

### トランザクションとロールバック

**Good**: トランザクション管理
```javascript
class OrderService {
  async createOrder(userId, items) {
    const connection = await db.getConnection();

    try {
      await connection.beginTransaction();

      // 1. 注文作成
      const [orderResult] = await connection.query(
        'INSERT INTO orders (user_id, total_amount, status) VALUES (?, ?, ?)',
        [userId, calculateTotal(items), 'pending']
      );

      const orderId = orderResult.insertId;

      // 2. 注文アイテム追加
      for (const item of items) {
        await connection.query(
          'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
          [orderId, item.productId, item.quantity, item.price]
        );

        // 3. 在庫減少
        const [updateResult] = await connection.query(
          'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?',
          [item.quantity, item.productId, item.quantity]
        );

        if (updateResult.affectedRows === 0) {
          throw new BadRequestError(`Insufficient stock for product ${item.productId}`);
        }
      }

      await connection.commit();

      return { orderId, status: 'success' };

    } catch (error) {
      await connection.rollback();

      if (error instanceof AppError) {
        throw error;
      }

      // デッドロック検出
      if (error.code === 'ER_LOCK_DEADLOCK') {
        logger.warn('Deadlock detected, order creation failed', { userId, error });
        throw new ConflictError('Order creation conflict, please try again');
      }

      throw new InternalServerError('Failed to create order', error);

    } finally {
      connection.release();
    }
  }
}
```

---

## 7. ロギング

### 構造化ログ

**Good**: Winston/Pino使用
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: 'my-app',
    environment: process.env.NODE_ENV
  },
  transports: [
    // ファイル出力
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error'
    }),
    new winston.transports.File({
      filename: 'logs/combined.log'
    })
  ]
});

// 開発環境: コンソール出力
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

// ログ使用例
logger.info('User created', { userId: 123, email: 'user@example.com' });
logger.warn('API rate limit approaching', { userId: 123, requestCount: 95 });
logger.error('Database connection failed', { error: error.message, stack: error.stack });
logger.fatal('Critical system error', { error });

module.exports = logger;
```

---

## チェックリスト

### エラークラス
- [ ] カスタムエラークラスの定義
- [ ] 適切なHTTPステータスコード
- [ ] 詳細なエラー情報（toJSON実装）
- [ ] isOperational フラグ

### エラーハンドリング
- [ ] グローバルエラーハンドラー実装
- [ ] async/awaitでtry-catch
- [ ] バリデーションエラー統一
- [ ] 外部API呼び出しエラー処理

### セキュリティ
- [ ] センシティブ情報の除外
- [ ] スタックトレースは開発環境のみ
- [ ] エラーメッセージは一般的に
- [ ] ログからパスワード等を除外

### ロギング
- [ ] 構造化ログ（JSON）
- [ ] リクエストID記録
- [ ] エラーレベル適切設定
- [ ] ログローテーション

---

## まとめ

このパターン集に従うことで：

- ✅ 予測可能なエラーレスポンス
- ✅ デバッグ効率の向上
- ✅ セキュリティリスク軽減
- ✅ 運用監視の容易化

エラーハンドリング設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [Node.js Error Handling Best Practices](https://nodejs.org/en/docs/guides/error-handling/)
- [Express Error Handling](https://expressjs.com/en/guide/error-handling.html)
- [OWASP Error Handling](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html)
