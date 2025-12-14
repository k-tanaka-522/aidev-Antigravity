# 単体テスト仕様書

## ドキュメント情報

| 項目 | 内容 |
|------|------|
| ドキュメントID | DD004-{YYYYMMDD} |
| プロジェクト名 | {プロジェクト名} |
| サブシステム名 | {サブシステム名} |
| 対象モジュール | {モジュール名} |
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
2. [テスト方針](#テスト方針)
3. [テスト環境](#テスト環境)
4. [テストケース](#テストケース)
5. [カバレッジ目標](#カバレッジ目標)
6. [テストデータ](#テストデータ)

---

## 概要

### 目的

{この単体テスト仕様書の目的を記述}

### スコープ

{対象となるモジュール・機能のスコープを記述}

### テスト対象

| No | 対象モジュール | クラス/関数名 | 説明 | テストケース数 |
|----|----------------|---------------|------|----------------|
| 1 | {モジュール名1} | {クラス名1} | {説明} | {10} |
| 2 | {モジュール名2} | {関数名1} | {説明} | {5} |
| 3 | {モジュール名3} | {クラス名2} | {説明} | {8} |

### 前提条件

- {前提条件1}
- {前提条件2}
- {前提条件3}

### 参照ドキュメント

| ドキュメント名 | ドキュメントID | 版数 |
|----------------|----------------|------|
| {詳細設計書} | {DD001-XX} | {1.0} |
| {クラス設計書} | {DD001-01-XX} | {1.0} |

---

## テスト方針

### テスト戦略

{テスト戦略を記述}

- {方針1: 全ての公開メソッドをテスト対象とする}
- {方針2: 境界値テストを必ず実施する}
- {方針3: 異常系テストを重視する}

### テストフレームワーク

| 項目 | 内容 |
|------|------|
| 言語 | {Python/Java/TypeScript/Go/C#} |
| テストフレームワーク | {pytest/JUnit/Jest/testing/xUnit} |
| モックライブラリ | {unittest.mock/Mockito/jest.mock/testify/Moq} |
| カバレッジツール | {pytest-cov/JaCoCo/Istanbul/go test -cover/coverlet} |
| アサーションライブラリ | {標準/AssertJ/expect/testify/FluentAssertions} |

### テスト粒度

| テスト種別 | 対象 | 実施タイミング |
|------------|------|----------------|
| ユニットテスト | 個別メソッド | コミット前 |
| 統合テスト | クラス間連携 | マージ前 |
| モックテスト | 外部依存 | 随時 |

### テストカバレッジ目標

| カバレッジ種別 | 目標値 | 備考 |
|----------------|--------|------|
| ステートメントカバレッジ | {80%以上} | {実行文網羅} |
| ブランチカバレッジ | {70%以上} | {分岐網羅} |
| 条件カバレッジ | {60%以上} | {条件網羅} |
| メソッドカバレッジ | {90%以上} | {メソッド網羅} |

---

## テスト環境

### テスト実行環境

| 項目 | 内容 |
|------|------|
| OS | {Windows/Linux/macOS} |
| OS バージョン | {x.y} |
| ランタイム/SDK | {Python 3.11/Java 17/Node.js 20/Go 1.21/.NET 8} |
| データベース | {PostgreSQL/MySQL/SQLite/メモリDB} |
| データベースバージョン | {x.y} |
| その他ミドルウェア | {Redis/RabbitMQ/など} |

### テスト用データベース

| 項目 | 内容 |
|------|------|
| データベース名 | {test_database} |
| 初期化方法 | {マイグレーション/フィクスチャ} |
| データ投入方法 | {SQLファイル/コード} |
| テスト後処理 | {ロールバック/削除} |

### 外部依存のモック

| 外部依存 | モック方法 | モックライブラリ |
|----------|------------|------------------|
| {外部API} | {HTTPモック} | {responses/WireMock/nock/httpmock/MockHttp} |
| {データベース} | {メモリDB/モック} | {SQLite/H2/など} |
| {ファイルシステム} | {仮想FS/モック} | {tmpdir/java.nio.file/memfs/など} |
| {時刻} | {固定時刻/モック} | {freezegun/固定Clock/など} |

---

## テストケース

### {クラス名1} テストケース

#### 対象クラス情報

| 項目 | 内容 |
|------|------|
| クラス名 | {クラス名1} |
| ファイルパス | {src/domain/models/user.py} |
| 責務 | {ユーザーエンティティの管理} |
| 依存クラス | {クラスA, クラスB} |

#### テストクラス情報

| 項目 | 内容 |
|------|------|
| テストクラス名 | {TestUser} |
| ファイルパス | {tests/domain/models/test_user.py} |
| セットアップ処理 | {テストデータ初期化} |
| ティアダウン処理 | {リソース解放} |

#### テストケース一覧

| No | テストケースID | テストケース名 | 優先度 | テスト種別 | 実施状況 |
|----|----------------|----------------|--------|------------|----------|
| 1 | UT-{001}-001 | ユーザー作成_正常系 | {高} | {正常系} | {未実施/実施済} |
| 2 | UT-{001}-002 | ユーザー作成_メール不正 | {高} | {異常系} | {未実施/実施済} |
| 3 | UT-{001}-003 | ユーザー作成_境界値_最小文字数 | {中} | {境界値} | {未実施/実施済} |
| 4 | UT-{001}-004 | ユーザー作成_境界値_最大文字数 | {中} | {境界値} | {未実施/実施済} |
| 5 | UT-{001}-005 | ユーザー更新_正常系 | {高} | {正常系} | {未実施/実施済} |

---

### UT-{001}-001: ユーザー作成_正常系

#### テストケース基本情報

| 項目 | 内容 |
|------|------|
| テストケースID | UT-{001}-001 |
| テストケース名 | ユーザー作成_正常系 |
| テスト対象メソッド | {User.create()} |
| テスト種別 | {正常系} |
| 優先度 | {高} |
| 作成者 | {作成者名} |
| 作成日 | {YYYY/MM/DD} |
| 更新日 | {YYYY/MM/DD} |

#### テスト目的

{正しい入力値でユーザーが作成されることを確認する}

#### 事前条件

- {データベースが初期化されていること}
- {テストデータが投入されていること}
- {モックオブジェクトが準備されていること}

#### テスト手順

| No | 手順 | 操作内容 | 期待結果 |
|----|------|----------|----------|
| 1 | セットアップ | テストデータを準備 | データ準備完了 |
| 2 | 実行 | User.create()を呼び出し | ユーザーオブジェクトが生成される |
| 3 | 検証 | 生成されたユーザーの属性を確認 | 全ての属性が正しく設定されている |
| 4 | ティアダウン | テストデータをクリア | データクリア完了 |

#### 入力データ

```json
{
  "username": "test_user",
  "email": "test@example.com",
  "password": "SecureP@ssw0rd",
  "full_name": "Test User",
  "role": "user"
}
```

#### 期待結果

```json
{
  "id": 1,
  "username": "test_user",
  "email": "test@example.com",
  "full_name": "Test User",
  "status": "active",
  "role": "user",
  "created_at": "2025-01-20T10:00:00Z",
  "updated_at": "2025-01-20T10:00:00Z"
}
```

#### アサーション

| No | 検証項目 | 検証方法 | 期待値 |
|----|----------|----------|--------|
| 1 | ユーザーID | assertEqual | {1} |
| 2 | ユーザー名 | assertEqual | {test_user} |
| 3 | メールアドレス | assertEqual | {test@example.com} |
| 4 | ステータス | assertEqual | {active} |
| 5 | ロール | assertEqual | {user} |
| 6 | 作成日時 | assertIsNotNone | {NULL以外} |

#### テストコード例

```python
import pytest
from datetime import datetime
from src.domain.models.user import User

class TestUser:
    """Userクラスのテスト"""

    def setup_method(self):
        """各テストメソッド実行前の処理"""
        self.test_data = {
            "username": "test_user",
            "email": "test@example.com",
            "password": "SecureP@ssw0rd",
            "full_name": "Test User",
            "role": "user"
        }

    def teardown_method(self):
        """各テストメソッド実行後の処理"""
        # リソースのクリーンアップ
        pass

    def test_create_user_正常系(self):
        """ユーザー作成_正常系"""
        # Arrange
        data = self.test_data

        # Act
        user = User.create(**data)

        # Assert
        assert user.id is not None
        assert user.username == "test_user"
        assert user.email == "test@example.com"
        assert user.full_name == "Test User"
        assert user.status == "active"
        assert user.role == "user"
        assert isinstance(user.created_at, datetime)
        assert isinstance(user.updated_at, datetime)
```

#### モック定義

| モック対象 | モック内容 | 戻り値 |
|------------|------------|--------|
| {データベース} | {INSERT文の実行} | {成功} |
| {現在時刻} | {固定時刻} | {2025-01-20T10:00:00Z} |

#### 備考

{特記事項があれば記述}

---

### UT-{001}-002: ユーザー作成_メール不正

#### テストケース基本情報

| 項目 | 内容 |
|------|------|
| テストケースID | UT-{001}-002 |
| テストケース名 | ユーザー作成_メール不正 |
| テスト対象メソッド | {User.create()} |
| テスト種別 | {異常系} |
| 優先度 | {高} |

#### テスト目的

{不正なメールアドレスでユーザー作成時に例外が発生することを確認する}

#### 入力データ

```json
{
  "username": "test_user",
  "email": "invalid-email",
  "password": "SecureP@ssw0rd",
  "full_name": "Test User",
  "role": "user"
}
```

#### 期待結果

{ValidationError例外が発生すること}

#### アサーション

| No | 検証項目 | 検証方法 | 期待値 |
|----|----------|----------|--------|
| 1 | 例外発生 | assertRaises | {ValidationError} |
| 2 | エラーメッセージ | assertIn | {"Invalid email format"} |
| 3 | エラーフィールド | assertEqual | {"email"} |

#### テストコード例

```python
def test_create_user_メール不正(self):
    """ユーザー作成_メール不正"""
    # Arrange
    data = {
        "username": "test_user",
        "email": "invalid-email",
        "password": "SecureP@ssw0rd",
        "full_name": "Test User",
        "role": "user"
    }

    # Act & Assert
    with pytest.raises(ValidationError) as exc_info:
        User.create(**data)

    # エラー内容の検証
    assert "Invalid email format" in str(exc_info.value)
    assert exc_info.value.field == "email"
```

---

### UT-{001}-003: ユーザー作成_境界値_最小文字数

#### テストケース基本情報

| 項目 | 内容 |
|------|------|
| テストケースID | UT-{001}-003 |
| テストケース名 | ユーザー作成_境界値_最小文字数 |
| テスト対象メソッド | {User.create()} |
| テスト種別 | {境界値} |
| 優先度 | {中} |

#### テスト目的

{ユーザー名の最小文字数(3文字)でユーザーが作成されることを確認する}

#### 境界値分析

| 項目 | 最小値-1 | 最小値 | 最小値+1 | 最大値-1 | 最大値 | 最大値+1 |
|------|----------|--------|----------|----------|--------|----------|
| ユーザー名 | 2文字(NG) | 3文字(OK) | 4文字(OK) | 49文字(OK) | 50文字(OK) | 51文字(NG) |

#### 入力データ

```json
{
  "username": "abc",
  "email": "test@example.com",
  "password": "SecureP@ssw0rd",
  "full_name": "Test User",
  "role": "user"
}
```

#### 期待結果

{ユーザーが正常に作成されること}

---

## カバレッジ目標

### クラス別カバレッジ目標

| クラス名 | ステートメント | ブランチ | 条件 | メソッド | 備考 |
|----------|----------------|----------|------|----------|------|
| {User} | {90%} | {85%} | {80%} | {100%} | {重要クラス} |
| {UserValidator} | {95%} | {90%} | {85%} | {100%} | {バリデーション} |
| {UserRepository} | {80%} | {75%} | {70%} | {90%} | {データアクセス} |

### 未カバー許容箇所

| クラス名 | メソッド名 | 理由 | 備考 |
|----------|------------|------|------|
| {User} | {__repr__} | {デバッグ用メソッド} | {-} |
| {UserRepository} | {_private_method} | {内部実装} | {-} |

---

## テストデータ

### マスタデータ

#### ユーザーマスタ

```json
[
  {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "full_name": "Admin User",
    "status": "active",
    "role": "admin"
  },
  {
    "id": 2,
    "username": "user1",
    "email": "user1@example.com",
    "full_name": "User One",
    "status": "active",
    "role": "user"
  }
]
```

### トランザクションデータ

{トランザクションデータのサンプルを記述}

### テストデータ生成方法

| データ種別 | 生成方法 | ツール/ライブラリ |
|------------|----------|-------------------|
| {ランダムデータ} | {ライブラリ} | {Faker/factory_boy/など} |
| {固定データ} | {JSONファイル} | {フィクスチャ} |
| {データベース} | {マイグレーション} | {Alembic/Flyway/など} |

---

## テスト実行

### テスト実行コマンド

#### 全テスト実行

```bash
# Python (pytest)
pytest tests/

# Java (Maven)
mvn test

# TypeScript (Jest)
npm test

# Go
go test ./...

# C# (.NET)
dotnet test
```

#### カバレッジ測定

```bash
# Python
pytest --cov=src --cov-report=html tests/

# Java
mvn test jacoco:report

# TypeScript
npm test -- --coverage

# Go
go test -cover ./...

# C#
dotnet test /p:CollectCoverage=true
```

#### 特定テスト実行

```bash
# Python
pytest tests/domain/models/test_user.py::TestUser::test_create_user_正常系

# Java
mvn test -Dtest=UserTest#testCreateUser

# TypeScript
npm test -- --testNamePattern="create user"

# Go
go test -run TestCreateUser ./...

# C#
dotnet test --filter "FullyQualifiedName~CreateUser"
```

---

## 付録

### テスト命名規則

| 言語 | 命名規則 | 例 |
|------|----------|-----|
| Python | test_{メソッド名}_{条件} | test_create_user_正常系 |
| Java | test{メソッド名}_{条件} | testCreateUser_Success |
| TypeScript | should {期待動作} when {条件} | should create user when valid input |
| Go | Test{メソッド名}_{条件} | TestCreateUser_Success |
| C# | {メソッド名}_{条件}_{期待結果} | CreateUser_ValidInput_ReturnsUser |

### ベストプラクティス

- {AAA(Arrange-Act-Assert)パターンを使用する}
- {1テストケース1アサート原則を守る}
- {テストケース間の依存を排除する}
- {テストデータは各テストケースで独立させる}
- {モックは最小限にする}

### 用語集

| 用語 | 説明 |
|------|------|
| {AAA} | {Arrange-Act-Assert: テストコード構造化パターン} |
| {モック} | {テスト用の偽オブジェクト} |
| {フィクスチャ} | {テスト用固定データ} |

### レビュー記録

| 日付 | レビュアー | 指摘事項 | 対応状況 |
|------|------------|----------|----------|
| {YYYY/MM/DD} | {レビュアー名} | {指摘事項} | {対応済/対応中/未対応} |

### 承認記録

| 役割 | 氏名 | 承認日 | 署名 |
|------|------|--------|------|
| {テスト設計者} | {氏名} | {YYYY/MM/DD} | {署名} |
| {レビュアー} | {氏名} | {YYYY/MM/DD} | {署名} |
| {承認者} | {氏名} | {YYYY/MM/DD} | {署名} |
