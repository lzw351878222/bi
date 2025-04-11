import requests
import json

def test_query():
    """测试查询API"""
    # API地址
    url = 'http://localhost:5000/api/query'
    
    # 查询部门树的SQL
    query_data = {
        "sql": """
        SELECT 
            dept_id,
            parent_dept_id,
            dept_name,
            dept_code,
            dept_level,
            CAST(dept_name AS CHAR(1000)) AS dept_path
        FROM department
        WHERE parent_dept_id IS NULL
        """,
        "params": []  # 如果SQL中有参数，在这里提供
    }
    
    try:
        # 发送POST请求
        response = requests.post(
            url,
            json=query_data,  # 使用json参数自动处理JSON序列化
            headers={'Content-Type': 'application/json'}
        )
        
        # 检查响应状态
        if response.status_code == 200:
            result = response.json()
            print("\n=== 查询成功 ===")
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            print(f"\n=== 查询失败: {response.status_code} ===")
            print(response.text)
            
    except Exception as e:
        print(f"请求出错: {str(e)}")

def test_schema():
    """测试获取表结构API"""
    url = 'http://localhost:5000/api/schema'
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            result = response.json()
            print("\n=== 表结构信息 ===")
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            print(f"\n=== 获取表结构失败: {response.status_code} ===")
            print(response.text)
            
    except Exception as e:
        print(f"请求出错: {str(e)}")

def test_health():
    """测试健康检查API"""
    url = 'http://localhost:5000/api/health'
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            result = response.json()
            print("\n=== 健康检查 ===")
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            print(f"\n=== 健康检查失败: {response.status_code} ===")
            print(response.text)
            
    except Exception as e:
        print(f"请求出错: {str(e)}")

if __name__ == "__main__":
    print("开始测试API...")
    
    # 测试健康检查
    test_health()
    
    # 测试查询
    test_query()
    
    # 测试获取表结构
    test_schema() 