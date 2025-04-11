-- =============================================
-- 企业经营数据分析系统 - 数据库设计文档
-- 版本: 1.0.0
-- 日期: 2024-03-20
-- =============================================

-- -----------------------------
-- 一、表结构说明
-- -----------------------------

/*
1. department (部门表)
   - 存储企业组织架构信息
   - 支持多级部门结构
   - 包含部门基本信息

2. employee (员工表)
   - 存储员工基本信息
   - 关联部门信息
   - 包含联系方式等基础数据

3. customer (客户表)
   - 存储客户信息
   - 包含客户类型、联系方式等
   - 记录信用额度等业务数据

4. product_category (产品类别表)
   - 产品分类信息
   - 支持多级分类
   - 包含排序等展示信息

5. product (产品表)
   - 产品基本信息
   - 关联产品类别
   - 包含价格等业务数据

6. sales_order (订单主表)
   - 订单基本信息
   - 关联客户、部门、员工
   - 记录订单状态和金额信息

7. sales_order_detail (订单明细表)
   - 订单商品明细
   - 关联产品信息
   - 记录数量、金额等

8. payment_record (回款记录表)
   - 订单回款信息
   - 关联订单和客户
   - 记录回款金额和状态

9. cost_center (成本中心表)
   - 成本中心基本信息
   - 关联部门
   - 记录预算等信息

10. financial_period (财务账期表)
    - 财务结算期间定义
    - 记录结算状态
*/

-- -----------------------------
-- 二、建表语句 (DDL)
-- -----------------------------

-- 创建数据库
CREATE DATABASE IF NOT EXISTS bi_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE bi_db;

