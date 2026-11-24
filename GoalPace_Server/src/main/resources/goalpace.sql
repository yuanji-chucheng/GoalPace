-- =============================================================
-- 拾阶 goalpace 数据库初始化脚本 (MySQL 8)
-- 使用方式: mysql -uroot -p < goalpace.sql
-- =============================================================

CREATE DATABASE IF NOT EXISTS goalpace DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE goalpace;

-- 1. 用户表
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号(唯一)',
  nickname VARCHAR(50) NOT NULL COMMENT '昵称',
  password VARCHAR(100) NOT NULL COMMENT 'BCrypt 加密密码',
  avatar VARCHAR(255) DEFAULT NULL COMMENT '头像 URL',
  points INT NOT NULL DEFAULT 0 COMMENT '累计积分',
  level INT NOT NULL DEFAULT 1 COMMENT '台阶等级',
  checkin_days INT NOT NULL DEFAULT 0 COMMENT '连续打卡天数(自然日)',
  create_time DATETIME NOT NULL,
  update_time DATETIME NOT NULL
) COMMENT '用户表';

-- 2. 目标表
CREATE TABLE IF NOT EXISTS goals (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL COMMENT '所属用户',
  title VARCHAR(100) NOT NULL COMMENT '目标标题',
  type VARCHAR(20) NOT NULL DEFAULT '习惯' COMMENT '类型: 长期/短期/习惯',
  category VARCHAR(30) NOT NULL DEFAULT '成长' COMMENT '分类',
  priority TINYINT NOT NULL DEFAULT 2 COMMENT '优先级: 1低/2中/3高',
  start_date DATE NOT NULL COMMENT '开始日期',
  end_date DATE DEFAULT NULL COMMENT '结束日期',
  description VARCHAR(500) DEFAULT NULL COMMENT '目标描述',
  remind_on TINYINT NOT NULL DEFAULT 0 COMMENT '是否开启提醒',
  remind_time VARCHAR(5) DEFAULT '19:00' COMMENT '提醒时间 HH:mm',
  archived TINYINT NOT NULL DEFAULT 0 COMMENT '是否归档',
  progress INT NOT NULL DEFAULT 0 COMMENT '进度 0-100',
  update_time DATETIME NOT NULL,
  KEY idx_goals_user (user_id)
) COMMENT '目标表';

-- 3. 任务表
CREATE TABLE IF NOT EXISTS tasks (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  goal_id BIGINT NOT NULL COMMENT '关联目标',
  title VARCHAR(100) NOT NULL COMMENT '任务标题',
  due_date DATE DEFAULT NULL COMMENT '到期日期',
  due_time VARCHAR(5) DEFAULT NULL COMMENT '到期时间 HH:mm',
  priority TINYINT NOT NULL DEFAULT 2 COMMENT '优先级: 1低/2中/3高',
  note VARCHAR(500) DEFAULT NULL COMMENT '备注',
  remind_on TINYINT NOT NULL DEFAULT 0 COMMENT '是否开启提醒',
  remind_advance INT NOT NULL DEFAULT 30 COMMENT '提前提醒分钟数',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0未完成/1已完成',
  complete_time DATETIME DEFAULT NULL COMMENT '完成时间',
  update_time DATETIME NOT NULL,
  KEY idx_tasks_goal (goal_id),
  KEY idx_tasks_due (due_date)
) COMMENT '任务表';

-- 4. 积分流水表
CREATE TABLE IF NOT EXISTS point_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL COMMENT '所属用户',
  `change` INT NOT NULL COMMENT '积分变动值(可正可负)',
  reason VARCHAR(100) NOT NULL COMMENT '变动原因',
  task_id BIGINT DEFAULT NULL COMMENT '关联任务',
  create_time DATETIME NOT NULL,
  KEY idx_point_logs_user (user_id)
) COMMENT '积分流水表';

-- 5. 复盘笔记表
CREATE TABLE IF NOT EXISTS review_notes (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  goal_id BIGINT NOT NULL COMMENT '关联目标',
  user_id BIGINT NOT NULL COMMENT '所属用户',
  content VARCHAR(2000) NOT NULL COMMENT '笔记内容',
  create_time DATETIME NOT NULL,
  KEY idx_review_goal (goal_id),
  KEY idx_review_user (user_id)
) COMMENT '复盘笔记表';
