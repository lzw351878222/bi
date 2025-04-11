from database_manager import DatabaseConnection
import logging
from datetime import datetime, timedelta

def main():
    # 配置日志
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

    # 创建数据库连接实例
    db = DatabaseConnection()

    try:
        # 测试连接
        if db.connect():
            # 示例1：查询客户订单
            print("\n=== 查询客户订单 ===")
            customer_id = 1
            orders = db.query_orders_by_customer(customer_id)
            for order in orders:
                print(f"订单号: {order['order_code']}, 金额: {order['actual_amount']}")

            # 示例2：查询部门员工
            print("\n=== 查询部门员工 ===")
            dept_id = 5
            employees = db.query_department_employees(dept_id)
            for emp in employees:
                print(f"员工: {emp['emp_name']}, 职位: {emp['position']}")

            # 示例3：查询产品销售统计
            print("\n=== 查询产品销售统计 ===")
            start_date = '2024-01-01'
            end_date = '2024-03-31'
            sales = db.query_product_sales(start_date, end_date)
            for sale in sales:
                print(f"产品: {sale['product_name']}, 销售额: {sale['total_amount']}")

            # 示例4：查询订单付款状态
            print("\n=== 查询订单付款状态 ===")
            order_id = 1
            payments = db.query_payment_status(order_id)
            for payment in payments:
                print(f"付款编号: {payment['payment_code']}, 金额: {payment['payment_amount']}")

            # 示例5：查询部门业绩
            print("\n=== 查询部门业绩 ===")
            performance = db.query_department_performance(start_date, end_date)
            for perf in performance:
                print(f"部门: {perf['dept_name']}, 销售额: {perf['total_sales']}")

    except Exception as e:
        logging.error(f"程序执行出错: {str(e)}")
    finally:
        # 关闭数据库连接
        db.disconnect()

if __name__ == "__main__":
    main() 