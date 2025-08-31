#!/bin/bash

# ==================== 配置参数 ====================
# 修改这些参数来适应您的需求
FORGE_API_KEY="forge-NzYw76092739faaccb69341db4e6b1c44c69"
MODEL_NAME="gpt-4.1"
PROVIDER_NAME="Azure"
API_BASE_URL="https://api.forge.tensorblock.co/v1"
LIMIT=2000
RESULT_FILE="result.csv"
# ================================================

# 设置工作目录为脚本所在目录
cd "$(dirname "$0")"

# 创建结果文件
echo "repo_name,start_time,end_time,total_tokens,total_input_tokens,total_output_tokens,total_cached_tokens,total_duration,total_cost" > "$RESULT_FILE"

# 获取所有目录（排除文件）
for repo_dir in */; do
    # 跳过非目录项
    if [ ! -d "$repo_dir" ]; then
        continue
    fi
    
    # 移除目录名末尾的斜杠
    repo_name="${repo_dir%/}"
    echo "处理仓库: $repo_name"
    
    # 1. cd进repo目录
    cd "$repo_name"
    
    # 2. 记录开始时间
    start_time=$(date -u +"%Y-%m-%dT%H:%M:%S.%6N+00:00")
    echo "开始时间: $start_time"
    
    # 3. 执行codex命令
    echo "执行 codex exec 命令..."
    codex exec -s danger-full-access "Please take a careful look into the current hardware and whole repo, and create a new dockerfile named envgym.dockerfile at the root of this repo that, when built, puts me in a /bin/bash cli setting at the root of the repository, with the repository installed."
    
    # 4. 记录结束时间
    end_time=$(date -u +"%Y-%m-%dT%H:%M:%S.%6N+00:00")
    echo "结束时间: $end_time"
    
    # 5. 获取使用统计
    echo "获取使用统计..."
    response=$(curl -s -X GET "$API_BASE_URL/statistic/usage/realtime" \
        -H "Authorization: Bearer $FORGE_API_KEY" \
        -G \
        --data-urlencode "provider_name=$PROVIDER_NAME" \
        --data-urlencode "model_name=$MODEL_NAME" \
        --data-urlencode "started_at=$start_time" \
        --data-urlencode "ended_at=$end_time" \
        --data-urlencode "limit=$LIMIT")
    
    # 调试：显示 API 响应
    echo "API 响应: $response"
    
    # 6. 计算总和
    echo "计算统计数据..."
    
    # 使用 jq 解析 JSON 并计算总和
    if command -v jq &> /dev/null; then
        # 检查响应是否为空或无效
        if [ -z "$response" ] || [ "$response" = "[]" ]; then
            echo "警告: API 响应为空"
            total_tokens=0
            total_input_tokens=0
            total_output_tokens=0
            total_cached_tokens=0
            total_duration=0
            total_cost=0
        else
            # 使用更安全的 jq 命令
            total_tokens=$(echo "$response" | jq -r '.[] | .tokens // 0' | awk '{sum += $1} END {print sum+0}')
            total_input_tokens=$(echo "$response" | jq -r '.[] | .input_tokens // 0' | awk '{sum += $1} END {print sum+0}')
            total_output_tokens=$(echo "$response" | jq -r '.[] | .output_tokens // 0' | awk '{sum += $1} END {print sum+0}')
            total_cached_tokens=$(echo "$response" | jq -r '.[] | .cached_tokens // 0' | awk '{sum += $1} END {print sum+0}')
            total_duration=$(echo "$response" | jq -r '.[] | .duration // 0' | awk '{sum += $1} END {printf "%.2f", sum}')
            total_cost=$(echo "$response" | jq -r '.[] | .cost // 0' | awk '{sum += $1} END {printf "%.6f", sum}')
        fi
    else
        # 如果没有 jq，使用简单的文本处理（不太准确）
        echo "警告: 未找到 jq 命令，使用简单的文本处理"
        total_tokens=0
        total_input_tokens=0
        total_output_tokens=0
        total_cached_tokens=0
        total_duration=0
        total_cost=0
    fi
    
    # 7. 写入结果到 CSV 文件
    echo "$repo_name,$start_time,$end_time,$total_tokens,$total_input_tokens,$total_output_tokens,$total_cached_tokens,$total_duration,$total_cost" >> "../$RESULT_FILE"
    
    echo "完成处理: $repo_name"
    echo "总 tokens: $total_tokens"
    echo "总输入 tokens: $total_input_tokens"
    echo "总输出 tokens: $total_output_tokens"
    echo "总缓存 tokens: $total_cached_tokens"
    echo "总时长: $total_duration 秒"
    echo "总成本: $total_cost"
    echo "----------------------------------------"
    
    # 返回上级目录
    cd ..
done

echo "所有仓库处理完成！结果保存在 $RESULT_FILE"
