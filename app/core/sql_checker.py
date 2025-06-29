import psycopg2
import requests
import os
from app.core.config import get_db_connection

def check_sql(query: str) -> dict:
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(f"EXPLAIN {query}")
        cur.fetchall()
        cur.close()
        conn.close()
        return {"success": True, "message": "✅ SQL 语法正确"}
    except psycopg2.Error as e:
        raw_error = e.pgerror.strip() if e.pgerror else str(e)
        ai_hint = generate_ai_fix_suggestion(query, raw_error)
        return {
            "success": False,
            "message": f"❌ SQL 语法错误：{raw_error}",
            "hint": ai_hint or "请检查字段名/表名是否拼写正确，或尝试在子句间添加空格。"
        }

def generate_ai_fix_suggestion(query: str, error_msg: str) -> str:
    api_key = os.getenv("AI_API_KEY")
    base_url = os.getenv("AI_API_BASE", "https://api.zhizengzeng.com/v1")

    if not api_key:
        return "⚠️ 未设置 AI_API_KEY，无法生成智能建议。"

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    messages = [
        {"role": "system", "content": "你是一个数据库专家，善于帮用户修复 SQL 语法错误。请分析错误并给出修改建议。"},
        {"role": "user", "content": f"以下 SQL 有语法错误，请指出原因并给出修复建议：\n\nSQL:\n{query}\n\n错误信息:\n{error_msg}"}
    ]

    payload = {
        "model": "gpt-3.5-turbo",  # 或根据设置自动切换
        "messages": messages,
        "temperature": 0.3
    }

    try:
        response = requests.post(f"{base_url}/chat/completions", headers=headers, json=payload, timeout=10)
        result = response.json()
        if "choices" in result and len(result["choices"]) > 0:
            return result["choices"][0]["message"]["content"].strip()
        else:
            return "AI 没有返回有效建议。"
    except Exception as e:
        return f"⚠️ AI 建议生成失败：{str(e)}"
