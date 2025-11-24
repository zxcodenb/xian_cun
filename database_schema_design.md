# 果味储物间 (Apple Pantry) - 数据库设计文档

## 📊 数据库架构

### 推荐数据库：PostgreSQL 14+

---

## 📋 数据表设计

### 1. 用户表 (users)

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    avatar TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 索引
    CONSTRAINT users_email_unique UNIQUE (email)
);

-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

---

### 2. 商品分类表 (categories)

```sql
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(10) NOT NULL,
    color VARCHAR(7) NOT NULL, -- 十六进制颜色值，如 #30D158
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 外键约束
    CONSTRAINT fk_categories_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_categories_name_user UNIQUE (name, user_id)
);

-- 创建索引
CREATE INDEX idx_categories_user_id ON categories(user_id);
CREATE INDEX idx_categories_name ON categories(name);
```

---

### 3. 商品表 (products)

```sql
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category_id BIGINT,
    name VARCHAR(255) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    days_left INTEGER NOT NULL CHECK (days_left >= 0),
    total_days INTEGER NOT NULL CHECK (total_days > 0),
    emoji VARCHAR(10) NOT NULL,
    purchase_date TIMESTAMP WITH TIME ZONE NOT NULL,
    description TEXT,
    brand VARCHAR(255),
    barcode VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    consumed_at TIMESTAMP WITH TIME ZONE,
    
    -- 外键约束
    CONSTRAINT fk_products_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    
    -- 检查约束
    CONSTRAINT chk_days_left CHECK (days_left >= 0),
    CONSTRAINT chk_total_days CHECK (total_days > 0)
);

-- 创建索引
CREATE INDEX idx_products_user_id ON products(user_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_days_left ON products(days_left);
CREATE INDEX idx_products_purchase_date ON products(purchase_date);
CREATE INDEX idx_products_created_at ON products(created_at);
CREATE INDEX idx_products_consumed_at ON products(consumed_at);
CREATE INDEX idx_products_barcode ON products(barcode);
```

---

### 4. 用户设置表 (user_settings)

```sql
CREATE TABLE user_settings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    notifications_enabled BOOLEAN DEFAULT true,
    expiring_warning_enabled BOOLEAN DEFAULT true,
    expiring_warning_days INTEGER DEFAULT 3 CHECK (expiring_warning_days > 0),
    daily_reminder_enabled BOOLEAN DEFAULT false,
    daily_reminder_time TIME DEFAULT '09:00:00',
    theme VARCHAR(20) DEFAULT 'auto' CHECK (theme IN ('auto', 'light', 'dark')),
    language VARCHAR(10) DEFAULT 'zh-CN',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 外键约束
    CONSTRAINT fk_user_settings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);
```

---

### 5. 提醒表 (reminders)

```sql
CREATE TABLE reminders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('expiring', 'custom')),
    remind_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'cancelled')),
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP WITH TIME ZONE,
    
    -- 外键约束
    CONSTRAINT fk_reminders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_reminders_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_reminders_product_id ON reminders(product_id);
CREATE INDEX idx_reminders_remind_at ON reminders(remind_at);
CREATE INDEX idx_reminders_status ON reminders(status);
```

---

### 6. 扫码历史表 (scan_history)

```sql
CREATE TABLE scan_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    barcode VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 外键约束
    CONSTRAINT fk_scan_history_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_scan_history_user_id ON scan_history(user_id);
CREATE INDEX idx_scan_history_barcode ON scan_history(barcode);
CREATE INDEX idx_scan_history_scanned_at ON scan_history(scanned_at);
```

---

### 7. 商品消耗记录表 (consumption_history)

```sql
CREATE TABLE consumption_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    consumed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    days_consumed INTEGER, -- 从购买到消耗的天数
    notes TEXT,
    
    -- 外键约束
    CONSTRAINT fk_consumption_history_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_consumption_history_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- 创建索引
CREATE INDEX idx_consumption_history_user_id ON consumption_history(user_id);
CREATE INDEX idx_consumption_history_consumed_at ON consumption_history(consumed_at);
```

---

### 8. 访问令牌表 (refresh_tokens)

```sql
CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT false,
    
    -- 外键约束
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
```

---

### 9. 系统配置表 (system_configs) - 可选

```sql
CREATE TABLE system_configs (
    id BIGSERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 插入默认配置
INSERT INTO system_configs (key, value, description) VALUES
('max_products_per_user', '500', '每用户最大商品数量限制'),
('default_expiry_warning_days', '3', '默认过期提醒天数'),
('barcode_api_endpoint', 'https://api.barcodespider.com/v1', '条形码查询API端点'),
('cleanup_consumed_after_days', '90', '清理已消耗商品记录的天数');
```

---

## 🔄 数据库视图

### 1. 商品统计视图 (v_product_statistics)

```sql
CREATE VIEW v_product_statistics AS
SELECT 
    p.user_id,
    COUNT(p.id) AS total_products,
    COUNT(CASE WHEN p.days_left <= 3 THEN 1 END) AS urgent_count,
    COUNT(CASE WHEN p.days_left > 3 AND p.days_left <= 15 THEN 1 END) AS warning_count,
    COUNT(CASE WHEN p.days_left > 15 THEN 1 END) AS safe_count,
    COUNT(CASE WHEN p.consumed_at IS NOT NULL THEN 1 END) AS consumed_count
FROM products p
GROUP BY p.user_id;
```

