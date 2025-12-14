# セキュリティチェックリスト（全般）

**最終更新**: 2025-12-15
**対象**: 全フェーズ（設計・実装・テスト）

---

## 使用方法

このチェックリストは、以下のタイミングで使用してください：

- **設計フェーズ**: セキュリティ要件の抜け漏れ確認
- **実装フェーズ**: コード生成前・生成後の検証
- **レビューフェーズ**: Pull Request作成前の最終確認
- **リリース前**: 本番デプロイ前の最終検証

---

## 1. 認証・認可（Authentication & Authorization）

### 必須チェック項目（Critical）

- [ ] **認証機構の実装**: 全ての保護されたエンドポイント/リソースに認証が必要か
- [ ] **パスワードポリシー**: 最低8文字、大小英数字+記号の組み合わせを要求しているか
- [ ] **パスワードハッシュ化**: bcrypt、Argon2等の適切なハッシュ関数を使用しているか
- [ ] **多要素認証（MFA）**: 管理者アカウントでMFAが有効化されているか
- [ ] **セッション管理**: セッションタイムアウトが適切に設定されているか（推奨: 15-30分）
- [ ] **認可チェック**: 全てのリソースアクセスで権限チェックが行われているか
- [ ] **最小権限の原則**: ユーザー・サービスアカウントに必要最小限の権限のみ付与されているか
- [ ] **ロールベース**: 役割（Role）に基づいたアクセス制御（RBAC）が実装されているか

### 推奨チェック項目（Recommended）

- [ ] OAuthトークンの有効期限が短く設定されているか（推奨: 1時間以内）
- [ ] リフレッシュトークンのローテーションが実装されているか
- [ ] ログイン試行回数制限（レート制限）が実装されているか

### Good / Bad Example

#### Good ✅
```javascript
// パスワードのハッシュ化（bcrypt使用）
const bcrypt = require('bcrypt');
const saltRounds = 12;
const hashedPassword = await bcrypt.hash(password, saltRounds);

// セッションタイムアウト設定
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 1800000, // 30分
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  }
}));
```

#### Bad ❌
```javascript
// パスワードを平文保存
const password = req.body.password;
await db.users.insert({ password: password }); // NG!

// セッションタイムアウトなし
app.use(session({
  secret: 'hardcoded-secret', // NG!
  cookie: { maxAge: null } // NG! タイムアウトなし
}));
```

---

## 2. 入力値検証（Input Validation）

### 必須チェック項目（Critical）

- [ ] **全ての入力を検証**: ユーザー入力、URLパラメータ、ヘッダーを検証しているか
- [ ] **ホワイトリスト方式**: 許可する値を定義しているか（ブラックリストではなく）
- [ ] **型チェック**: 期待する型（文字列、数値等）と一致しているか確認しているか
- [ ] **長さ制限**: 最大長を設定しているか（DoS対策）
- [ ] **エスケープ処理**: HTMLエスケープ、SQLエスケープが適切に行われているか
- [ ] **ファイルアップロード**: 拡張子、MIMEタイプ、サイズを検証しているか
- [ ] **正規表現の安全性**: ReDoS攻撃に脆弱な正規表現を使用していないか

### Good / Bad Example

#### Good ✅
```javascript
// 入力値検証（Joi使用）
const Joi = require('joi');

const schema = Joi.object({
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(0).max(120).required(),
  username: Joi.string().alphanum().min(3).max(30).required()
});

const { error, value } = schema.validate(req.body);
if (error) {
  return res.status(400).json({ error: error.details[0].message });
}
```

#### Bad ❌
```javascript
// 検証なし
const username = req.body.username;
const query = `SELECT * FROM users WHERE username = '${username}'`; // SQL Injection!
```

---

## 3. 機密情報管理（Secrets Management）

### 必須チェック項目（Critical）

- [ ] **環境変数の使用**: APIキー、パスワード等を環境変数から読み込んでいるか
- [ ] **ハードコード禁止**: コード内に機密情報がハードコードされていないか
- [ ] **.gitignoreの設定**: `.env`、認証情報ファイルが除外されているか
- [ ] **シークレット管理サービス**: AWS Secrets Manager、HashiCorp Vault等を使用しているか
- [ ] **暗号化された保存**: 保存時に暗号化されているか（at-rest encryption）
- [ ] **通信の暗号化**: 送信時にTLS/SSLで暗号化されているか（in-transit encryption）
- [ ] **ログに機密情報なし**: ログファイルに機密情報が出力されていないか

