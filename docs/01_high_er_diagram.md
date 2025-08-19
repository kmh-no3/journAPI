# ER図（MVP）

このドキュメントは、JournAPI の最小構成（MVP）のER図です。

```mermaid
erDiagram
    accounts {
        int id PK
        string code "科目コード(UNIQUE)"
        string name "科目名"
        enum type "asset/liability/equity/revenue/expense"
        int parent_id FK "親科目(任意)"
        bool is_active
    }

    journal_headers {
        int id PK
        date entry_date
        string period "YYYY-MM"
        string description
        int created_by
        datetime created_at
    }

    journal_lines {
        int id PK
        int entry_id FK
        int account_id FK
        enum side "DEBIT/CREDIT"
        decimal amount
        string memo
    }

    %% Relations
    accounts ||--o{ journal_lines : "1:N 科目→明細"
    journal_headers ||--o{ journal_lines : "1:N 仕訳→明細"

```

## 構成メモ
- **accounts** … 勘定科目マスタ（type=asset/liability/equity/revenue/expense）
- **journal_headers** … 仕訳ヘッダ（periodは`YYYY-MM`）
- **journal_lines** … 仕訳明細（entry_id・account_idへのFK、sideはDEBIT/CREDIT）