-- 部门表
CREATE TABLE department (
    dept_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '部门ID',
    parent_dept_id BIGINT COMMENT '父部门ID',
    dept_name VARCHAR(50) NOT NULL COMMENT '部门名称',
    dept_code VARCHAR(20) NOT NULL COMMENT '部门编码',
    leader_id BIGINT COMMENT '部门负责人ID',
    dept_level INT NOT NULL COMMENT '部门层级',
    sort_order INT DEFAULT 0 COMMENT '排序号',
    status TINYINT DEFAULT 1 COMMENT '状态(1:正常,0:停用)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    UNIQUE KEY uk_dept_code (dept_code),
    INDEX idx_parent_id (parent_dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- 员工表
CREATE TABLE employee (
    emp_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID',
    emp_code VARCHAR(20) NOT NULL COMMENT '员工工号',
    emp_name VARCHAR(50) NOT NULL COMMENT '员工姓名',
    dept_id BIGINT NOT NULL COMMENT '所属部门ID',
    position VARCHAR(50) COMMENT '职位',
    mobile VARCHAR(20) COMMENT '手机号',
    email VARCHAR(50) COMMENT '邮箱',
    entry_date DATE COMMENT '入职日期',
    status TINYINT DEFAULT 1 COMMENT '状态(1:在职,0:离职)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_emp_code (emp_code),
    INDEX idx_dept_id (dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

-- 客户表
CREATE TABLE customer (
    customer_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '客户ID',
    customer_code VARCHAR(20) NOT NULL COMMENT '客户编码',
    customer_name VARCHAR(100) NOT NULL COMMENT '客户名称',
    customer_type TINYINT COMMENT '客户类型(1:企业,2:个人)',
    contact_name VARCHAR(50) COMMENT '联系人',
    contact_mobile VARCHAR(20) COMMENT '联系电话',
    address VARCHAR(200) COMMENT '地址',
    credit_limit DECIMAL(20,2) DEFAULT 0 COMMENT '信用额度',
    status TINYINT DEFAULT 1 COMMENT '状态(1:正常,0:停用)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_customer_code (customer_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';

-- 产品类别表
CREATE TABLE product_category (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '类别ID',
    parent_id BIGINT COMMENT '父类别ID',
    category_name VARCHAR(50) NOT NULL COMMENT '类别名称',
    category_code VARCHAR(20) NOT NULL COMMENT '类别编码',
    sort_order INT DEFAULT 0 COMMENT '排序号',
    status TINYINT DEFAULT 1 COMMENT '状态(1:正常,0:停用)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_category_code (category_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品类别表';

-- 产品表
CREATE TABLE product (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '产品ID',
    product_code VARCHAR(20) NOT NULL COMMENT '产品编码',
    product_name VARCHAR(100) NOT NULL COMMENT '产品名称',
    category_id BIGINT COMMENT '产品类别ID',
    unit VARCHAR(10) COMMENT '单位',
    standard_price DECIMAL(20,2) COMMENT '标准售价',
    cost_price DECIMAL(20,2) COMMENT '成本价',
    status TINYINT DEFAULT 1 COMMENT '状态(1:正常,0:停用)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_product_code (product_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品表';

-- 订单主表
CREATE TABLE sales_order (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    order_code VARCHAR(30) NOT NULL COMMENT '订单编号',
    customer_id BIGINT NOT NULL COMMENT '客户ID',
    order_date DATE NOT NULL COMMENT '订单日期',
    dept_id BIGINT NOT NULL COMMENT '销售部门ID',
    emp_id BIGINT NOT NULL COMMENT '销售员ID',
    total_amount DECIMAL(20,2) DEFAULT 0 COMMENT '订单总金额',
    discount_amount DECIMAL(20,2) DEFAULT 0 COMMENT '优惠金额',
    actual_amount DECIMAL(20,2) DEFAULT 0 COMMENT '实际金额',
    payment_status TINYINT DEFAULT 0 COMMENT '付款状态(0:未付款,1:部分付款,2:已付款)',
    delivery_status TINYINT DEFAULT 0 COMMENT '发货状态(0:未发货,1:部分发货,2:已发货)',
    order_status TINYINT DEFAULT 0 COMMENT '订单状态(0:待审核,1:已审核,2:已取消)',
    remark VARCHAR(500) COMMENT '备注',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    UNIQUE KEY uk_order_code (order_code),
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- 订单明细表
CREATE TABLE sales_order_detail (
    detail_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '明细ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    product_id BIGINT NOT NULL COMMENT '产品ID',
    quantity DECIMAL(20,2) NOT NULL COMMENT '数量',
    unit_price DECIMAL(20,2) NOT NULL COMMENT '单价',
    amount DECIMAL(20,2) NOT NULL COMMENT '金额',
    cost_price DECIMAL(20,2) COMMENT '成本价',
    gross_profit DECIMAL(20,2) COMMENT '毛利',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 回款记录表
CREATE TABLE payment_record (
    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '回款ID',
    payment_code VARCHAR(30) NOT NULL COMMENT '回款编号',
    customer_id BIGINT NOT NULL COMMENT '客户ID',
    order_id BIGINT COMMENT '关联订单ID',
    payment_date DATE NOT NULL COMMENT '回款日期',
    payment_amount DECIMAL(20,2) NOT NULL COMMENT '回款金额',
    payment_method TINYINT COMMENT '付款方式(1:现金,2:银行转账,3:支票)',
    payment_status TINYINT DEFAULT 0 COMMENT '状态(0:待确认,1:已确认)',
    remark VARCHAR(500) COMMENT '备注',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    updated_by BIGINT COMMENT '更新人',
    UNIQUE KEY uk_payment_code (payment_code),
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='回款记录表';

-- 成本中心表
CREATE TABLE cost_center (
    cost_center_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成本中心ID',
    cost_center_code VARCHAR(20) NOT NULL COMMENT '成本中心编码',
    cost_center_name VARCHAR(50) NOT NULL COMMENT '成本中心名称',
    dept_id BIGINT COMMENT '关联部门ID',
    budget_amount DECIMAL(20,2) DEFAULT 0 COMMENT '预算金额',
    status TINYINT DEFAULT 1 COMMENT '状态(1:正常,0:停用)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_cost_center_code (cost_center_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成本中心表';

-- 财务账期表
CREATE TABLE financial_period (
    period_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '账期ID',
    period_year INT NOT NULL COMMENT '年度',
    period_month INT NOT NULL COMMENT '月份',
    status TINYINT DEFAULT 0 COMMENT '状态(0:未结算,1:已结算)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_year_month (period_year, period_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='财务账期表';

-- -----------------------------
-- 三、示例查询SQL
-- -----------------------------

-- 1. 组织架构维度查询

-- 1.1 查询部门树结构
WITH RECURSIVE dept_tree AS (
    -- 查询顶级部门
    SELECT 
        dept_id,
        parent_dept_id,
        dept_name,
        dept_code,
        dept_level,
        CAST(dept_name AS CHAR(1000)) AS dept_path
    FROM department
    WHERE parent_dept_id IS NULL
    
    UNION ALL
    
    -- 递归查询子部门
    SELECT 
        d.dept_id,
        d.parent_dept_id,
        d.dept_name,
        d.dept_code,
        d.dept_level,
        CONCAT(dt.dept_path, ' > ', d.dept_name)
    FROM department d
    JOIN dept_tree dt ON d.parent_dept_id = dt.dept_id
)
SELECT * FROM dept_tree ORDER BY dept_path;

-- 1.2 查询各部门人数统计
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as employee_count,
    SUM(CASE WHEN e.status = 1 THEN 1 ELSE 0 END) as active_employee_count
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- 2. 销售维度查询

-- 2.1 按月统计销售业绩
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(o.total_amount) as total_amount,
    SUM(o.actual_amount) as actual_amount,
    SUM(od.gross_profit) as total_profit
FROM sales_order o
JOIN sales_order_detail od ON o.order_id = od.order_id
WHERE o.order_status = 1
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month DESC;

-- 2.2 销售员业绩排名
SELECT 
    e.emp_name,
    d.dept_name,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(o.actual_amount) as total_sales,
    SUM(od.gross_profit) as total_profit,
    ROUND(SUM(od.gross_profit) / SUM(o.actual_amount) * 100, 2) as profit_rate
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
JOIN sales_order o ON e.emp_id = o.emp_id
JOIN sales_order_detail od ON o.order_id = od.order_id
WHERE o.order_status = 1
GROUP BY e.emp_id, e.emp_name, d.dept_name
ORDER BY total_sales DESC;

-- 3. 产品维度查询

-- 3.1 产品销售排行
SELECT 
    p.product_code,
    p.product_name,
    pc.category_name,
    COUNT(DISTINCT od.order_id) as order_count,
    SUM(od.quantity) as total_quantity,
    SUM(od.amount) as total_amount,
    SUM(od.gross_profit) as total_profit,
    ROUND(SUM(od.gross_profit) / SUM(od.amount) * 100, 2) as profit_rate
FROM product p
JOIN product_category pc ON p.category_id = pc.category_id
JOIN sales_order_detail od ON p.product_id = od.product_id
JOIN sales_order o ON od.order_id = o.order_id
WHERE o.order_status = 1
GROUP BY p.product_id, p.product_code, p.product_name, pc.category_name
ORDER BY total_amount DESC;

-- 3.2 产品类别销售分析
SELECT 
    pc.category_name,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT od.order_id) as order_count,
    SUM(od.quantity) as total_quantity,
    SUM(od.amount) as total_amount,
    SUM(od.gross_profit) as total_profit
FROM product_category pc
LEFT JOIN product p ON pc.category_id = p.category_id
LEFT JOIN sales_order_detail od ON p.product_id = od.product_id
LEFT JOIN sales_order o ON od.order_id = o.order_id AND o.order_status = 1
GROUP BY pc.category_id, pc.category_name
ORDER BY total_amount DESC;

-- 4. 客户维度查询

-- 4.1 客户消费排行
SELECT 
    c.customer_code,
    c.customer_name,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(o.total_amount) as total_amount,
    SUM(o.actual_amount) as actual_amount,
    MAX(o.order_date) as last_order_date,
    SUM(p.payment_amount) as total_payment
FROM customer c
LEFT JOIN sales_order o ON c.customer_id = o.customer_id AND o.order_status = 1
LEFT JOIN payment_record p ON c.customer_id = p.customer_id AND p.payment_status = 1
GROUP BY c.customer_id, c.customer_code, c.customer_name
ORDER BY total_amount DESC;

-- 4.2 客户回款分析
SELECT 
    c.customer_name,
    SUM(o.actual_amount) as total_order_amount,
    SUM(p.payment_amount) as total_payment_amount,
    SUM(o.actual_amount) - SUM(IFNULL(p.payment_amount, 0)) as unpaid_amount,
    ROUND(SUM(IFNULL(p.payment_amount, 0)) / SUM(o.actual_amount) * 100, 2) as payment_rate
FROM customer c
JOIN sales_order o ON c.customer_id = o.customer_id AND o.order_status = 1
LEFT JOIN payment_record p ON o.order_id = p.order_id AND p.payment_status = 1
GROUP BY c.customer_id, c.customer_name
HAVING unpaid_amount > 0
ORDER BY unpaid_amount DESC;

-- 5. 财务维度查询

-- 5.1 账期销售统计
SELECT 
    fp.period_year,
    fp.period_month,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(o.total_amount) as total_amount,
    SUM(o.actual_amount) as actual_amount,
    SUM(od.gross_profit) as total_profit,
    SUM(p.payment_amount) as total_payment
FROM financial_period fp
LEFT JOIN sales_order o ON fp.period_year = YEAR(o.order_date) 
    AND fp.period_month = MONTH(o.order_date)
    AND o.order_status = 1
LEFT JOIN sales_order_detail od ON o.order_id = od.order_id
LEFT JOIN payment_record p ON o.order_id = p.order_id AND p.payment_status = 1
GROUP BY fp.period_year, fp.period_month
ORDER BY fp.period_year DESC, fp.period_month DESC;

-- 5.2 成本中心分析
SELECT 
    cc.cost_center_name,
    cc.budget_amount,
    SUM(o.actual_amount) as actual_amount,
    SUM(od.gross_profit) as total_profit,
    ROUND((SUM(o.actual_amount) / cc.budget_amount) * 100, 2) as budget_usage_rate
FROM cost_center cc
JOIN department d ON cc.dept_id = d.dept_id
JOIN sales_order o ON d.dept_id = o.dept_id AND o.order_status = 1
JOIN sales_order_detail od ON o.order_id = od.order_id
GROUP BY cc.cost_center_id, cc.cost_center_name, cc.budget_amount
ORDER BY budget_usage_rate DESC;

-- 6. 时间维度查询

-- 6.1 按季度统计销售趋势
SELECT 
    YEAR(o.order_date) as sales_year,
    QUARTER(o.order_date) as sales_quarter,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(o.total_amount) as total_amount,
    SUM(o.actual_amount) as actual_amount,
    SUM(od.gross_profit) as total_profit,
    ROUND(SUM(od.gross_profit) / SUM(o.actual_amount) * 100, 2) as profit_rate
FROM sales_order o
JOIN sales_order_detail od ON o.order_id = od.order_id
WHERE o.order_status = 1
GROUP BY YEAR(o.order_date), QUARTER(o.order_date)
ORDER BY sales_year DESC, sales_quarter DESC;

-- 6.2 按周统计订单量
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%u') as year_week,
    MIN(o.order_date) as week_start_date,
    MAX(o.order_date) as week_end_date,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(o.actual_amount) as total_amount
FROM sales_order o
WHERE o.order_status = 1
GROUP BY DATE_FORMAT(o.order_date, '%Y-%u')
ORDER BY year_week DESC;

-- 7. 地域维度查询（假设从客户地址提取地域信息）

-- 7.1 按省份统计销售情况
SELECT 
    SUBSTRING_INDEX(c.address, '省', 1) as province,
    COUNT(DISTINCT c.customer_id) as customer_count,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(o.actual_amount) as total_amount,
    SUM(od.gross_profit) as total_profit
FROM customer c
JOIN sales_order o ON c.customer_id = o.customer_id
JOIN sales_order_detail od ON o.order_id = od.order_id
WHERE o.order_status = 1
GROUP BY SUBSTRING_INDEX(c.address, '省', 1)
ORDER BY total_amount DESC;

-- 8. 价格区间分析

-- 8.1 产品价格区间分布
SELECT 
    CASE 
        WHEN p.standard_price <= 100 THEN '0-100'
        WHEN p.standard_price <= 500 THEN '101-500'
        WHEN p.standard_price <= 1000 THEN '501-1000'
        WHEN p.standard_price <= 5000 THEN '1001-5000'
        ELSE '5000以上'
    END as price_range,
    COUNT(p.product_id) as product_count,
    ROUND(AVG(p.standard_price), 2) as avg_price,
    SUM(od.quantity) as total_sales_quantity,
    SUM(od.amount) as total_sales_amount
FROM product p
LEFT JOIN sales_order_detail od ON p.product_id = od.product_id
LEFT JOIN sales_order o ON od.order_id = o.order_id AND o.order_status = 1
GROUP BY CASE 
    WHEN p.standard_price <= 100 THEN '0-100'
    WHEN p.standard_price <= 500 THEN '101-500'
    WHEN p.standard_price <= 1000 THEN '501-1000'
    WHEN p.standard_price <= 5000 THEN '1001-5000'
    ELSE '5000以上'
END
ORDER BY MIN(p.standard_price);

-- 9. 客户行为分析

-- 9.1 客户购买频率分析
WITH customer_purchase_freq AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COUNT(DISTINCT o.order_id) as order_count,
        MIN(o.order_date) as first_order_date,
        MAX(o.order_date) as last_order_date,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) as date_diff
    FROM customer c
    JOIN sales_order o ON c.customer_id = o.customer_id
    WHERE o.order_status = 1
    GROUP BY c.customer_id, c.customer_name
    HAVING order_count > 1
)
SELECT 
    customer_name,
    order_count,
    first_order_date,
    last_order_date,
    date_diff as days_between_orders,
    ROUND(date_diff / (order_count - 1), 2) as avg_days_between_orders
FROM customer_purchase_freq
ORDER BY avg_days_between_orders;

-- 9.2 客户流失预警
SELECT 
    c.customer_name,
    MAX(o.order_date) as last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(o.order_date)) as days_since_last_order,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.actual_amount) as total_amount
FROM customer c
JOIN sales_order o ON c.customer_id = o.customer_id
WHERE o.order_status = 1
GROUP BY c.customer_id, c.customer_name
HAVING days_since_last_order > 90
ORDER BY days_since_last_order DESC;

-- 10. 产品组合分析

-- 10.1 产品搭配分析
SELECT 
    p1.product_name as product1,
    p2.product_name as product2,
    COUNT(DISTINCT od1.order_id) as combination_count
FROM sales_order_detail od1
JOIN sales_order_detail od2 ON od1.order_id = od2.order_id AND od1.product_id < od2.product_id
JOIN product p1 ON od1.product_id = p1.product_id
JOIN product p2 ON od2.product_id = p2.product_id
JOIN sales_order o ON od1.order_id = o.order_id
WHERE o.order_status = 1
GROUP BY p1.product_id, p2.product_id, p1.product_name, p2.product_name
HAVING combination_count > 1
ORDER BY combination_count DESC;

-- 11. 销售效率分析

-- 11.1 订单转化率
SELECT 
    e.emp_name,
    d.dept_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(CASE WHEN o.order_status = 1 THEN 1 ELSE 0 END) as successful_orders,
    ROUND(SUM(CASE WHEN o.order_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id), 2) as conversion_rate,
    ROUND(AVG(CASE WHEN o.order_status = 1 THEN o.actual_amount ELSE 0 END), 2) as avg_order_amount
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
JOIN sales_order o ON e.emp_id = o.emp_id
GROUP BY e.emp_id, e.emp_name, d.dept_name
ORDER BY conversion_rate DESC;

-- 12. 回款效率分析

-- 12.1 回款周期分析
SELECT 
    c.customer_name,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(AVG(DATEDIFF(p.payment_date, o.order_date)), 2) as avg_payment_days,
    MIN(DATEDIFF(p.payment_date, o.order_date)) as min_payment_days,
    MAX(DATEDIFF(p.payment_date, o.order_date)) as max_payment_days
FROM customer c
JOIN sales_order o ON c.customer_id = o.customer_id
JOIN payment_record p ON o.order_id = p.order_id
WHERE o.order_status = 1 AND p.payment_status = 1
GROUP BY c.customer_id, c.customer_name
HAVING order_count > 1
ORDER BY avg_payment_days;

-- 13. 产品生命周期分析

-- 13.1 产品销售趋势
SELECT 
    p.product_name,
    DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(od.quantity) as total_quantity,
    SUM(od.amount) as total_amount,
    ROUND(AVG(od.unit_price), 2) as avg_price
FROM product p
JOIN sales_order_detail od ON p.product_id = od.product_id
JOIN sales_order o ON od.order_id = o.order_id
WHERE o.order_status = 1
GROUP BY p.product_id, p.product_name, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY p.product_id, sales_month;

-- 14. 利润分析

-- 14.1 产品毛利率排行
SELECT 
    p.product_name,
    pc.category_name,
    SUM(od.quantity) as total_quantity,
    SUM(od.amount) as total_sales,
    SUM(od.gross_profit) as total_profit,
    ROUND(SUM(od.gross_profit) * 100.0 / SUM(od.amount), 2) as profit_rate,
    ROUND(AVG(od.unit_price), 2) as avg_selling_price,
    ROUND(AVG(od.cost_price), 2) as avg_cost_price
FROM product p
JOIN product_category pc ON p.category_id = pc.category_id
JOIN sales_order_detail od ON p.product_id = od.product_id
JOIN sales_order o ON od.order_id = o.order_id
WHERE o.order_status = 1
GROUP BY p.product_id, p.product_name, pc.category_name
HAVING total_quantity > 0
ORDER BY profit_rate DESC;

-- 15. 综合分析

-- 15.1 部门-产品-客户交叉分析
SELECT 
    d.dept_name,
    pc.category_name,
    COUNT(DISTINCT o.customer_id) as customer_count,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(od.quantity) as total_quantity,
    SUM(od.amount) as total_amount,
    SUM(od.gross_profit) as total_profit,
    ROUND(SUM(od.gross_profit) * 100.0 / SUM(od.amount), 2) as profit_rate
FROM department d
JOIN sales_order o ON d.dept_id = o.dept_id
JOIN sales_order_detail od ON o.order_id = od.order_id
JOIN product p ON od.product_id = p.product_id
JOIN product_category pc ON p.category_id = pc.category_id
WHERE o.order_status = 1
GROUP BY d.dept_id, d.dept_name, pc.category_id, pc.category_name
ORDER BY d.dept_name, total_amount DESC; 