### Good / Bad Example

#### Good ✅
```javascript
// 環境変数から読み込み
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
};

// ログには機密情報を含めない
logger.info('Database connection established', { host: dbConfig.host });
```

#### Bad ❌
```javascript
// ハードコード
const dbConfig = {
  host: 'localhost',
  user: 'admin',
  password: 'P@ssw0rd123', // NG!
  database: 'mydb'
};

// ログに機密情報
logger.info('Login attempt', { username, password }); // NG!
```

---

## 4. SQLインジェクション対策

### 必須チェック項目（Critical）

- [ ] **プリペアドステートメント**: パラメータ化クエリを使用しているか
- [ ] **ORM使用**: ORM（Sequelize、TypeORM等）を使用しているか
- [ ] **動的SQL禁止**: 文字列連結でSQLを構築していないか
- [ ] **最小権限のDB接続**: アプリケーションDBユーザーが必要最小限の権限しか持っていないか

### Good / Bad Example

#### Good ✅
```javascript
// プリペアドステートメント（PostgreSQL）
const result = await client.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ORM使用（Sequelize）
const user = await User.findOne({ where: { email: email } });
```

#### Bad ❌
```javascript
// 文字列連結（SQL Injection脆弱性）
const query = `SELECT * FROM users WHERE email = '${email}'`; // NG!
const result = await client.query(query);
```

---

## 5. XSS（Cross-Site Scripting）対策

### 必須チェック項目（Critical）

- [ ] **出力のエスケープ**: HTML出力時に適切にエスケープしているか
- [ ] **Content-Security-Policy**: CSPヘッダーが設定されているか
- [ ] **HTTPOnlyクッキー**: セッションクッキーにHttpOnly属性が設定されているか
- [ ] **テンプレートエンジンの自動エスケープ**: 有効化されているか（React、Vue等）
- [ ] **ユーザー入力のHTML挿入禁止**: `innerHTML`、`dangerouslySetInnerHTML`を避けているか

### Good / Bad Example

#### Good ✅
```javascript
// React（自動エスケープ）
const UserProfile = ({ userName }) => {
  return <div>{userName}</div>; // 自動エスケープ
};

// CSPヘッダー設定
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self'"
  );
  next();
});
```

#### Bad ❌
```javascript
// dangerouslySetInnerHTMLの使用
const UserProfile = ({ userName }) => {
  return <div dangerouslySetInnerHTML={{ __html: userName }} />; // NG!
};

// エスケープなし
document.getElementById('output').innerHTML = userInput; // NG!
```

---

## 6. CSRF（Cross-Site Request Forgery）対策

### 必須チェック項目（Critical）

- [ ] **CSRFトークン**: フォーム送信時にCSRFトークンを使用しているか
- [ ] **SameSite属性**: クッキーにSameSite属性が設定されているか
- [ ] **リファラーチェック**: 重要な操作でリファラーを検証しているか
- [ ] **CORSの適切な設定**: 必要なオリジンのみ許可しているか

### Good / Bad Example

#### Good ✅
```javascript
// CSRFトークン（csurf使用）
const csrf = require('csurf');
app.use(csrf({ cookie: true }));

// SameSite属性
app.use(session({
  cookie: {
    sameSite: 'strict',
    httpOnly: true,
    secure: true
  }
}));

// CORS設定
const cors = require('cors');
app.use(cors({
  origin: 'https://trusted-domain.com',
  credentials: true
}));
```

#### Bad ❌
```javascript
// CSRF対策なし
app.post('/transfer', (req, res) => {
  // CSRFトークンの検証なし
  const { to, amount } = req.body;
  transferMoney(to, amount);
});

// CORS全許可
app.use(cors({ origin: '*' })); // NG!
```

---

## 7. セキュアな通信

### 必須チェック項目（Critical）

- [ ] **HTTPS強制**: 本番環境で全通信がHTTPSで行われているか
- [ ] **HSTS有効化**: Strict-Transport-Securityヘッダーが設定されているか
- [ ] **TLS 1.2以上**: 古いSSL/TLSバージョンが無効化されているか
- [ ] **証明書検証**: 証明書の有効性を検証しているか
- [ ] **セキュアなクッキー**: Secure属性が設定されているか

