# 認証・認可ベストプラクティス

**最終更新**: 2025-12-15
**対象**: Web/モバイルアプリケーションの認証・認可実装

---

## 使用方法

このドキュメントは、認証・認可機能の設計・実装時に参照してください：

- **設計フェーズ**: 認証方式の選定（JWT, Session, OAuth等）
- **実装フェーズ**: セキュアな実装パターン
- **セキュリティレビュー**: 脆弱性チェック
- **コンプライアンス**: OWASP推奨事項の確認

---

## 認証 vs 認可

| 概念 | 説明 | 例 |
|------|------|-----|
| **認証（Authentication）** | 「誰か」を確認 | ログイン、パスワード検証 |
| **認可（Authorization）** | 「何ができるか」を確認 | 管理者権限、リソースアクセス権 |

---

## 1. パスワード管理

### ✅ Good Practice

#### パスワードハッシュ化

**Good**: bcrypt/Argon2使用
```javascript
// Node.js (bcrypt)
const bcrypt = require('bcrypt');

// ユーザー登録時
async function registerUser(email, password) {
  // ソルトラウンド: 10-12推奨（コスト vs セキュリティ）
  const saltRounds = 12;
  const hashedPassword = await bcrypt.hash(password, saltRounds);

  await db.query(
    'INSERT INTO users (email, password_hash) VALUES (?, ?)',
    [email, hashedPassword]
  );

  return { email, registered: true };
}

// ログイン時
async function login(email, password) {
  const user = await db.query(
    'SELECT id, email, password_hash FROM users WHERE email = ?',
    [email]
  );

  if (!user) {
    throw new Error('Invalid credentials');
  }

  const isValid = await bcrypt.compare(password, user.password_hash);

  if (!isValid) {
    throw new Error('Invalid credentials');
  }

  return generateToken(user);
}
```

**Bad**:
```javascript
// NG: 平文保存
await db.query(
  'INSERT INTO users (email, password) VALUES (?, ?)',
  [email, password]  // NG!!! 絶対にやってはいけない
);

// NG: MD5/SHA1ハッシュ（脆弱）
const hashedPassword = crypto.createHash('md5').update(password).digest('hex');

// NG: ソルトなしハッシュ
const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');
```

---

#### パスワードポリシー

**Good**: 強力なパスワード要件
```javascript
function validatePassword(password) {
  const minLength = 8;
  const maxLength = 128;

  // 長さチェック
  if (password.length < minLength || password.length > maxLength) {
    return {
      valid: false,
      error: `パスワードは${minLength}文字以上、${maxLength}文字以下で入力してください`
    };
  }

  // 複雑性チェック（任意: 要件により調整）
  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);

  const complexityCount = [hasUpperCase, hasLowerCase, hasNumber, hasSpecial]
    .filter(Boolean).length;

  if (complexityCount < 3) {
    return {
      valid: false,
      error: 'パスワードは大文字、小文字、数字、記号のうち3種類以上を含む必要があります'
    };
  }

  // 脆弱なパスワードチェック
  const commonPasswords = ['password', '123456', 'qwerty', 'admin'];
  if (commonPasswords.includes(password.toLowerCase())) {
    return {
      valid: false,
      error: 'よく使われるパスワードは使用できません'
    };
  }

  return { valid: true };
}
```

---

## 2. JWT（JSON Web Token）認証

### トークンベース認証

**Good**: セキュアなJWT実装
```javascript
const jwt = require('jsonwebtoken');

// 環境変数から秘密鍵を取得（絶対にハードコードしない）
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;

// アクセストークン生成（短命: 15分）
function generateAccessToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role
    },
    JWT_SECRET,
    {
      expiresIn: '15m',
      issuer: 'myapp.com',
      audience: 'myapp.com'
    }
  );
}

// リフレッシュトークン生成（長命: 7日）
function generateRefreshToken(user) {
  const token = jwt.sign(
    { userId: user.id },
    JWT_REFRESH_SECRET,
    {
      expiresIn: '7d',
      issuer: 'myapp.com'
    }
  );

  // リフレッシュトークンをDBに保存（無効化可能にする）
  db.query(
    'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
    [user.id, token, new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)]
  );

  return token;
}

// トークン検証ミドルウェア
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];  // "Bearer TOKEN"

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'Token expired' });
      }
      return res.status(403).json({ error: 'Invalid token' });
    }

    req.user = decoded;
    next();
  });
}

// リフレッシュトークンでアクセストークン再発行
async function refreshAccessToken(refreshToken) {
  // リフレッシュトークン検証
  const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET);

  // DBに保存されているか確認（無効化対策）
  const storedToken = await db.query(
    'SELECT * FROM refresh_tokens WHERE token = ? AND user_id = ? AND expires_at > NOW()',
    [refreshToken, decoded.userId]
  );

  if (!storedToken) {
    throw new Error('Invalid refresh token');
  }

  // ユーザー情報取得
  const user = await db.query('SELECT * FROM users WHERE id = ?', [decoded.userId]);

  // 新しいアクセストークン発行
  return generateAccessToken(user);
}

// 使用例
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await authenticateUser(email, password);

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({
      accessToken,
      refreshToken,
      expiresIn: 900  // 15分（秒）
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

app.post('/api/refresh', async (req, res) => {
  const { refreshToken } = req.body;

  try {
    const newAccessToken = await refreshAccessToken(refreshToken);
    res.json({ accessToken: newAccessToken });
  } catch (error) {
    res.status(403).json({ error: 'Invalid refresh token' });
  }
});

app.get('/api/protected', authenticateToken, (req, res) => {
  res.json({ message: 'Protected data', user: req.user });
});
```

