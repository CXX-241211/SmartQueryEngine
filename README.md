# 📊 SmartQueryEngine

一个通用的智能 SQL 查询与分析工具，支持命令行和 API 使用，结合自然语言处理技术实现 AI 辅助数据库操作。可适用于智能家居、企业数据分析、教育系统等场景。

---

## 🔧 功能特性

- ✅ 使用 SQL 查询数据库
- ✅ 自然语言自动转 SQL（支持中文/英文）
- ✅ 自动检查 SQL 错误并返回建议
- ✅ 查询结果表格可视化（文本表格，支持图形可选）
- ✅ FastAPI 接口支持系统级调用
- ✅ 可扩展为多种关系模式（非智能家居限定）
- ✅ 支持 CLI / HTTP 双通道使用
- ✅ 可选前端测试界面（`test_ui.html`）

---

## 📁 项目结构

```

SmartQueryEngine/
├── app/
│   ├── api.py             # FastAPI 接口
│   ├── cli.py             # 可选 CLI 拓展入口
│   ├── core/              # 核心逻辑模块
│   │   ├── config.py      # 环境变量加载
│   │   ├── ai.py          # 调用 AI API 转换 NL → SQL
│   │   ├── visualizer.py  # SQL 执行 & 可视化
│   │   ├── sql_checker.py # SQL 检查模块
│   ├── db/
│   │   ├── init.py        # 初始化数据库脚本
│   │   ├── models.sql     # 表结构文件（示例）
├── main.py                # 主 CLI 启动入口
├── requirements.txt       # 依赖清单
├── .env                   # 数据库与 API 配置
├── test\_ui.html           # 简易可视化前端测试页面
└── README.md

````

---

## 🚀 快速开始

### 0. 数据库准备

```
首先你需要有一个数据库，如pg, mysql等等

有时候无法连接需要在services.msc先启动，要注意的是我们采用utf-8

创建一个空数据库
```

### 1. 安装依赖

```bash
pip install -r requirements.txt
````

### 2. 修改 `.env` 配置

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_dbname
DB_USER=your_username
DB_PASSWORD=your_password

AI_API_KEY=your_api_key
AI_API_BASE=https://api.zhizengzeng.com/v1
```

### 3. 初始化数据库

```bash
python main.py init
```

### 4. 执行 SQL 查询（命令行）

```bash
python main.py run-sql "SELECT * FROM users" --explain
```

### 5. 自然语言查询

```bash
python main.py nl-query "列出房屋面积超过 100 的用户"
```

### 6. 启动 API 服务

```bash
python main.py run-api
```

浏览器访问接口咱的文档：

```
先看到【INFO:Application startup complete.】就代表它准备完毕了

👉 http://127.0.0.1:8000/docs
```

---

## 🌐 可用 API 接口

| 方法   | 地址          | 描述             |
| ---- | ----------- | -------------- |
| GET  | `/query`    | 传入 SQL 查询字符串执行 |
| POST | `/nl-query` | 传入自然语言，转换并执行   |
| GET  | `/schema`   | 获取数据库结构（供参考）   |

---

## 💻 前端测试页面

双击打开 `test_ui.html`，可体验自然语言转 SQL 与结果展示。

---

## 🐳 Docker（可选）

### `Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY ../qq /app

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 构建镜像

```bash
docker build -t smart-query-engine .
```

### 运行容器

```bash
docker run -d -p 8000:8000 --env-file .env smart-query-engine
```

---

## 🧪 示例数据库结构（models.sql）

```
在app/db/models.sql 我们设计了一个基于智能家居系统的数据库，并生成了案例数据供测试使用
```

---

## 📎 TODO（可扩展模块）

* 图形结果可视化（matplotlib/plotly）
* 查询缓存与优化建议
* 用户权限与 API key 限制
* 多模态查询（上传 CSV 文件进行分析）

---

## 📃 许可证

MIT License

---

### 最后，这是我们的开发流程：


🚀 第一阶段：项目初始化

* 📁 **项目结构设计**（CLI + API）
* 📦 **初始化依赖管理**（`requirements.txt` / `poetry` 等）
* ⚙️ **环境配置管理**（`.env`）
* 🧱 **数据库初始化脚本**（自动建库、建表）
* 🧪 **PostgreSQL 连接测试**

---
🚀 第二阶段：SQL 查询 + 错误分析 + 查询结果可视化

| 步骤 | 功能项         | 描述                              |
| - | ----------- | ------------------------------- |
| 1 | SQL 查询执行    | 接收 SQL 字符串并运行                   |
| 2 | 错误处理与用户友好提示 | 捕获 SQL 错误并返回清晰错误 + 修改建议         |
| 3 | 查询结果表格化     | 使用 `pandas + tabulate` 美观输出结果   |
| 4 | 查询流程可视化     | 使用 `EXPLAIN` 文字方式展示执行计划         |
| 5 | CLI 命令支持    | 添加 `run-sql` 与 `check-sql` 两条命令 |

---
🚀 第三阶段：自然语言转 SQL 接口

| 步骤 | 功能项          | 描述                                      |
| - | ------------ | --------------------------------------- |
| 1 | 接入 AI API    | 使用 API：`https://api.zhizengzeng.com/v1` |
| 2 | 构造 Prompt 模板 | 自动提取数据库结构 + 拼接自然语言查询目标                  |
| 3 | 解析 AI 返回结果   | 提取 SQL 并执行                              |
| 4 | CLI 命令支持     | 添加 `nl-query` 命令，支持自然语言查询               |

---
🚀 第四阶段：FastAPI 接口封装

|  步骤 | 接口/功能点              | 描述                               |
| - | ------------------- | -------------------------------- |
| 1 | 启动 FastAPI 服务       | 启动监听 `http://localhost:8000`     |
| 2 | `/query` 接口         | 接收 SQL 查询字符串并执行，返回表格文本结果         |
| 3 | `/nl-query` 接口      | 接收自然语言 → 转换为 SQL → 执行并返回结果       |
| 4 | `/schema` 接口        | 返回当前数据库结构（表名+字段+类型）              |
| 5 | Pydantic 数据模型统一输入输出 | 使用 Pydantic 定义请求体/响应体结构，确保结构清晰可控 |

