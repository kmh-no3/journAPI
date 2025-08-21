-- ===== Types (ENUM) =====
DO $$
BEGIN
    CREATE TYPE side_enum AS ENUM ('DEBIT','CREDIT');
    EXCEPTION
        WHEN duplicate_object THEN
            NULL;
END $$;

DO $$
BEGIN
    CREATE TYPE acc_type_enum AS ENUM ('asset','liability','equity','revenue','expense');
EXCEPTION
    WHEN duplicate_object THEN
        NULL;
END $$;

-- ===== Accounts =====
CREATE TABLE IF NOT EXISTS accounts (
    id          BIGSERIAL PRIMARY KEY,
    code        VARCHAR(16) NOT NULL UNIQUE,
    name        VARCHAR(120) NOT NULL,
    type        acc_type_enum NOT NULL,
    parent_id   BIGINT NULL REFERENCES accounts(id),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

-- ===== Journal Headers =====
CREATE TABLE IF NOT EXISTS journal_headers (
    id          BIGSERIAL PRIMARY KEY,
    entry_date  DATE    NOT NULL,  
    period      CHAR(7) NOT NULL, -- YYYY-MM
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 検索用インデックス(期間/作成時刻)
CREATE INDEX IF NOT EXISTS idx_jh_entry_date    ON journal_headers(entry_date);
CREATE INDEX IF NOT EXISTS idx_jh_created_at_id  ON journal_headers(created_at, id);

-- ===== Journal Lines =====
CREATE TABLE IF NOT EXISTS journal_lines (
    id          BIGSERIAL PRIMARY KEY,
    header_id   BIGINT NOT NULL REFERENCES journal_headers(id) ON DELETE CASCADE,
    account_id  BIGINT NOT NULL REFERENCES accounts(id),
    side        side_enum NOT NULL,
    amount      NUMERIC(18,2) NOT NULL CHECK (amount > 0),
    memo        TEXT
);

-- 参照・集計に効くインデックス
CREATE INDEX IF NOT EXISTS idx_jl_header  ON journal_lines(header_id);
CREATE INDEX IF NOT EXISTS idx_jl_account ON journal_lines(account_id);