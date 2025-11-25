# 🍏 储物间 (Apple Pantry)

> 一个优雅的食物库存管理应用，帮助您跟踪食品保质期，减少浪费

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 📱 项目截图

*这里可以添加应用截图*

---

## ✨ 核心功能

### 🏠 首页 - 智能库存概览
- **玻璃拟态设计** - 优雅的毛玻璃效果Header
- **商品网格布局** - 2列卡片展示，清晰直观
- **智能筛选** - 全部/临期/紧急三种筛选模式
- **状态概览** - 实时显示急需和临期商品数量
- **空状态引导** - 友好的空状态页面引导用户添加商品

### ➕ 新增商品 - 两种添加方式
- **扫码添加** - 扫描条形码自动识别商品信息
  - 全屏相机界面模拟
  - 扫描动画反馈
  - 自动填充商品信息
- **手动添加** - 完整的表单填写
  - 商品名称、分类、品牌
  - 保质期天数设置
  - Emoji图标选择
  - 商品描述（可选）

### 📋 商品详情
- **底部弹窗设计** - 半屏展示，不打断操作流程
- **完整商品信息** - 展示所有商品详情
- **保质期进度** - 可视化显示剩余天数
- **状态标签** - 新鲜/临期/紧急状态一目了然

### ⚙️ 设置中心
- 提醒设置
- 分类管理
- 统计报告
- 关于与帮助

---

## 🏗️ 技术架构

### 前端 (Flutter)

```
lib/
├── main.dart              # 应用入口
├── models/                # 数据模型
│   └── product.dart
├── screens/              # 页面
│   ├── dashboard/
│   ├── add_product/
│   ├── settings/
│   └── product_detail/
├── widgets/              # 可复用组件
│   ├── product_card.dart
│   ├── filter_chip.dart
│   └── glass_header.dart
└── services/             # 服务层
    ├── api_service.dart
    └── storage_service.dart
```

**核心技术栈**:
- Flutter 3.x
- Material Design 3
- Cupertino (iOS风格组件)
- 自定义动画系统

### 后端 (REST API)

```
api/
├── auth/                  # 认证模块
│   ├── login
│   ├── register
│   └── refresh-token
├── products/              # 商品管理
│   ├── GET /products
│   ├── POST /products
│   ├── PUT /products/{id}
│   ├── DELETE /products/{id}
│   └── POST /products/{id}/consume
├── categories/            # 分类管理
├── settings/              # 用户设置
├── reminders/             # 提醒功能
├── statistics/            # 统计数据
└── scan/                  # 扫码识别
```

**技术栈推荐**:
- Node.js + Express / Python + FastAPI / Java + Spring Boot
- PostgreSQL / MySQL
- JWT认证
- RESTful API设计

### 数据库 (PostgreSQL)

```
表结构:
├── users                 # 用户表
├── products              # 商品表
├── categories            # 分类表
├── user_settings         # 用户设置
├── reminders             # 提醒表
├── scan_history          # 扫码历史
└── consumption_history   # 消耗记录
```

---

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android SDK (API 21+)

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-username/apple-pantry.git
cd apple-pantry
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
# 连接Android设备或启动模拟器
flutter run

# 构建release版本
flutter build apk --release
```

4. **后端部署** (可选)
```bash
# 查看后端API文档
cat backend_api_documentation.md

# 查看数据库设计
cat database_schema_design.md
```

---

## 📊 项目结构

```
apple-pantry/
├── README.md                          # 项目说明 (本文件)
├── backend_api_documentation.md       # 后端API文档
├── database_schema_design.md          # 数据库设计文档
├── lib/                               # Flutter源码
│   └── main.dart                      # 主入口文件
├── android/                           # Android配置
├── ios/                               # iOS配置
├── web/                               # Web配置 (可选)
├── assets/                            # 静态资源
│   ├── images/
│   └── fonts/
└── pubspec.yaml                       # 依赖配置
```

---

## 🎨 设计理念

**关键词**: 极简、留白、轻拟物、通透、动效自然、柔和阴影

### 配色方案

| 颜色 | 用途 | 值 |
|------|------|-----|
| 背景色 | 主背景 | `#F5F5F7` |
| 品牌色 | 按钮、选中状态 | `#0A84FF` |
| 文本深色 | 标题、重要信息 | `#1C1C1E` |
| 文本浅色 | 辅助信息 | `#3C3C4399` |
| 安全状态 | 新鲜商品 | `#30D158` |
| 警告状态 | 临期商品 | `#FFD60A` |
| 紧急状态 | 紧急商品 | `#FF453A` |

