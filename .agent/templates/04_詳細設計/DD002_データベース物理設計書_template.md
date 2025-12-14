# データベース物理設計書

## ドキュメント情報

| 項目 | 内容 |
|------|------|
| ドキュメントID | DD002-{YYYYMMDD} |
| プロジェクト名 | {プロジェクト名} |
| サブシステム名 | {サブシステム名} |
| 対象データベース | {データベース名} |
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
2. [データベース環境](#データベース環境)
3. [物理テーブル定義](#物理テーブル定義)
4. [インデックス設計](#インデックス設計)
5. [パーティション設計](#パーティション設計)
6. [制約定義](#制約定義)
7. [ストレージ設計](#ストレージ設計)
8. [パフォーマンスチューニング](#パフォーマンスチューニング)

---

## 概要

### 目的

{このデータベース物理設計書の目的を記述}

### スコープ

{対象となるデータベースのスコープを記述}

### 前提条件

- {前提条件1}
- {前提条件2}
- {前提条件3}

### 参照ドキュメント

| ドキュメント名 | ドキュメントID | 版数 |
|----------------|----------------|------|
| {論理データモデル} | {BD002-XX} | {1.0} |
| {基本設計書} | {BD001-XX} | {1.0} |

---

## データベース環境

### データベース基本情報

| 項目 | 内容 |
|------|------|
| DBMS製品 | {MySQL/PostgreSQL/Oracle/SQL Server/MongoDB/など} |
| バージョン | {x.y.z} |
| エディション | {Community/Enterprise/Standard/など} |
| 文字セット | {UTF8MB4/UTF8/SJIS/など} |
| 照合順序 | {utf8mb4_general_ci/など} |
| タイムゾーン | {UTC/JST/など} |
| ストレージエンジン | {InnoDB/MyISAM/など} |

### データベース構成

| 項目 | 本番環境 | ステージング環境 | 開発環境 |
|------|----------|------------------|----------|
| ホスト名 | {ホスト名} | {ホスト名} | {ホスト名} |
| ポート | {3306} | {3306} | {3306} |
| データベース名 | {DB名} | {DB名} | {DB名} |
| スキーマ名 | {スキーマ名} | {スキーマ名} | {スキーマ名} |
| レプリケーション | {Master-Slave/Multi-Master/なし} | {なし} | {なし} |
| バックアップ | {毎日/毎週} | {毎週} | {不要} |

### インスタンス仕様

| 項目 | 本番環境 | ステージング環境 | 開発環境 |
|------|----------|------------------|----------|
| インスタンスタイプ | {db.m5.xlarge} | {db.t3.medium} | {db.t3.small} |
| vCPU | {4} | {2} | {2} |
| メモリ | {16GB} | {4GB} | {2GB} |
| ストレージ種別 | {SSD/HDD/Provisioned IOPS} | {SSD} | {SSD} |
| ストレージサイズ | {500GB} | {100GB} | {50GB} |
| IOPS | {3000} | {1000} | {100} |
| Multi-AZ | {有効/無効} | {無効} | {無効} |

### 接続情報

| 項目 | 内容 |
|------|------|
| 接続プール最小 | {10} |
| 接続プール最大 | {100} |
| 接続タイムアウト | {30秒} |
| クエリタイムアウト | {300秒} |
| アイドルタイムアウト | {600秒} |

---

## 物理テーブル定義

### テーブル一覧

| No | テーブル物理名 | テーブル論理名 | 行数見積 | 増加率 | パーティション | 備考 |
|----|----------------|----------------|----------|--------|----------------|------|
| 1 | {table_name_1} | {テーブル名1} | {10,000} | {1,000件/月} | {有/無} | {備考} |
| 2 | {table_name_2} | {テーブル名2} | {100,000} | {10,000件/月} | {有/無} | {備考} |
| 3 | {table_name_3} | {テーブル名3} | {1,000,000} | {100,000件/月} | {有/無} | {備考} |

### {table_name_1}

#### テーブル基本情報

| 項目 | 内容 |
|------|------|
| テーブル物理名 | {table_name_1} |
| テーブル論理名 | {テーブル論理名} |
| テーブル説明 | {テーブルの説明} |
| ストレージエンジン | {InnoDB/MyISAM/など} |
| 文字セット | {utf8mb4} |
| 照合順序 | {utf8mb4_general_ci} |
| 行フォーマット | {DYNAMIC/COMPACT/REDUNDANT} |
| 初期サイズ | {10MB} |
| 増加率 | {1MB/月} |
| 保持期間 | {5年/無期限} |

#### カラム定義

| No | カラム物理名 | カラム論理名 | データ型 | サイズ | NULL | デフォルト値 | 説明 | 備考 |
|----|--------------|--------------|----------|------|------|--------------|------|------|
| 1 | {column_id} | {カラム名} | {BIGINT/VARCHAR/など} | {20/255/など} | {NOT NULL/NULL} | {値/なし} | {説明} | {PK} |
| 2 | {column_name} | {カラム名} | {VARCHAR} | {100} | {NOT NULL/NULL} | {値/なし} | {説明} | {UK} |
| 3 | {column_status} | {カラム名} | {TINYINT} | {1} | {NOT NULL/NULL} | {0} | {説明} | {Index} |
| 4 | {column_date} | {カラム名} | {DATETIME} | {-} | {NOT NULL/NULL} | {CURRENT_TIMESTAMP} | {説明} | {Index} |
| 5 | {created_at} | {作成日時} | {DATETIME} | {-} | {NOT NULL} | {CURRENT_TIMESTAMP} | {作成日時} | {-} |
| 6 | {created_by} | {作成者} | {VARCHAR} | {50} | {NOT NULL} | {-} | {作成者ID} | {-} |
| 7 | {updated_at} | {更新日時} | {DATETIME} | {-} | {NOT NULL} | {CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP} | {更新日時} | {-} |
| 8 | {updated_by} | {更新者} | {VARCHAR} | {50} | {NOT NULL} | {-} | {更新者ID} | {-} |
| 9 | {version} | {バージョン} | {INT} | {-} | {NOT NULL} | {1} | {楽観的ロック用} | {-} |
| 10 | {is_deleted} | {削除フラグ} | {BOOLEAN} | {-} | {NOT NULL} | {FALSE} | {論理削除フラグ} | {Index} |

#### 主キー制約

| 制約名 | 対象カラム | 備考 |
|--------|------------|------|
| {PK_table_name_1} | {column_id} | {備考} |

#### 一意キー制約

| 制約名 | 対象カラム | 備考 |
|--------|------------|------|
| {UK_table_name_1_column_name} | {column_name} | {備考} |

#### 外部キー制約

| 制約名 | 対象カラム | 参照テーブル | 参照カラム | ON DELETE | ON UPDATE | 備考 |
|--------|------------|--------------|------------|-----------|-----------|------|
| {FK_table_name_1_ref_table} | {ref_id} | {ref_table_name} | {id} | {CASCADE/RESTRICT/SET NULL/NO ACTION} | {CASCADE/RESTRICT/SET NULL/NO ACTION} | {備考} |

#### CHECK制約

| 制約名 | 条件式 | 説明 |
|--------|--------|------|
| {CHK_table_name_1_status} | {status IN (0, 1, 2, 9)} | {ステータス値の制限} |
| {CHK_table_name_1_amount} | {amount >= 0} | {金額は0以上} |

#### DDL文

```sql
CREATE TABLE {table_name_1} (
    {column_id} BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    {column_name} VARCHAR(100) NOT NULL COMMENT '名称',
    {column_status} TINYINT NOT NULL DEFAULT 0 COMMENT 'ステータス',
    {column_date} DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '日付',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    created_by VARCHAR(50) NOT NULL COMMENT '作成者',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    updated_by VARCHAR(50) NOT NULL COMMENT '更新者',
    version INT NOT NULL DEFAULT 1 COMMENT 'バージョン',
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE COMMENT '削除フラグ',

    PRIMARY KEY (column_id),
    UNIQUE KEY UK_table_name_1_column_name (column_name),
    KEY IDX_table_name_1_status (column_status),
    KEY IDX_table_name_1_date (column_date),
    KEY IDX_table_name_1_deleted (is_deleted),

    CONSTRAINT CHK_table_name_1_status CHECK (column_status IN (0, 1, 2, 9))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='{テーブル論理名}';
```

### {table_name_2}

{上記と同様の形式で記述}

---

## インデックス設計

### インデックス一覧

| No | テーブル名 | インデックス名 | インデックス種別 | 対象カラム | カーディナリティ | 選択率 | 備考 |
|----|------------|----------------|------------------|------------|------------------|--------|------|
| 1 | {table_name_1} | {PK_table_name_1} | {PRIMARY KEY} | {column_id} | {高} | {-} | {主キー} |
| 2 | {table_name_1} | {UK_table_name_1_name} | {UNIQUE} | {column_name} | {高} | {-} | {一意制約} |
| 3 | {table_name_1} | {IDX_table_name_1_status_date} | {INDEX} | {column_status, column_date} | {中} | {10%} | {検索用} |
| 4 | {table_name_1} | {IDX_table_name_1_date} | {INDEX} | {column_date} | {中} | {20%} | {ソート用} |

### {table_name_1} インデックス詳細

#### IDX_{table_name_1}_status_date

| 項目 | 内容 |
|------|------|
| インデックス名 | IDX_{table_name_1}_status_date |
| インデックス種別 | {B-Tree/Hash/Full-Text/Spatial} |
| 対象カラム | {column_status, column_date} |
| カラム順序 | {column_status ASC, column_date DESC} |
| 一意性 | {非一意} |
| クラスタ化 | {なし/あり} |
| 部分インデックス | {なし/条件式} |
| 目的 | {ステータス・日付での検索を高速化} |

##### 使用されるクエリ

```sql
-- クエリ例1
SELECT * FROM {table_name_1}
WHERE column_status = 1
  AND column_date >= '2025-01-01'
ORDER BY column_date DESC;

-- クエリ例2
SELECT COUNT(*) FROM {table_name_1}
WHERE column_status IN (1, 2)
  AND column_date BETWEEN '2025-01-01' AND '2025-12-31';
```

##### パフォーマンス指標

| 項目 | 目標値 | 実測値 | 備考 |
|------|--------|--------|------|
| 検索時間 | {< 100ms} | {未測定} | {100万件時} |
| インデックスサイズ | {< 50MB} | {未測定} | {-} |
| 更新オーバーヘッド | {< 10ms} | {未測定} | {INSERT時} |

#### IDX_{table_name_1}_date

{上記と同様の形式で記述}

---

## パーティション設計

### パーティション一覧

| No | テーブル名 | パーティション方式 | パーティションキー | パーティション数 | 備考 |
|----|------------|--------------------|--------------------|------------------|------|
| 1 | {table_name_1} | {RANGE/HASH/LIST/KEY} | {column_date} | {12} | {月次パーティション} |
| 2 | {table_name_2} | {RANGE/HASH/LIST/KEY} | {column_id} | {4} | {ハッシュパーティション} |

### {table_name_1} パーティション詳細

#### パーティション基本情報

| 項目 | 内容 |
|------|------|
| テーブル名 | {table_name_1} |
| パーティション方式 | {RANGE COLUMNS} |
| パーティションキー | {column_date} |
| サブパーティション | {なし/あり} |
| パーティション数 | {12} |
| 自動追加 | {有/無} |
| 自動削除 | {有/無} |
| 保持期間 | {12ヶ月} |

#### パーティション定義

| パーティション名 | 範囲 | 行数見積 | サイズ見積 | 備考 |
|------------------|------|----------|------------|------|
| {p_202501} | {< '2025-02-01'} | {10,000} | {10MB} | {2025年1月} |
| {p_202502} | {< '2025-03-01'} | {10,000} | {10MB} | {2025年2月} |
| {p_202512} | {< '2026-01-01'} | {10,000} | {10MB} | {2025年12月} |
| {p_max} | {MAXVALUE} | {-} | {-} | {上限なし} |

#### DDL文

```sql
CREATE TABLE {table_name_1} (
    -- カラム定義は省略
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
PARTITION BY RANGE COLUMNS(column_date) (
    PARTITION p_202501 VALUES LESS THAN ('2025-02-01'),
    PARTITION p_202502 VALUES LESS THAN ('2025-03-01'),
    PARTITION p_202503 VALUES LESS THAN ('2025-04-01'),
    PARTITION p_202504 VALUES LESS THAN ('2025-05-01'),
    PARTITION p_202505 VALUES LESS THAN ('2025-06-01'),
    PARTITION p_202506 VALUES LESS THAN ('2025-07-01'),
    PARTITION p_202507 VALUES LESS THAN ('2025-08-01'),
    PARTITION p_202508 VALUES LESS THAN ('2025-09-01'),
    PARTITION p_202509 VALUES LESS THAN ('2025-10-01'),
    PARTITION p_202510 VALUES LESS THAN ('2025-11-01'),
    PARTITION p_202511 VALUES LESS THAN ('2025-12-01'),
    PARTITION p_202512 VALUES LESS THAN ('2026-01-01'),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);
```

#### パーティション管理手順

##### パーティション追加

```sql
-- 新しいパーティションを追加
ALTER TABLE {table_name_1}
REORGANIZE PARTITION p_max INTO (
    PARTITION p_202601 VALUES LESS THAN ('2026-02-01'),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);
```

##### パーティション削除

```sql
-- 古いパーティションを削除
ALTER TABLE {table_name_1}
DROP PARTITION p_202501;
```

---

## 制約定義

### 制約一覧

| No | テーブル名 | 制約名 | 制約種別 | 対象カラム | 説明 |
|----|------------|--------|----------|------------|------|
| 1 | {table_name_1} | {PK_table_name_1} | {PRIMARY KEY} | {column_id} | {主キー} |
| 2 | {table_name_1} | {UK_table_name_1_name} | {UNIQUE} | {column_name} | {一意制約} |
| 3 | {table_name_1} | {FK_table_name_1_ref} | {FOREIGN KEY} | {ref_id} | {外部キー} |
| 4 | {table_name_1} | {CHK_table_name_1_status} | {CHECK} | {column_status} | {値制約} |
| 5 | {table_name_1} | {NN_table_name_1_name} | {NOT NULL} | {column_name} | {非NULL制約} |

### デフォルト値一覧

| テーブル名 | カラム名 | デフォルト値 | 説明 |
|------------|----------|--------------|------|
| {table_name_1} | {column_status} | {0} | {初期ステータス} |
| {table_name_1} | {created_at} | {CURRENT_TIMESTAMP} | {作成日時} |
| {table_name_1} | {version} | {1} | {初期バージョン} |
| {table_name_1} | {is_deleted} | {FALSE} | {削除フラグ} |

---

## ストレージ設計

### テーブルスペース設計

| テーブルスペース名 | 目的 | 初期サイズ | 最大サイズ | 自動拡張 | 拡張サイズ | 備考 |
|--------------------|------|------------|------------|----------|------------|------|
| {TBS_DATA} | {データ格納} | {1GB} | {100GB/無制限} | {有効} | {100MB} | {メインデータ} |
| {TBS_INDEX} | {インデックス格納} | {500MB} | {50GB/無制限} | {有効} | {50MB} | {インデックス} |
| {TBS_TEMP} | {一時領域} | {500MB} | {10GB/無制限} | {有効} | {100MB} | {一時テーブル} |
| {TBS_ARCHIVE} | {アーカイブ} | {1GB} | {500GB/無制限} | {有効} | {100MB} | {履歴データ} |

### ファイル配置

| データ種別 | 配置ディスク | マウントポイント | サイズ | 備考 |
|------------|--------------|------------------|--------|------|
| データファイル | {/dev/sdb1} | {/data/mysql} | {100GB} | {SSD} |
| インデックスファイル | {/dev/sdb1} | {/data/mysql} | {50GB} | {SSD} |
| ログファイル | {/dev/sdc1} | {/log/mysql} | {20GB} | {SSD} |
| バックアップ | {/dev/sdd1} | {/backup/mysql} | {500GB} | {HDD} |

### バッファプール設定

| 項目 | 値 | 説明 |
|------|-----|------|
| innodb_buffer_pool_size | {12GB} | {物理メモリの75%} |
| innodb_buffer_pool_instances | {4} | {並列処理数} |
| innodb_log_file_size | {1GB} | {Redoログサイズ} |
| innodb_log_buffer_size | {16MB} | {ログバッファ} |
| innodb_flush_log_at_trx_commit | {1} | {トランザクション毎にフラッシュ} |

---

## パフォーマンスチューニング

### クエリパフォーマンス目標

| クエリ種別 | 目標レスポンス | 同時実行数 | 備考 |
|------------|----------------|------------|------|
| 単純検索 | {< 100ms} | {100} | {主キー検索} |
| 複雑検索 | {< 500ms} | {50} | {JOIN複数} |
| 集計クエリ | {< 3秒} | {10} | {大量データ集計} |
| INSERT | {< 50ms} | {100} | {単一行} |
| UPDATE | {< 100ms} | {50} | {条件付き更新} |
| DELETE | {< 100ms} | {20} | {条件付き削除} |

### スロークエリ設定

| 項目 | 値 | 説明 |
|------|-----|------|
| slow_query_log | {ON} | {スロークエリログ有効化} |
| long_query_time | {1.0} | {1秒以上のクエリを記録} |
| log_queries_not_using_indexes | {ON} | {インデックス未使用クエリを記録} |
| min_examined_row_limit | {1000} | {1000行以上スキャンを記録} |

### 統計情報更新

| テーブル名 | 更新頻度 | 更新タイミング | 方法 | 備考 |
|------------|----------|----------------|------|------|
| {table_name_1} | {毎日} | {深夜2:00} | {ANALYZE TABLE} | {自動実行} |
| {table_name_2} | {毎週} | {日曜2:00} | {ANALYZE TABLE} | {自動実行} |

### キャッシュ設定

| 項目 | 値 | 説明 |
|------|-----|------|
| query_cache_type | {OFF/ON} | {クエリキャッシュ} |
| query_cache_size | {0/256MB} | {キャッシュサイズ} |
| table_open_cache | {4000} | {テーブルオープンキャッシュ} |
| thread_cache_size | {100} | {スレッドキャッシュ} |

---

## バックアップ・リストア

### バックアップ設計

| 項目 | 内容 |
|------|------|
| バックアップ方式 | {論理バックアップ/物理バックアップ/スナップショット} |
| バックアップツール | {mysqldump/Percona XtraBackup/AWS Backup/など} |
| バックアップ頻度 | {毎日/毎週} |
| バックアップ時刻 | {深夜3:00} |
| フルバックアップ | {日曜日} |
| 差分バックアップ | {月-土曜日} |
| 保持期間 | {30日} |
| 世代管理 | {7世代} |
| バックアップ先 | {S3/ローカルディスク/NAS} |
| 暗号化 | {有/無} |
| 圧縮 | {有/無} |

### リストア手順

#### フルリストア

```bash
# バックアップファイルからリストア
mysql -u {user} -p {database_name} < backup_YYYYMMDD.sql

# または物理バックアップの場合
xtrabackup --copy-back --target-dir=/backup/YYYYMMDD/
```

#### ポイントインタイムリカバリ

```bash
# バイナリログを使用したリカバリ
mysqlbinlog --start-datetime="2025-01-01 00:00:00" \
            --stop-datetime="2025-01-01 12:00:00" \
            binlog.000001 | mysql -u {user} -p {database_name}
```

### リストア目標時間

| 項目 | 目標値 | 備考 |
|------|--------|------|
| RTO (Recovery Time Objective) | {4時間} | {リストア完了までの時間} |
| RPO (Recovery Point Objective) | {1時間} | {許容されるデータ損失時間} |

---

## セキュリティ設計

### ユーザー・権限管理

| ユーザー名 | 権限 | 接続元 | 用途 | 備考 |
|------------|------|--------|------|------|
| {app_user} | {SELECT, INSERT, UPDATE, DELETE} | {アプリサーバー} | {アプリケーション用} | {-} |
| {batch_user} | {SELECT, INSERT, UPDATE, DELETE} | {バッチサーバー} | {バッチ処理用} | {-} |
| {admin_user} | {ALL PRIVILEGES} | {踏み台サーバー} | {管理用} | {MFA必須} |
| {readonly_user} | {SELECT} | {BIツール} | {参照専用} | {-} |

### 暗号化設定

| 項目 | 設定 | 備考 |
|------|------|------|
| 通信暗号化 | {TLS 1.2以上必須} | {SSL証明書使用} |
| データ暗号化(保存時) | {有効/無効} | {AES-256} |
| バックアップ暗号化 | {有効/無効} | {AES-256} |
| パスワードポリシー | {強度: MEDIUM} | {8文字以上、複雑性要求} |

### 監査ログ

| 項目 | 設定 | 備考 |
|------|------|------|
| 監査ログ有効化 | {有効/無効} | {-} |
| 記録対象 | {DDL, DML, DCL} | {-} |
| 保持期間 | {90日} | {-} |
| ログローテーション | {毎日} | {-} |

---

## 監視設計

### 監視項目

| 監視項目 | 閾値(警告) | 閾値(異常) | 監視間隔 | 通知先 |
|----------|------------|------------|----------|--------|
| CPU使用率 | {70%} | {90%} | {5分} | {運用チーム} |
| メモリ使用率 | {80%} | {95%} | {5分} | {運用チーム} |
| ディスク使用率 | {70%} | {85%} | {10分} | {運用チーム} |
| 接続数 | {80/100} | {95/100} | {1分} | {運用チーム} |
| スロークエリ数 | {10件/時間} | {50件/時間} | {1時間} | {開発チーム} |
| レプリケーション遅延 | {60秒} | {300秒} | {1分} | {運用チーム} |
| デッドロック発生 | {1件/日} | {10件/日} | {1時間} | {開発チーム} |

### アラート設定

| アラート名 | 条件 | 重要度 | 対応方針 |
|------------|------|--------|----------|
| {ディスク容量逼迫} | {使用率85%超過} | {高} | {即時対応} |
| {レプリケーション停止} | {遅延300秒超過} | {高} | {即時対応} |
| {接続数上限} | {接続数95%超過} | {中} | {1時間以内対応} |
| {スロークエリ多発} | {50件/時間超過} | {低} | {翌営業日対応} |

---

## 付録

### ER図

```mermaid
erDiagram
    {table_name_1} ||--o{ {table_name_2} : "has"
    {table_name_1} {
        BIGINT column_id PK
        VARCHAR column_name UK
        TINYINT column_status
        DATETIME created_at
    }
    {table_name_2} {
        BIGINT column_id PK
        BIGINT ref_id FK
        VARCHAR column_value
        DATETIME created_at
    }
```

### データ型対応表

| 論理データ型 | MySQL | PostgreSQL | Oracle | SQL Server |
|--------------|-------|------------|--------|------------|
| 整数(小) | TINYINT | SMALLINT | NUMBER(3) | TINYINT |
| 整数(中) | INT | INTEGER | NUMBER(10) | INT |
| 整数(大) | BIGINT | BIGINT | NUMBER(19) | BIGINT |
| 文字列(可変) | VARCHAR | VARCHAR | VARCHAR2 | VARCHAR |
| 文字列(固定) | CHAR | CHAR | CHAR | CHAR |
| 日付時刻 | DATETIME | TIMESTAMP | DATE | DATETIME2 |
| 真偽値 | BOOLEAN | BOOLEAN | NUMBER(1) | BIT |
| バイナリ | BLOB | BYTEA | BLOB | VARBINARY |

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
| {DBA} | {氏名} | {YYYY/MM/DD} | {署名} |
| {承認者} | {氏名} | {YYYY/MM/DD} | {署名} |
