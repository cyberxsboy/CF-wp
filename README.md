# 通过 Cloudflare Workers 和 Pages 部署 WordPress 站点

## 概述

本指南将帮助你使用 Cloudflare Workers 和 Pages 部署一个无服务器的 WordPress 站点。这种方案利用了 Cloudflare 的边缘计算能力，提供了高性能、低延迟的全球访问体验。

## 方案架构

### 方案 1: WordPress + Workers + D1 数据库
- **Cloudflare Workers**: 运行 PHP WordPress 核心
- **Cloudflare D1**: SQLite 数据库存储
- **Cloudflare R2**: 媒体文件存储
- **Cloudflare Pages**: 托管静态资源

### 方案 2: 静态化 WordPress + Pages
- **WordPress**: 本地或服务器运行
- **静态化插件**: 将 WordPress 转换为静态网站
- **Cloudflare Pages**: 部署静态文件

## 方案详解

### 方案 1: 完整的 WordPress on Workers (推荐)

#### 先决条件
- Cloudflare 账号
- Node.js 16+ 和 npm
- Wrangler CLI

#### 步骤 1: 安装 Wrangler CLI

```bash
npm install -g wrangler
wrangler login
```

#### 步骤 2: 创建项目结构

项目结构如下:
```
cloudflare-wordpress/
├── wrangler.toml          # Cloudflare Workers 配置
├── package.json           # 项目依赖
├── src/
│   ├── index.js          # Workers 入口文件
│   └── wordpress/        # WordPress 文件
├── schema.sql            # 数据库架构
└── static/               # 静态资源
```

#### 步骤 3: 配置数据库

1. 创建 D1 数据库:
```bash
wrangler d1 create wordpress-db
```

2. 记录返回的数据库 ID，并更新 `wrangler.toml`

3. 初始化数据库:
```bash
wrangler d1 execute wordpress-db --file=./schema.sql
```

#### 步骤 4: 配置 R2 存储桶

```bash
wrangler r2 bucket create wordpress-media
```

#### 步骤 5: 部署到 Workers

```bash
wrangler deploy
```

### 方案 2: 静态化 WordPress (更简单)

这种方案适合不需要频繁更新的博客或内容网站。

#### 工具选择

1. **Simply Static** (插件)
2. **WP2Static** (插件)
3. **Gatsby + WPGraphQL**
4. **Next.js + WordPress REST API**

#### 使用 Simply Static 的步骤

1. 在你的 WordPress 站点安装 Simply Static 插件
2. 配置插件设置
3. 生成静态文件
4. 将生成的文件上传到 Cloudflare Pages

#### 使用 Cloudflare Pages 部署

```bash
# 安装 Wrangler
npm install -g wrangler

# 登录
wrangler login

# 创建 Pages 项目
wrangler pages create wordpress-static

# 部署静态文件
wrangler pages deploy ./static-output --project-name=wordpress-static
```

## 详细配置文件

详细的配置文件已包含在本项目中:
- `wrangler.toml` - Workers 配置
- `src/index.js` - Workers 脚本
- `schema.sql` - 数据库架构
- `package.json` - 项目依赖

## 性能优化

### 缓存策略
- 使用 Cloudflare Cache API 缓存页面
- 设置合适的 TTL
- 使用 ETag 进行条件请求

### CDN 配置
- 启用 Cloudflare CDN
- 配置图片优化
- 启用 Brotli 压缩

## 注意事项

### 限制
1. **Workers 限制**:
   - CPU 时间限制: 50ms (免费) / 50ms-30s (付费)
   - 请求大小限制: 100MB
   - 不支持所有 PHP 功能

2. **D1 数据库限制**:
   - 数据库大小: 500MB (免费) / 更大 (付费)
   - 每天读取: 500万次
   - 每天写入: 10万次

3. **R2 存储限制**:
   - 免费额度: 10GB 存储

### 兼容性
- 并非所有 WordPress 插件都能在 Workers 环境运行
- 需要使用兼容的主题
- 某些动态功能可能需要调整

## 成本估算

### 免费层级
- Workers: 10万次请求/天
- Pages: 无限带宽
- D1: 500万次读取/天
- R2: 10GB 存储

### 付费层级 (Workers Paid)
- $5/月起
- 1000万次请求
- 更高的 CPU 限制

## 替代方案

如果 Cloudflare Workers 方案不适合你，考虑:

1. **WordPress.com**: 托管的 WordPress 服务
2. **WP Engine**: 专业 WordPress 托管
3. **静态站点生成器**: Gatsby, Hugo, Jekyll
4. **Headless CMS**: WordPress 作为后端，前端使用 Next.js/Nuxt.js

## 资源链接

- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [Cloudflare Pages 文档](https://developers.cloudflare.com/pages/)
- [Cloudflare D1 文档](https://developers.cloudflare.com/d1/)
- [Cloudflare R2 文档](https://developers.cloudflare.com/r2/)

## 故障排查

### 常见问题

1. **Workers 超时**
   - 优化数据库查询
   - 使用缓存
   - 考虑升级到付费计划

2. **数据库连接失败**
   - 检查 D1 绑定配置
   - 验证数据库 ID

3. **静态资源加载失败**
   - 检查 R2 绑定
   - 验证 CORS 设置

## 总结

使用 Cloudflare Workers 和 Pages 部署 WordPress 是一个创新的方案，适合:
- 中小型博客和内容网站
- 需要全球低延迟访问的站点
- 预算有限的项目

对于复杂的企业网站，建议考虑传统的托管方案或混合方案。

