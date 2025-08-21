# JournAPI

## 目次
1. [プロジェクト概要](#プロジェクト概要)
2. [プロジェクト構築](#プロジェクト構築)
3. [環境セットアップ](#環境セットアップ)
   - [ローカル開発環境（brew）](#ローカル開発環境brew)
   - [Docker環境](#docker環境)
4. [データベースセットアップ](#データベースセットアップ)
5. [開発優先度](#開発優先度)
6. [ドキュメント](#ドキュメント)

## プロジェクト概要

JornAPIは、複式簿記システムのAPIサーバーである。仕訳帳、元帳、試算表の機能を提供し、外部公開を想定したセキュリティ機能を備えている。
又、本プロジェクトはバックエンドエンジニアリングのポートフォリオとして作成されたものである。

### 主要機能
- **仕訳管理**: 仕訳の登録・照会・編集・削除
- **元帳管理**: 勘定科目別の元帳照会
- **試算表**: 期間別試算表の生成
- **期間ロック**: 会計期間の締め切り管理
- **勘定科目マスタ**: 勘定科目の管理
- **データ整合性**: 複式簿記の整合性チェック
- **セキュリティ機能**: CORS、レート機能、セキュリティヘッダ
- **監視・ログ**: パフォーマンス監視と構造化ログ

### 複式簿記の基本概念
JournAPIは複式簿記の原則に従って設計されている。
- **借方・貸方の一致**: 全ての取引で借方合計と貸方合計が一致
- **勘定科目体系**: 資産、負債、純資産、収益、費用の5つの区分
- **期間管理**: 会計期間（YYYY-MM）による取引の管理
- **データ整合性**: 仕訳→元帳→試算表の一貫性を保証

## プロジェクト構築

### Spring Boot Initializr コマンド

このプロジェクトは以下のSpring Boot Initializrコマンドで作成されました：

```bash
curl https://start.spring.io/starter.zip \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.5.4 \
  -d javaVersion=21 \
  -d groupId=com.journapi \
  -d artifactId=journapi \
  -d name=JournAPI \
  -d packaging=jar \
  -d dependencies=web,data-jpa,validation,postgresql,flyway,lombok \
  -o journapi.zip

unzip -q journapi.zip -d journapi
```

### 使用技術スタック

- **Spring Boot**: 3.5.4
- **Java**: 21
- **Maven**: プロジェクト管理
- **Spring Web**: RESTful API
- **Spring Data JPA**: データアクセス
- **Spring Validation**: 入力検証
- **PostgreSQL**: データベース
- **Flyway**: データベースマイグレーション
- **Lombok**: ボイラープレートコード削減

### 環境設定

詳細な環境設定については [environment_rules.md](environment_rules.md) を参照してください。

## 環境セットアップ

### ローカル開発環境（brew）

#### 1. PostgreSQLのインストール

macOSの場合：
```bash
brew install postgresql
```

#### 2. PostgreSQLの起動・停止

**初回セットアップ時（一度だけ実行）:**
```bash
# PostgreSQLサービスの起動
brew services start postgresql

# 起動確認
brew services list | grep postgresql
```

**開発作業時の起動・停止:**
```bash
# PostgreSQLサービスの起動
brew services start postgresql

# PostgreSQLサービスの停止
brew services stop postgresql

# PostgreSQLサービスの再起動
brew services restart postgresql

# サービス状態の確認
brew services list | grep postgresql
```

**注意**: 開発作業を開始する前に、必ずPostgreSQLサービスを起動してください。

#### 3. データベースのセットアップ

自動セットアップスクリプトを使用：
```bash
./setup-database.sh
```

手動セットアップの場合：
```sql
-- PostgreSQLに接続
psql -U postgres

-- データベースとユーザーの作成
CREATE DATABASE journapi;
CREATE USER devuser WITH PASSWORD 'devpass';
GRANT ALL PRIVILEGES ON DATABASE journapi TO devuser;
```

#### 4. アプリケーションの起動

```bash
./mvnw spring-boot:run
```

### Docker環境

#### 5. Dockerのインストール

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) をインストール
- Docker Composeが含まれていることを確認

#### 6. Docker Composeでの起動

```bash
# アプリケーションとデータベースの起動
docker-compose up -d

# ログの確認
docker-compose logs -f

# 停止
docker-compose down
```

#### 7. 個別コンテナでの起動

```bash
# PostgreSQLコンテナの起動
docker run --name journapi-postgres \
  -e POSTGRES_DB=journapi \
  -e POSTGRES_USER=devuser \
  -e POSTGRES_PASSWORD=devpass \
  -p 5432:5432 \
  -d postgres:14

# アプリケーションの起動
./mvnw spring-boot:run
```

## データベースセットアップ

### Flywayマイグレーションの実行

アプリケーション起動時に自動実行されます：
```bash
# マイグレーション状況の確認
./mvnw flyway:info

# 手動マイグレーション実行
./mvnw flyway:migrate
```

### 初期データの確認

```bash
# データベース接続テスト
./mvnw test -Dtest=DatabaseConnectionTest

# 直接データベースに接続
psql journapi -U devuser -c "SELECT COUNT(*) FROM accounts;"
```

## 開発優先度

### 優先度:高
1. **データベース & マイグレーション** ✅
   - Flyway 初期マイグレーション (accounts, journal_headers, journal_lines)
   - JDBC 接続確認 (dev環境)

2. **勘定科目マスタ管理**
   - 勘定科目のCRUD操作
   - 勘定科目の階層構造管理
   - 勘定科目の検索・フィルタリング

3. **仕訳帳管理**
   - 仕訳の登録・更新・削除
   - 仕訳の検索・フィルタリング
   - 複式簿記の整合性チェック

4. **基本的な会計処理**
   - 元帳の生成
   - 試算表の生成
   - 期間別データの管理

### 優先度:中
1. **API設計 & 実装**
   - RESTful API設計
   - エラーハンドリング
   - バリデーション

2. **セキュリティ機能**
   - CORS設定
   - レート制限
   - セキュリティヘッダー

### 優先度:低
1. **監視・ログ**
   - パフォーマンス監視
   - 構造化ログ
   - メトリクス収集

2. **テスト**
   - 単体テスト
   - 統合テスト
   - E2Eテスト

## ドキュメント

### 優先度:高（現在の開発対象）
- [データベーススキーマ仕様](docs/database_schema.md) - 勘定科目マスタ・仕訳帳管理の基盤
- [ER図](docs/01_high_er_diagram.md) - データベース設計の視覚的理解
- [マイグレーションスクリプト](docs/migration_scripts.md) - データベース構築・運用
- [API設計ドキュメント](docs/01_high_api-outline.md) - RESTful API設計・実装

### 参考資料
- [プロジェクト概要](README.md#プロジェクト概要) - システム全体の概要
- [開発優先度](README.md#開発優先度) - 開発ロードマップ
- [環境設定ルール](environment_rules.md) - プロジェクト全体の環境設定基準