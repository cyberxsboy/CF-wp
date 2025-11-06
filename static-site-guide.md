# 使用 Cloudflare Pages 部署静态 WordPress 站点

这是一个更简单的方案，适合不需要频繁更新内容的博客或网站。

## 方案概述

1. 在本地或服务器运行 WordPress
2. 使用插件将 WordPress 转换为静态网站
3. 将静态文件部署到 Cloudflare Pages

## 方法 1: 使用 Simply Static 插件

### 步骤 1: 安装 WordPress

在本地使用 Local by Flywheel、XAMPP 或 Docker 安装 WordPress。

### 步骤 2: 安装 Simply Static 插件

1. 登录 WordPress 管理后台
2. 进入 "插件" > "安装插件"
3. 搜索 "Simply Static"
4. 安装并启用

### 步骤 3: 配置 Simply Static

1. 进入 "Simply Static" > "Settings"
2. 配置以下选项：
   - **Delivery Method**: Local Directory
   - **Local Directory**: 选择输出目录（如 `/static-output`）
   - **URLs**: 配置你的网站 URL

### 步骤 4: 生成静态文件

1. 进入 "Simply Static" > "Generate"
2. 点击 "Generate Static Files"
3. 等待生成完成

### 步骤 5: 部署到 Cloudflare Pages

```bash
# 安装 Wrangler
npm install -g wrangler

# 登录
wrangler login

# 部署
wrangler pages deploy ./static-output --project-name=my-wordpress-blog
```

## 方法 2: 使用 WP2Static 插件

WP2Static 是另一个流行的静态化插件，功能更强大。

### 安装和配置

1. 安装 WP2Static 插件
2. 进入 "WP2Static" > "Settings"
3. 配置输出选项
4. 点击 "Start Export"

### 直接部署到 Cloudflare Pages

WP2Static 支持直接部署到多个平台，包括：
- Cloudflare Pages
- Netlify
- GitHub Pages
- AWS S3

配置 Cloudflare Pages 部署：
1. 在 WP2Static 设置中选择 "Add-ons"
2. 安装 "Cloudflare Pages" 插件
3. 配置 API 令牌
4. 一键部署

## 方法 3: 使用 Gatsby + WordPress

这是一个现代化的 Headless CMS 方案。

### 架构
- **WordPress**: 作为后端 CMS（使用 WPGraphQL 插件）
- **Gatsby**: 静态站点生成器
- **Cloudflare Pages**: 托管平台

### 步骤 1: 设置 WordPress

```bash
# 在 WordPress 中安装插件
# WPGraphQL
# WPGatsby
```

### 步骤 2: 创建 Gatsby 项目

```bash
npm install -g gatsby-cli
gatsby new my-wordpress-blog https://github.com/gatsbyjs/gatsby-starter-wordpress-blog
cd my-wordpress-blog
```

### 步骤 3: 配置 Gatsby

编辑 `gatsby-config.js`:

```javascript
module.exports = {
  plugins: [
    {
      resolve: 'gatsby-source-wordpress',
      options: {
        url: 'https://your-wordpress-site.com/graphql',
      },
    },
  ],
}
```

### 步骤 4: 构建静态站点

```bash
gatsby build
```

### 步骤 5: 部署到 Cloudflare Pages

```bash
wrangler pages deploy ./public --project-name=gatsby-wordpress-blog
```

## 方法 4: 使用 Next.js + WordPress

### 架构
- **WordPress**: 后端 CMS（REST API 或 GraphQL）
- **Next.js**: 前端框架（支持 SSG 和 ISR）
- **Cloudflare Pages**: 托管平台

### 步骤 1: 创建 Next.js 项目

```bash
npx create-next-app@latest my-wordpress-blog
cd my-wordpress-blog
```

### 步骤 2: 安装依赖

```bash
npm install axios
# 或者使用 WPGraphQL
npm install graphql graphql-request
```

### 步骤 3: 获取 WordPress 数据

创建 `lib/wordpress.js`:

```javascript
const API_URL = 'https://your-wordpress-site.com/wp-json/wp/v2';

export async function getAllPosts() {
  const res = await fetch(`${API_URL}/posts?_embed`);
  const posts = await res.json();
  return posts;
}

export async function getPostBySlug(slug) {
  const posts = await fetch(`${API_URL}/posts?slug=${slug}&_embed`);
  const post = await posts.json();
  return post[0];
}
```

### 步骤 4: 创建页面

`pages/index.js`:

