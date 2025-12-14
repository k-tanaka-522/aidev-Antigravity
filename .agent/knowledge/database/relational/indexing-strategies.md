# データベースインデックス戦略

**最終更新**: 2025-12-15
**対象**: リレーショナルデータベース（MySQL, PostgreSQL, SQL Server等）

---

## 使用方法

このドキュメントは、データベース設計・パフォーマンスチューニング時に参照してください：

- **設計フェーズ**: テーブル設計時のインデックス計画
- **パフォーマンス問題**: スロークエリ発生時の原因調査
- **最適化**: インデックス追加・削除・再構築の判断
- **レビュー**: インデックス設計の妥当性検証

---

## インデックスの基本原則

### インデックスとは

データベースの**目次**のような役割を持ち、データ検索を高速化する仕組み。

**メリット**:
- ✅ SELECT文の高速化
- ✅ WHERE句、JOIN、ORDER BYの最適化
- ✅ ユニーク制約の実装

**デメリット**:
- ❌ INSERT/UPDATE/DELETEの遅延
- ❌ ディスク容量の消費
- ❌ メンテナンスコスト

---

## 1. プライマリキー（PRIMARY KEY）

### ✅ Good Practice

**Good**: サロゲートキー（AUTO_INCREMENT）
```sql
-- MySQL/PostgreSQL
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
);
```

**理由**:
- 整数型は文字列より高速
- AUTO_INCREMENTで順序性保証（B-Tree効率的）
- UUIDより小さい（8バイト vs 16バイト）

---

**Bad**: 複合主キー（不必要な場合）
```sql
-- NG: 主キーが複合キーで肥大化
CREATE TABLE order_items (
  order_id BIGINT,
  product_id BIGINT,
  quantity INT,
  PRIMARY KEY (order_id, product_id)  -- NG: JOINが遅くなる可能性
);
```

**Better**: サロゲートキー追加
```sql
CREATE TABLE order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT NOT NULL,

  UNIQUE KEY uk_order_product (order_id, product_id),
  INDEX idx_order_id (order_id),
  INDEX idx_product_id (product_id),

  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

---

## 2. 単一カラムインデックス

### WHERE句で頻繁に使用するカラム

**Good**: 検索条件に使うカラムにインデックス
```sql
CREATE TABLE products (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category_id BIGINT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  status ENUM('active', 'inactive', 'deleted') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- 頻繁に検索されるカラムにインデックス
  INDEX idx_category_id (category_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
);

-- 高速化されるクエリ
SELECT * FROM products WHERE category_id = 10;
SELECT * FROM products WHERE status = 'active';
SELECT * FROM products WHERE created_at > '2025-01-01';
```

---

**Bad**: すべてのカラムにインデックス
```sql
-- NG: 過剰なインデックス
CREATE TABLE products (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  price DECIMAL(10, 2),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  INDEX idx_name (name),           -- 必要？
  INDEX idx_description (description),  -- NG: TEXT型にインデックスは非効率
  INDEX idx_price (price),         -- 必要？
  INDEX idx_created_at (created_at),
  INDEX idx_updated_at (updated_at)  -- 必要？
);
```

**Why Bad**:
- 更新コスト増大
- ディスク容量の無駄
- オプティマイザの判断が複雑化

---

## 3. 複合インデックス（Composite Index）

### 最左一致の原則

**Good**: 検索条件の順序を考慮
```sql
CREATE TABLE orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  status VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- 複合インデックス: user_id, status, created_at
  INDEX idx_user_status_created (user_id, status, created_at)
);

-- ✅ インデックスが使われる
SELECT * FROM orders WHERE user_id = 123;
SELECT * FROM orders WHERE user_id = 123 AND status = 'completed';
SELECT * FROM orders WHERE user_id = 123 AND status = 'completed' AND created_at > '2025-01-01';

-- ❌ インデックスが使われない
SELECT * FROM orders WHERE status = 'completed';  -- user_idがない
SELECT * FROM orders WHERE created_at > '2025-01-01';  -- user_idがない
```

**インデックスの順序ルール**:
1. **等価条件（=）を先**に配置
2. **範囲条件（>, <, BETWEEN）を後**に配置
3. **カーディナリティの高い**カラムを先に（多様な値を持つカラム）

---

**Good**: カーディナリティを考慮した順序
```sql
-- カーディナリティ分析
-- user_id: 100,000通り（高）
-- status: 5通り（低: pending, processing, completed, cancelled, refunded）
-- created_at: 日時（高）

