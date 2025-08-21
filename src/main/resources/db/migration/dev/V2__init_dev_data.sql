-- ===== Dev Environment Initial Data =====

-- 基本勘定科目の挿入（最小限）
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
