from flask import Flask, request, jsonify
from sql_executor import SQLExecutor
import logging
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # 启用CORS支持

# 创建SQL执行器实例
sql_executor = SQLExecutor()

@app.route('/api/query', methods=['POST'])
def execute_query():
    """
    执行SQL查询API
    请求体格式：
    {
        "sql": "SELECT * FROM table_name",
        "params": [] (可选)
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'sql' not in data:
            return jsonify({
                'success': False,
                'error': '缺少SQL语句'
            }), 400

        sql = data['sql']
        params = data.get('params')

        # 执行查询
        result = sql_executor.execute_query(sql, params)
        
        return jsonify(result)

    except Exception as e:
        logging.error(f"API执行错误: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/schema', methods=['GET'])
def get_schema():
    """获取数据库表结构信息"""
    try:
        result = sql_executor.get_table_schema()
        return jsonify(result)
    except Exception as e:
        logging.error(f"获取表结构错误: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """健康检查接口"""
    try:
        if sql_executor.connect():
            return jsonify({
                'success': True,
                'message': '服务正常运行'
            })
        else:
            return jsonify({
                'success': False,
                'message': '数据库连接失败'
            }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    # 配置日志
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    
    # 启动服务器
    app.run(host='0.0.0.0', port=5000, debug=True) 