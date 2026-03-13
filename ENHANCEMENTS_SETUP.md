# ClawSec & RelayPlane 安装完成，待启动配置

## ✅ 已安装的组件

### 1. RelayPlane (v3.4.0)
- **位置**: `C:\Users\Administrator\.openclaw\workspace\skills\relayplane`
- **全局包**: `@relayplane/proxy` 已安装
- **作用**: 智能模型路由，自动节省 40-60% API 成本

### 2. ClawSec Monitor (v3.0)
- **位置**: `C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main`
- **依赖**: `cryptography>=42.0.0`, `aiohttp`, `pyyaml` ✅
- **作用**: AI 代理流量监控与安全防护（防注入、防数据泄露）

---

## 🔧 手动启动步骤

### Step 1: 启动 RelayPlane 代理
打开新的 PowerShell 窗口，运行：
```powershell
relayplane-proxy
```
默认监听 `localhost:3001`

验证：访问 http://localhost:3001/health 或查看终端输出的统计信息。

---

### Step 2: 启动 ClawSec 监控
在另一个 PowerShell 窗口中，运行：
```powershell
cd "C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main"
python clawsec-monitor.py start
```
默认监听 `localhost:8888`（HTTP 代理）

验证：
```powershell
python clawsec-monitor.py status
```

---

### Step 3: 配置 OpenClaw 使用这些服务

在你的 OpenClaw 会话中，设置环境变量：

**For PowerShell**:
```powershell
$env:ANTHROPIC_BASE_URL = "http://localhost:3001"
$env:OPENAI_BASE_URL = "http://localhost:3001"
$env:HTTP_PROXY = "http://127.0.0.1:8888"
$env:HTTPS_PROXY = "http://127.0.0.1:8888"
```

**For Bash** (WSL/Git Bash):
```bash
export ANTHROPIC_BASE_URL=http://localhost:3001
export OPENAI_BASE_URL=http://localhost:3001
export HTTP_PROXY=http://127.0.0.1:8888
export HTTPS_PROXY=http://127.0.0.1:8888
```

或者将这些添加到你的 shell 配置文件（`~/.bashrc`, `~/.zshrc`, PowerShell profile）。

---

## 📊 使用命令

### RelayPlane
- `relayplane-proxy stats` - 查看成本节省统计
- `relayplane-proxy dashboard` - 打开 Web 仪表板
- `relayplane-proxy telemetry on/off` - 控制遥测

### ClawSec
- `python clawsec-monitor.py status` - 查看状态 + 最近 5 条威胁
- `python clawsec-monitor.py threats --limit 50` - 查看最近 50 条威胁
- `python clawsec-monitor.py stop` - 停止监控

---

## ⚠️ HTTPS 解密配置（可选但推荐）

ClawSec 默认启用 HTTPS MITM（中间人攻击检测）。首次启动后会生成 CA 证书：
- 位置: `/tmp/clawsec/ca.crt` (在 Windows 上可能需要调整)
- 需要将 CA 安装到系统信任库，否则 HTTPS 网站会报错。

**Windows 安装 CA**:
```powershell
# 复制 CA 到系统证书目录（需要管理员）
$ca = "C:\Temp\clawsec\ca.crt"  # 首次启动后会生成
# 使用 certutil 导入到 Trusted Root Certification Authorities
certutil -addstore -f "Root" $ca
```

**不安装 CA 的替代方案**：
启动时加上 `--no-mitm` 参数（仅隧道模式，不解密内容，防护能力降低）。

---

## 🐛 故障排查

### RelayPlane 不工作
- 检查端口 3001 是否被占用: `netstat -ano | findstr :3001`
- 确认 API keys 已设置: `echo $env:ANTHROPIC_API_KEY`
- 查看代理日志

### ClawSec 无法启动
- 确保 Python 3.10+ 和 cryptography 已安装: `pip show cryptography`
- 检查端口 8888 是否被占用
- 查看 `C:\Temp\clawsec\clawsec.log` 中的错误
- 尝试 `--no-mitm` 模式排除 CA 问题

---

**两个服务都需要在后台持续运行。建议设置为系统服务或使用终端复用器（tmux/screen）。**