-- Good: 高カーディナリティを先に
INDEX idx_user_status (user_id, status);

-- Bad: 低カーディナリティを先に（非効率）
INDEX idx_status_user (status, user_id);
```

---

## 4. ユニークインデックス（UNIQUE）

### 重複防止 + 高速検索

**Good**: ビジネスルールの制約 + パフォーマンス
```sql
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  username VARCHAR(50) NOT NULL,

  -- ユニーク制約 + インデックス
  UNIQUE KEY uk_email (email),
  UNIQUE KEY uk_username (username)
);

-- アプリケーションレベルでの重複チェック不要
-- データベースが保証
INSERT INTO users (email, username) VALUES ('test@example.com', 'testuser');
-- エラー: Duplicate entry 'test@example.com' for key 'uk_email'
```

---

**Good**: 複合ユニークキー
```sql
CREATE TABLE user_follows (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  follower_id BIGINT NOT NULL,
  followee_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- 同じユーザーを複数回フォローできないようにする
  UNIQUE KEY uk_follower_followee (follower_id, followee_id),

  INDEX idx_followee (followee_id),

  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (followee_id) REFERENCES users(id)
);
```

---

## 5. 部分インデックス（Partial Index）

### 条件付きインデックス（PostgreSQL）

**Good**: アクティブレコードのみインデックス
```sql
-- PostgreSQL
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(20) NOT NULL,
  price DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 部分インデックス: status='active'のみ
CREATE INDEX idx_active_products ON products (created_at)
WHERE status = 'active';

-- 高速化されるクエリ
SELECT * FROM products
WHERE status = 'active'
ORDER BY created_at DESC;
```

**メリット**:
- インデックスサイズ削減
- 更新コスト削減（削除済みレコードのインデックス更新不要）

---

## 6. カバリングインデックス（Covering Index）

### SELECT対象カラムをすべて含む

**Good**: テーブルアクセス不要
```sql
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  age INT,
  status VARCHAR(20),
  created_at TIMESTAMP,

  -- カバリングインデックス
  INDEX idx_covering (status, email, name)
);

-- ✅ インデックスのみでクエリ完結（テーブルアクセス不要）
SELECT email, name
FROM users
WHERE status = 'active';

-- ❌ テーブルアクセスが必要（ageがインデックスにない）
SELECT email, name, age
FROM users
WHERE status = 'active';
```

---

## 7. フルテキストインデックス

### 全文検索

**Good**: FULLTEXT INDEX（MySQL/PostgreSQL）
```sql
-- MySQL
CREATE TABLE articles (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FULLTEXT INDEX ft_title_content (title, content)
) ENGINE=InnoDB;

-- 全文検索クエリ
SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('データベース 最適化' IN NATURAL LANGUAGE MODE);

-- ブール検索
SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('+データベース -SQL' IN BOOLEAN MODE);
```

---

**PostgreSQL**: GIN インデックス
```sql
-- PostgreSQL
CREATE TABLE articles (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  search_vector tsvector
);

-- GINインデックス作成
CREATE INDEX idx_search ON articles USING GIN(search_vector);

-- 検索ベクトル生成トリガー
CREATE TRIGGER tsvector_update BEFORE INSERT OR UPDATE
ON articles FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.japanese', title, content);

-- 全文検索
SELECT * FROM articles
WHERE search_vector @@ to_tsquery('japanese', 'データベース & 最適化');
```

---

## 8. 空間インデックス（Spatial Index）

### 地理データ検索

**Good**: 位置情報検索の最適化
```sql
-- MySQL (Spatial Index)
CREATE TABLE locations (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  point POINT NOT NULL SRID 4326,

  SPATIAL INDEX idx_point (point)
) ENGINE=InnoDB;

-- 範囲内検索
SET @center = ST_GeomFromText('POINT(139.6917 35.6895)', 4326);  -- 東京
SET @radius = 5000;  -- 5km

SELECT name,
       ST_Distance_Sphere(point, @center) AS distance
FROM locations
WHERE ST_Distance_Sphere(point, @center) <= @radius
ORDER BY distance;
```

---

## 9. インデックスのアンチパターン

### ❌ 避けるべきパターン

#### 1. 関数を使った検索
```sql
-- NG: インデックスが使われない
SELECT * FROM users WHERE YEAR(created_at) = 2025;
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- Good: 範囲検索またはカラム追加
SELECT * FROM users
WHERE created_at >= '2025-01-01' AND created_at < '2026-01-01';

