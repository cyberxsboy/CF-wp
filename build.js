/**
 * 构建脚本
 * 用于准备 WordPress 文件用于 Workers 部署
 */

const fs = require('fs');
const path = require('path');

console.log('开始构建 WordPress on Cloudflare Workers...');

// 创建必要的目录
const dirs = ['dist', 'dist/static'];

dirs.forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`✓ 创建目录: ${dir}`);
  }
});

console.log('✓ 构建完成！');
console.log('\n下一步:');
console.log('1. 运行 npm run db:create 创建 D1 数据库');
console.log('2. 运行 npm run db:init 初始化数据库');
console.log('3. 运行 npm run r2:create 创建 R2 存储桶');
console.log('4. 运行 npm run kv:create 创建 KV 命名空间');
console.log('5. 更新 wrangler.toml 中的数据库 ID 和 KV 命名空间 ID');
console.log('6. 运行 npm run deploy 部署到 Cloudflare Workers');

