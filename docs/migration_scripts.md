# マイグレーションスクリプト

このドキュメントは、JournAPIのデータベースマイグレーション用スクリプトです。
**注意**: これらのスクリプトは開発環境でのみ実行してください。

## 制約追加スクリプト

### 主キー制約
```sql
-- accounts
ALTER TABLE accounts ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);

-- journal_headers
ALTER TABLE journal_headers ADD CONSTRAINT journal_headers_pkey PRIMARY KEY (id);

-- journal_lines
ALTER TABLE journal_lines ADD CONSTRAINT journal_lines_pkey PRIMARY KEY (id);
```

### 外部キー制約
```sql
-- journal_lines → journal_headers
ALTER TABLE journal_lines 
ADD CONSTRAINT journal_lines_header_id_fkey 
FOREIGN KEY (header_id) REFERENCES journal_headers(id);

-- journal_lines → accounts
ALTER TABLE journal_lines 
ADD CONSTRAINT journal_lines_account_id_fkey 
FOREIGN KEY (account_id) REFERENCES accounts(id);

-- accounts → accounts (自己参照)
ALTER TABLE accounts 
ADD CONSTRAINT accounts_parent_id_fkey 
FOREIGN KEY (parent_id) REFERENCES accounts(id);
```

### ユニーク制約
```sql
-- 勘定科目コードの一意性
ALTER TABLE accounts ADD CONSTRAINT accounts_code_unique UNIQUE (code);
```

### チェック制約
```sql
-- 会計期間の形式チェック
ALTER TABLE journal_headers 
ADD CONSTRAINT journal_headers_period_check 
CHECK (period ~ '^\d{4}-\d{2}$');

-- 金額の正値チェック
ALTER TABLE journal_lines 
ADD CONSTRAINT journal_lines_amount_check 
CHECK (amount > 0);
```

## インデックス作成スクリプト

```sql
-- 勘定科目コード検索
CREATE INDEX idx_accounts_code ON accounts(code);

-- 勘定科目タイプ検索
CREATE INDEX idx_accounts_type ON accounts(type);

-- 仕訳期間検索
CREATE INDEX idx_journal_headers_period ON journal_headers(period);

-- 仕訳日検索
CREATE INDEX idx_journal_headers_entry_date ON journal_headers(entry_date);

-- 仕訳明細の勘定科目検索
CREATE INDEX idx_journal_lines_account_id ON journal_lines(account_id);
```

## 注意事項

### 実行前の確認事項
1. **バックアップ**: 実行前にデータベースのバックアップを取得
2. **環境確認**: 正しい環境（開発/テスト/本番）で実行していることを確認
3. **権限確認**: 適切な権限を持つユーザーで実行

### 実行順序
1. テーブル作成
2. 主キー制約追加
3. 外部キー制約追加
4. ユニーク制約追加
5. チェック制約追加
6. インデックス作成

### エラー時の対処
- 制約違反エラーが発生した場合、既存データの確認が必要
- 外部キー制約エラーの場合、参照先テーブルの存在確認
- ユニーク制約エラーの場合、重複データの確認と修正
