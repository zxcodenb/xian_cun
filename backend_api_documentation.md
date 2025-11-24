# 果味储物间 (Apple Pantry) - 后端API文档

## 📋 基础信息

- **API版本**: v1.0
- **基础URL**: `https://api.applepantry.com/v1`
- **协议**: HTTPS
- **数据格式**: JSON
- **字符编码**: UTF-8

## 🔐 认证方式

### Bearer Token认证
所有需要认证的接口都必须在请求头中携带token：
```
Authorization: Bearer <your_token_here>
```

---

## 📦 商品管理 API

### 1. 获取商品列表
**接口**: `GET /products`

**描述**: 获取当前用户的所有商品列表

**查询参数**:
- `filter` (string, optional): 筛选类型
  - `all`: 全部商品
  - `warning`: 临期商品 (4-15天)
  - `urgent`: 紧急商品 (1-3天)
- `category` (string, optional): 按分类筛选
- `sort` (string, optional): 排序方式
  - `daysLeft_asc`: 按剩余天数升序
  - `daysLeft_desc`: 按剩余天数降序
  - `created_at_desc`: 按创建时间降序(默认)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "name": "全脂牛奶",
        "category": "乳制品",
        "daysLeft": 2,
        "totalDays": 14,
        "emoji": "🥛",
        "purchaseDate": "2025-11-20T10:30:00Z",
        "description": "精选优质牧场奶源，口感醇厚，营养丰富。适合直接饮用或制作咖啡、麦片等。",
        "brand": "蒙牛",
        "createdAt": "2025-11-20T10:30:00Z",
        "updatedAt": "2025-11-20T10:30:00Z"
      }
    ],
    "total": 5,
    "page": 1,
    "perPage": 20
  }
}
```

---

### 2. 获取单个商品详情
**接口**: `GET /products/{id}`

**路径参数**:
- `id` (integer): 商品ID

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "name": "全脂牛奶",
    "category": "乳制品",
    "daysLeft": 2,
    "totalDays": 14,
    "emoji": "🥛",
    "purchaseDate": "2025-11-20T10:30:00Z",
    "description": "精选优质牧场奶源，口感醇厚，营养丰富。适合直接饮用或制作咖啡、麦片等。",
    "brand": "蒙牛",
    "createdAt": "2025-11-20T10:30:00Z",
    "updatedAt": "2025-11-20T10:30:00Z"
  }
}
```

---

### 3. 添加商品
**接口**: `POST /products`

**请求头**:
- `Content-Type: application/json`
- `Authorization: Bearer <token>`

**请求体**:
```json
{
  "name": "红富士苹果",
  "category": "生鲜",
  "daysLeft": 7,
  "totalDays": 14,
  "emoji": "🍎",
  "purchaseDate": "2025-11-23T10:30:00Z",
  "description": "新鲜红富士苹果，脆甜多汁，营养丰富。",
  "brand": "烟台产地"
}
```

**响应示例**:
```json
{
  "code": 201,
  "message": "商品添加成功",
  "data": {
    "id": 6,
    "name": "红富士苹果",
    "category": "生鲜",
    "daysLeft": 7,
    "totalDays": 14,
    "emoji": "🍎",
    "purchaseDate": "2025-11-23T10:30:00Z",
    "description": "新鲜红富士苹果，脆甜多汁，营养丰富。",
    "brand": "烟台产地",
    "createdAt": "2025-11-23T10:30:00Z",
    "updatedAt": "2025-11-23T10:30:00Z"
  }
}
```

---

### 4. 更新商品信息
**接口**: `PUT /products/{id}`

**路径参数**:
- `id` (integer): 商品ID

**请求体** (所有字段可选):
```json
{
  "name": "全脂牛奶(已更新)",
  "daysLeft": 3,
  "description": "更新后的描述"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "商品更新成功",
  "data": {
    "id": 1,
    "name": "全脂牛奶(已更新)",
    "daysLeft": 3,
    "description": "更新后的描述",
    "updatedAt": "2025-11-23T11:30:00Z"
  }
}
```

---

### 5. 删除商品
**接口**: `DELETE /products/{id}`

**路径参数**:
- `id` (integer): 商品ID

**响应示例**:
```json
{
  "code": 200,
  "message": "商品删除成功"
}
```

---

### 6. 消耗/使用商品
**接口**: `POST /products/{id}/consume`

**路径参数**:
- `id` (integer): 商品ID

