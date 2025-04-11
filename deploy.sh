#!/bin/bash

# 确保脚本在错误时退出
set -e

echo "开始部署SQL查询API服务..."

# 1. 安装Docker（如果未安装）
if ! command -v docker &> /dev/null; then
    echo "正在安装Docker..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# 2. 安装Docker Compose（如果未安装）
if ! command -v docker-compose &> /dev/null; then
    echo "正在安装Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 3. 创建必要的目录
echo "创建项目目录..."
mkdir -p logs

# 4. 设置环境变量
echo "配置环境变量..."
if [ ! -f .env ]; then
    echo "创建.env文件..."
    cat > .env << EOF
DB_HOST=your_db_host
DB_PORT=3306
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=bi
EOF
    echo "请编辑.env文件，配置正确的数据库连接信息"
    exit 1
fi

# 5. 构建和启动容器
echo "构建和启动Docker容器..."
sudo docker-compose build
sudo docker-compose up -d

# 6. 检查服务状态
echo "检查服务状态..."
sleep 5
if curl -s http://localhost/health | grep -q "success"; then
    echo "服务已成功启动!"
    echo "API服务地址: http://localhost"
    echo "健康检查地址: http://localhost/health"
else
    echo "服务可能未正常启动，请检查日志:"
    sudo docker-compose logs
fi

# 显示一些有用的命令
echo "
常用命令:
- 查看日志: sudo docker-compose logs -f
- 重启服务: sudo docker-compose restart
- 停止服务: sudo docker-compose down
- 启动服务: sudo docker-compose up -d
" 