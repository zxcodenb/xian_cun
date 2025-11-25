# 🚀 后端API实现示例

## 概述

本文档提供AI商品识别后端API的Node.js实现示例，使用OpenAI GPT-4V或Claude-3 Vision进行图片识别。

## 📋 API接口定义

### 请求
```
POST /api/recognize-product
Content-Type: multipart/form-data
```

### 参数
- `image` - 商品图片文件

### 响应
```json
{
  "success": true,
  "result": {
    "name": "商品名称",
    "category": "商品分类",
    "brand": "品牌名称",
    "days_left": 剩余天数,
    "shelf_life_days": 保质期总天数,
    "description": "商品描述",
    "confidence": 0.95,
    "production_date": "YYYY-MM-DD"
  }
}
```

## 🛠️ Node.js + Express实现

### 1. 项目初始化

```bash
mkdir ai-recognition-api
cd ai-recognition-api
npm init -y
npm install express multer openai cors dotenv
```

### 2. 环境变量配置 (.env)

```env
OPENAI_API_KEY=your_openai_api_key_here
PORT=3000
```

### 3. 主服务文件 (server.js)

```javascript
require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const OpenAI = require('openai');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// 配置CORS
app.use(cors());
app.use(express.json());

// 初始化OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// 配置multer用于接收文件
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

/**
 * AI识别商品信息
 * POST /api/recognize-product
 */
app.post('/api/recognize-product', upload.single('image'), async (req, res) => {
  try {
    // 检查是否有图片
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: '请上传图片'
      });
    }

    // 将图片转换为base64
    const base64Image = req.file.buffer.toString('base64');
    const dataUri = `data:${req.file.mimetype};base64,${base64Image}`;

    // 调用OpenAI Vision API
    const response = await openai.chat.completions.create({
      model: "gpt-4-vision-preview",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: `请分析这张商品图片，提取以下信息，并以JSON格式返回：
              {
                "name": "商品名称",
                "category": "商品分类（从：乳制品、烘焙、生鲜、水果、蔬菜、肉类、海鲜、冷冻、调味、零食、饮料、酒类中选择）",
                "brand": "品牌名称",
                "shelf_life_days": 保质期总天数（数字）,
                "production_date": "YYYY-MM-DD格式的生产日期（如果没有则返回null）",
                "description": "商品详细描述"
              }
              如果无法识别某些信息，请返回合理的默认值。`
            },
            {
              type: "image_url",
              image_url: {
                url: dataUri
              }
            }
          ]
        }
      ],
      max_tokens: 500
    });

    // 解析AI返回的JSON
    const aiResponse = response.choices[0].message.content;
    let result;

    try {
      // 尝试解析JSON
      const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        result = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('无法解析AI返回的JSON');
      }
    } catch (parseError) {
      // 如果解析失败，使用默认值
      result = {
        name: "未识别的商品",
        category: "其他",
        brand: "未知",
        shelf_life_days: 14,
        production_date: null,
        description: aiResponse
      };
    }

    // 计算剩余天数
    let daysLeft;
    if (result.production_date && result.shelf_life_days) {
      const productionDate = new Date(result.production_date);
      const expirationDate = new Date(productionDate.getTime() + result.shelf_life_days * 24 * 60 * 60 * 1000);
      daysLeft = Math.ceil((expirationDate - new Date()) / (1000 * 60 * 60 * 24));
      daysLeft = Math.max(0, daysLeft); // 不允许负数
    } else {
      // 根据分类给出默认剩余天数
      const categoryDefaults = {
        '乳制品': 7,
        '烘焙': 5,
        '生鲜': 3,
        '水果': 5,
        '蔬菜': 4,
        '肉类': 2,
        '海鲜': 1,
        '冷冻': 30,
        '调味': 365,
        '零食': 180,
        '饮料': 90,
        '酒类': 730
      };
      daysLeft = categoryDefaults[result.category] || 7;
    }

    // 构建最终结果
    const finalResult = {
      name: result.name,
      category: result.category,
      brand: result.brand,
      days_left: daysLeft,
      shelf_life_days: result.shelf_life_days,
      description: result.description,
      production_date: result.production_date,
      confidence: 0.85 // 可根据实际情况调整
    };

    res.json({
      success: true,
      result: finalResult
    });

  } catch (error) {
    console.error('识别错误:', error);
    res.status(500).json({
      success: false,
      error: error.message || '识别失败，请稍后重试'
    });
  }
});

app.listen(port, () => {
  console.log(`🚀 AI识别服务启动成功！`);
  console.log(`📍 服务地址: http://localhost:${port}`);
  console.log(`📖 API文档: POST /api/recognize-product`);
});
```

### 4. 启动服务

```bash
node server.js
```

## 🔧 Claude-3 Vision实现版本

如果使用Anthropic Claude-3 Vision：

```javascript
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

