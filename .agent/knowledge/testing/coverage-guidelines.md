# テストカバレッジガイドライン

**最終更新**: 2025-12-15
**対象**: 全テストレベル（単体・結合・E2E）

---

## 使用方法

このガイドラインは、テスト戦略策定・実装時に使用してください：

- **テスト計画時**: カバレッジ目標の設定
- **実装時**: テストケース作成の指針
- **レビュー時**: テストの充足性確認
- **CI/CD**: カバレッジ閾値の設定

---

## テストピラミッド

```
      /\
     /E2E\         少ない（遅い、高コスト）
    /------\
   / 結合   \       中程度
  /----------\
 / 単体テスト \     多い（速い、低コスト）
/--------------\
```

### 推奨バランス

| テストレベル | 割合 | 実行時間 | カバレッジ目標 |
|-------------|------|---------|---------------|
| 単体テスト | 70% | < 10秒 | 80%以上 |
| 結合テスト | 20% | < 1分 | 主要パス100% |
| E2Eテスト | 10% | < 5分 | クリティカルパス100% |

---

## 1. 単体テスト（Unit Test）

### カバレッジ目標

| 項目 | 目標 | 説明 |
|------|------|------|
| **行カバレッジ** | 80%以上 | 実行された行の割合 |
| **分岐カバレッジ** | 75%以上 | if/else等の分岐の網羅 |
| **関数カバレッジ** | 90%以上 | 実行された関数の割合 |

### 必須テスト項目

- [ ] **正常系**: 期待される入力での動作
- [ ] **異常系**: エラーケースの処理
- [ ] **境界値**: 最小値、最大値、境界値
- [ ] **エッジケース**: null、undefined、空文字列等
- [ ] **副作用**: 状態変更、外部呼び出しのモック

### Good / Bad Example

#### Good ✅ - JavaScript (Jest)
```javascript
// テスト対象: ユーザー登録関数
function registerUser(email, password) {
  if (!email || !password) {
    throw new Error('Email and password are required');
  }
  if (password.length < 8) {
    throw new Error('Password must be at least 8 characters');
  }
  if (!email.includes('@')) {
    throw new Error('Invalid email format');
  }
  return { email, registered: true };
}

// テストコード（網羅的）
describe('registerUser', () => {
  // 正常系
  test('should register user with valid credentials', () => {
    const result = registerUser('user@example.com', 'password123');
    expect(result).toEqual({
      email: 'user@example.com',
      registered: true
    });
  });

  // 異常系: メール未入力
  test('should throw error when email is missing', () => {
    expect(() => registerUser('', 'password123'))
      .toThrow('Email and password are required');
  });

  // 異常系: パスワード未入力
  test('should throw error when password is missing', () => {
    expect(() => registerUser('user@example.com', ''))
      .toThrow('Email and password are required');
  });

  // 異常系: パスワード長さ不足
  test('should throw error when password is too short', () => {
    expect(() => registerUser('user@example.com', 'short'))
      .toThrow('Password must be at least 8 characters');
  });

  // 異常系: 無効なメール形式
  test('should throw error when email format is invalid', () => {
    expect(() => registerUser('invalid-email', 'password123'))
      .toThrow('Invalid email format');
  });

  // 境界値: 最小長のパスワード
  test('should accept password with exactly 8 characters', () => {
    const result = registerUser('user@example.com', '12345678');
    expect(result.registered).toBe(true);
  });
});
```

#### Bad ❌ - 不十分なテスト
```javascript
// テストコード（不十分）
describe('registerUser', () => {
  // 正常系のみ
  test('should register user', () => {
    const result = registerUser('user@example.com', 'password123');
    expect(result.registered).toBe(true);
  });

  // 異常系、境界値テストなし（NG!）
});
```

---

## 2. 結合テスト（Integration Test）

### カバレッジ目標

| 項目 | 目標 | 説明 |
|------|------|------|
| **主要パス** | 100% | クリティカルな業務フロー |
| **API エンドポイント** | 100% | 全てのエンドポイント |
| **データベース操作** | 主要CRUD 100% | 作成・読取・更新・削除 |

### 必須テスト項目

