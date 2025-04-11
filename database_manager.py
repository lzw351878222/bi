import pymysql
from typing import List, Dict, Any, Union
from datetime import datetime
import logging
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

class DatabaseConnection:
    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = int(os.getenv('DB_PORT', 3306))
        self.user = os.getenv('DB_USER', 'root')
        self.password = os.getenv('DB_PASSWORD', 'root')
        self.database = os.getenv('DB_NAME', 'bi')
        self.connection = None
        self.cursor = None
        
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

    def execute_query(self, sql: str, params: tuple = None) -> List[Dict[str, Any]]:
        """
        执行查询SQL
        :param sql: SQL语句
        :param params: SQL参数
        :return: 查询结果列表
        """
        try:
            if not self.connection or self.connection.open == False:
                self.connect()
            
            self.cursor.execute(sql, params)
            results = self.cursor.fetchall()
            return results
        except Exception as e:
            logging.error(f"查询执行失败: {str(e)}")
            return []

    def execute_update(self, sql: str, params: tuple = None) -> bool:
        """
        执行更新SQL（INSERT, UPDATE, DELETE）
        :param sql: SQL语句
        :param params: SQL参数
        :return: 是否执行成功
        """
        try:
            if not self.connection or self.connection.open == False:
                self.connect()
            
            self.cursor.execute(sql, params)
            self.connection.commit()
            return True
        except Exception as e:
            self.connection.rollback()
            logging.error(f"更新执行失败: {str(e)}")
            return False

    def query_orders_by_customer(self, customer_id: int) -> List[Dict[str, Any]]:
        """查询指定客户的订单"""
        sql = """
        SELECT 
            o.order_id,
            o.order_code,
            c.customer_name,
            o.order_date,
            o.total_amount,
            o.actual_amount,
            o.payment_status,
            o.delivery_status
        FROM sales_order o
        JOIN customer c ON o.customer_id = c.customer_id
        WHERE o.customer_id = %s
        ORDER BY o.order_date DESC
        """
        return self.execute_query(sql, (customer_id,))

    def query_department_employees(self, dept_id: int) -> List[Dict[str, Any]]:
        """查询部门员工"""
        sql = """
        SELECT 
            e.emp_id,
            e.emp_code,
            e.emp_name,
            e.position,
            e.mobile,
            e.email,
            e.entry_date
        FROM employee e
        WHERE e.dept_id = %s
        ORDER BY e.emp_code
        """
        return self.execute_query(sql, (dept_id,))

    def query_product_sales(self, start_date: str, end_date: str) -> List[Dict[str, Any]]:
        """查询产品销售统计"""
        sql = """
        SELECT 
            p.product_code,
            p.product_name,
            COUNT(DISTINCT o.order_id) as order_count,
            SUM(d.quantity) as total_quantity,
            SUM(d.amount) as total_amount,
            SUM(d.gross_profit) as total_profit
        FROM sales_order_detail d
        JOIN product p ON d.product_id = p.product_id
        JOIN sales_order o ON d.order_id = o.order_id
        WHERE o.order_date BETWEEN %s AND %s
        GROUP BY p.product_id, p.product_code, p.product_name
        ORDER BY total_amount DESC
        """
        return self.execute_query(sql, (start_date, end_date))

    def query_payment_status(self, order_id: int) -> List[Dict[str, Any]]:
        """查询订单付款状态"""
        sql = """
        SELECT 
            p.payment_id,
            p.payment_code,
            p.payment_date,
            p.payment_amount,
            p.payment_method,
            p.payment_status
        FROM payment_record p
        WHERE p.order_id = %s
        ORDER BY p.payment_date
        """
        return self.execute_query(sql, (order_id,))

    def query_department_performance(self, start_date: str, end_date: str) -> List[Dict[str, Any]]:
        """查询部门业绩"""
        sql = """
        SELECT 
            d.dept_name,
            COUNT(DISTINCT o.order_id) as order_count,
            SUM(o.actual_amount) as total_sales,
            SUM(od.gross_profit) as total_profit
        FROM department d
        JOIN employee e ON d.dept_id = e.dept_id
        JOIN sales_order o ON e.emp_id = o.emp_id
        JOIN sales_order_detail od ON o.order_id = od.order_id
        WHERE o.order_date BETWEEN %s AND %s
        GROUP BY d.dept_id, d.dept_name
        ORDER BY total_sales DESC
        """
        return self.execute_query(sql, (start_date, end_date)) 