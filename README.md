# JournAPI

## 目次
1. [プロジェクト概要](#プロジェクト概要)
2. [プロジェクト構築](#プロジェクト構築)
3. [開発優先度](#開発優先度)
4. [ドキュメント](#ドキュメント)

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

## 開発優先度
**優先度: 高**
- 仕訳管理
- 勘定科目マスタ
- データ整合性
- セキュリティ機能
- 監視・ログ

**優先度: 中**
- 元帳管理
- 試算表
- 期間ロック
- 認証・認可（トークンベースに拡張）
- 監視強化：メトリクス（リクエスト数、P95レイテンシ、エラー率）
- 監査ログ（誰がいつ何を変更したか）

**優先度: 小**
- ロール/権限管理（RBAC）
- 外部監視サービス/APM（Datadog, New Relicなど）
- アラート運用（しきい値通知）
- 仕訳データのインポート/エクスポート（CSV）
- 高度なCSPや署名付き監査証跡

## ドキュメント
優先度: 高
- [API アウトライン](docs/01_high_api-outline.md)
- [ER 図](docs/01_high_er_diagram.md)