**描述**: 标记商品为已使用/已消耗，从列表中移除

**响应示例**:
```json
{
  "code": 200,
  "message": "商品已消耗"
}
```

---

## 🏷️ 商品分类 API

### 7. 获取所有分类
**接口**: `GET /categories`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "生鲜",
      "icon": "🥬",
      "color": "#30D158"
    },
    {
      "id": 2,
      "name": "乳制品",
      "icon": "🥛",
      "color": "#0A84FF"
    }
  ]
}
```

---

### 8. 创建新分类
**接口**: `POST /categories`

**请求体**:
```json
{
  "name": "冷冻食品",
  "icon": "🧊",
  "color": "#FFD60A"
}
```

**响应示例**:
```json
{
  "code": 201,
  "message": "分类创建成功",
  "data": {
    "id": 3,
    "name": "冷冻食品",
    "icon": "🧊",
    "color": "#FFD60A"
  }
}
```

---

### 9. 删除分类
**接口**: `DELETE /categories/{id}`

**路径参数**:
- `id` (integer): 分类ID

**响应示例**:
```json
{
  "code": 200,
  "message": "分类删除成功"
}
```

---

## 📊 统计数据 API

### 10. 获取使用统计
**接口**: `GET /statistics`

**查询参数**:
- `period` (string, optional): 统计周期
  - `week`: 本周
  - `month`: 本月
  - `year`: 今年
  - `all`: 全部(默认)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalProducts": 5,
    "totalConsumed": 12,
    "expiringSoon": 2,  // 7天内过期
    "expired": 1,       // 已过期
    "byCategory": [
      {
        "category": "生鲜",
        "count": 2,
        "percentage": 40
      },
      {
        "category": "乳制品",
        "count": 1,
        "percentage": 20
      }
    ],
    "dailyConsumption": [
      {
        "date": "2025-11-20",
        "count": 3
      },
      {
        "date": "2025-11-21",
        "count": 2
      }
    ]
  }
}
```

---

### 11. 获取即将过期的商品
**接口**: `GET /products/expiring`

**查询参数**:
- `days` (integer, optional): 未来几天内过期，默认7天

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "name": "全脂牛奶",
        "daysLeft": 2,
        "category": "乳制品",
        "emoji": "🥛"
      }
    ],
    "count": 1
  }
}
```

---

## ⚙️ 设置 API

### 12. 获取用户设置
**接口**: `GET /settings`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "notifications": {
      "enabled": true,
      "expiringWarning": true,
      "expiringDays": 3,
      "dailyReminder": false
    },
    "theme": "auto",
    "language": "zh-CN"
  }
}
```

---

### 13. 更新用户设置
**接口**: `PUT /settings`

**请求体**:
```json
{
  "notifications": {
    "enabled": true,
    "expiringWarning": true,
    "expiringDays": 5,
    "dailyReminder": true
  },
  "theme": "dark"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "设置更新成功",
  "data": {
    "notifications": {
      "enabled": true,
      "expiringWarning": true,
      "expiringDays": 5,
      "dailyReminder": true
    },
    "theme": "dark"
  }
}
```

---

### 14. 获取提醒列表
**接口**: `GET /reminders`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "productId": 1,
      "productName": "全脂牛奶",
      "expiryDate": "2025-11-25T10:30:00Z",
      "remindAt": "2025-11-23T10:30:00Z",
      "type": "expiring",
      "status": "pending"
    }
  ]
}
```

---

### 15. 创建提醒
**接口**: `POST /reminders`

**请求体**:
```json
{
  "productId": 1,
  "type": "expiring", // expiring, custom
  "remindAt": "2025-11-23T10:30:00Z"
}
```

**响应示例**:
```json
{
  "code": 201,
  "message": "提醒创建成功",
  "data": {
    "id": 2,
    "productId": 1,
    "type": "expiring",
    "remindAt": "2025-11-23T10:30:00Z",
    "status": "pending"
  }
}
```

---

### 16. 删除提醒
**接口**: `DELETE /reminders/{id}`

**路径参数**:
- `id` (integer): 提醒ID

**响应示例**:
```json
{
  "code": 200,
  "message": "提醒删除成功"
}
```

---

## 🔍 扫码识别 API

### 17. 扫码识别商品
**接口**: `POST /products/scan`

**请求体**:
```json
{
  "barcode": "6901234567890"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "识别成功",
  "data": {
    "name": "红富士苹果",
    "category": "生鲜",
    "emoji": "🍎",
    "brand": "烟台产地",
    "defaultDaysLeft": 14,
    "description": "新鲜红富士苹果，脆甜多汁，营养丰富。"
  }
}
```

---

### 18. 扫码历史记录
**接口**: `GET /scan-history`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "barcode": "6901234567890",
      "productName": "红富士苹果",
      "scannedAt": "2025-11-23T10:30:00Z"
    }
  ]
}
```

