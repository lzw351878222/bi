import pymysql
from typing import List, Dict, Any, Union
import logging
import os
from dotenv import load_dotenv
import json
from datetime import datetime, date
import re

# 加载环境变量
load_dotenv()

class SQLExecutor:
    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = int(os.getenv('DB_PORT', 3306))
        self.user = os.getenv('DB_USER', 'root')
        self.password = os.getenv('DB_PASSWORD', 'root')
        self.database = os.getenv('DB_NAME', 'bi')
        self.connection = None
        self.cursor = None
        self.setup_logging()

    def setup_logging(self):
        """配置日志"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('sql_executor.log'),
                logging.StreamHandler()
            ]
        )

    def connect(self):
        """建立数据库连接"""
        try:
            self.connection = pymysql.connect(
                host=self.host,
                port=self.port,
                user=self.user,
                password=self.password,
                database=self.database,
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor
            )
            self.cursor = self.connection.cursor()
            logging.info("数据库连接成功")
            return True
        except Exception as e:
            logging.error(f"数据库连接失败: {str(e)}")
            return False

    def disconnect(self):
        """关闭数据库连接"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        logging.info("数据库连接已关闭")

    def validate_sql(self, sql: str) -> bool:
        """
        验证SQL语句的安全性
        :param sql: SQL语句
        :return: 是否安全
        """
        # 转换为小写以便检查
        sql_lower = sql.lower()
        
        # 检查是否包含危险操作
        dangerous_operations = [
            'drop', 'truncate', 'delete', 'update', 'insert', 
            'create', 'alter', 'rename', 'replace'
        ]
        
        for op in dangerous_operations:
            if op in sql_lower:
                logging.warning(f"SQL语句包含危险操作: {op}")
                return False
        
        # 检查是否是SELECT语句
        if not sql_lower.strip().startswith('select'):
            logging.warning("只允许执行SELECT语句")
            return False
        
        return True

    def format_value(self, value: Any) -> str:
        """
        格式化值以便JSON序列化
        :param value: 任意值
        :return: 格式化后的字符串
        """
        if isinstance(value, (datetime, date)):
            return value.isoformat()
        return str(value)

    def execute_query(self, sql: str, params: tuple = None) -> Dict[str, Any]:
        """
        执行查询SQL并返回结果
        :param sql: SQL语句
        :param params: SQL参数
        :return: 查询结果和元数据
        """
        result = {
            'success': False,
            'data': None,
            'columns': None,
            'error': None,
            'execution_time': 0,
            'row_count': 0
        }

        try:
            # 验证SQL
            if not self.validate_sql(sql):
                result['error'] = "SQL语句不安全或不被允许"
                return result

            # 确保连接
            if not self.connection or self.connection.open == False:
                self.connect()

            # 记录开始时间
            start_time = datetime.now()

            # 执行查询
            self.cursor.execute(sql, params)
            data = self.cursor.fetchall()

            # 获取列信息
            columns = [desc[0] for desc in self.cursor.description]

            # 格式化数据
            formatted_data = []
            for row in data:
                formatted_row = {}
                for key, value in row.items():
                    formatted_row[key] = self.format_value(value)
                formatted_data.append(formatted_row)

            # 计算执行时间
            execution_time = (datetime.now() - start_time).total_seconds()

            result.update({
                'success': True,
                'data': formatted_data,
                'columns': columns,
                'execution_time': execution_time,
                'row_count': len(data)
            })

            logging.info(f"查询执行成功, 返回 {len(data)} 条记录, 耗时 {execution_time:.3f} 秒")

        except Exception as e:
            error_msg = str(e)
            logging.error(f"查询执行失败: {error_msg}")
            result['error'] = error_msg

        return result

    def get_table_schema(self) -> Dict[str, Any]:
        """
        获取数据库表结构信息
        :return: 表结构信息
        """
        result = {
            'success': False,
            'tables': {},
            'error': None
        }

        try:
            if not self.connection or self.connection.open == False:
                self.connect()

            # 获取所有表名
            self.cursor.execute("""
                SELECT 
                    table_name, 
                    table_comment
                FROM information_schema.tables 
                WHERE table_schema = %s
            """, (self.database,))
            tables = self.cursor.fetchall()

            for table in tables:
                table_name = table['table_name']
                
                # 获取表字段信息
                self.cursor.execute("""
                    SELECT 
                        column_name,
                        column_type,
                        is_nullable,
                        column_key,
                        column_default,
                        column_comment
                    FROM information_schema.columns 
                    WHERE table_schema = %s AND table_name = %s
                    ORDER BY ordinal_position
                """, (self.database, table_name))
                
                columns = self.cursor.fetchall()
                
                result['tables'][table_name] = {
                    'comment': table['table_comment'],
                    'columns': columns
                }

            result['success'] = True
            logging.info(f"成功获取数据库表结构信息, 共 {len(tables)} 张表")

        except Exception as e:
            error_msg = str(e)
            logging.error(f"获取表结构失败: {error_msg}")
            result['error'] = error_msg

        return result

def main():
    """主函数，用于测试"""
    executor = SQLExecutor()
    
    try:
        # 测试连接
        if executor.connect():
            # 测试查询
            test_sql = """
            SELECT 
                d.dept_name,
                COUNT(e.emp_id) as employee_count
            FROM department d
            LEFT JOIN employee e ON d.dept_id = e.dept_id
            GROUP BY d.dept_id, d.dept_name
            LIMIT 5
            """
            
            result = executor.execute_query(test_sql)
            print("\n查询结果:")
            print(json.dumps(result, ensure_ascii=False, indent=2))

            # 获取表结构
            schema = executor.get_table_schema()
            print("\n表结构信息:")
            print(json.dumps(schema, ensure_ascii=False, indent=2))

    except Exception as e:
        logging.error(f"程序执行出错: {str(e)}")
    finally:
        executor.disconnect()

if __name__ == "__main__":
    main() 