**Bad**:
```javascript
// NG: 秘密鍵をハードコード
const token = jwt.sign({ userId: 1 }, 'my-secret-key');

// NG: 有効期限なし
const token = jwt.sign({ userId: 1 }, JWT_SECRET);  // expiresInなし

// NG: センシティブ情報をペイロードに含める
const token = jwt.sign(
  {
    userId: 1,
    password: 'hashed-password',  // NG!
    creditCard: '1234-5678-9012'  // NG!
  },
  JWT_SECRET
);
```

---

## 3. セッションベース認証

### サーバーサイドセッション

**Good**: セキュアなセッション管理
```javascript
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const { createClient } = require('redis');

// Redisクライアント作成
const redisClient = createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
});

redisClient.connect();

// セッションミドルウェア設定
app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,  // 強力な秘密鍵
  resave: false,
  saveUninitialized: false,
  name: 'sessionId',  // デフォルトの'connect.sid'は避ける
  cookie: {
    httpOnly: true,      // XSS対策: JavaScriptからアクセス不可
    secure: true,        // HTTPS必須
    sameSite: 'strict',  // CSRF対策
    maxAge: 1000 * 60 * 60 * 24  // 24時間
  }
}));

// ログイン処理
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  const user = await authenticateUser(email, password);

  if (user) {
    // セッションにユーザー情報を保存
    req.session.userId = user.id;
    req.session.email = user.email;
    req.session.role = user.role;

    // セッション固定攻撃対策: セッションIDを再生成
    req.session.regenerate((err) => {
      if (err) {
        return res.status(500).json({ error: 'Session error' });
      }

      req.session.userId = user.id;
      res.json({ message: 'Logged in successfully' });
    });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// ログアウト
app.post('/api/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: 'Logout failed' });
    }

    res.clearCookie('sessionId');
    res.json({ message: 'Logged out successfully' });
  });
});

// 認証確認ミドルウェア
function requireAuth(req, res, next) {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  next();
}

app.get('/api/profile', requireAuth, async (req, res) => {
  const user = await db.query('SELECT * FROM users WHERE id = ?', [req.session.userId]);
  res.json(user);
});
```

---

## 4. OAuth 2.0 / OpenID Connect

### ソーシャルログイン

**Good**: OAuth 2.0実装（Googleログイン例）
```javascript
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

// Google認証URLにリダイレクト
app.get('/api/auth/google', (req, res) => {
  const authorizeUrl = client.generateAuthUrl({
    access_type: 'offline',
    scope: [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email'
    ],
    state: generateStateToken()  // CSRF対策
  });

  res.redirect(authorizeUrl);
});

// コールバック処理
app.get('/api/auth/google/callback', async (req, res) => {
  const { code, state } = req.query;

  // stateトークン検証（CSRF対策）
  if (!verifyStateToken(state)) {
    return res.status(403).json({ error: 'Invalid state token' });
  }

  try {
    // 認可コードをアクセストークンに交換
    const { tokens } = await client.getToken(code);
    client.setCredentials(tokens);

    // ユーザー情報取得
    const ticket = await client.verifyIdToken({
      idToken: tokens.id_token,
      audience: process.env.GOOGLE_CLIENT_ID
    });

    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture } = payload;

    // ユーザー登録またはログイン
    let user = await db.query('SELECT * FROM users WHERE google_id = ?', [googleId]);

    if (!user) {
      // 新規ユーザー登録
      user = await db.query(
        'INSERT INTO users (google_id, email, name, avatar) VALUES (?, ?, ?, ?)',
        [googleId, email, name, picture]
      );
    }

    // JWTトークン発行
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({ accessToken, refreshToken });
  } catch (error) {
    res.status(401).json({ error: 'Authentication failed' });
  }
});

function generateStateToken() {
  const token = crypto.randomBytes(32).toString('hex');
  // Redisなどに一時保存（5分間有効）
  redisClient.setEx(`oauth_state:${token}`, 300, 'valid');
  return token;
}

function verifyStateToken(token) {
  const isValid = redisClient.get(`oauth_state:${token}`);
  if (isValid) {
    redisClient.del(`oauth_state:${token}`);
    return true;
  }
  return false;
}
```

---

## 5. 多要素認証（MFA）

### TOTP（Time-based One-Time Password）

