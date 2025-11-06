-- WordPress 数据库架构（简化版）
-- 适用于 Cloudflare D1 (SQLite)

-- 文章表
CREATE TABLE IF NOT EXISTS wp_posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_author INTEGER NOT NULL DEFAULT 0,
  post_date TEXT NOT NULL DEFAULT '',
  post_date_gmt TEXT NOT NULL DEFAULT '',
  post_content TEXT NOT NULL,
  post_title TEXT NOT NULL,
  post_excerpt TEXT NOT NULL,
  post_status VARCHAR(20) NOT NULL DEFAULT 'publish',
  comment_status VARCHAR(20) NOT NULL DEFAULT 'open',
  ping_status VARCHAR(20) NOT NULL DEFAULT 'open',
  post_password VARCHAR(255) NOT NULL DEFAULT '',
  post_name VARCHAR(200) NOT NULL DEFAULT '',
  to_ping TEXT NOT NULL,
  pinged TEXT NOT NULL,
  post_modified TEXT NOT NULL DEFAULT '',
  post_modified_gmt TEXT NOT NULL DEFAULT '',
  post_content_filtered TEXT NOT NULL,
  post_parent INTEGER NOT NULL DEFAULT 0,
  guid VARCHAR(255) NOT NULL DEFAULT '',
  menu_order INTEGER NOT NULL DEFAULT 0,
  post_type VARCHAR(20) NOT NULL DEFAULT 'post',
  post_mime_type VARCHAR(100) NOT NULL DEFAULT '',
  comment_count INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_post_name ON wp_posts(post_name);
CREATE INDEX idx_post_type_status_date ON wp_posts(post_type, post_status, post_date, id);
CREATE INDEX idx_post_parent ON wp_posts(post_parent);
CREATE INDEX idx_post_author ON wp_posts(post_author);

-- 用户表
CREATE TABLE IF NOT EXISTS wp_users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_login VARCHAR(60) NOT NULL DEFAULT '',
  user_pass VARCHAR(255) NOT NULL DEFAULT '',
  user_nicename VARCHAR(50) NOT NULL DEFAULT '',
  user_email VARCHAR(100) NOT NULL DEFAULT '',
  user_url VARCHAR(100) NOT NULL DEFAULT '',
  user_registered TEXT NOT NULL DEFAULT '',
  user_activation_key VARCHAR(255) NOT NULL DEFAULT '',
  user_status INTEGER NOT NULL DEFAULT 0,
  display_name VARCHAR(250) NOT NULL DEFAULT ''
);

CREATE INDEX idx_user_login_key ON wp_users(user_login);
CREATE INDEX idx_user_nicename ON wp_users(user_nicename);
CREATE INDEX idx_user_email ON wp_users(user_email);

