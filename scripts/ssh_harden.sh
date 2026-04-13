#!/bin/bash

# ==========================================================
# 🔐 Debian 12 SSH 安全加固一键脚本
# 适用环境: Debian 12 / Ubuntu 22.04+
# 功能: 启用公钥登录，禁用密码登录，禁用键盘交互认证
# ==========================================================

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
  echo "请使用 root 权限运行此脚本 (sudo sh ssh_harden.sh)"
  exit 1
fi

echo "🚀 开始 SSH 安全加固流程..."

# 1. 备份原配置
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)
echo "✅ 已完成配置备份至 /etc/ssh/sshd_config.bak_..."

# 2. 清理旧的认证配置
sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i '/^KbdInteractiveAuthentication/d' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/d' /etc/ssh/sshd_config

# 3. 写入新的安全规则
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config
echo "✅ 已禁用密码登录，启用公钥验证。"

# 4. 检查配置语法
sshd -t
if [ $? -eq 0 ]; then
    # 5. 重启服务
    systemctl restart ssh
    echo "🎉 SSH 服务已重启，加固成功！"
    echo "⚠️ 请确保当前终端不要断开，先开一个新窗口测试公钥登录是否成功。"
else
    echo "❌ 配置文件检测到错误，请检查 /etc/ssh/sshd_config"
    mv /etc/ssh/sshd_config.bak_* /etc/ssh/sshd_config
    echo "🔄 已自动还原备份配置。"
fi