---

### 2. 即将过期商品视图 (v_expiring_products)

```sql
CREATE VIEW v_expiring_products AS
SELECT 
    p.*,
    p.user_id,
    CASE 
        WHEN p.days_left <= 3 THEN 'urgent'
        WHEN p.days_left <= 15 THEN 'warning'
        ELSE 'safe'
    END AS status
FROM products p
WHERE p.consumed_at IS NULL
    AND p.days_left <= 15
ORDER BY p.days_left ASC;
```

---

## 📝 示例查询

### 1. 获取用户所有商品（带分类）

```sql
SELECT 
    p.id,
    p.name,
    p.category_name,
    p.days_left,
    p.total_days,
    p.emoji,
    p.purchase_date,
    p.description,
    p.brand,
    c.icon AS category_icon,
    c.color AS category_color,
    p.created_at
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.user_id = $1
    AND p.consumed_at IS NULL
ORDER BY p.created_at DESC;
```

### 2. 按状态筛选商品

```sql
-- 获取紧急商品（1-3天）
SELECT * FROM products
WHERE user_id = $1 
    AND consumed_at IS NULL
    AND days_left <= 3
ORDER BY days_left ASC;

-- 获取临期商品（4-15天）
SELECT * FROM products
WHERE user_id = $1 
    AND consumed_at IS NULL
    AND days_left > 3 
    AND days_left <= 15
ORDER BY days_left ASC;
```

### 3. 获取用户统计信息

```sql
SELECT 
    (SELECT COUNT(*) FROM products WHERE user_id = $1 AND consumed_at IS NULL) AS active_products,
    (SELECT COUNT(*) FROM products WHERE user_id = $1 AND consumed_at IS NOT NULL) AS consumed_products,
    (SELECT COUNT(*) FROM products WHERE user_id = $1 AND days_left <= 7 AND consumed_at IS NULL) AS expiring_soon,
    (SELECT COUNT(*) FROM consumption_history WHERE user_id = $1 AND consumed_at >= CURRENT_DATE - INTERVAL '30 days') AS consumed_last_30_days;
```

---

## 🚀 性能优化建议

### 1. 分区策略（适用于大数据量）

```sql
-- 按月分区products表
CREATE TABLE products_2025_11 PARTITION OF products
FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
```

### 2. 物化视图（定期刷新统计数据）

```sql
CREATE MATERIALIZED VIEW mv_daily_consumption AS
SELECT 
    DATE(consumed_at) AS consumption_date,
    user_id,
    COUNT(*) AS count
FROM consumption_history
GROUP BY DATE(consumed_at), user_id;

-- 创建刷新函数
CREATE OR REPLACE FUNCTION refresh_daily_consumption()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_daily_consumption;
END;
$$ LANGUAGE plpgsql;
```

### 3. 数据库维护

```sql
-- 定期清理过期token
DELETE FROM refresh_tokens 
WHERE expires_at < CURRENT_TIMESTAMP;

-- 定期清理已消耗商品的统计数据（保留90天）
DELETE FROM consumption_history 
WHERE consumed_at < CURRENT_DATE - INTERVAL '90 days';
```

---

## 🔒 安全建议

### 1. 行级安全策略 (RLS)

```sql
-- 启用RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 创建策略：用户只能访问自己的数据
CREATE POLICY products_user_policy ON products
    FOR ALL TO app_user
    USING (user_id = current_setting('app.current_user_id')::BIGINT);

-- 设置用户ID
SELECT set_config('app.current_user_id', '123', true);
```

### 2. 数据加密

```sql
-- 使用pgcrypto扩展加密敏感数据
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 加密存储密码
UPDATE users 
SET password_hash = crypt('password123', gen_salt('bf'))
WHERE id = 1;

-- 验证密码
SELECT id FROM users 
WHERE email = 'user@example.com' 
    AND password_hash = crypt('password123', password_hash);
```

---

## 📊 数据库部署

### 1. Docker Compose 配置

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14
    container_name: apple_pantry_db
    environment:
      POSTGRES_USER: apple_user
      POSTGRES_PASSWORD: your_secure_password
      POSTGRES_DB: apple_pantry
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped

volumes:
  postgres_data:
```

### 2. 备份策略

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backup/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR

# 备份数据库
pg_dump -h localhost -U apple_user -d apple_pantry > $BACKUP_DIR/backup.sql

# 压缩备份
gzip $BACKUP_DIR/backup.sql

# 删除7天前的备份
find /backup -type f -mtime +7 -delete
```

---

## 📈 监控指标

### 1. 关键指标

- **活跃用户数**: 过去7天有操作的用户
- **商品总数**: 当前未消耗的商品数量
- **过期提醒发送数**: 每天发送的过期提醒数量
- **API响应时间**: 平均响应时间和95分位响应时间

### 2. 慢查询日志

```sql
-- 启用慢查询日志
ALTER SYSTEM SET log_min_duration_statement = 1000; -- 记录超过1秒的查询
ALTER SYSTEM SET log_statement = 'mod';
SELECT pg_reload_conf();
```

---

**文档版本**: v1.0  
**最后更新**: 2025-11-23  
**维护者**: Apple Pantry开发团队
