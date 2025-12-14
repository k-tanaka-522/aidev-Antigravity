# テーブル定義書

## ドキュメント情報

| 項目 | 内容 |
|------|------|
| ドキュメントID | BD006-03 |
| ドキュメント名 | テーブル定義書 |
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
2. [テーブル定義](#テーブル定義)
3. [共通カラム定義](#共通カラム定義)
4. [DDL生成](#ddl生成)

---

## 概要

### 目的

{このテーブル定義書の目的を記述}

### 適用範囲

{このテーブル定義書が適用される範囲を記述}

### データ型定義

| データ型（論理） | データ型（物理：PostgreSQL） | データ型（物理：MySQL） | 説明 |
|-----------------|--------------------------|----------------------|------|
| UUID | UUID | CHAR(36) | ユニークID |
| 文字列（可変） | VARCHAR(n) | VARCHAR(n) | 可変長文字列 |
| 文字列（固定） | CHAR(n) | CHAR(n) | 固定長文字列 |
| テキスト | TEXT | TEXT | 長文テキスト |
| 整数 | INTEGER | INT | 整数 |
| 長整数 | BIGINT | BIGINT | 長整数 |
| 小数 | NUMERIC(p,s) | DECIMAL(p,s) | 固定小数点数 |
| 真偽値 | BOOLEAN | TINYINT(1) | 真偽値 |
| 日付 | DATE | DATE | 日付 |
| 時刻 | TIME | TIME | 時刻 |
| 日時 | TIMESTAMP | DATETIME | 日時 |
| JSON | JSONB | JSON | JSON形式データ |

---

## テーブル定義

### テーブル定義テンプレート

各テーブルについて以下の形式で定義します。

---

#### テーブルID: {T-XXX}

##### テーブル基本情報

| 項目 | 内容 |
|------|------|
| テーブルID | {T-XXX} |
| テーブル論理名 | {論理名} |
| テーブル物理名 | {physical_name} |
| テーブル種別 | {マスタ/トランザクション/履歴/ログ} |
| 概要 | {テーブルの概要説明} |
| レコード数見積 | {件数} |
| 成長率 | {件/年} |
| パーティション | {有/無} |
| 備考 | {備考} |

##### カラム定義

| No | カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 制約 | 説明 | 備考 |
|----|-------------|-------------|---------|------|------|-------------|------|------|------|
| {No} | {論理名} | {physical_name} | {型} | {桁数} | {○/×} | {値} | {PK/FK/UK/CK} | {説明} | {備考} |

##### 主キー (Primary Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| {制約名} | {カラム名} | {備考} |

##### 外部キー (Foreign Key)

| 制約名 | カラム | 参照テーブル | 参照カラム | ON UPDATE | ON DELETE | 備考 |
|--------|--------|-------------|-----------|-----------|-----------|------|
| {制約名} | {カラム名} | {テーブル名} | {カラム名} | {CASCADE/RESTRICT} | {CASCADE/RESTRICT/SET NULL} | {備考} |

##### ユニークキー (Unique Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| {制約名} | {カラム名} | {備考} |

##### インデックス

| インデックス名 | 種別 | カラム | 説明 | 備考 |
|---------------|------|--------|------|------|
| {インデックス名} | {B-Tree/Hash/GiST/GIN} | {カラム名} | {説明} | {備考} |

##### チェック制約

| 制約名 | 条件式 | 説明 |
|--------|--------|------|
| {制約名} | {条件式} | {説明} |

---

### T-001: users（ユーザー）

##### テーブル基本情報

| 項目 | 内容 |
|------|------|
| テーブルID | T-001 |
| テーブル論理名 | ユーザー |
| テーブル物理名 | users |
| テーブル種別 | トランザクション |
| 概要 | システムユーザーの情報を管理する |
| レコード数見積 | 10,000件 |
| 成長率 | 1,000件/年 |
| パーティション | 無 |
| 備考 | |

##### カラム定義

| No | カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 制約 | 説明 | 備考 |
|----|-------------|-------------|---------|------|------|-------------|------|------|------|
| 1 | ユーザーID | user_id | UUID | - | × | uuid_generate_v4() | PK | ユーザーを一意に識別するID | |
| 2 | メールアドレス | email | VARCHAR | 255 | × | - | UK | メールアドレス | ログインIDとして使用 |
| 3 | パスワードハッシュ | password_hash | VARCHAR | 255 | × | - | | bcryptでハッシュ化したパスワード | |
| 4 | 姓 | last_name | VARCHAR | 50 | × | - | | 姓 | |
| 5 | 名 | first_name | VARCHAR | 50 | × | - | | 名 | |
| 6 | メール認証済み | email_verified | BOOLEAN | - | × | false | | メールアドレスの認証状態 | |
| 7 | メール認証日時 | email_verified_at | TIMESTAMP | - | ○ | NULL | | メール認証が完了した日時 | |
| 8 | 最終ログイン日時 | last_login_at | TIMESTAMP | - | ○ | NULL | | 最後にログインした日時 | |
| 9 | ステータス | status | VARCHAR | 20 | × | 'active' | CK | ユーザーのステータス | active/inactive/suspended |
| 10 | 作成日時 | created_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | | レコード作成日時 | |
| 11 | 更新日時 | updated_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | | レコード更新日時 | |

##### 主キー (Primary Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| pk_users | user_id | |

##### 外部キー (Foreign Key)

なし

##### ユニークキー (Unique Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| uk_users_email | email | メールアドレスの重複を防止 |

##### インデックス

| インデックス名 | 種別 | カラム | 説明 | 備考 |
|---------------|------|--------|------|------|
| idx_users_email | B-Tree | email | メールアドレスでの検索用 | ユニークキーと重複だが明示的に定義 |
| idx_users_status | B-Tree | status | ステータスでの絞り込み用 | |
| idx_users_created_at | B-Tree | created_at | 登録日でのソート用 | |

##### チェック制約

| 制約名 | 条件式 | 説明 |
|--------|--------|------|
| ck_users_status | status IN ('active', 'inactive', 'suspended') | ステータスは定義された値のみ |
| ck_users_email_format | email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z\|a-z]{2,}$' | メールアドレス形式の検証 |

---

### T-011: products（商品）

##### テーブル基本情報

| 項目 | 内容 |
|------|------|
| テーブルID | T-011 |
| テーブル論理名 | 商品 |
| テーブル物理名 | products |
| テーブル種別 | トランザクション |
| 概要 | 商品情報を管理する |
| レコード数見積 | 10,000件 |
| 成長率 | 1,000件/年 |
| パーティション | 無 |
| 備考 | |

##### カラム定義

| No | カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 制約 | 説明 | 備考 |
|----|-------------|-------------|---------|------|------|-------------|------|------|------|
| 1 | 商品ID | product_id | VARCHAR | 20 | × | - | PK | 商品を一意に識別するID | PROD-XXXXXXX形式 |
| 2 | カテゴリID | category_id | INTEGER | - | × | - | FK | 商品カテゴリID | |
| 3 | 商品コード | product_code | VARCHAR | 50 | × | - | UK | 商品コード | JAN/SKUコード |
| 4 | 商品名 | product_name | VARCHAR | 200 | × | - | | 商品名 | |
| 5 | 説明 | description | TEXT | - | ○ | NULL | | 商品の詳細説明 | |
| 6 | 価格 | price | NUMERIC | 10,2 | × | - | CK | 販売価格 | 税抜 |
| 7 | 原価 | cost | NUMERIC | 10,2 | ○ | NULL | CK | 仕入原価 | |
| 8 | ステータス | status | VARCHAR | 20 | × | 'draft' | CK | 商品のステータス | draft/active/discontinued |
| 9 | 有効フラグ | is_active | BOOLEAN | - | × | true | | 有効/無効フラグ | |
| 10 | 作成日時 | created_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | | レコード作成日時 | |
| 11 | 更新日時 | updated_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | | レコード更新日時 | |

##### 主キー (Primary Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| pk_products | product_id | |

##### 外部キー (Foreign Key)

| 制約名 | カラム | 参照テーブル | 参照カラム | ON UPDATE | ON DELETE | 備考 |
|--------|--------|-------------|-----------|-----------|-----------|------|
| fk_products_category | category_id | categories | category_id | CASCADE | RESTRICT | カテゴリが更新されたら商品のカテゴリIDも更新 |

##### ユニークキー (Unique Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| uk_products_code | product_code | 商品コードの重複を防止 |

##### インデックス

| インデックス名 | 種別 | カラム | 説明 | 備考 |
|---------------|------|--------|------|------|
| idx_products_category | B-Tree | category_id | カテゴリ別検索用 | |
| idx_products_name | B-Tree | product_name | 商品名検索用 | LIKE検索に使用 |
| idx_products_status_active | B-Tree | status, is_active | ステータス・有効フラグでの絞り込み用 | 複合インデックス |
| idx_products_price | B-Tree | price | 価格範囲検索用 | |
| idx_products_created_at | B-Tree | created_at | 登録日でのソート用 | |

##### チェック制約

| 制約名 | 条件式 | 説明 |
|--------|--------|------|
| ck_products_status | status IN ('draft', 'active', 'discontinued') | ステータスは定義された値のみ |
| ck_products_price | price >= 0 | 価格は0以上 |
| ck_products_cost | cost IS NULL OR cost >= 0 | 原価は0以上（NULLも許可） |

---

### T-030: orders（注文）

##### テーブル基本情報

| 項目 | 内容 |
|------|------|
| テーブルID | T-030 |
| テーブル論理名 | 注文 |
| テーブル物理名 | orders |
| テーブル種別 | トランザクション |
| 概要 | 注文ヘッダー情報を管理する |
| レコード数見積 | 100,000件 |
| 成長率 | 50,000件/年 |
| パーティション | 有（年次パーティション） |
| 備考 | パーティションキー: order_date |

##### カラム定義

| No | カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 制約 | 説明 | 備考 |
|----|-------------|-------------|---------|------|------|-------------|------|------|------|
| 1 | 注文ID | order_id | VARCHAR | 20 | × | - | PK | 注文を一意に識別するID | ORD-YYYYMMDD-XXXXX形式 |
| 2 | 注文番号 | order_number | VARCHAR | 30 | × | - | UK | 注文番号（表示用） | |
| 3 | 顧客ID | customer_id | VARCHAR | 20 | × | - | FK | 顧客ID | |
| 4 | 注文日 | order_date | DATE | - | × | CURRENT_DATE | | 注文日 | パーティションキー |
| 5 | 小計 | subtotal | NUMERIC | 12,2 | × | 0 | CK | 小計金額 | |
| 6 | 消費税 | tax | NUMERIC | 12,2 | × | 0 | CK | 消費税額 | |
| 7 | 送料 | shipping_fee | NUMERIC | 12,2 | × | 0 | CK | 送料 | |
| 8 | 割引額 | discount | NUMERIC | 12,2 | × | 0 | CK | 割引額 | |
| 9 | 合計金額 | total_amount | NUMERIC | 12,2 | × | 0 | CK | 合計金額 | subtotal + tax + shipping_fee - discount |
| 10 | ステータス | status | VARCHAR | 20 | × | 'pending' | CK | 注文ステータス | pending/confirmed/shipped/delivered/cancelled |
| 11 | 備考 | notes | TEXT | - | ○ | NULL | | 備考 | |
| 12 | 作成日時 | created_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | | レコード作成日時 | |
| 13 | 更新日時 | updated_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | | レコード更新日時 | |

##### 主キー (Primary Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| pk_orders | order_id, order_date | パーティションキーを含む複合主キー |

##### 外部キー (Foreign Key)

| 制約名 | カラム | 参照テーブル | 参照カラム | ON UPDATE | ON DELETE | 備考 |
|--------|--------|-------------|-----------|-----------|-----------|------|
| fk_orders_customer | customer_id | customers | customer_id | CASCADE | RESTRICT | 顧客が削除された注文は残す |

##### ユニークキー (Unique Key)

| 制約名 | カラム | 備考 |
|--------|--------|------|
| uk_orders_number | order_number | 注文番号の重複を防止 |

##### インデックス

| インデックス名 | 種別 | カラム | 説明 | 備考 |
|---------------|------|--------|------|------|
| idx_orders_customer | B-Tree | customer_id | 顧客別注文検索用 | |
| idx_orders_date | B-Tree | order_date | 注文日範囲検索用 | パーティションキー |
| idx_orders_status | B-Tree | status | ステータス絞り込み用 | |
| idx_orders_created | B-Tree | created_at | 作成日時でのソート用 | |

##### チェック制約

| 制約名 | 条件式 | 説明 |
|--------|--------|------|
| ck_orders_status | status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') | ステータスは定義された値のみ |
| ck_orders_amounts | subtotal >= 0 AND tax >= 0 AND shipping_fee >= 0 AND discount >= 0 AND total_amount >= 0 | 金額は全て0以上 |
| ck_orders_total | total_amount = subtotal + tax + shipping_fee - discount | 合計金額の整合性チェック |

---

## 共通カラム定義

### 標準共通カラム

すべてのテーブルに含める標準的な共通カラム

| カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 説明 |
|-------------|-------------|---------|------|------|-------------|------|
| 作成日時 | created_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | レコード作成日時 |
| 更新日時 | updated_at | TIMESTAMP | - | × | CURRENT_TIMESTAMP | レコード更新日時 |

### 論理削除用カラム（オプション）

| カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 説明 |
|-------------|-------------|---------|------|------|-------------|------|
| 削除フラグ | is_deleted | BOOLEAN | - | × | false | 論理削除フラグ |
| 削除日時 | deleted_at | TIMESTAMP | - | ○ | NULL | 削除日時 |

### 楽観的ロック用カラム（オプション）

| カラム論理名 | カラム物理名 | データ型 | 桁数 | NULL | デフォルト値 | 説明 |
|-------------|-------------|---------|------|------|-------------|------|
| バージョン | version | INTEGER | - | × | 0 | 楽観的ロック用バージョン番号 |

---

## DDL生成

### DDL生成例（PostgreSQL）

#### users テーブル

```sql
-- ユーザーテーブル作成
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    email_verified BOOLEAN NOT NULL DEFAULT false,
    email_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT ck_users_status CHECK (status IN ('active', 'inactive', 'suspended')),
    CONSTRAINT ck_users_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

-- インデックス作成
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- コメント追加
COMMENT ON TABLE users IS 'ユーザー情報を管理するテーブル';
COMMENT ON COLUMN users.user_id IS 'ユーザーID（UUID）';
COMMENT ON COLUMN users.email IS 'メールアドレス（ログインID）';
COMMENT ON COLUMN users.password_hash IS 'パスワードハッシュ（bcrypt）';
COMMENT ON COLUMN users.status IS 'ステータス（active/inactive/suspended）';

-- 更新日時の自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### products テーブル

```sql
-- 商品テーブル作成
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category_id INTEGER NOT NULL,
    product_code VARCHAR(50) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    cost NUMERIC(10,2),
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_products_code UNIQUE (product_code),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_products_status CHECK (status IN ('draft', 'active', 'discontinued')),
    CONSTRAINT ck_products_price CHECK (price >= 0),
    CONSTRAINT ck_products_cost CHECK (cost IS NULL OR cost >= 0)
);

-- インデックス作成
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_status_active ON products(status, is_active);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_created_at ON products(created_at);

-- コメント追加
COMMENT ON TABLE products IS '商品情報を管理するテーブル';
COMMENT ON COLUMN products.product_id IS '商品ID（PROD-XXXXXXX形式）';
COMMENT ON COLUMN products.product_code IS '商品コード（JAN/SKU）';
COMMENT ON COLUMN products.price IS '販売価格（税抜）';
COMMENT ON COLUMN products.cost IS '仕入原価';
COMMENT ON COLUMN products.status IS 'ステータス（draft/active/discontinued）';

-- 更新日時の自動更新トリガー
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### orders テーブル（パーティションテーブル）

```sql
-- 注文テーブル作成（パーティション親テーブル）
CREATE TABLE orders (
    order_id VARCHAR(20),
    order_number VARCHAR(30) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    tax NUMERIC(12,2) NOT NULL DEFAULT 0,
    shipping_fee NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, order_date),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_orders_status CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    CONSTRAINT ck_orders_amounts CHECK (
        subtotal >= 0 AND tax >= 0 AND shipping_fee >= 0 AND discount >= 0 AND total_amount >= 0
    ),
    CONSTRAINT ck_orders_total CHECK (total_amount = subtotal + tax + shipping_fee - discount)
) PARTITION BY RANGE (order_date);

-- 2024年パーティション作成
CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- 2025年パーティション作成
CREATE TABLE orders_2025 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- インデックス作成
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);

-- ユニークキー（グローバル）
CREATE UNIQUE INDEX uk_orders_number ON orders(order_number);

-- コメント追加
COMMENT ON TABLE orders IS '注文ヘッダー情報を管理するテーブル（年次パーティション）';
COMMENT ON COLUMN orders.order_id IS '注文ID（ORD-YYYYMMDD-XXXXX形式）';
COMMENT ON COLUMN orders.order_date IS '注文日（パーティションキー）';
COMMENT ON COLUMN orders.status IS 'ステータス（pending/confirmed/shipped/delivered/cancelled）';

-- 更新日時の自動更新トリガー
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

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

- [ER図] BD006-01_ER図
- [テーブル一覧] BD006-02_テーブル一覧
- [機能設計書] BD002_機能設計書
- [画面項目定義書] BD003-03_画面項目定義書

### 外部参照

- {参照先タイトル}: {URL}