### Good / Bad Example

#### Good ✅
```javascript
// HTTPS強制リダイレクト
app.use((req, res, next) => {
  if (!req.secure && process.env.NODE_ENV === 'production') {
    return res.redirect('https://' + req.headers.host + req.url);
  }
  next();
});

// HSTSヘッダー
app.use((req, res, next) => {
  res.setHeader(
    'Strict-Transport-Security',
    'max-age=31536000; includeSubDomains; preload'
  );
  next();
});
```

#### Bad ❌
```javascript
// HTTPのまま運用
app.listen(80); // NG! 本番環境でHTTP

// Secure属性なし
res.cookie('session', sessionId); // NG! Secure属性がない
```

---

## 8. 依存関係のセキュリティ

### 必須チェック項目（Critical）

- [ ] **脆弱性スキャン**: `npm audit`、`Snyk`等で定期的にスキャンしているか
- [ ] **最新バージョン**: 依存パッケージが最新（または最新に近い）バージョンか
- [ ] **信頼できるパッケージ**: ダウンロード数、メンテナンス状況を確認しているか
- [ ] **依存関係の最小化**: 不要な依存を削除しているか
- [ ] **ロックファイル**: `package-lock.json`をコミットしているか

### Good / Bad Example

#### Good ✅
```bash
# 定期的な脆弱性スキャン
npm audit
npm audit fix

# Dependabot有効化（GitHub）
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
```

#### Bad ❌
```json
// 古いバージョンの使用
{
  "dependencies": {
    "express": "3.0.0", // NG! 非常に古い
    "lodash": "4.17.15" // NG! 脆弱性あり
  }
}
```

---

## 9. エラーハンドリング

### 必須チェック項目（Critical）

- [ ] **詳細情報の非公開**: スタックトレースを本番環境で公開していないか
- [ ] **汎用エラーメッセージ**: 攻撃者に有用な情報を含まないか
- [ ] **エラーログ記録**: エラーはサーバー側でログ記録されているか
- [ ] **適切なHTTPステータスコード**: エラーの種類に応じたコードを返しているか

### Good / Bad Example

#### Good ✅
```javascript
// 本番環境では汎用エラー
app.use((err, req, res, next) => {
  logger.error('Error occurred', { error: err });

  if (process.env.NODE_ENV === 'production') {
    res.status(500).json({ error: 'Internal Server Error' });
  } else {
    res.status(500).json({ error: err.message, stack: err.stack });
  }
});
```

#### Bad ❌
```javascript
// スタックトレースを公開
app.use((err, req, res, next) => {
  res.status(500).json({
    error: err.message,
    stack: err.stack // NG! 攻撃者に有用な情報
  });
});
```

---

## 10. アクセス制御

### 必須チェック項目（Critical）

- [ ] **認可チェック**: 全てのリソースアクセスで権限確認を行っているか
- [ ] **オブジェクトレベル**: 他人のデータにアクセスできないか（IDOR対策）
- [ ] **パストラバーサル対策**: ファイルパスを検証しているか
- [ ] **管理機能の保護**: 管理画面が適切に保護されているか

### Good / Bad Example

#### Good ✅
```javascript
// オブジェクトレベルの認可チェック
app.get('/api/documents/:id', async (req, res) => {
  const document = await Document.findById(req.params.id);

  // 所有者チェック
  if (document.ownerId !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  res.json(document);
});
```

#### Bad ❌
```javascript
// 認可チェックなし（IDOR脆弱性）
app.get('/api/documents/:id', async (req, res) => {
  const document = await Document.findById(req.params.id);
  res.json(document); // NG! 所有者チェックなし
});
```

---

## チェックリスト完了基準

### Phase 1完了
- [ ] 上記の全ての「必須チェック項目（Critical）」を確認
- [ ] 問題が見つかった場合は修正

### Phase 2完了
- [ ] 「推奨チェック項目（Recommended）」を確認
- [ ] 可能な範囲で対応

---

## 参考資料

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CWE Top 25**: https://cwe.mitre.org/top25/
- **NIST Cybersecurity Framework**: https://www.nist.gov/cyberframework

---

**このチェックリストを使用して、セキュアなシステム開発を実現してください。**
