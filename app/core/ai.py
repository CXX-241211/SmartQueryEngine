# app/core/ai.py
import os
import httpx
from app.core.config import get_db_connection

AI_API_BASE = os.getenv("AI_API_BASE")
AI_API_KEY = os.getenv("AI_API_KEY")

def get_schema_info() -> str:
    """提取数据库表结构，供提示语使用"""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT table_name, column_name, data_type 
        FROM information_schema.columns 
        WHERE table_schema = 'public'
        ORDER BY table_name, ordinal_position
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()

    schema = {}
    for table, col, dtype in rows:
        schema.setdefault(table, []).append(f"{col} ({dtype})")

    result = ""
    for table, cols in schema.items():
        result += f"表 {table}:\n" + "\n".join(f"  - {col}" for col in cols) + "\n\n"
    return result.strip()

async def nl_to_sql(nl_query: str) -> str:
    prompt = f"""
你是一个 SQL 助手，数据库结构如下：

{get_schema_info()}

请将用户的自然语言转换为标准 PostgreSQL SQL 查询语句。
仅返回 SQL 本身，不要解释。

用户的问题是：
{nl_query}
    """.strip()

    headers = {"Authorization": f"Bearer {AI_API_KEY}"}
    data = {
        "model": "gpt-3.5-turbo",  # 或你系统支持的模型名
        "messages": [
            {"role": "system", "content": "你是一个 SQL 助手"},
            {"role": "user", "content": prompt}
        ]
    }

    async with httpx.AsyncClient(base_url=AI_API_BASE, headers=headers, timeout=30) as client:
        response = await client.post("/chat/completions", json=data)
        response.raise_for_status()
        reply = response.json()
        sql = reply["choices"][0]["message"]["content"]
        return sql.strip().strip("```sql").strip("```")
