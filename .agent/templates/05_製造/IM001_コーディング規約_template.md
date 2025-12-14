# コーディング規約

## ドキュメント情報

| 項目 | 内容 |
|------|------|
| ドキュメントID | IM001-{YYYYMMDD} |
| プロジェクト名 | {プロジェクト名} |
| 対象言語 | {Python/Java/TypeScript/Go/C#} |
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
2. [命名規則](#命名規則)
3. [フォーマット規則](#フォーマット規則)
4. [コメント規約](#コメント規約)
5. [コーディングスタイル](#コーディングスタイル)
6. [ベストプラクティス](#ベストプラクティス)
7. [禁止事項](#禁止事項)

---

## 概要

### 目的

{このコーディング規約の目的を記述}

### スコープ

{対象となるプロジェクト・言語のスコープを記述}

### 基本方針

- {可読性を最優先とする}
- {保守性を考慮したコードを書く}
- {一貫性のあるコードスタイルを維持する}
- {チーム全体で規約を遵守する}

### 準拠規約

| 規約名 | バージョン | URL | 備考 |
|--------|------------|-----|------|
| {PEP 8/Google Java Style/Airbnb/Effective Go/C# Coding Conventions} | {x.y} | {URL} | {公式規約} |
| {社内規約} | {1.0} | {URL/なし} | {独自規約} |

### ツール設定

| ツール種別 | ツール名 | 設定ファイル | 備考 |
|------------|----------|--------------|------|
| リンター | {pylint/checkstyle/eslint/golangci-lint/StyleCop} | {.pylintrc/.eslintrc/etc} | {自動チェック} |
| フォーマッター | {black/google-java-format/prettier/gofmt/dotnet-format} | {設定ファイル名} | {自動整形} |
| 型チェッカー | {mypy/なし/TypeScript/なし/なし} | {mypy.ini/tsconfig.json} | {静的型チェック} |

---

## 命名規則

### 基本原則

- {意味のある名前を使用する}
- {省略形は避け、明確な名前を使う}
- {英語を使用する(日本語ローマ字は禁止)}
- {略語は一般的なもののみ使用可(ID, URL, HTTPなど)}

### 命名パターン

| 対象 | 命名規則 | 例 | 備考 |
|------|----------|-----|------|
| クラス名 | {PascalCase/UpperCamelCase} | User, UserRepository | {名詞} |
| インターフェース名 | {PascalCase (I接頭辞/なし)} | IUserService, UserService | {形容詞/名詞} |
| メソッド名 | {camelCase/snake_case} | getUserById, get_user_by_id | {動詞+名詞} |
| 関数名 | {camelCase/snake_case} | calculateTotal, calculate_total | {動詞+名詞} |
| 変数名 | {camelCase/snake_case} | userName, user_name | {名詞} |
| 定数名 | {UPPER_SNAKE_CASE} | MAX_RETRY_COUNT | {全て大文字} |
| プライベート変数 | {_camelCase/_snake_case} | _userName, _user_name | {アンダースコア接頭辞} |
| パッケージ名 | {lowercase/snake_case} | userservice, user_service | {全て小文字} |
| ファイル名 | {PascalCase/snake_case} | UserService.java, user_service.py | {クラス名に合わせる} |

### 言語別命名規則

#### Python

```python
# Good
class UserRepository:
    """ユーザーリポジトリ"""
    MAX_RETRY_COUNT = 3

    def __init__(self):
        self._db_connection = None

    def get_user_by_id(self, user_id: int) -> User:
        """IDでユーザーを取得"""
        pass

# Bad
class userRepository:  # クラス名はPascalCase
    max_retry_count = 3  # 定数はUPPER_SNAKE_CASE

    def getUserById(self, userId):  # snake_case推奨
        pass
```

#### Java

```java
// Good
public class UserRepository {
    private static final int MAX_RETRY_COUNT = 3;
    private Connection dbConnection;

    public User getUserById(int userId) {
        // 処理
    }
}

// Bad
public class user_repository {  // クラス名はPascalCase
    private static final int maxRetryCount = 3;  // 定数はUPPER_SNAKE_CASE

    public User get_user_by_id(int user_id) {  // メソッド名はcamelCase
        // 処理
    }
}
```

### 特殊な命名規則

| 対象 | 規則 | 例 | 備考 |
|------|------|-----|------|
| テストクラス | {Test接頭辞/Test接尾辞} | TestUserService, UserServiceTest | {-} |
| テストメソッド | {test接頭辞/should} | test_create_user, shouldCreateUser | {-} |
| ブール値変数 | {is/has/can接頭辞} | isActive, hasPermission, canEdit | {-} |
| 例外クラス | {Exception/Error接尾辞} | ValidationException, NotFoundError | {-} |
| インターフェース実装 | {Impl接尾辞/具体名} | UserServiceImpl, DatabaseUserService | {-} |

---

## フォーマット規則

### インデント

| 項目 | 規則 | 備考 |
|------|------|------|
| インデント文字 | {スペース/タブ} | {スペース推奨} |
| インデント幅 | {2/4スペース} | {言語により異なる} |
| 継続行インデント | {4/8スペース} | {通常の2倍} |

### 行長

| 項目 | 規則 | 備考 |
|------|------|------|
| 最大行長 | {80/100/120文字} | {言語により異なる} |
| コメント行長 | {72/80文字} | {コードより短く} |
| 長い行の分割 | {必須} | {読みやすく分割} |

### 空白・改行

#### 空白の使用

```python
# Good
result = calculate_total(a, b)
if x == 1:
    y = 2

# Bad
result=calculate_total(a,b)
if x==1:
    y=2
```

#### 改行ルール

- {関数・メソッド間は2行空ける}
- {クラス間は2行空ける}
- {論理的なブロック間は1行空ける}
- {ファイル末尾は改行で終わる}

### 括弧・ブロック

#### 言語別ブレーススタイル

```javascript
// JavaScript/TypeScript/C#: K&R スタイル
function calculateTotal(a, b) {
    if (a > 0) {
        return a + b;
    }
    return 0;
}

// Java: Allman スタイル(一部)または K&R
public int calculateTotal(int a, int b)
{
    if (a > 0)
    {
        return a + b;
    }
    return 0;
}

// Python: インデントベース
def calculate_total(a, b):
    if a > 0:
        return a + b
    return 0
```

---

## コメント規約

### コメントの原則

- {コードで表現できることはコードで表現する}
- {なぜ(Why)を書く、何を(What)は書かない}
- {コメントとコードの乖離を避ける}
- {TODO/FIXMEコメントは期限付きで使用}

### ファイルヘッダーコメント

```python
"""
ユーザーサービスモジュール

このモジュールはユーザーに関するビジネスロジックを提供します。

Author: {作成者名}
Created: {YYYY-MM-DD}
Copyright: (c) {YYYY} {会社名}
"""
```

### クラス・関数ドキュメント

#### Python (Docstring)

```python
class UserService:
    """ユーザーサービスクラス

    ユーザーの登録、更新、削除などの操作を提供します。

    Attributes:
        repository (UserRepository): ユーザーリポジトリ
        logger (Logger): ロガー
    """

    def create_user(self, username: str, email: str) -> User:
        """ユーザーを作成する

        Args:
            username (str): ユーザー名(3-50文字)
            email (str): メールアドレス

        Returns:
            User: 作成されたユーザー

        Raises:
            ValidationError: 入力値が不正な場合
            DuplicateError: ユーザーが既に存在する場合
        """
        pass
```

#### Java (Javadoc)

```java
/**
 * ユーザーサービスクラス
 *
 * ユーザーの登録、更新、削除などの操作を提供します。
 *
 * @author {作成者名}
 * @version 1.0
 * @since 2025-01-01
 */
public class UserService {
    /**
     * ユーザーを作成する
     *
     * @param username ユーザー名(3-50文字)
     * @param email メールアドレス
     * @return 作成されたユーザー
     * @throws ValidationException 入力値が不正な場合
     * @throws DuplicateException ユーザーが既に存在する場合
     */
    public User createUser(String username, String email) {
        // 実装
    }
}
```

#### TypeScript (JSDoc)

```typescript
/**
 * ユーザーサービスクラス
 *
 * ユーザーの登録、更新、削除などの操作を提供します。
 */
export class UserService {
    /**
     * ユーザーを作成する
     *
     * @param username - ユーザー名(3-50文字)
     * @param email - メールアドレス
     * @returns 作成されたユーザー
     * @throws {ValidationError} 入力値が不正な場合
     * @throws {DuplicateError} ユーザーが既に存在する場合
     */
    createUser(username: string, email: string): User {
        // 実装
    }
}
```

### インラインコメント

```python
# Good: 理由を説明
# NOTE: パフォーマンス向上のため、キャッシュを使用
user = cache.get(user_id)

# ビジネスルールにより、管理者は削除不可
if user.role == 'admin':
    raise CannotDeleteAdminError()

# Bad: 自明なことを説明
# ユーザーIDで検索
user = get_user_by_id(user_id)

# xに1を足す
x = x + 1
```

### TODO/FIXMEコメント

```python
# TODO(username): ページネーション実装 (期限: 2025-12-31)
def get_users():
    pass

# FIXME(username): メモリリーク修正 (優先度: 高)
def process_data():
    pass

# HACK(username): 一時的な回避策 (Issue #123)
def workaround():
    pass
```

---

## コーディングスタイル

### 変数宣言

```python
# Good: 1行1変数
user_name = "John"
user_email = "john@example.com"
user_age = 30

# Bad: 1行複数変数
user_name, user_email, user_age = "John", "john@example.com", 30
```

### 条件分岐

```python
# Good: 肯定形の条件を使う
if is_valid:
    process()
else:
    handle_error()

# Good: 早期リターン
def get_user(user_id):
    if user_id is None:
        return None

    user = find_user(user_id)
    if user is None:
        return None

    return user

# Bad: ネストが深い
def get_user(user_id):
    if user_id is not None:
        user = find_user(user_id)
        if user is not None:
            return user
        else:
            return None
    else:
        return None
```

### ループ

```python
# Good: リスト内包表記
active_users = [user for user in users if user.is_active]

# Good: enumerate使用
for index, user in enumerate(users):
    print(f"{index}: {user.name}")

# Bad: range(len())
for i in range(len(users)):
    print(f"{i}: {users[i].name}")
```

### 例外処理

```python
# Good: 具体的な例外をキャッチ
try:
    user = get_user(user_id)
except UserNotFoundError:
    logger.warning(f"User not found: {user_id}")
    return None
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise

# Bad: 汎用的な例外をキャッチ
try:
    user = get_user(user_id)
except Exception:
    pass
```

### 関数設計

```python
# Good: 単一責任の原則
def validate_email(email: str) -> bool:
    """メールアドレスの妥当性を検証"""
    return EMAIL_PATTERN.match(email) is not None

def send_welcome_email(email: str) -> None:
    """ウェルカムメールを送信"""
    message = create_welcome_message()
    send_email(email, message)

# Bad: 複数の責任
def validate_and_send_email(email: str) -> bool:
    """メール検証と送信を両方行う"""
    if not EMAIL_PATTERN.match(email):
        return False
    message = create_welcome_message()
    send_email(email, message)
    return True
```

---

## ベストプラクティス

### DRY原則 (Don't Repeat Yourself)

```python
# Good: 共通処理を関数化
def log_user_action(user_id: int, action: str) -> None:
    timestamp = datetime.now()
    logger.info(f"[{timestamp}] User {user_id}: {action}")

log_user_action(user_id, "login")
log_user_action(user_id, "update_profile")

# Bad: 重複コード
timestamp = datetime.now()
logger.info(f"[{timestamp}] User {user_id}: login")

timestamp = datetime.now()
logger.info(f"[{timestamp}] User {user_id}: update_profile")
```

### SOLID原則

- {Single Responsibility Principle: 単一責任の原則}
- {Open/Closed Principle: 開放閉鎖の原則}
- {Liskov Substitution Principle: リスコフの置換原則}
- {Interface Segregation Principle: インターフェース分離の原則}
- {Dependency Inversion Principle: 依存性逆転の原則}

### 型ヒント・型注釈

```python
# Good: 型ヒント使用(Python)
def get_user_by_id(user_id: int) -> Optional[User]:
    pass

def calculate_total(items: List[Item]) -> Decimal:
    pass

# TypeScript: 型注釈
function getUserById(userId: number): User | null {
    // 実装
}
```

### マジックナンバーの排除

```python
# Good: 定数化
MAX_LOGIN_ATTEMPTS = 3
SESSION_TIMEOUT_SECONDS = 3600

if login_attempts > MAX_LOGIN_ATTEMPTS:
    lock_account()

# Bad: マジックナンバー
if login_attempts > 3:
    lock_account()
```

---

## 禁止事項

### 禁止パターン

| 禁止事項 | 理由 | 代替案 |
|----------|------|--------|
| グローバル変数の使用 | 副作用、テスト困難 | 依存性注入、引数渡し |
| ハードコーディング | 保守性低下 | 設定ファイル、環境変数 |
| 過度なネスト(4階層以上) | 可読性低下 | 早期リターン、関数分割 |
| 100行を超える関数 | 複雑性増大 | 関数分割 |
| 意味のない変数名(a, b, x) | 可読性低下 | 意味のある名前 |
| コメントアウトされたコード | 混乱の原因 | バージョン管理に任せる |
| 警告の無視 | 潜在的バグ | 警告を修正する |

### セキュリティ禁止事項

```python
# Bad: SQLインジェクション脆弱性
query = f"SELECT * FROM users WHERE id = {user_id}"

# Good: プリペアドステートメント
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))

# Bad: パスワード平文保存
user.password = password

# Good: ハッシュ化
user.password_hash = hash_password(password)

# Bad: 機密情報のログ出力
logger.info(f"Password: {password}")

# Good: マスキング
logger.info(f"Password: ***")
```

---

## 付録

### リンター設定例

#### .pylintrc (Python)

```ini
[MASTER]
max-line-length=100

[MESSAGES CONTROL]
disable=C0111

[FORMAT]
indent-string='    '
```

#### .eslintrc.json (JavaScript/TypeScript)

```json
{
  "extends": "airbnb",
  "rules": {
    "max-len": ["error", { "code": 100 }],
    "indent": ["error", 2]
  }
}
```

### チェックリスト

- [ ] 命名規則に従っているか
- [ ] 適切にインデントされているか
- [ ] コメントは適切か
- [ ] マジックナンバーは排除されているか
- [ ] 例外処理は適切か
- [ ] 型ヒント・型注釈は付与されているか
- [ ] テストは書かれているか
- [ ] リンターでエラーがないか

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
| {作成者} | {氏名} | {YYYY/MM/DD} | {署名} |
| {レビュアー} | {氏名} | {YYYY/MM/DD} | {署名} |
| {承認者} | {氏名} | {YYYY/MM/DD} | {署名} |
