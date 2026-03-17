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

## 🚨 2026-03-13 - 关键运维经验补充

### Gateway Token 对齐原则
- 出现 `gateway token mismatch` 时，**先对齐配置，后考虑删除环境变量**
- 本次根因是**进程级环境变量** `OPENCLAW_GATEWAY_TOKEN=openclaw-manager-local-token` 覆盖了原配置
- 需要统一检查并保持一致的 4 处：
  1. `$env:OPENCLAW_GATEWAY_TOKEN`
  2. `openclaw.json -> gateway.auth.token`
  3. `openclaw.json -> gateway.remote.token`
  4. `C:\Users\Administrator\.openclaw\gateway\token.txt`
- 重要经验：`openclaw status` 正常，不代表 tools 一定正常；最好再用 `sessions_list` 验证一次

### 模型与配置状态
- 当前主模型稳定为 **gpt-5.4**
- 2026-03-13 对 OpenRouter 相关大模型配置进行过清理，长期方向是：
  - 优先本地 / 免费模型
  - 降低付费模型误用风险
  - 敏感改动前先备份，再做结构化修改

---

## 🔄 进行中事项

- 飞书群组消息接收链路曾异常，怀疑与开发者后台长连接订阅配置有关，后续如再出现需优先复查订阅模式
- RelayPlane / ClawSec 如需长期稳定运行，最好迁移为更正式的服务化方式，而不是依赖临时会话
- 备份失败通知仍值得后续补上，但当前三重备份主链路已可用

---

## 💬 重要对话摘要

与大哥的协作模式：
- 明确任务后快速执行（"收到！"文化）
- 发现问题和解决方案及时汇报
- 安全优先，质疑可疑包
- 技术细节透明化，不隐藏问题
- 配置改动倾向先备份、再清理、再验证，不赌运气

---

_Last updated: 2026-03-15 09:00_
_Next review: 2026-03-22_
