#!/bin/bash

# 激活虚拟环境（如果有的话）
# source venv/bin/activate

# 设置环境变量
export FLASK_APP=api_server.py
export FLASK_ENV=production

# 使用gunicorn启动应用
gunicorn --bind 0.0.0.0:5000 wsgi:app --workers 4 --timeout 120 