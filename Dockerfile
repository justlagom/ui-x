# 建议使用 Alpine 基础镜像，体积更小
FROM alpine:latest

# 安装必要的工具，如 net-tools
RUN apk update && apk add --no-cache net-tools curl

# 设定 X-UI 程序的安装路径
WORKDIR /usr/local/x-ui

# 核心步骤：将本地仓库根目录下的 X-UI 可执行文件及其他必要文件复制到镜像中
# 假设你的可执行文件名为 'x-ui'
COPY x-ui .
# 复制其他可能的配置文件或依赖文件（如果存在）
# COPY config.json . 

# 赋予可执行权限
RUN chmod +x x-ui

# 设置数据库文件路径，方便外部挂载实现数据持久化
ENV XUI_DB_FILE="/etc/x-ui/x-ui.db"
RUN mkdir -p /etc/x-ui

# X-UI 面板默认端口
EXPOSE 2053

# 容器启动时运行 X-UI
ENTRYPOINT ["/usr/local/x-ui/x-ui"]
CMD ["start"]
