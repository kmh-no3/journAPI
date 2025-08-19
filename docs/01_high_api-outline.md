# JournAPI - API アウトライン（優先度: 高 完整版）

ベースURL: `/api/v1`  
形式: JSON

---

## 共通仕様

### エラー形式
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "...", "details": { } } }
```

### ステータスコード指針
- `201 Created`: 作成成功
- `200 OK`: 正常取得/更新
- `204 No Content`: 削除成功
- `400 Bad Request`: バリデーションエラー
- `404 Not Found`: 対象なし
- `409 Conflict`: ユニーク制約違反（例: code重複）
- `429 Too Many Requests`: レート制限超過
- `500`: サーバエラー

---

# 1. 仕訳ヘッダ + 明細（`journal_headers`）

> 仕訳は「ヘッダ + 複数明細」を一括で扱う。行単位の直接操作はMVP範囲外。

## POST `/journal-headers`
**目的**: 仕訳ヘッダと明細を一括登録  
**検証**:
- 同一仕訳内の**借方合計 = 貸方合計**
- 金額は `amount > 0`
- `side ∈ { "DEBIT", "CREDIT" }`
- `accountId` が存在する（`accounts` 参照）

**リクエスト例**
```json
{
  "entryDate": "2025-08-20",
  "period": "2025-08",
  "description": "商品売上",
  "lines": [
    { "accountId": 1, "side": "DEBIT",  "amount": 1000, "memo": "現金受取" },
    { "accountId": 50, "side": "CREDIT", "amount": 1000, "memo": "売上" }
  ]
}
```

**レスポンス例（201）**
```json
{
  "id": 123,
  "entryDate": "2025-08-20",
  "period": "2025-08",
  "description": "商品売上",
  "lines": [
    { "id": 9001, "accountId": 1, "side": "DEBIT",  "amount": 1000, "memo": "現金受取" },
    { "id": 9002, "accountId": 50, "side": "CREDIT", "amount": 1000, "memo": "売上" }
  ],
  "createdAt": "2025-08-20T09:10:00Z"
}
```

**エラー例**
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "Debit and credit totals must match." } }
```

---

## GET `/journal-headers`
**目的**: 仕訳ヘッダ一覧（必要に応じて明細同梱）  
**クエリ**:
- `from=YYYY-MM-DD` / `to=YYYY-MM-DD`
- `period=YYYY-MM`
- `accountId=...`（その科目を含む仕訳のみ）
- `include=lines`（`true/false`）
- `limit`（default 50, max 200）
- `cursor`（次ページトークン）

**レスポンス例**
```json
{
  "items": [
    { "id": 123, "entryDate": "2025-08-20", "period": "2025-08", "description": "商品売上" }
  ],
  "nextCursor": "eyJpZCI6MTIzfQ=="
}
```

---

## GET `/journal-headers/{id}`
**目的**: 仕訳1件（ヘッダ＋全明細）  
**レスポンス**: `POST /journal-headers` と同構造

**404例**
```json
{ "error": { "code": "NOT_FOUND", "message": "Journal header not found." } }
```

---

## PUT `/journal-headers/{id}`
**目的**: ヘッダ＋明細の**全置換更新**  
**注意**: 更新後も「借貸一致」「金額>0」「科目存在」を再検証。

**リクエスト/レスポンス**: `POST /journal-headers` と同構造（idはパス優先）

---

## DELETE `/journal-headers/{id}`
**目的**: 仕訳の削除（物理/論理は実装ポリシーに依存）  
**レスポンス**: `204 No Content`

---

# 2. 勘定科目マスタ（`accounts`）

> すべての仕訳は `accounts` の `id` を参照する。`type` は会計5分類。

## データモデル（参考）
```json
{
  "id": 1,
  "code": "1000",
  "name": "現金",
  "type": "asset",            // asset | liability | equity | revenue | expense
  "parentId": null,           // 階層化（任意）
  "isActive": true
}
```

---

## POST `/accounts`
**目的**: 勘定科目の追加  
**検証**:
- `code` はユニーク（例: 1000, 1100…）
- `type ∈ { asset, liability, equity, revenue, expense }`

**リクエスト例**
```json
{
  "code": "1000",
  "name": "現金",
  "type": "asset",
  "parentId": null,
  "isActive": true
}
```

**レスポンス例（201）**
```json
{
  "id": 1,
  "code": "1000",
  "name": "現金",
  "type": "asset",
  "parentId": null,
  "isActive": true
}
```

**エラー例（409）**
```json
{ "error": { "code": "CONFLICT", "message": "Account code already exists." } }
```

---

## GET `/accounts`
**目的**: 勘定科目一覧の取得（フィルタ/検索）  
**クエリ**:
- `type=asset`（会計区分でフィルタ）
- `isActive=true|false`
- `parentId=...`（子科目のみ取得）
- `q=...`（`code` と `name` のあいまい検索）
- `order=name|code|id`（昇順）
- `limit`（default 50, max 200）
- `cursor`

**レスポンス例**
```json
{
  "items": [
    { "id": 1, "code": "1000", "name": "現金", "type": "asset", "parentId": null, "isActive": true }
  ],
  "nextCursor": null
}
```

---

## GET `/accounts/{id}`
**目的**: 勘定科目の取得

**レスポンス例（200）**
```json
{ "id": 1, "code": "1000", "name": "現金", "type": "asset", "parentId": null, "isActive": true }
```

**404例**
```json
{ "error": { "code": "NOT_FOUND", "message": "Account not found." } }
```

---

## PUT `/accounts/{id}`
**目的**: 勘定科目の**全置換更新**（MVPではPUT採用）  
**検証**: `code` が他のレコードと重複しないこと、`type` が5分類のいずれか

**リクエスト例**
```json
{
  "code": "1010",
  "name": "現金（店舗）",
  "type": "asset",
  "parentId": null,
  "isActive": true
}
```

**レスポンス例（200）**
```json
{
  "id": 1,
  "code": "1010",
  "name": "現金（店舗）",
  "type": "asset",
  "parentId": null,
  "isActive": true
}
```

**エラー例（409）**
```json
{ "error": { "code": "CONFLICT", "message": "Account code already exists." } }
```

---

## DELETE `/accounts/{id}`
**目的**: 勘定科目の削除  
**推奨**: 実運用では**論理削除**（`isActive=false`）を推奨。MVPでは物理削除でも可。

**レスポンス**: `204 No Content`

**注意**: 既に仕訳で使用中の科目は削除不可とするのが安全（`409 Conflict` で返す）。

**エラー例（409）**
```json
{ "error": { "code": "CONFLICT", "message": "Account is referenced by journal lines." } }
```

---

# 3. ヘルスチェック

## GET `/healthz`
**目的**: 稼働/バージョン確認  
**レスポンス（200）**
```json
{ "status": "ok", "version": "1.0.0" }
```

---

## 実装メモ（非機能の最小）
- CORS: 許可オリジンのみ
- レート制限: `/journal-headers` 系 60 req/min 目安
- セキュリティヘッダ: `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `HSTS`（TLS前提）, （簡易CSP）
- ログ: 構造化（`ts, level, traceId, route, status, latencyMs`）
- 入力バリデーション: スキーマ検証（型/必須/列挙/範囲）
