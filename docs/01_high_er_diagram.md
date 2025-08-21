# ER図（MVP）

このドキュメントは、JournAPI の最小構成（MVP）のER図です。

```mermaid
erDiagram
    accounts {
        bigint id PK "BIGSERIAL"
        varchar code "VARCHAR(16) UNIQUE"
        varchar name "VARCHAR(120)"
        enum type "acc_type_enum: asset/liability/equity/revenue/expense"
        bigint parent_id FK "NULL可, 自己参照"
        boolean is_active "DEFAULT TRUE"
    }

    journal_headers {
        bigint id PK "BIGSERIAL"
        date entry_date "NOT NULL"
        char period "CHAR(7) NOT NULL, YYYY-MM形式"
        text description "NULL可"
        timestamptz created_at "DEFAULT now()"
    }

    journal_lines {
        bigint id PK "BIGSERIAL"
        bigint header_id FK "NOT NULL, journal_headers.id"
        bigint account_id FK "NOT NULL, accounts.id"
        enum side "side_enum: DEBIT/CREDIT"
        decimal amount "NOT NULL"
        text memo "NULL可"
    }

    %% Relations
    accounts ||--o{ journal_lines : "1:N 科目→明細"
    journal_headers ||--o{ journal_lines : "1:N 仕訳→明細"
    accounts ||--o{ accounts : "1:N 親科目→子科目"
```

## 概要

### テーブル構成
- **accounts**: 勘定科目マスタ（階層構造対応）
- **journal_headers**: 仕訳ヘッダー（期間管理）
- **journal_lines**: 仕訳明細（複式簿記の借方・貸方）

### 主要な関係
1. **勘定科目階層**: accountsテーブルの自己参照による親子関係
2. **仕訳構造**: journal_headersとjournal_linesの1対多関係
3. **科目参照**: journal_linesからaccountsへの参照

詳細な技術仕様については [database_schema.md](database_schema.md) を参照してください。