app.post('/api/recognize-product', upload.single('image'), async (req, res) => {
  try {
    const base64Image = req.file.buffer.toString('base64');
    const mediaType = req.file.mimetype;

    const response = await anthropic.messages.create({
      model: "claude-3-vision-20240229",
      max_tokens: 500,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: `请分析这张商品图片，提取商品信息并以JSON格式返回...`
            },
            {
              type: "image",
              source: {
                type: "base64",
                media_type: mediaType,
                data: base64Image,
              },
            },
          ],
        },
      ],
    });

    // 处理响应...
  } catch (error) {
    // 错误处理...
  }
});
```

## 📦 完整项目结构

```
ai-recognition-api/
├── .env                 # 环境变量
├── server.js            # 主服务文件
├── package.json         # 项目配置
├── node_modules/        # 依赖
└── logs/               # 日志目录（可选）
    └── recognition.log
```

## 🐳 Docker部署

### Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

### 构建和运行

```bash
docker build -t ai-recognition-api .
docker run -p 3000:3000 --env-file .env ai-recognition-api
```

## 🔒 安全最佳实践

### 1. API密钥保护
- 使用环境变量存储API密钥
- 不要在代码中硬编码密钥
- 使用密钥轮换策略

### 2. 输入验证
```javascript
// 文件类型验证
const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
if (!allowedTypes.includes(req.file.mimetype)) {
  return res.status(400).json({ error: '不支持的文件类型' });
}

// 文件大小限制（5MB）
const maxSize = 5 * 1024 * 1024;
if (req.file.size > maxSize) {
  return res.status(400).json({ error: '图片大小不能超过5MB' });
}
```

### 3. 限流保护
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 限制每个IP 15分钟内最多100次请求
  message: '请求过于频繁，请稍后再试'
});

app.use('/api/', limiter);
```

### 4. 日志记录
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/recognition.log' }),
  ],
});

// 记录识别请求
logger.info('商品识别请求', {
  ip: req.ip,
  filename: req.file.originalname,
  size: req.file.size,
  timestamp: new Date().toISOString()
});
```

## 💰 成本优化建议

### 1. 图片预处理
```javascript
const sharp = require('sharp');

// 压缩图片
sharp(req.file.buffer)
  .resize(800, 800, { fit: 'inside' })
  .jpeg({ quality: 80 })
  .toBuffer()
  .then(async (buffer) => {
    // 使用压缩后的图片调用API
    const base64Image = buffer.toString('base64');
    // ...
  });
```

### 2. 结果缓存
```javascript
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 3600 }); // 1小时缓存

// 缓存key：图片hash值
const imageHash = crypto.createHash('md5').update(req.file.buffer).digest('hex');
const cached = cache.get(imageHash);

if (cached) {
  return res.json({ success: true, result: cached, cached: true });
}

// 识别后存储到缓存
cache.set(imageHash, finalResult);
```

### 3. 批量处理
```javascript
// 支持一次上传多张图片
app.post('/api/recognize-products', upload.array('images', 10), async (req, res) => {
  const results = [];
  for (const file of req.files) {
    // 处理每张图片...
    results.push(result);
  }
  res.json({ success: true, results });
});
```

## 🧪 测试

### 单元测试（Jest）

```javascript
const request = require('supertest');
const app = require('./server');

describe('商品识别API', () => {
  test('POST /api/recognize-product - 成功识别', async () => {
    const response = await request(app)
      .post('/api/recognize-product')
      .attach('image', 'test/sample-product.jpg')
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.result).toHaveProperty('name');
    expect(response.body.result).toHaveProperty('category');
  });

  test('POST /api/recognize-product - 未上传图片', async () => {
    const response = await request(app)
      .post('/api/recognize-product')
      .expect(400);

    expect(response.body.success).toBe(false);
    expect(response.body.error).toBe('请上传图片');
  });
});
```

## 📊 监控和指标

### 关键指标
- 识别成功率
- 平均响应时间
- API调用次数
- 错误率
- 成本消耗

### Prometheus指标示例

```javascript
const promClient = require('prom-client');

// 创建指标
const recognitionCounter = new promClient.Counter({
  name: 'recognitions_total',
  help: '识别请求总数'
});

const recognitionDuration = new promClient.Histogram({
  name: 'recognition_duration_seconds',
  help: '识别耗时'
});

// 使用指标
recognitionCounter.inc();
const end = recognitionDuration.startTimer();
try {
  // 识别逻辑...
} finally {
  end();
}
```

## 🔗 相关文档

- [OpenAI Vision API文档](https://platform.openai.com/docs/guides/vision)
- [Anthropic Claude-3 Vision文档](https://docs.anthropic.com/claude/docs/vision)
- [Express.js文档](https://expressjs.com/)
- [Multer文档](https://github.com/expressjs/multer)

---

**版本**: v1.0.0
**最后更新**: 2025-11-24
**开发者**: Claude Code
