# 🚀 開発ライフサイクル全体オーケストレーション

## 🎯 High-Level Goal
10種類の専門AIエージェントチームを活用し、定義、設計、実装、テスト、セキュリティ確保、デプロイメントの全工程を実行し、定義された品質およびセキュリティ基準を満たす新しいソフトウェアシステムを構築する。

## 👥 Agents Involved (Actors)
* **PMエージェント:** Project Manager.
* **システムコンサルタントエージェント:** Initial requirement analysis.
* **UI/UXデザイナーエージェント:** User flow, wireframes.
* **アプリケーションアーキテクトエージェント:** Component design.
* **インフラアーキテクトエージェント:** Cloud infrastructure and CI/CD planning.
* **セキュリティエージェント:** Vulnerability identification and security control definition.
* **コーダーエージェント:** Source code and unit test implementation.
* **テスターエージェント:** Integration and End-to-End (E2E) test execution.
* **QAエージェント:** Final quality review and release gate approval.
* **SREエージェント:** Monitoring setup and production deployment execution.

---

## フェーズ 1: 定義と計画

### 1.1 初期要件定義と実現可能性調査
* **アクター:** システムコンサルタントエージェント
* **インプット:** ユーザーからの高レベルなビジネス目標。
* **テンプレート:** `.agent/templates/02_要件定義書テンプレート.md`
* **タスク:** 実現可能性を分析し、テンプレートを用いて中核となるビジネス要件を明確化する。
* **アウトプット:** `requirements/initial_spec.md`

### 1.2 プロジェクト計画策定
* **アクター:** PMエージェント
* **インプット:** `requirements/initial_spec.md`
* **テンプレート:** `.agent/templates/01_プロジェクトマネジメント計画書テンプレート.md`
* **タスク:** WBS、スケジュール、リソース（エージェント）配分計画を含む包括的な計画を策定する。
* **アウトプット:** `project_plan/schedule.md`

### 1.3 ユーザー体験設計
* **アクター:** UI/UXデザイナーエージェント
* **インプット:** 中核となるビジネス要件。
* **テンプレート:** `.agent/templates/08_UIUXレビュー報告書テンプレート.md` (レビュー時参照)
* **タスク:** ユーザーフローを定義し、ワイヤーフレームを作成し、デザイン仕様を生成する。
* **アウトプット:** `design/wireframes.png`、`design/user_stories.md`

---

## フェーズ 2: 設計と基盤構築

### 2.1 アプリケーション設計
* **アクター:** アプリケーションアーキテクトエージェント
* **インプット:** `design/user_stories.md`
* **テンプレート:** `.agent/templates/04_基本設計書テンプレート.md`
* **タスク:** テンプレートに従い、マイクロサービス/コンポーネントの設計、データフロー、技術スタックの選定を行う。
* **アウトプット:** `architecture/app_design.md`

### 2.2 インフラストラクチャ設計
* **アクター:** インフラアーキテクトエージェント
* **インプット:** `architecture/app_design.md`
* **テンプレート:** `.agent/templates/03_インフラ構成書テンプレート.md`
* **タスク:** アプリケーション設計に基づき、クラウドインフラ、ネットワーク、CI/CDパイプラインをIaCを使用して設計する。
* **アウトプット:** `infrastructure/tf_plan.md`、`infrastructure/cicd_pipeline.yaml`

### 2.3 セキュリティ要件定義
* **アクター:** セキュリティエージェント
* **インプット:** `architecture/app_design.md`、`infrastructure/tf_plan.md`
* **テンプレート:** `.agent/templates/07_セキュリティ監査報告書テンプレート.md`
* **タスク:** 設計初期段階で潜在的な脅威を特定し、セキュリティ制御を定義する。
* **アウトプット:** `security/controls_checklist.md`

---

## フェーズ 3: 実装とSRE準備

### 3.1 コード実装と単体テスト
* **アクター:** コーダーエージェント
* **インプット:** `architecture/app_design.md`、`design/user_stories.md`
* **テンプレート:** `.agent/templates/05_詳細設計書テンプレート.md`, `.agent/templates/11_コーディング規約_共通編テンプレート.md`
* **タスク:** 詳細設計書を作成した後、すべての機能のソースコードと、対応する単体テストを実装する。
* **アウトプット:** `src/**/*.py`、`src/**/*_test.py`

### 3.2 監視・ロギング構成
* **アクター:** SREエージェント
* **インプット:** `infrastructure/tf_plan.md`
* **テンプレート:** `.agent/templates/09_運用マニュアルテンプレート.md`
* **タスク:** IaC内に、包括的な監視、アラート、一元化されたロギングシステムを構成する。
* **アウトプット:** `infrastructure/monitoring_config.yaml`

---

## フェーズ 4: 検証とデプロイ

### 4.1 統合テストとE2Eテストの実行
* **アクター:** テスターエージェント
* **インプット:** 実装済みコード、`design/user_stories.md`
* **テンプレート:** `.agent/templates/06_テスト計画書テンプレート.md`
* **タスク:** ユーザーストーリーに基づき、結合テストとエンドツーエンドテストを実行する。発見されたバグを報告し、修正を依頼する。
* **アウトプット:** `test_reports/e2e_results.json`

### 4.2 最終品質保証とリリース承認
* **アクター:** QAエージェント
* **インプット:** `test_reports/e2e_results.json`、`security/controls_checklist.md`（検証済み）
* **タスク:** すべての成果物（設計、コード、テストカバレッジ、セキュリティコンプライアンス）をレビューする。すべてのチェックが通過した場合、リリースを承認する。
* **アウトプット:** `qa/release_approval.md`（ステータス: 承認済み/却下）

### 4.3 プロダクションデプロイ
* **アクター:** SREエージェント
* **インプット:** `qa/release_approval.md`（ステータス: 承認済み）
* **タスク:** 最終的な本番デプロイメントスクリプトを実行し、ロールアウトの健全性を監視し、正常な安定化を確認する。
* **アウトプット:** Production deployment logs, `deployment_status.md`
