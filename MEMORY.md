# 长期记忆 - 超级六一

_这是我在 oc-981e-feishu-group workspace 的长期记忆库。记录重要决策、成就、经验和学习。_

---

## 📅 2026-03-12 - 重大里程碑

### 🎯 15天安全自检任务完成

**安全评分: 93/100 (优秀 - 生产就绪)**

#### 核心成就
1. **备份系统完全就绪**
   - 三重备份策略 (Git, 文件镜像, 数据库)
   - 解决数据库锁问题（文件复制替代 SQLite 备份）
   - 备份监控脚本准备就绪

2. **模型安全升级**
   - 切换到本地模型 `codex-local/gpt-5.4`
   - 添加 RelayPlane 智能路由（预计节省 40-60% 成本）
   - 环境变量正确配置

3. **安全监控部署**
   - ClawSec Monitor 运行（Windows 兼容性修复）
   - Self-Improving Agent 安装并通过人工审查
   - 严格的技能审查流程（拒绝可疑包）

4. **系统加固**
   - OpenClaw Gateway 稳定运行
   - 所有服务仅监听 127.0.0.1（最小化攻击面）
   - API keys 通过 auth-profiles.json 加密存储

#### 关键技术决策
- **RelayPlane**: 独立运行，不占用 OpenClaw 会话（避免阻塞）
- **ClawSec**: 适配 Windows 系统调用（taskkill 替代 os.kill）
- **技能审查**: 人工代码审查 + VirusTotal 检查，跳过所有被标记包
- **备份策略**: 文件级复制解决 SQLite 锁限制

#### 经验教训
1. OpenClaw `exec(background: true)` 不适合长期服务管理（会阻塞后续调用）
2. Windows 环境需避免 Linux-only 系统调用（如 `os.kill`）
3. 安全扫描工具（security-check）可能误报，需人工判断
4. 启用环境变量 `ANTHROPIC_BASE_URL` 是模型切换的关键

---

## 📦 已安装的关键 Skills

| 名称 | 版本 | 用途 | 安全等级 |
|------|------|------|----------|
| `relayplane` | 3.4.0 | 智能模型路由，省成本 | 🟢 低 |
| `xiucheng-self-improving-agent` | 1.0.0 | 自动记录错误，持续学习 | 🟢 低 |
| `clawsec` | 1.0.0 | AI 流量监控，防注入/泄露 | 🟡 中 |

---

## 🔐 当前系统架构

```
OpenClaw (localhost:18789)
    ↓ (通过环境变量)
RelayPlane Proxy (localhost:3001)
    ↓ (路由到)
codex-local/gpt-5.4 (localhost:8317)

ClawSec Monitor (localhost:8888) - 流量监控
Backup System - 三重保障
```

---

## 💬 重要对话摘要

与大哥的协作模式：
- 明确任务后快速执行（"收到！"文化）
- 发现问题和解决方案及时汇报
- 安全优先，质疑可疑包
- 技术细节透明化，不隐藏问题

---

_Last updated: 2026-03-12 17:35_
_Next review: 2026-03-19_
