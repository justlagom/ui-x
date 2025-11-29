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
# 核心修正：根据 TARGETARCH 变量，选择并重命名正确的二进制文件为 'x-ui'
RUN target_file="" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        target_file="xuiwpph_amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        target_file="xuiwpph_arm64"; \
    else \
        echo "Error: Unsupported architecture $TARGETARCH."; exit 1; \
    fi && \
    \
    echo "Expected executable name: $target_file" && \
    \
    # 检查目标文件是否存在
    if [ ! -f "$target_file" ]; then \
        echo "Error: Required binary '$target_file' not found in the build context. Check spelling (case-sensitive!) and existence in your GitHub repo."; exit 1; \
    fi && \
    \
    # 移动文件
    echo "Attempting to rename $target_file to x-ui..."; \
    mv "$target_file" x-ui

# 3. 赋予可执行权限
RUN chmod +x x-ui

# Setup for persistence
ENV XUI_DB_FILE="/etc/x-ui/x-ui.db"
RUN mkdir -p /etc/x-ui

EXPOSE 54321

ENTRYPOINT ["/usr/local/x-ui/x-ui"]
CMD ["start"]
