# app/db/init.py
import psycopg2
from app.core.config import get_db_connection


def init_db():
    conn = get_db_connection()
    cur = conn.cursor()

    # 指定 encoding 解决 UnicodeDecodeError
    with open("app/db/models.sql", "r", encoding="utf-8") as f:
        sql = f.read()
        cur.execute(sql)

    conn.commit()
    cur.close()
    conn.close()
    print("✅ 数据库初始化完成")