- [ ] **コンポーネント間連携**: 複数モジュールの統合
- [ ] **データベーストランザクション**: CRUD操作
- [ ] **外部API連携**: サードパーティAPIとの通信
- [ ] **認証・認可**: ログイン、権限チェック
- [ ] **エラーハンドリング**: 統合時のエラー処理

### Good / Bad Example

#### Good ✅ - API結合テスト (Supertest + Express)
```javascript
const request = require('supertest');
const app = require('../app');
const db = require('../db');

describe('POST /api/users', () => {
  beforeEach(async () => {
    await db.migrate.latest();
    await db.seed.run();
  });

  afterEach(async () => {
    await db.migrate.rollback();
  });

  // 正常系
  test('should create a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'newuser@example.com',
        password: 'password123'
      })
      .expect(201);

    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('newuser@example.com');

    // DBに実際に保存されているか確認
    const user = await db('users').where({ email: 'newuser@example.com' }).first();
    expect(user).toBeDefined();
  });

  // 異常系: 重複メール
  test('should return 409 when email already exists', async () => {
    await request(app)
      .post('/api/users')
      .send({
        email: 'existing@example.com',
        password: 'password123'
      })
      .expect(409);
  });

  // 異常系: バリデーションエラー
  test('should return 400 when email is invalid', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'invalid-email',
        password: 'password123'
      })
      .expect(400);

    expect(response.body.error).toContain('Invalid email');
  });

  // 認証テスト
  test('should require authentication for protected routes', async () => {
    await request(app)
      .get('/api/users/profile')
      .expect(401);
  });
});
```

#### Bad ❌ - 不十分な結合テスト
```javascript
// 結合テスト（不十分）
describe('POST /api/users', () => {
  test('should create a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'newuser@example.com',
        password: 'password123'
      })
      .expect(201);
  });

  // 異常系、DB確認、認証テストなし（NG!）
});
```

---

## 3. E2Eテスト（End-to-End Test）

### カバレッジ目標

| 項目 | 目標 | 説明 |
|------|------|------|
| **クリティカルパス** | 100% | ビジネス上重要なフロー |
| **主要ユーザーストーリー** | 80%以上 | 代表的な利用シナリオ |

### 必須テスト項目

- [ ] **ユーザー登録・ログイン**: 認証フロー全体
- [ ] **主要業務フロー**: 商品購入、申込み等
- [ ] **決済処理**: 支払いフロー（テスト環境）
- [ ] **マルチブラウザ**: Chrome、Firefox、Safari
- [ ] **モバイル**: レスポンシブデザインの確認

### Good / Bad Example

#### Good ✅ - E2Eテスト (Playwright)
```javascript
const { test, expect } = require('@playwright/test');

test.describe('User Registration Flow', () => {
  test('should complete user registration successfully', async ({ page }) => {
    // 1. 登録ページにアクセス
    await page.goto('/register');
    await expect(page).toHaveTitle(/Sign Up/);

    // 2. フォームに入力
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'SecurePass123!');

    // 3. 利用規約に同意
    await page.check('[name="agreeToTerms"]');

    // 4. 送信
    await page.click('button[type="submit"]');

    // 5. 成功メッセージ確認
    await expect(page.locator('.success-message'))
      .toContainText('Registration successful');

    // 6. 確認メール送信通知
    await expect(page.locator('.email-sent'))
      .toBeVisible();

    // 7. リダイレクト確認
    await expect(page).toHaveURL('/welcome');
  });

  test('should show error when email already exists', async ({ page }) => {
    await page.goto('/register');

    await page.fill('[name="email"]', 'existing@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'SecurePass123!');
    await page.check('[name="agreeToTerms"]');
    await page.click('button[type="submit"]');

    // エラーメッセージ表示
    await expect(page.locator('.error-message'))
      .toContainText('Email already in use');
  });

  test('should show validation error when passwords do not match', async ({ page }) => {
    await page.goto('/register');

    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'DifferentPass!');
    await page.check('[name="agreeToTerms"]');
    await page.click('button[type="submit"]');

    // バリデーションエラー
    await expect(page.locator('[name="confirmPassword"] + .error'))
      .toContainText('Passwords do not match');
  });
});

// マルチブラウザテスト
test.describe('Cross-browser compatibility', () => {
  test.use({ browserName: 'chromium' });
  test('should work on Chrome', async ({ page }) => {
    // テスト内容
  });

  test.use({ browserName: 'firefox' });
  test('should work on Firefox', async ({ page }) => {
    // テスト内容
  });

  test.use({ browserName: 'webkit' });
  test('should work on Safari', async ({ page }) => {
    // テスト内容
  });
});
```