---

## 👤 用户相关 API

### 19. 用户注册
**接口**: `POST /auth/register`

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "张三"
}
```

**响应示例**:
```json
{
  "code": 201,
  "message": "注册成功",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "张三",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenExpiresIn": 86400
  }
}
```

---

### 20. 用户登录
**接口**: `POST /auth/login`

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "张三",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenExpiresIn": 86400
  }
}
```

---

### 21. 获取用户信息
**接口**: `GET /user/profile`

**请求头**:
- `Authorization: Bearer <token>`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "张三",
    "avatar": "https://cdn.example.com/avatars/1.jpg",
    "createdAt": "2025-11-01T10:30:00Z"
  }
}
```

---

### 22. 更新用户信息
**接口**: `PUT /user/profile`

**请求体**:
```json
{
  "name": "李四",
  "avatar": "https://cdn.example.com/avatars/2.jpg"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "用户信息更新成功",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "李四",
    "avatar": "https://cdn.example.com/avatars/2.jpg"
  }
}
```

---

### 23. 修改密码
**接口**: `PUT /auth/password`

**请求体**:
```json
{
  "oldPassword": "password123",
  "newPassword": "newpassword456"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "密码修改成功"
}
```

---

### 24. 刷新Token
**接口**: `POST /auth/refresh`

**请求体**:
```json
{
  "refreshToken": "your_refresh_token_here"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenExpiresIn": 86400
  }
}
```

---

### 25. 用户登出
**接口**: `POST /auth/logout`

**请求头**:
- `Authorization: Bearer <token>`

**响应示例**:
```json
{
  "code": 200,
  "message": "登出成功"
}
```

---

## 📱 批量操作 API

### 26. 批量删除商品
**接口**: `POST /products/batch-delete`

**请求体**:
```json
{
  "productIds": [1, 2, 3]
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "批量删除成功",
  "data": {
    "deletedCount": 3
  }
}
```

---

### 27. 批量更新商品
**接口**: `POST /products/batch-update`

**请求体**:
```json
{
  "productIds": [1, 2],
  "daysLeft": 10
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "批量更新成功",
  "data": {
    "updatedCount": 2
  }
}
```

---

## 📈 数据导出 API

### 28. 导出商品数据
**接口**: `GET /exports/products`

**查询参数**:
- `format` (string): 导出格式 (csv, xlsx, json，默认json)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "downloadUrl": "https://cdn.example.com/exports/products_20251123.xlsx",
    "expiresAt": "2025-11-24T10:30:00Z"
  }
}
```

---

## ⚠️ 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（token无效或过期） |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 409 | 资源冲突（如邮箱已存在） |
| 422 | 表单验证失败 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

---

## 📝 通用响应格式

### 成功响应
```json
{
  "code": 200,
  "message": "操作描述",
  "data": { ... },
  "timestamp": "2025-11-23T10:30:00Z"
}
```

### 错误响应
```json
{
  "code": 400,
  "message": "错误描述",
  "errors": {
    "field": ["错误详情"]
  },
  "timestamp": "2025-11-23T10:30:00Z"
}
```

---

## 🚀 快速开始

### 1. 注册用户
```bash
curl -X POST https://api.applepantry.com/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "张三"
  }'
```

### 2. 登录获取token
```bash
curl -X POST https://api.applepantry.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

### 3. 获取商品列表
```bash
curl -X GET https://api.applepantry.com/v1/products \
  -H "Authorization: Bearer your_token_here"
```

---

## 📚 技术栈建议

- **后端框架**: 
  - Node.js + Express
  - Python + FastAPI/Django
  - Java + Spring Boot
  - Go + Gin

- **数据库**:
  - PostgreSQL (推荐)
  - MySQL
  - MongoDB

- **认证**: JWT (JSON Web Token)

- **部署**:
  - Docker容器化
  - 云服务器 (AWS/阿里云/腾讯云)
  - CDN加速静态资源

---

**文档版本**: v1.0  
**最后更新**: 2025-11-23  
**维护者**: Apple Pantry开发团队