### 视觉特色

- **玻璃拟态卡片** - 半透明效果+模糊背景
- **柔和阴影** - 营造悬浮感
- **圆角设计** - 大圆角(20-30px)，更友好
- **呼吸动画** - 临期商品轻微闪烁提醒
- **苹果风格** - 遵循iOS Human Interface Guidelines

---

## 📦 已实现功能清单

### ✅ 前端功能
- [x] 用户界面设计与实现
- [x] 商品列表展示与筛选
- [x] 商品详情查看
- [x] 扫码模拟界面
- [x] 手动添加表单
- [x] 底部导航栏
- [x] 响应式布局适配
- [x] 动画效果实现
- [x] 空状态处理
- [x] 表单验证
- [x] 状态管理

### ✅ 后端API (设计完成)
- [x] 用户认证 (注册/登录/登出)
- [x] 商品CRUD操作
- [x] 分类管理
- [x] 用户设置
- [x] 提醒系统
- [x] 统计数据
- [x] 扫码识别
- [x] 批量操作
- [x] 数据导出

### ✅ 数据库设计
- [x] 表结构设计
- [x] 索引优化
- [x] 视图创建
- [x] 外键约束
- [x] 性能优化建议
- [x] 安全策略
- [x] 备份方案

---

## 🔄 开发计划

### 近期计划 (v1.1)
- [ ] **真实扫码功能** - 集成相机权限和条码扫描库
- [ ] **数据持久化** - 本地存储(SQLite)或云同步
- [ ] **推送通知** - 过期提醒通知
- [ ] **黑暗模式** - 深色主题支持

### 中期计划 (v1.5)
- [ ] **智能推荐** - 基于历史数据推荐购买
- [ ] **社交分享** - 分享商品列表或统计
- [ ] **多语言支持** - 国际化 (i18n)
- [ ] **Apple Watch支持** - 通知和快速查看

### 长期计划 (v2.0)
- [ ] **AI识别** - 拍照识别商品
- [ ] **购物清单** - 基于库存生成购物建议
- [ ] **营养分析** - 展示营养成分信息
- [ ] **社区功能** - 用户评价和推荐

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 贡献类型

- 🐛 Bug修复
- ✨ 新功能
- 📚 文档改进
- 🎨 UI/UX优化
- 🔧 性能优化
- 🧪 测试用例

---

## 📝 开发规范

### 代码风格
- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `flutter_format` 格式化代码
- 添加有意义的注释
- 保持函数和类的单一职责

### 提交规范
```
feat: 添加新功能
fix: 修复bug
docs: 更新文档
style: 代码格式调整
refactor: 代码重构
test: 添加测试
chore: 构建过程或辅助工具的变动
```

### 示例
```bash
git commit -m "feat: 添加商品搜索功能"
git commit -m "fix: 修复筛选按钮被遮挡的问题"
git commit -m "docs: 更新API文档"
```

---

## 🐛 常见问题

### Q: 如何添加新的商品分类？
A: 在 `AddSelectScreen` 中点击"手动添加"，或在设置页面的"分类管理"中创建。

### Q: 如何修改筛选条件？
A: 编辑 `lib/main.dart` 中的 `_DashboardScreenState` 类，找到 `filteredItems` getter方法。

### Q: 可以自定义商品图标吗？
A: 是的，手动添加时可以在"Emoji图标"字段输入任意Emoji。

### Q: 数据存储在哪里？
A: 当前版本使用内存存储，生产环境建议使用云数据库同步。

---

## 📜 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 🙏 致谢

- [Flutter Team](https://flutter.dev/) - 优秀的跨平台框架
- [Material Design](https://material.io/) - 设计规范
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/) - iOS设计指南

---
**⭐ 如果这个项目对您有帮助，请给我们一个Star！**

---

*最后更新: 2025-11-23*
