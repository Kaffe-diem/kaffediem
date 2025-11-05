---
title: API Endpoints Reference
description: Complete reference for Kaffediem's REST API including authentication, collections, CRUD operations, and error responses.
---

## Base URL

```
http://localhost:4000  (development)
https://kaffebase.example (production)
```

## Authentication

API uses session-based authentication with cookies.

### Session Endpoints

#### Create Session (Login)

```http
POST /api/session
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "user": {
    "id": "abc123",
    "name": "John Doe",
    "email": "user@example.com",
    "is_admin": false
  }
}
```

#### Get Current Session

```http
GET /api/session
```

**Response 200:**
```json
{
  "user": { /* user object */ }
}
```

**Response 401:** (Not authenticated)
```json
{
  "error": "Not authenticated"
}
```

#### Delete Session (Logout)

```http
DELETE /api/session
```

**Response 204:** (No content)

## Collections API

All collection endpoints follow the same pattern:

```
/api/collections/{collection}/records
```

### Standard CRUD Operations

#### List Records

```http
GET /api/collections/{collection}/records
```

**Example:**
```http
GET /api/collections/item/records
```

**Response 200:**
```json
{
  "items": [
    { "id": "item1", "name": "Latte", "price_nok": 45, ... },
    { "id": "item2", "name": "Espresso", "price_nok": 35, ... }
  ]
}
```

#### Get Single Record

```http
GET /api/collections/{collection}/records/:id
```

**Response 200:**
```json
{
  "item": { "id": "item1", "name": "Latte", ... }
}
```

**Response 404:**
```json
{
  "error": "Not found"
}
```

#### Create Record

```http
POST /api/collections/{collection}/records
Content-Type: application/json

{
  "name": "New Item",
  "price_nok": 50,
  ...
}
```

**Response 201:**
```json
{
  "item": { "id": "generated_id", "name": "New Item", ... }
}
```

**Response 422:** (Validation error)
```json
{
  "errors": {
    "name": ["can't be blank"],
    "price_nok": ["must be greater than 0"]
  }
}
```

#### Update Record

```http
PATCH /api/collections/{collection}/records/:id
Content-Type: application/json

{
  "name": "Updated Name",
  "price_nok": 55
}
```

Or with PUT:
```http
PUT /api/collections/{collection}/records/:id
```

**Response 200:**
```json
{
  "item": { "id": "item1", "name": "Updated Name", ... }
}
```

#### Delete Record

```http
DELETE /api/collections/{collection}/records/:id
```

**Response 204:** (No content)

## Available Collections

### Category

```http
/api/collections/category/records
```

**Fields:**
- `id`: string (auto-generated)
- `name`: string (required)
- `sort_order`: integer
- `enable`: boolean
- `valid_customizations`: array of string IDs

### Item

```http
/api/collections/item/records
```

**Fields:**
- `id`: string (auto-generated)
- `name`: string (required)
- `price_nok`: decimal (required)
- `category`: string (required, category ID)
- `image`: string (file path) or File upload
- `enable`: boolean
- `sort_order`: integer

**Special**: Supports `multipart/form-data` for image uploads.

### Customization Key

```http
/api/collections/customization_key/records
```

**Fields:**
- `id`: string (auto-generated)
- `name`: string (required)
- `enable`: boolean
- `label_color`: string (hex color)
- `default_value`: string (customization value ID)
- `multiple_choice`: boolean
- `sort_order`: integer

### Customization Value

```http
/api/collections/customization_value/records
```

**Fields:**
- `id`: string (auto-generated)
- `name`: string (required)
- `price_increment_nok`: decimal
- `constant_price`: boolean (true = additive, false = multiplicative)
- `belongs_to`: string (required, customization key ID)
- `enable`: boolean
- `sort_order`: integer

### Message

```http
/api/collections/message/records
```

**Fields:**
- `id`: string (auto-generated)
- `title`: string (required)
- `subtitle`: string (nullable)

### Status

```http
/api/collections/status/records
```

**Fields:**
- `id`: string (auto-generated)
- `open`: boolean
- `show_message`: boolean
- `message`: string (nullable)

### Order

```http
/api/collections/order/records
```

**Fields:**
- `id`: string (auto-generated)
- `customer_id`: integer (nullable)
- `day_id`: integer (auto-generated)
- `state`: enum (`received`, `production`, `completed`, `dispatched`)
- `missing_information`: boolean
- `items`: array of order items (denormalized snapshot)

**Create Order Format:**
```json
{
  "customer_id": null,
  "missing_information": false,
  "state": "received",
  "items": [
    {
      "item": "item_id",
      "customizations": [
        {
          "key": "size_key_id",
          "value": ["medium_value_id"]
        }
      ]
    }
  ]
}
```

Backend transforms this into denormalized snapshot with names and prices.

## Error Responses

### 400 Bad Request

Invalid request format or parameters.

```json
{
  "error": "Invalid request"
}
```

### 401 Unauthorized

Not authenticated.

```json
{
  "error": "Not authenticated"
}
```

### 403 Forbidden

Authenticated but not authorized.

```json
{
  "error": "Forbidden"
}
```

### 404 Not Found

Resource doesn't exist.

```json
{
  "error": "Not found"
}
```

### 422 Unprocessable Entity

Validation failed.

```json
{
  "errors": {
    "field_name": ["error message 1", "error message 2"]
  }
}
```

### 500 Internal Server Error

Server error.

```json
{
  "error": "Internal server error"
}
```

## Rate Limiting

Currently no rate limiting is implemented. Consider adding for production.

## CORS

CORS is enabled via `cors_plug`. Configured in `config/config.exs`.

## Content Types

### JSON

Most endpoints use JSON:

```
Content-Type: application/json
```

### Multipart Form Data

Item creation/update with image upload:

```
Content-Type: multipart/form-data
```

## Examples

### Create Order with cURL

```bash
curl -X POST http://localhost:4000/api/collections/order/records \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "customer_id": null,
    "state": "received",
    "items": [
      {
        "item": "latte_id",
        "customizations": [
          {
            "key": "size_key",
            "value": ["large_id"]
          }
        ]
      }
    ]
  }'
```

### Upload Item Image

```bash
curl -X POST http://localhost:4000/api/collections/item/records \
  -F "name=Cappuccino" \
  -F "price_nok=48" \
  -F "category=coffee_id" \
  -F "enable=true" \
  -F "sort_order=1" \
  -F "image=@/path/to/image.jpg"
```

### Update Order State

```bash
curl -X PATCH http://localhost:4000/api/collections/order/records/order123 \
  -H "Content-Type: application/json" \
  -d '{"state": "production"}'
```

## Next Steps

- [WebSocket Channels](/dev/reference/websocket-channels) - Real-time API
- [Types and Schemas](/dev/reference/types-and-schemas) - Data structures
- [Database Schema](/dev/reference/database-schema) - Database tables