```javascript
import { getAllPosts } from '../lib/wordpress';

export default function Home({ posts }) {
  return (
    <div>
      <h1>我的博客</h1>
      {posts.map(post => (
        <article key={post.id}>
          <h2>{post.title.rendered}</h2>
          <div dangerouslySetInnerHTML={{ __html: post.excerpt.rendered }} />
        </article>
      ))}
    </div>
  );
}

export async function getStaticProps() {
  const posts = await getAllPosts();
  return {
    props: { posts },
    revalidate: 60, // ISR: 每 60 秒重新生成
  };
}
```

### 步骤 5: 配置 Cloudflare Pages

创建 `package.json` 脚本:

```json
{
  "scripts": {
    "build": "next build",
    "export": "next export"
  }
}
```

### 步骤 6: 部署

使用 Git 集成自动部署：

1. 将代码推送到 GitHub
2. 登录 Cloudflare Dashboard
3. 进入 "Workers & Pages"
4. 点击 "Create application" > "Pages"
5. 连接 GitHub 仓库
6. 配置构建设置：
   - **Build command**: `npm run build && npm run export`
   - **Build output directory**: `out`
7. 点击 "Save and Deploy"

## 自动化更新

### 使用 Webhooks

当 WordPress 内容更新时，自动触发重新部署。

#### 在 WordPress 中设置 Webhook

安装插件 "WP Webhooks" 或在 `functions.php` 中添加:

```php
add_action('save_post', function($post_id) {
  if (wp_is_post_revision($post_id)) return;
  
  // 触发 Cloudflare Pages 部署
  $webhook_url = 'https://api.cloudflare.com/client/v4/pages/webhooks/deploy_hooks/YOUR_HOOK_ID';
  
  wp_remote_post($webhook_url, array(
    'method' => 'POST',
  ));
});
```

#### 创建 Cloudflare Pages Deploy Hook

1. 在 Cloudflare Pages 项目设置中
2. 进入 "Build & deployments"
3. 创建 Deploy Hook
4. 复制 URL 并在 WordPress 中使用

### 使用 GitHub Actions

创建 `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Cloudflare Pages

on:
  schedule:
    - cron: '0 */6 * * *' # 每 6 小时运行一次
  workflow_dispatch: # 手动触发

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
        env:
          WORDPRESS_API_URL: ${{ secrets.WORDPRESS_API_URL }}
      
      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: my-wordpress-blog
          directory: out
```

## 性能优化

### 1. 图片优化

使用 Cloudflare Images 或 next/image:

```javascript
import Image from 'next/image';

<Image
  src="/wp-content/uploads/image.jpg"
  alt="描述"
  width={800}
  height={600}
  loading="lazy"
/>
```

### 2. CDN 缓存

Cloudflare Pages 自动提供全球 CDN。

### 3. 资源压缩

确保启用 Brotli 和 Gzip 压缩。

### 4. 预渲染

使用 Next.js 的 ISR（Incremental Static Regeneration）：

```javascript
export async function getStaticProps() {
  const posts = await getAllPosts();
  return {
    props: { posts },
    revalidate: 3600, // 每小时重新生成
  };
}
```

## 比较不同方案

| 方案 | 优点 | 缺点 | 适合场景 |
|------|------|------|----------|
| Simply Static | 简单易用 | 功能有限 | 小型博客 |
| WP2Static | 功能丰富 | 配置复杂 | 中型网站 |
| Gatsby | 性能优秀 | 构建时间长 | 内容丰富的博客 |
| Next.js | 灵活强大 | 需要开发知识 | 定制化网站 |
| Workers (完整) | 动态功能 | 兼容性问题 | 需要动态功能 |

## 推荐方案

### 个人博客（不常更新）
→ **Simply Static + Cloudflare Pages**

### 专业博客（频繁更新）
→ **Next.js + WordPress REST API + Cloudflare Pages**

### 企业网站（复杂功能）
→ **Gatsby + WordPress GraphQL + Cloudflare Pages**

### 需要动态功能
→ **WordPress on Workers (完整方案)**

## 总结

静态化 WordPress 是一个成熟的解决方案，提供了：
- ✅ 极高的性能
- ✅ 更好的安全性
- ✅ 更低的成本
- ✅ 全球 CDN 加速

唯一的缺点是需要重新生成静态文件来更新内容，但这可以通过 Webhooks 自动化。

选择最适合你需求的方案，开始构建你的 WordPress 站点吧！

