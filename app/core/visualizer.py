# app/core/visualizer.py
import pandas as pd
from tabulate import tabulate
from app.core.config import get_db_connection

def run_query(query: str) -> str:
    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute(query)
        if cur.description:  # 有返回结果
            rows = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            df = pd.DataFrame(rows, columns=columns)
            return tabulate(df, headers='keys', tablefmt='grid', showindex=False)
        else:
            return "✅ 执行成功，无返回结果"
    finally:
        cur.close()
        conn.close()

def explain_query(query: str) -> str:
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(f"EXPLAIN {query}")
        rows = cur.fetchall()
        plan = "\n".join(row[0] for row in rows)
        return plan
    finally:
        cur.close()
        conn.close()
