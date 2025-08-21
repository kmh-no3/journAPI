package com.journapi.journapi;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("dev")
class DatabaseConnectionTest {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void testDatabaseConnection() throws SQLException {
        // データソースの確認
        assertNotNull(dataSource, "DataSource should not be null");
        
        // 接続の確認
        try (Connection connection = dataSource.getConnection()) {
            assertTrue(connection.isValid(5), "Database connection should be valid");
            
            // データベース情報の確認
            String databaseProductName = connection.getMetaData().getDatabaseProductName();
            String databaseProductVersion = connection.getMetaData().getDatabaseProductVersion();
            
            System.out.println("Database: " + databaseProductName);
            System.out.println("Version: " + databaseProductVersion);
            
            assertTrue(databaseProductName.contains("PostgreSQL"), "Should be PostgreSQL database");
        }
    }

    @Test
    void testFlywayMigration() {
        // Flywayマイグレーション後のテーブル存在確認
        String[] expectedTables = {"accounts", "journal_headers", "journal_lines"};
        
        for (String tableName : expectedTables) {
            boolean tableExists = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = ?", 
                Integer.class, 
                tableName
            ) > 0;
            
            assertTrue(tableExists, "Table " + tableName + " should exist after migration");
        }
    }

    @Test
    void testAccountsTableData() {
        // 勘定科目テーブルのデータ確認
        int accountCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM accounts", Integer.class);
        assertTrue(accountCount > 0, "Accounts table should contain data");
        
        System.out.println("Number of accounts: " + accountCount);
        
        // 基本勘定科目の存在確認
        String[] expectedAccounts = {"1000", "2000", "3000", "4000", "5000"};
        for (String accountCode : expectedAccounts) {
            boolean accountExists = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM accounts WHERE code = ?", 
                Integer.class, 
                accountCode
            ) > 0;
            
            assertTrue(accountExists, "Account with code " + accountCode + " should exist");
        }
    }

    @Test
    void testJournalTablesData() {
        // 仕訳ヘッダーテーブルのデータ確認
        int headerCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM journal_headers", Integer.class);
        assertTrue(headerCount >= 0, "Journal headers table should be accessible");
        
        // 仕訳明細テーブルのデータ確認
        int lineCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM journal_lines", Integer.class);
        assertTrue(lineCount >= 0, "Journal lines table should be accessible");
        
        System.out.println("Number of journal headers: " + headerCount);
        System.out.println("Number of journal lines: " + lineCount);
    }

    @Test
    void testDatabaseConstraints() {
        // 外部キー制約の確認
        boolean foreignKeyExists = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.table_constraints " +
            "WHERE constraint_type = 'FOREIGN KEY' AND table_name = 'journal_lines'", 
            Integer.class
        ) > 0;
        
        assertTrue(foreignKeyExists, "Foreign key constraints should exist on journal_lines table");
    }
}
