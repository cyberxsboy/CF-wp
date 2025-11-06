# WordPress on Cloudflare Workers 部署指南

## 快速开始

### 第一步：安装依赖

```bash
npm install
```

### 第二步：登录 Cloudflare

```bash
wrangler login
```

这会打开浏览器窗口，让你登录 Cloudflare 账号。

### 第三步：获取 Account ID

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 选择任意域名
3. 在右侧找到 Account ID
4. 复制 Account ID 并填入 `wrangler.toml` 文件

### 第四步：创建 D1 数据库

```bash
npm run db:create
```

命令会输出类似以下内容：
```
✅ Successfully created DB 'wordpress-db'

[[d1_databases]]
binding = "DB"
database_name = "wordpress-db"
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

复制 `database_id` 并填入 `wrangler.toml` 文件的对应位置。

### 第五步：初始化数据库

```bash
npm run db:init
```

这会执行 `schema.sql` 文件，创建所有必要的表和默认数据。

### 第六步：创建 R2 存储桶

```bash
npm run r2:create
```

### 第七步：创建 KV 命名空间

```bash
npm run kv:create
```

命令会输出类似以下内容：
```
🌀 Creating namespace with title "wordpress-on-workers-CACHE"
✨ Success!
Add the following to your configuration file in your kv_namespaces array:
{ binding = "CACHE", id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }
```

复制 `id` 并填入 `wrangler.toml` 文件的对应位置。

对于预览环境，运行：
```bash
wrangler kv:namespace create CACHE --preview
```

### 第八步：本地测试

```bash
npm run dev
```

这会在本地启动开发服务器，通常在 `http://localhost:8787`。

### 第九步：部署到生产环境

```bash
npm run deploy
```

部署成功后，你会看到类似以下输出：
```
Total Upload: xx.xx KiB / gzip: xx.xx KiB
Uploaded wordpress-on-workers (x.xx sec)
Published wordpress-on-workers (x.xx sec)
  https://wordpress-on-workers.your-subdomain.workers.dev
```

## 配置自定义域名

### 方法 1: 通过 Cloudflare Dashboard

1. 登录 Cloudflare Dashboard
2. 进入 Workers & Pages
3. 选择你的 Worker
4. 点击 "Triggers" 标签
5. 点击 "Add Custom Domain"
6. 输入你的域名（例如：blog.yourdomain.com）
7. 点击 "Add Custom Domain"

### 方法 2: 通过 wrangler.toml

编辑 `wrangler.toml` 文件，在 `[env.production]` 部分添加：

```toml
[env.production]
name = "wordpress-on-workers-prod"
routes = [
  { pattern = "blog.yourdomain.com/*", zone_name = "yourdomain.com" }
]
```

然后部署：
```bash
npm run deploy:prod
```

## 数据库管理

### 查看数据库内容

```bash
wrangler d1 execute wordpress-db --command "SELECT * FROM wp_posts LIMIT 10"
```

### 导出数据库

```bash
wrangler d1 export wordpress-db --output=backup.sql
```

### 导入数据库

```bash
wrangler d1 execute wordpress-db --file=backup.sql
```

### 添加新文章

你可以通过 SQL 直接插入新文章：

```bash
wrangler d1 execute wordpress-db --command "
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_name, post_modified, post_modified_gmt, post_type, comment_count) 
VALUES (1, datetime('now'), datetime('now'), '<p>这是文章内容</p>', '文章标题', '', 'publish', 'open', 'open', 'article-slug', datetime('now'), datetime('now'), 'post', 0)
"
```

## R2 媒体文件管理

### 上传文件到 R2

```bash
wrangler r2 object put wordpress-media/images/photo.jpg --file=./photo.jpg
```

### 列出 R2 中的文件

```bash
wrangler r2 object list wordpress-media
```

### 删除 R2 中的文件

```bash
wrangler r2 object delete wordpress-media/images/photo.jpg
```

## 缓存管理

### 清除 KV 缓存

```bash
wrangler kv:key delete --binding=CACHE "cache-key"
```

### 查看所有缓存键

```bash
wrangler kv:key list --binding=CACHE
```

## 监控和调试

### 查看实时日志

```bash
npm run tail
```

或者：
```bash
wrangler tail
```

### 查看 Worker 分析数据

1. 登录 Cloudflare Dashboard
2. 进入 Workers & Pages
3. 选择你的 Worker
4. 查看 "Analytics" 标签

## 性能优化建议

### 1. 启用缓存

代码中已经实现了基本的缓存策略：
- 首页缓存 5 分钟（300 秒）
- 文章页缓存 10 分钟（600 秒）
- 媒体文件缓存 1 年

你可以根据需要调整这些值。

### 2. 优化数据库查询

- 使用索引
- 限制查询结果数量
- 使用预编译语句

