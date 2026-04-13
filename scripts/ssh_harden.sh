#!/bin/bash

# ==========================================================
# 🔐 Debian 12 SSH 安全加固一键脚本 (增强版)
# 适用环境: Debian 12 / Ubuntu 22.04+
# 功能: 检测公钥状态 -> 开启公钥验证 -> 禁用密码登录
# ==========================================================

# 1. 权限检查
if [ "$EUID" -ne 0 ]; then 
  echo "❌ 错误: 请使用 root 权限运行此脚本 (sudo bash $0)"
  exit 1
fi

echo "🚀 开始 SSH 安全加固流程..."

# 2. 安全防锁死检测：检查是否已配置公钥
AUTH_KEY_FILE="$HOME/.ssh/authorized_keys"
if [ ! -f "$AUTH_KEY_FILE" ] || [ ! -s "$AUTH_KEY_FILE" ]; then
    echo "-------------------------------------------------------"
    echo "❌ 警告：未在 $AUTH_KEY_FILE 中发现有效的公钥内容！"
    echo "为了防止禁用密码后您无法登录服务器，脚本已自动终止。"
    echo "请先按照 README 手册第二阶段上传公钥后再执行。"
    echo "-------------------------------------------------------"
    exit 1
fi

echo "✅ 检测到公钥已存在，继续执行加固..."

# 3. 备份原配置
BACKUP_FILE="/etc/ssh/sshd_config.bak_$(date +%F_%T)"
cp /etc/ssh/sshd_config "$BACKUP_FILE"
echo "✅ 已完成配置备份至 $BACKUP_FILE"

# 4. 修改 SSH 配置项
# 使用 sed 清理并重新设置关键安全参数
sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i '/^KbdInteractiveAuthentication/d' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/d' /etc/ssh/sshd_config

echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config

# 5. 语法检查与重启服务
sshd -t
if [ $? -eq 0 ]; then
    systemctl restart ssh
    echo "-------------------------------------------------------"
    echo "🎉 SSH 安全加固成功！"
    echo "✅ 已启用 Ed25519 公钥验证。"
    echo "🚫 已禁用密码登录和键盘交互验证。"
    echo "⚠️  注意：请务必保持当前窗口不要关闭，新开一个窗口测试是否能成功登录！"
    echo "-------------------------------------------------------"
else
    echo "❌ 配置文件语法检测失败，正在还原备份..."
    mv "$BACKUP_FILE" /etc/ssh/sshd_config
    echo "🔄 配置已还原，请检查错误原因。"
fi