-- 评论表
CREATE TABLE IF NOT EXISTS wp_comments (
  comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
  comment_post_id INTEGER NOT NULL DEFAULT 0,
  comment_author TEXT NOT NULL,
  comment_author_email VARCHAR(100) NOT NULL DEFAULT '',
  comment_author_url VARCHAR(200) NOT NULL DEFAULT '',
  comment_author_ip VARCHAR(100) NOT NULL DEFAULT '',
  comment_date TEXT NOT NULL DEFAULT '',
  comment_date_gmt TEXT NOT NULL DEFAULT '',
  comment_content TEXT NOT NULL,
  comment_karma INTEGER NOT NULL DEFAULT 0,
  comment_approved VARCHAR(20) NOT NULL DEFAULT '1',
  comment_agent VARCHAR(255) NOT NULL DEFAULT '',
  comment_type VARCHAR(20) NOT NULL DEFAULT 'comment',
  comment_parent INTEGER NOT NULL DEFAULT 0,
  user_id INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_comment_post_id ON wp_comments(comment_post_id);
CREATE INDEX idx_comment_approved_date_gmt ON wp_comments(comment_approved, comment_date_gmt);
CREATE INDEX idx_comment_date_gmt ON wp_comments(comment_date_gmt);
CREATE INDEX idx_comment_parent ON wp_comments(comment_parent);
CREATE INDEX idx_comment_author_email ON wp_comments(comment_author_email);

-- 分类和标签表（术语表）
CREATE TABLE IF NOT EXISTS wp_terms (
  term_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(200) NOT NULL DEFAULT '',
  slug VARCHAR(200) NOT NULL DEFAULT '',
  term_group INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_term_slug ON wp_terms(slug);
CREATE INDEX idx_term_name ON wp_terms(name);

-- 术语分类表
CREATE TABLE IF NOT EXISTS wp_term_taxonomy (
  term_taxonomy_id INTEGER PRIMARY KEY AUTOINCREMENT,
  term_id INTEGER NOT NULL DEFAULT 0,
  taxonomy VARCHAR(32) NOT NULL DEFAULT '',
  description TEXT NOT NULL,
  parent INTEGER NOT NULL DEFAULT 0,
  count INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_taxonomy ON wp_term_taxonomy(taxonomy);
CREATE INDEX idx_term_id_taxonomy ON wp_term_taxonomy(term_id, taxonomy);

-- 文章与术语关系表
CREATE TABLE IF NOT EXISTS wp_term_relationships (
  object_id INTEGER NOT NULL DEFAULT 0,
  term_taxonomy_id INTEGER NOT NULL DEFAULT 0,
  term_order INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (object_id, term_taxonomy_id)
);

CREATE INDEX idx_term_taxonomy_id ON wp_term_relationships(term_taxonomy_id);

-- 选项表（配置）
CREATE TABLE IF NOT EXISTS wp_options (
  option_id INTEGER PRIMARY KEY AUTOINCREMENT,
  option_name VARCHAR(191) NOT NULL DEFAULT '',
  option_value TEXT NOT NULL,
  autoload VARCHAR(20) NOT NULL DEFAULT 'yes'
);

CREATE UNIQUE INDEX idx_option_name ON wp_options(option_name);
CREATE INDEX idx_autoload ON wp_options(autoload);

-- 元数据表
CREATE TABLE IF NOT EXISTS wp_postmeta (
  meta_id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER NOT NULL DEFAULT 0,
  meta_key VARCHAR(255) DEFAULT NULL,
  meta_value TEXT
);

CREATE INDEX idx_post_id ON wp_postmeta(post_id);
CREATE INDEX idx_meta_key ON wp_postmeta(meta_key);

-- 用户元数据表
CREATE TABLE IF NOT EXISTS wp_usermeta (
  umeta_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL DEFAULT 0,
  meta_key VARCHAR(255) DEFAULT NULL,
  meta_value TEXT
);

CREATE INDEX idx_user_id ON wp_usermeta(user_id);
CREATE INDEX idx_meta_key ON wp_usermeta(meta_key);

-- 插入默认数据

-- 默认选项
INSERT INTO wp_options (option_name, option_value, autoload) VALUES
('siteurl', 'https://yourdomain.com', 'yes'),
('home', 'https://yourdomain.com', 'yes'),
('blogname', 'My WordPress Blog', 'yes'),
('blogdescription', 'Powered by Cloudflare Workers', 'yes'),
('users_can_register', '0', 'yes'),
('admin_email', 'admin@yourdomain.com', 'yes'),
('start_of_week', '1', 'yes'),
('use_balanceTags', '0', 'yes'),
('use_smilies', '1', 'yes'),
('require_name_email', '1', 'yes'),
('comments_notify', '1', 'yes'),
('posts_per_rss', '10', 'yes'),
('rss_use_excerpt', '0', 'yes'),
('mailserver_url', 'mail.example.com', 'yes'),
('mailserver_login', 'login@example.com', 'yes'),
('mailserver_pass', 'password', 'yes'),
('mailserver_port', '110', 'yes'),
('default_category', '1', 'yes'),
('default_comment_status', 'open', 'yes'),
('default_ping_status', 'open', 'yes'),
('default_pingback_flag', '0', 'yes'),
('posts_per_page', '10', 'yes'),
('date_format', 'Y-m-d', 'yes'),
('time_format', 'H:i', 'yes'),
('links_updated_date_format', 'Y-m-d H:i', 'yes'),
('comment_moderation', '0', 'yes'),
('moderation_notify', '1', 'yes'),
('permalink_structure', '/%year%/%monthnum%/%day%/%postname%/', 'yes'),
('rewrite_rules', '', 'yes'),
('hack_file', '0', 'yes'),
('blog_charset', 'UTF-8', 'yes'),
('moderation_keys', '', 'no'),
('active_plugins', 'a:0:{}', 'yes'),
('category_base', '', 'yes'),
('ping_sites', 'http://rpc.pingomatic.com/', 'yes'),
('comment_max_links', '2', 'yes'),
('gmt_offset', '0', 'yes'),
('default_email_category', '1', 'yes'),
('recently_edited', '', 'no'),
('template', 'twentytwentyfour', 'yes'),
('stylesheet', 'twentytwentyfour', 'yes'),
('comment_registration', '0', 'yes'),
('html_type', 'text/html', 'yes'),
('use_trackback', '0', 'yes'),
('default_role', 'subscriber', 'yes'),
('db_version', '55853', 'yes'),
('uploads_use_yearmonth_folders', '1', 'yes'),
('upload_path', '', 'yes'),
('blog_public', '1', 'yes'),
('default_link_category', '2', 'yes'),
('show_on_front', 'posts', 'yes'),
('tag_base', '', 'yes'),
('show_avatars', '1', 'yes'),
('avatar_rating', 'G', 'yes'),
('upload_url_path', '', 'yes'),
('thumbnail_size_w', '150', 'yes'),
('thumbnail_size_h', '150', 'yes'),
('thumbnail_crop', '1', 'yes'),
('medium_size_w', '300', 'yes'),
('medium_size_h', '300', 'yes'),
('avatar_default', 'mystery', 'yes'),
('large_size_w', '1024', 'yes'),
('large_size_h', '1024', 'yes'),
('image_default_link_type', 'none', 'yes'),
('image_default_size', '', 'yes'),
('image_default_align', '', 'yes'),
('close_comments_for_old_posts', '0', 'yes'),
('close_comments_days_old', '14', 'yes'),
('thread_comments', '1', 'yes'),
('thread_comments_depth', '5', 'yes'),
('page_comments', '0', 'yes'),
('comments_per_page', '50', 'yes'),
('default_comments_page', 'newest', 'yes'),
('comment_order', 'asc', 'yes'),
('sticky_posts', 'a:0:{}', 'yes'),
('widget_categories', 'a:0:{}', 'yes'),
('widget_text', 'a:0:{}', 'yes'),
('widget_rss', 'a:0:{}', 'yes'),
('uninstall_plugins', 'a:0:{}', 'no'),
('timezone_string', 'Asia/Shanghai', 'yes'),
('page_for_posts', '0', 'yes'),
('page_on_front', '0', 'yes'),
('default_post_format', '0', 'yes'),
('link_manager_enabled', '0', 'yes'),
('finished_splitting_shared_terms', '1', 'yes'),
('site_icon', '0', 'yes'),
('medium_large_size_w', '768', 'yes'),
('medium_large_size_h', '0', 'yes'),
('wp_page_for_privacy_policy', '0', 'yes'),
('show_comments_cookies_opt_in', '1', 'yes'),
('admin_email_lifespan', '1640000000', 'yes'),
('disallowed_keys', '', 'no'),
('comment_previously_approved', '1', 'yes'),
('auto_plugin_theme_update_emails', 'a:0:{}', 'no'),
('auto_update_core_dev', 'enabled', 'yes'),
('auto_update_core_minor', 'enabled', 'yes'),
('auto_update_core_major', 'enabled', 'yes'),
('wp_force_deactivated_plugins', 'a:0:{}', 'yes'),
('initial_db_version', '55853', 'yes'),
('wp_user_roles', 'a:5:{s:13:"administrator";a:2:{s:4:"name";s:13:"Administrator";s:12:"capabilities";a:61:{s:13:"switch_themes";b:1;s:11:"edit_themes";b:1;s:16:"activate_plugins";b:1;s:12:"edit_plugins";b:1;s:10:"edit_users";b:1;s:10:"edit_files";b:1;s:14:"manage_options";b:1;s:17:"moderate_comments";b:1;s:17:"manage_categories";b:1;s:12:"manage_links";b:1;s:12:"upload_files";b:1;s:6:"import";b:1;s:15:"unfiltered_html";b:1;s:10:"edit_posts";b:1;s:17:"edit_others_posts";b:1;s:20:"edit_published_posts";b:1;s:13:"publish_posts";b:1;s:10:"edit_pages";b:1;s:4:"read";b:1;s:8:"level_10";b:1;s:7:"level_9";b:1;s:7:"level_8";b:1;s:7:"level_7";b:1;s:7:"level_6";b:1;s:7:"level_5";b:1;s:7:"level_4";b:1;s:7:"level_3";b:1;s:7:"level_2";b:1;s:7:"level_1";b:1;s:7:"level_0";b:1;s:17:"edit_others_pages";b:1;s:20:"edit_published_pages";b:1;s:13:"publish_pages";b:1;s:12:"delete_pages";b:1;s:19:"delete_others_pages";b:1;s:22:"delete_published_pages";b:1;s:12:"delete_posts";b:1;s:19:"delete_others_posts";b:1;s:22:"delete_published_posts";b:1;s:20:"delete_private_posts";b:1;s:18:"edit_private_posts";b:1;s:18:"read_private_posts";b:1;s:20:"delete_private_pages";b:1;s:18:"edit_private_pages";b:1;s:18:"read_private_pages";b:1;s:12:"delete_users";b:1;s:12:"create_users";b:1;s:17:"unfiltered_upload";b:1;s:14:"edit_dashboard";b:1;s:14:"update_plugins";b:1;s:14:"delete_plugins";b:1;s:15:"install_plugins";b:1;s:13:"update_themes";b:1;s:14:"install_themes";b:1;s:11:"update_core";b:1;s:10:"list_users";b:1;s:12:"remove_users";b:1;s:13:"promote_users";b:1;s:18:"edit_theme_options";b:1;s:13:"delete_themes";b:1;s:6:"export";b:1;}}s:6:"editor";a:2:{s:4:"name";s:6:"Editor";s:12:"capabilities";a:34:{s:17:"moderate_comments";b:1;s:17:"manage_categories";b:1;s:12:"manage_links";b:1;s:12:"upload_files";b:1;s:15:"unfiltered_html";b:1;s:10:"edit_posts";b:1;s:17:"edit_others_posts";b:1;s:20:"edit_published_posts";b:1;s:13:"publish_posts";b:1;s:10:"edit_pages";b:1;s:4:"read";b:1;s:7:"level_7";b:1;s:7:"level_6";b:1;s:7:"level_5";b:1;s:7:"level_4";b:1;s:7:"level_3";b:1;s:7:"level_2";b:1;s:7:"level_1";b:1;s:7:"level_0";b:1;s:17:"edit_others_pages";b:1;s:20:"edit_published_pages";b:1;s:13:"publish_pages";b:1;s:12:"delete_pages";b:1;s:19:"delete_others_pages";b:1;s:22:"delete_published_pages";b:1;s:12:"delete_posts";b:1;s:19:"delete_others_posts";b:1;s:22:"delete_published_posts";b:1;s:20:"delete_private_posts";b:1;s:18:"edit_private_posts";b:1;s:18:"read_private_posts";b:1;s:20:"delete_private_pages";b:1;s:18:"edit_private_pages";b:1;s:18:"read_private_pages";b:1;}}s:6:"author";a:2:{s:4:"name";s:6:"Author";s:12:"capabilities";a:10:{s:12:"upload_files";b:1;s:10:"edit_posts";b:1;s:20:"edit_published_posts";b:1;s:13:"publish_posts";b:1;s:4:"read";b:1;s:7:"level_2";b:1;s:7:"level_1";b:1;s:7:"level_0";b:1;s:12:"delete_posts";b:1;s:22:"delete_published_posts";b:1;}}s:11:"contributor";a:2:{s:4:"name";s:11:"Contributor";s:12:"capabilities";a:5:{s:10:"edit_posts";b:1;s:4:"read";b:1;s:7:"level_1";b:1;s:7:"level_0";b:1;s:12:"delete_posts";b:1;}}s:10:"subscriber";a:2:{s:4:"name";s:10:"Subscriber";s:12:"capabilities";a:2:{s:4:"read";b:1;s:7:"level_0";b:1;}}}', 'yes'),
('fresh_site', '0', 'yes'),
('WPLANG', 'zh_CN', 'yes'),
('new_admin_email', 'admin@yourdomain.com', 'yes');

-- 默认分类
INSERT INTO wp_terms (name, slug, term_group) VALUES
('未分类', 'uncategorized', 0);

INSERT INTO wp_term_taxonomy (term_id, taxonomy, description, parent, count) VALUES
(1, 'category', '', 0, 0);

-- 示例文章
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_name, post_modified, post_modified_gmt, post_type, comment_count) VALUES
(1, datetime('now'), datetime('now'), '<p>欢迎使用在 Cloudflare Workers 上运行的 WordPress！这是一个示例文章。</p><p>这个方案利用了 Cloudflare 的边缘计算能力，提供了高性能、低延迟的全球访问体验。</p><h2>主要特点</h2><ul><li>全球边缘节点部署</li><li>超低延迟访问</li><li>自动扩展</li><li>成本优化</li></ul>', '欢迎使用 WordPress on Cloudflare Workers', '', 'publish', 'open', 'open', 'welcome-to-wordpress-on-cloudflare-workers', datetime('now'), datetime('now'), 'post', 0);

-- 将文章关联到默认分类
INSERT INTO wp_term_relationships (object_id, term_taxonomy_id, term_order) VALUES
(1, 1, 0);

-- 更新分类计数
UPDATE wp_term_taxonomy SET count = 1 WHERE term_taxonomy_id = 1;