#### Bad ❌ - 不十分なE2Eテスト
```javascript
// E2Eテスト（不十分）
test('user registration', async ({ page }) => {
  await page.goto('/register');
  await page.fill('[name="email"]', 'newuser@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('button[type="submit"]');

  // 成功確認のみ、異常系・検証なし（NG!）
});
```

---

## 4. カバレッジ計測

### カバレッジレポートの見方

#### Istanbul (nyc) の例
```bash
# カバレッジ計測
npm test -- --coverage

# レポート例
-----------------------|---------|----------|---------|---------|-------------------
File                   | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
-----------------------|---------|----------|---------|---------|-------------------
All files              |   85.23 |    78.45 |   92.11 |   84.98 |
 src/                  |   90.12 |    82.34 |   95.00 |   89.87 |
  user.js              |   95.00 |    90.00 |  100.00 |   94.50 | 45-48
  product.js           |   80.00 |    70.00 |   85.00 |   78.90 | 12,23-25,67
-----------------------|---------|----------|---------|---------|-------------------
```

### カバレッジ閾値の設定

#### jest.config.js
```javascript
module.exports = {
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 90,
      lines: 80
    },
    // 重要なファイルは高い閾値
    './src/auth/*.js': {
      statements: 95,
      branches: 90,
      functions: 100,
      lines: 95
    }
  }
};
```

---

## 5. テストすべき重要項目

### セキュリティ

- [ ] **認証**: 未認証時のリダイレクト
- [ ] **認可**: 権限のないアクセスの拒否
- [ ] **入力値検証**: SQLインジェクション、XSS対策
- [ ] **CSRF対策**: トークン検証
- [ ] **セッション管理**: タイムアウト、無効化

### パフォーマンス

- [ ] **応答時間**: APIが規定時間内に応答するか
- [ ] **負荷**: 同時アクセス数に耐えられるか
- [ ] **メモリリーク**: 長時間稼働でメモリが増え続けないか

### データ整合性

- [ ] **トランザクション**: ロールバックが正しく動作するか
- [ ] **外部キー制約**: データの整合性が保たれるか
- [ ] **並行処理**: 同時更新時の競合解決

---

## 6. テスト除外項目

以下は通常カバレッジから除外してOK：

- [ ] **設定ファイル**: config.js等
- [ ] **型定義**: types.ts、interfaces.ts
- [ ] **テストコード自体**: *.test.js、*.spec.js
- [ ] **ログ出力のみの関数**: console.log等
- [ ] **デバッグコード**: 開発中のコメントアウト

### .nycrc（Istanbul設定）
```json
{
  "exclude": [
    "**/*.test.js",
    "**/*.spec.js",
    "**/config/**",
    "**/types/**",
    "**/__mocks__/**"
  ]
}
```

---

## 7. CI/CDでの自動化

### GitHub Actions例
```yaml
name: Test & Coverage

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: npm install

      - name: Run tests with coverage
        run: npm test -- --coverage

      - name: Check coverage thresholds
        run: npm run test:coverage:check

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/coverage-final.json
          fail_ci_if_error: true
```

---

## チェックリスト完了基準

### 単体テスト
- [ ] 行カバレッジ 80%以上
- [ ] 分岐カバレッジ 75%以上
- [ ] 関数カバレッジ 90%以上
- [ ] 正常系・異常系・境界値をテスト

### 結合テスト
- [ ] 主要パス 100%
- [ ] 全APIエンドポイント
- [ ] データベース操作
- [ ] 認証・認可

### E2Eテスト
- [ ] クリティカルパス 100%
- [ ] 主要ユーザーストーリー 80%以上
- [ ] マルチブラウザ確認

### CI/CD
- [ ] カバレッジ自動計測
- [ ] 閾値チェック
- [ ] レポート生成

---

## 参考資料

- **Jest**: https://jestjs.io/
- **Playwright**: https://playwright.dev/
- **Istanbul (nyc)**: https://istanbul.js.org/
- **Testing Trophy**: https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications

---

**このガイドラインを使用して、適切なテストカバレッジを実現してください。**
