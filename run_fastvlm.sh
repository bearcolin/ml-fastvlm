#!/bin/bash
# ---------- 环境 ----------
source /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
conda activate fastvlm

# ---------- 选图 ----------
IMG_PATH=$(osascript -e 'POSIX path of (choose file of type {"public.image"} with prompt "请选择一张图片进行描述")')

# ---------- 推理 ----------
cd /Users/colin/ml-fastvlm
RESULT=$(python predict.py \
        --model-path checkpoints/llava-fastvithd_0.5b_stage3 \
        --image-file "$IMG_PATH" \
        --prompt "描述一下这张图片" 2>/dev/null)

[ -z "$RESULT" ] && osascript -e 'display notification "模型运行失败或无输出" with title "FastVLM 出错"' && exit 1

# ---------- 弹窗循环（后台运行） ----------
osascript <<EOF &
set resultText to "$(echo "$RESULT" | sed 's/"/\\"/g')"
repeat
    set userChoice to display dialog resultText ¬
        with title "FastVLM 图像描述" ¬
        buttons {"复制", "关闭"} default button "关闭"
    if button returned of userChoice is "复制" then
        do shell script "/usr/bin/printf %s " & quoted form of resultText & " | pbcopy"
    else
        exit repeat
    end if
end repeat
EOF

# ---------- 主脚本立即结束 ----------
exit 0