-- または計算済みカラムにインデックス
ALTER TABLE users ADD COLUMN email_lower VARCHAR(255) GENERATED ALWAYS AS (LOWER(email)) STORED;
CREATE INDEX idx_email_lower ON users(email_lower);
```

---

#### 2. 前方一致以外のLIKE検索
```sql
-- NG: インデックスが使われない
SELECT * FROM users WHERE email LIKE '%@example.com';  -- 後方一致
SELECT * FROM users WHERE email LIKE '%test%';         -- 部分一致

-- Good: インデックスが使われる
SELECT * FROM users WHERE email LIKE 'test@%';  -- 前方一致
```

---

#### 3. NULL値の扱い
```sql
-- NG: NULLはインデックスに含まれない（多くのDB）
SELECT * FROM orders WHERE cancelled_at IS NULL;

-- Good: デフォルト値を使う
ALTER TABLE orders
MODIFY COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';

CREATE INDEX idx_status ON orders(status);

SELECT * FROM orders WHERE status = 'active';
```

---

## 10. インデックスのメンテナンス

### 統計情報の更新

**MySQL**:
```sql
-- テーブル統計を更新
ANALYZE TABLE users;

-- インデックス再構築
ALTER TABLE users ENGINE=InnoDB;

-- 断片化確認
SHOW TABLE STATUS LIKE 'users';
```

**PostgreSQL**:
```sql
-- 統計情報更新
ANALYZE users;

-- バキューム（不要領域回収）
VACUUM ANALYZE users;

-- 再インデックス
REINDEX TABLE users;
```

---

### インデックス使用状況の確認

**MySQL**:
```sql
-- スロークエリログ有効化
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;

-- クエリ実行計画確認
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- インデックス統計
SHOW INDEX FROM users;
```

**PostgreSQL**:
```sql
-- 実行計画確認
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- 未使用インデックス検出
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY schemaname, tablename;
```

---

## チェックリスト

### インデックス設計
- [ ] 主キーは整数型サロゲートキー
- [ ] WHERE句で頻繁に使うカラムにインデックス
- [ ] 複合インデックスは最左一致を考慮
- [ ] ユニーク制約が必要な場合はUNIQUE INDEX

### パフォーマンス
- [ ] カーディナリティの高いカラムを先に
- [ ] カバリングインデックスで最適化
- [ ] 関数使用を避ける
- [ ] LIKE検索は前方一致のみ

### メンテナンス
- [ ] 定期的に統計情報更新（ANALYZE）
- [ ] 未使用インデックスの削除
- [ ] 実行計画（EXPLAIN）で確認
- [ ] スロークエリログの監視

### 避けるべきこと
- [ ] すべてのカラムにインデックスを作らない
- [ ] TEXT/BLOB型に通常のインデックスを作らない
- [ ] 低カーディナリティのカラム単独でインデックスを作らない
- [ ] 更新頻度の高いテーブルに過剰なインデックスを作らない

---

## パフォーマンス計測例

### Before / After比較

**Before**: インデックスなし
```sql
-- クエリ
SELECT * FROM orders
WHERE user_id = 12345 AND status = 'completed';

-- 実行計画
type: ALL
rows: 1000000  -- フルスキャン
Extra: Using where

-- 実行時間: 2.5秒
```

**After**: 複合インデックス追加
```sql
-- インデックス作成
CREATE INDEX idx_user_status ON orders(user_id, status);

-- 実行計画
type: ref
rows: 150  -- インデックス使用
Extra: Using index condition

-- 実行時間: 0.05秒（50倍高速化）
```

---

## まとめ

適切なインデックス戦略により：

- ✅ クエリ実行速度の大幅改善
- ✅ データベース負荷軽減
- ✅ スケーラビリティ向上
- ✅ ユーザーエクスペリエンス改善

データベース設計・パフォーマンスチューニング時に、このガイドラインを参照してください。

---

## 参考資料

- [MySQL Indexing Best Practices](https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html)
- [PostgreSQL Index Types](https://www.postgresql.org/docs/current/indexes-types.html)
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [High Performance MySQL](https://www.oreilly.com/library/view/high-performance-mysql/9781492080503/)
