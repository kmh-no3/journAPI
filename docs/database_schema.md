# データベーススキーマ仕様

このドキュメントは、JournAPIのデータベーススキーマの詳細技術仕様です。

## テーブル詳細

### accounts（勘定科目マスタ）

勘定科目の基本情報と階層構造を管理するテーブルです。

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | BIGSERIAL | PRIMARY KEY | 自動採番の主キー |
| code | VARCHAR(16) | NOT NULL, UNIQUE | 勘定科目コード（例: 1000, 1100） |
| name | VARCHAR(120) | NOT NULL | 勘定科目名（例: 現金, 売掛金） |
| type | acc_type_enum | NOT NULL | 勘定科目区分 |
| parent_id | BIGINT | NULL, FK | 親科目ID（階層構造） |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | 有効フラグ |

#### acc_type_enum（勘定科目区分）
- `asset`: 資産
- `liability`: 負債
- `equity`: 純資産
- `revenue`: 収益
- `expense`: 費用

### journal_headers（仕訳ヘッダー）

仕訳の基本情報と期間管理を行うテーブルです。

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | BIGSERIAL | PRIMARY KEY | 自動採番の主キー |
| entry_date | DATE | NOT NULL | 仕訳日 |
| period | CHAR(7) | NOT NULL | 会計期間（YYYY-MM形式） |
| description | TEXT | NULL | 仕訳の説明 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | 作成日時（タイムゾーン対応） |

### journal_lines（仕訳明細）

仕訳の借方・貸方の詳細を管理するテーブルです。

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | BIGSERIAL | PRIMARY KEY | 自動採番の主キー |
| header_id | BIGINT | NOT NULL, FK | 仕訳ヘッダーID |
| account_id | BIGINT | NOT NULL, FK | 勘定科目ID |
| side | side_enum | NOT NULL | 借方・貸方 |
| amount | DECIMAL | NOT NULL | 金額 |
| memo | TEXT | NULL | メモ |

#### side_enum（借方・貸方）
- `DEBIT`: 借方
- `CREDIT`: 貸方

## 制約・インデックス

### 主キー制約
- **accounts.id**: 主キー（自動採番）
- **journal_headers.id**: 主キー（自動採番）
- **journal_lines.id**: 主キー（自動採番）

### 外部キー制約
- **journal_lines.header_id** → **journal_headers.id**: 仕訳明細から仕訳ヘッダーへの参照
- **journal_lines.account_id** → **accounts.id**: 仕訳明細から勘定科目への参照
- **accounts.parent_id** → **accounts.id**: 勘定科目の自己参照（階層構造）

### ユニーク制約
- **accounts.code**: 勘定科目コードの一意性

### チェック制約
- **journal_headers.period**: YYYY-MM形式の会計期間
- **journal_lines.amount**: 正の金額（0より大きい値）

### 推奨インデックス
- **accounts.code**: 勘定科目コード検索用
- **accounts.type**: 勘定科目タイプ検索用
- **journal_headers.period**: 会計期間検索用
- **journal_headers.entry_date**: 仕訳日検索用
- **journal_lines.account_id**: 勘定科目別仕訳検索用

## 初期データ

### 基本勘定科目（11件）

```sql
INSERT INTO accounts (code, name, type, parent_id, is_active) VALUES
('1000', '資産', 'asset', NULL, true),
('1100', '現金', 'asset', NULL, true),
('1200', '売掛金', 'asset', NULL, true),
('2000', '負債', 'liability', NULL, true),
('2100', '買掛金', 'liability', NULL, true),
('3000', '純資産', 'equity', NULL, true),
('3100', '資本金', 'equity', NULL, true),
('4000', '収益', 'revenue', NULL, true),
('4100', '売上高', 'revenue', NULL, true),
('5000', '費用', 'expense', NULL, true),
('5100', '水道光熱費', 'expense', NULL, true);
```

### 勘定科目体系

```
資産 (1000)
├── 現金 (1100)
└── 売掛金 (1200)

負債 (2000)
└── 買掛金 (2100)

純資産 (3000)
└── 資本金 (3100)

収益 (4000)
└── 売上高 (4100)

費用 (5000)
└── 水道光熱費 (5100)
```

## ビジネスルール

### 複式簿記の原則
- 全ての仕訳で借方合計と貸方合計が一致する必要があります
- 各仕訳は最低2行（借方1行、貸方1行）必要です

### 期間管理
- 会計期間はYYYY-MM形式で管理します
- 仕訳は必ず特定の会計期間に属します

### 勘定科目管理
- 勘定科目コードは一意である必要があります
- 勘定科目は階層構造で管理できます
- 無効化された勘定科目は新規仕訳で使用できません

## パフォーマンス考慮事項

### 推奨インデックス
- **accounts.code**: 勘定科目コード検索用インデックス
- **accounts.type**: 勘定科目タイプ検索用インデックス
- **journal_headers.period**: 会計期間検索用インデックス
- **journal_headers.entry_date**: 仕訳日検索用インデックス
- **journal_lines.account_id**: 勘定科目別仕訳検索用インデックス

### パーティショニング戦略
- 将来的に大量データが予想される場合は、journal_headersテーブルを期間でパーティショニングすることを検討

## 拡張性

### 将来の機能追加を考慮した設計
1. **ユーザー管理**: 認証・認可機能の追加
2. **監査ログ**: データ変更履歴の追跡
3. **添付ファイル**: 仕訳に関連するファイル管理
4. **承認フロー**: 仕訳の承認プロセス
5. **多通貨対応**: 為替レート管理

### マイグレーション戦略
- Flywayを使用したバージョン管理
- 後方互換性を保ったスキーマ変更
- データ移行時の整合性確保
