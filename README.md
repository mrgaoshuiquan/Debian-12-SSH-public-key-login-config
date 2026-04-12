# Debian 12 SSH 公钥登录配置手册

本手册适用于将 Windows 11 作为本地环境，对远程 Debian 12 服务器进行公钥登录改造并禁用密码。

## 第一阶段：本地生成密钥对（Windows 11）

1. 打开 **PowerShell** 或 **终端**。

2. 执行命令：

```powershell
ssh-keygen -t ed25519 -f C:\Users\您的用户名\vpssshkey
```

3. **结果说明**：
   - `vpssshkey`：**私钥**（你的钥匙，绝对不能泄露）
   - `vpssshkey.pub`：**公钥**（锁头，上传到服务器）

## 第二阶段：上传公钥至服务器

### 方法 A：使用 FinalShell（图形化）

1. 用记事本打开本地 `vpssshkey.pub`，复制内容。

2. 登录服务器，执行：

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "粘贴公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 方法 B：使用 PowerShell 命令（快捷）

```powershell
type C:\Users\您的用户名\vpssshkey.pub | ssh root@45.192.202.30 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

## 第三阶段：FinalShell 连接配置

1. 打开 FinalShell 连接管理器 → **右键点击服务器** → **编辑**。

2. **认证方式**：选择 **"公钥"**。

3. **私钥文件**：导入本地的 **vpssshkey** 文件。

4. **密码**：填写生成密钥时设置的 passphrase（若无则留空）。

5. 点击确定并尝试连接，确保**无需 root 密码**即可直接登录。

## 第四阶段：服务器端禁用密码（核心加固）

> **⚠️ 注意**：请务必确保已能通过公钥登录成功，再执行此步。

1. **备份原配置**：

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

2. **执行加固命令**（清理并禁用密码通道）：

```bash
# 删除旧的认证配置
sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i '/^KbdInteractiveAuthentication/d' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/d' /etc/ssh/sshd_config

# 写入新的安全规则
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config

# 重启 SSH 服务
systemctl restart ssh
```

## 第五阶段：检查与验证

### 1. 验证配置文件生效情况

```bash
sshd -T | grep -E "passwordauthentication|kbdinteractiveauthentication"
```

- **预期输出**：均为 `no`

### 2. 验证暴力破解拦截

在本地 PowerShell 输入：

```powershell
ssh -o PubkeyAuthentication=no root@66.66.66.66 ##您VPS的IP
```

- **预期结果**：提示 `Permission denied (publickey)` 且无法输入密码，说明加固成功。

## 🆘 紧急救援与备份

### 万一配置错误导致无法登录

1. 通过 VPS 服务商提供的 **VNC 控制台** 登录。

2. 还原配置：
   ```bash
   cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config && systemctl restart ssh
   ```

### 私钥备份

请将 `acck`（私钥）文件备份至加密盘或可靠云端。

> **⚠️ 重要提醒**：一旦丢失私钥，若密码登录已关闭，你将无法再通过网络进入该服务器。

---

**手册编写日期**：2026-04-11