**Good**: Google Authenticator対応
```javascript
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');

// MFA有効化: シークレット生成
app.post('/api/mfa/enable', authenticateToken, async (req, res) => {
  const secret = speakeasy.generateSecret({
    name: `MyApp (${req.user.email})`,
    issuer: 'MyApp'
  });

  // QRコード生成
  const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

  // シークレットを一時保存（確認後に本保存）
  await db.query(
    'UPDATE users SET mfa_secret_temp = ? WHERE id = ?',
    [secret.base32, req.user.userId]
  );

  res.json({
    secret: secret.base32,
    qrCode: qrCodeUrl
  });
});

// MFA確認
app.post('/api/mfa/verify', authenticateToken, async (req, res) => {
  const { token } = req.body;

  const user = await db.query('SELECT mfa_secret_temp FROM users WHERE id = ?', [req.user.userId]);

  const verified = speakeasy.totp.verify({
    secret: user.mfa_secret_temp,
    encoding: 'base32',
    token,
    window: 2  // ±2ステップ許容（60秒のズレ許容）
  });

  if (verified) {
    // MFAを正式に有効化
    await db.query(
      'UPDATE users SET mfa_secret = mfa_secret_temp, mfa_enabled = TRUE WHERE id = ?',
      [req.user.userId]
    );

    res.json({ message: 'MFA enabled successfully' });
  } else {
    res.status(400).json({ error: 'Invalid token' });
  }
});

// ログイン時のMFA検証
app.post('/api/login', async (req, res) => {
  const { email, password, mfaToken } = req.body;

  const user = await authenticateUser(email, password);

  if (user.mfa_enabled) {
    if (!mfaToken) {
      return res.status(200).json({ mfaRequired: true });
    }

    const verified = speakeasy.totp.verify({
      secret: user.mfa_secret,
      encoding: 'base32',
      token: mfaToken,
      window: 2
    });

    if (!verified) {
      return res.status(401).json({ error: 'Invalid MFA token' });
    }
  }

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  res.json({ accessToken, refreshToken });
});
```

---

## 6. ロールベースアクセス制御（RBAC）

### 権限管理

**Good**: 柔軟なRBAC実装
```javascript
// データベーススキーマ
/*
CREATE TABLE roles (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE permissions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  resource VARCHAR(50) NOT NULL,
  action VARCHAR(50) NOT NULL
);

CREATE TABLE role_permissions (
  role_id BIGINT,
  permission_id BIGINT,
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
  user_id BIGINT,
  role_id BIGINT,
  PRIMARY KEY (user_id, role_id)
);
*/

// 権限チェックミドルウェア
function requirePermission(resource, action) {
  return async (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const hasPermission = await checkPermission(req.user.userId, resource, action);

    if (!hasPermission) {
      return res.status(403).json({
        error: 'Insufficient permissions',
        required: `${resource}:${action}`
      });
    }

    next();
  };
}

async function checkPermission(userId, resource, action) {
  const result = await db.query(`
    SELECT COUNT(*) as count
    FROM user_roles ur
    JOIN role_permissions rp ON ur.role_id = rp.role_id
    JOIN permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = ?
      AND p.resource = ?
      AND p.action = ?
  `, [userId, resource, action]);

  return result.count > 0;
}

// 使用例
app.get('/api/users',
  authenticateToken,
  requirePermission('users', 'read'),
  async (req, res) => {
    const users = await db.query('SELECT id, email, name FROM users');
    res.json(users);
  }
);

app.post('/api/users',
  authenticateToken,
  requirePermission('users', 'create'),
  async (req, res) => {
    // ユーザー作成処理
  }
);

app.delete('/api/users/:id',
  authenticateToken,
  requirePermission('users', 'delete'),
  async (req, res) => {
    // ユーザー削除処理
  }
);
```

---

## チェックリスト

### パスワード
- [ ] bcrypt/Argon2でハッシュ化（saltRounds ≥ 12）
- [ ] 最小8文字以上の要件
- [ ] 脆弱なパスワードの禁止
- [ ] パスワードリセット機能

### JWT
- [ ] 秘密鍵を環境変数で管理
- [ ] 短い有効期限（15分推奨）
- [ ] リフレッシュトークン実装
- [ ] センシティブ情報を含めない

### セッション
- [ ] Redisなど外部ストレージ使用
- [ ] httpOnly, secure, sameSite設定
- [ ] セッション再生成（ログイン時）
- [ ] タイムアウト設定

### セキュリティ
- [ ] HTTPS必須
- [ ] CSRF対策（トークン、SameSite）
- [ ] レート制限（ログイン試行）
- [ ] ログイン履歴記録

---

## まとめ

このベストプラクティスに従うことで：

- ✅ セキュアな認証・認可実装
- ✅ OWASP推奨事項準拠
- ✅ スケーラブルな設計
- ✅ 優れたユーザーエクスペリエンス

認証・認可設計・実装・レビュー時に、このガイドラインを参照してください。

---

## 参考資料

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect](https://openid.net/connect/)