### 3. 图片优化

使用 Cloudflare Image Resizing：

```javascript
router.get('/wp-content/uploads/*', async (request, env) => {
  const url = new URL(request.url);
  
  // 添加图片优化参数
  if (url.searchParams.has('width')) {
    // 使用 Cloudflare Images API
  }
  
  // ... 现有代码
});
```

### 4. 启用压缩

Cloudflare 会自动处理 Gzip 和 Brotli 压缩。

## 安全建议

### 1. 设置环境变量

在 Cloudflare Dashboard 中设置敏感信息：
- JWT 密钥
- 管理员密码哈希
- API 密钥

### 2. 实现认证

为管理后台添加认证逻辑：

```javascript
// 简单的 Basic Auth 示例
function requireAuth(request) {
  const authorization = request.headers.get('Authorization');
  if (!authorization) {
    return new Response('需要认证', {
      status: 401,
      headers: {
        'WWW-Authenticate': 'Basic realm="Admin Area"',
      },
    });
  }
  
  const [username, password] = atob(authorization.split(' ')[1]).split(':');
  
  // 验证用户名和密码
  if (username === 'admin' && password === 'your-secure-password') {
    return null; // 认证成功
  }
  
  return new Response('认证失败', { status: 401 });
}
```

### 3. 启用 HTTPS

Cloudflare Workers 默认使用 HTTPS，但确保你的自定义域名也配置了 SSL。

### 4. 防止 SQL 注入

代码中已经使用了参数化查询，这可以防止 SQL 注入。

### 5. 内容安全策略

添加 CSP 头：

```javascript
headers.set('Content-Security-Policy', "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';");
```

## 迁移现有 WordPress 站点

### 1. 导出现有数据

在现有 WordPress 站点上：
1. 使用 phpMyAdmin 导出数据库
2. 下载 `wp-content/uploads` 目录

### 2. 转换数据库

由于 D1 使用 SQLite，你需要转换 MySQL 数据：

```bash
# 使用工具转换 MySQL 到 SQLite
# 例如：mysql2sqlite
mysql2sqlite wordpress.sql | sqlite3 wordpress.db
```

### 3. 导入数据到 D1

```bash
wrangler d1 execute wordpress-db --file=wordpress-sqlite.sql
```

### 4. 上传媒体文件到 R2

```bash
# 批量上传
for file in wp-content/uploads/**/*; do
  wrangler r2 object put wordpress-media/${file#wp-content/uploads/} --file=$file
done
```

## 故障排查

### 问题：Worker 响应 500 错误

**解决方案**：
1. 查看日志：`wrangler tail`
2. 检查数据库连接
3. 验证环境变量

### 问题：数据库查询超时

**解决方案**：
1. 优化查询
2. 添加索引
3. 减少查询复杂度

### 问题：图片无法加载

**解决方案**：
1. 检查 R2 绑定配置
2. 验证文件路径
3. 检查 CORS 设置

### 问题：缓存未生效

**解决方案**：
1. 检查 Cache API 使用
2. 验证缓存键
3. 检查 Cache-Control 头

## 成本估算

### 免费层级（适合个人博客）
- Workers: 10万次请求/天
- D1: 500万次读取/天，10万次写入/天
- R2: 10GB 存储
- KV: 10万次读取/天，1000次写入/天

**预计流量**：
- 日访问量 < 10,000
- 月流量 < 300,000
- **成本**: $0/月

### 小型网站
- Workers Paid: $5/月
  - 1000万次请求/月
- D1: 按使用量计费
- R2: $0.015/GB/月

**预计流量**：
- 日访问量 10,000 - 100,000
- 月流量 300,000 - 3,000,000
- **成本**: $5-15/月

### 中型网站
- Workers Paid: $5/月 + 超额费用
- D1: 按使用量计费
- R2: 按存储和请求计费

**预计流量**：
- 日访问量 > 100,000
- 月流量 > 3,000,000
- **成本**: $20-50/月

## 下一步

1. **自定义主题**：创建自己的 WordPress 主题
2. **添加功能**：实现评论、搜索、RSS 等
3. **性能优化**：使用 Cloudflare Analytics 分析性能
4. **SEO 优化**：添加 meta 标签、sitemap 等
5. **集成 CMS**：考虑使用 Headless CMS 方案

## 参考资源

- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [D1 数据库文档](https://developers.cloudflare.com/d1/)
- [R2 存储文档](https://developers.cloudflare.com/r2/)
- [WordPress 开发者文档](https://developer.wordpress.org/)

## 社区和支持

- [Cloudflare 社区论坛](https://community.cloudflare.com/)
- [Cloudflare Discord](https://discord.gg/cloudflaredev)
- [WordPress 支持论坛](https://wordpress.org/support/)

祝你部署成功！🎉

