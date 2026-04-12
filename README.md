🔐 Debian 12 SSH 公钥登录加固指南
<p align="center"> <img src="https://img.shields.io/badge/Debian-12-red?logo=debian"> <img src="https://img.shields.io/badge/SSH-Secure-green?logo=gnubash"> <img src="https://img.shields.io/badge/Auth-PublicKey-blue"> <img src="https://img.shields.io/badge/Security-Hardened-success"> </p>

🚀 本指南适用于：
Windows 11 本地环境 + Debian 12 服务器
实现 SSH 公钥登录 + 禁用密码登录（防爆破）

📚 目录
🧱 第一阶段：生成密钥
📤 第二阶段：上传公钥
🔌 第三阶段：客户端配置
🛡️ 第四阶段：禁用密码登录
✅ 第五阶段：验证安全性
🆘 紧急恢复
⚠️ 注意事项
🧱 第一阶段：生成密钥

📋 在 Windows PowerShell 执行：

ssh-keygen -t ed25519 -f C:\Users\gaoshuiquan\acck

📌 生成结果：

文件	说明
acck	🔑 私钥（严禁泄露）
acck.pub	🔓 公钥（上传到服务器）
📤 第二阶段：上传公钥
✅ 方法一（推荐，一键完成）
type C:\Users\gaoshuiquan\acck.pub | ssh root@45.192.202.30 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
🖱️ 方法二（手动）
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
🔌 第三阶段：客户端配置
FinalShell 配置：
项目	配置
认证方式	公钥
私钥文件	acck
密码	passphrase（可为空）

✅ 测试结果：

无需输入 root 密码即可登录
🛡️ 第四阶段：禁用密码登录

⚠️ 务必确认公钥登录正常，否则会锁死服务器！

🧾 备份配置
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
🚀 一键加固（可直接复制）
# 删除旧配置
sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i '/^KbdInteractiveAuthentication/d' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/d' /etc/ssh/sshd_config

# 写入新规则
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config

# 重启服务
systemctl restart ssh
✅ 第五阶段：验证安全性
🔍 检查配置
sshd -T | grep -E "passwordauthentication|kbdinteractiveauthentication"

预期输出：

passwordauthentication no
kbdinteractiveauthentication no
🚫 测试禁止密码登录
ssh -o PubkeyAuthentication=no root@45.192.202.30

预期：

Permission denied (publickey)

✅ 说明：密码登录已彻底关闭

🆘 紧急恢复

如果你被锁在服务器外：

1️⃣ 使用控制台（VNC）

登录 VPS 面板提供的远程控制台

2️⃣ 恢复配置
cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
systemctl restart ssh
⚠️ 注意事项
🔒 私钥 acck 必须备份
❌ 丢失私钥 + 禁用密码 = 永久无法登录
💾 建议备份到：
加密U盘
私密云盘
⭐ 推荐升级（可选）

你可以进一步增强安全：

🚫 修改 SSH 端口（防扫描）
🧱 安装 Fail2ban（防爆破）
🌐 使用 Cloudflare Tunnel（隐藏真实IP）
🔐 限制 IP 登录（白名单）
📅 信息
创建时间：2026-04-11
作者：GaoOps
