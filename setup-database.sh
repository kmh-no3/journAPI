#!/bin/bash

# PostgreSQLデータベースセットアップスクリプト
# 使用方法: ./setup-database.sh

echo "=== PostgreSQL Database Setup for JournAPI ==="

# PostgreSQLサービスの確認
if ! command -v psql &> /dev/null; then
    echo "Error: PostgreSQL is not installed or not in PATH"
    exit 1
fi

# データベース接続情報
DB_NAME="journapi"
DB_USER="devuser"
DB_PASSWORD="devpass"
DB_HOST="localhost"
DB_PORT="5432"

echo "Creating database: $DB_NAME"
echo "User: $DB_USER"
echo "Host: $DB_HOST:$DB_PORT"

# データベースの作成（現在のユーザーで実行）
echo "Creating database..."
psql postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Database already exists or creation failed"

# ユーザーの作成
echo "Creating user..."
psql postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || echo "User already exists or creation failed"

# 権限の付与
echo "Granting privileges..."
psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null || echo "Privilege grant failed"

# データベースへの接続確認
echo "Testing connection..."
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT version();" >/dev/null 2>&1; then
    echo "✅ Database setup completed successfully!"
    echo "You can now run the application with: ./mvnw spring-boot:run"
else
    echo "❌ Database connection failed. Please check your PostgreSQL installation."
    exit 1
fi
