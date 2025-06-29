# app/api.py
from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import Optional
import asyncio

from app.core.visualizer import run_query
from app.core.sql_checker import check_sql
from app.core.ai import nl_to_sql, get_schema_info
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Smart Query Engine API", version="0.1")

# 可选：允许跨域（如果你有网页测试工具）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class NLQuery(BaseModel):
    query: str
    execute: bool = True

@app.get("/query")
def query_sql(sql: str, explain: bool = False):
    """执行 SQL 查询"""
    check = check_sql(sql)
    if not check["success"]:
        return {
            "success": False,
            "error": check["message"],
            "hint": check["hint"]
        }

    result = run_query(sql)
    if explain:
        from app.core.visualizer import explain_query
        plan = explain_query(sql)
        return {"success": True, "result": result, "explain": plan}
    return {"success": True, "result": result}

@app.post("/nl-query")
async def nl_query_api(nl: NLQuery):
    sql = await nl_to_sql(nl.query)
    output = {"sql": sql}
    if nl.execute:
        output["result"] = run_query(sql)
    return output

@app.get("/schema")
def get_schema():
    return {"schema": get_schema_info()}

@app.get("/")
def home():
    return {"message": "欢迎使用 SmartQueryEngine API，请访问 /docs 查看接口文档"}
