# 使用轻量级 Alpine 基础镜像
FROM alpine:latest

# 定义目标架构参数，由 GitHub Actions 传入
ARG TARGETARCH

# 安装必要的工具，bash是必须的，因为它更可靠
RUN apk update && apk add --no-cache net-tools curl bash

# 设定 X-UI 程序的安装路径
WORKDIR /usr/local/x-ui

# 1. 复制所有文件到工作目录
COPY . .

# 🚨 诊断步骤：打印当前工作目录的文件列表和架构
# 请在 GitHub Actions 日志中查看这几行的输出！
RUN echo "--- DIAGNOSTIC START ---" && \
    echo "Current Working Directory Files (ls -l):" && \
    ls -l && \
    echo "Target Architecture received: $TARGETARCH" && \
    echo "--- DIAGNOSTIC END ---" && \
    # 核心修正：根据 TARGETARCH 变量，选择并重命名正确的二进制文件为 'x-ui'
    if [ "$TARGETARCH" = "amd64" ]; then \
        echo "Attempting to rename xuiwpph_amd64 to x-ui..."; \
        mv xuiwpph_amd64 x-ui; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "Attempting to rename xuiwpph_arm64 to x-ui..."; \
        mv xuiwpph_arm64 x-ui; \
    else \
        echo "Error: Unsupported architecture or missing binary. TARGETARCH=$TARGETARCH"; exit 1; \
    fi

# 3. 赋予可执行权限
RUN chmod +x x-ui

# Setup for persistence
ENV XUI_DB_FILE="/etc/x-ui/x-ui.db"
RUN mkdir -p /etc/x-ui

EXPOSE 54321

ENTRYPOINT ["/usr/local/x-ui/x-ui"]
CMD ["start"]
