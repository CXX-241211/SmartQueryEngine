# main.py
import typer
from app.db.init import init_db

cli = typer.Typer()


# P1：基础布局
@cli.command()
def init():
    """初始化数据库"""
    init_db()

# P2：实现sql校验以及检索
from app.core.sql_checker import check_sql
from app.core.visualizer import run_query, explain_query

@cli.command(name="check-sql")
def check_sql_cmd(query: str):
    """检查 SQL 语法并给出提示"""
    result = check_sql(query)
    print(result["message"])
    if not result["success"]:
        print("💡 建议：", result["hint"])

@cli.command()
def run_sql(query: str, explain: bool = False):
    """执行 SQL 查询并可视化结果"""
    if explain:
        plan = explain_query(query)
        print("📊 查询计划：")
        print(plan)
    print("📋 查询结果：")
    print(run_query(query))


# P3：实现自然语言转sql
import asyncio
from app.core.ai import nl_to_sql

@cli.command(name="nl-query")
def nl_query(query: str, execute: bool = True):
    """自然语言查询转 SQL，可选择执行"""
    sql = asyncio.run(nl_to_sql(query))
    print("🤖 转换后的 SQL：\n", sql)
    if execute:
        from app.core.visualizer import run_query
        print("📋 执行结果：")
        print(run_query(sql))

# P4：fastapi接口以及接口文档生成
@cli.command(name="run-api")
def run_api(host: str = "127.0.0.1", port: int = 8000):
    """运行 FastAPI 服务"""
    import uvicorn
    uvicorn.run("app.api:app", host=host, port=port, reload=True)


if __name__ == "__main__":
    cli()



