# AGENT_REGISTRY.md

_多 Agent 工作区总表。用于记录 agent ID、用途、workspace、记忆位置与维护规则。_

## 维护规则
- 新增子 agent 时，先确认：**用途是什么**、**要取什么名字**。
- 优先修改 **workspace 标识/路径**，**不修改 agent ID**。
- 每个 agent 必须有：独立 `MEMORY.md`、独立 `memory/`、独立 `AGENTS.md`、独立 `TOOLS.md`、独立 `HEARTBEAT.md`。
- `USER.md` / `IDENTITY.md` / `SOUL.md` / `ERRORS.md` 与主 agent 保持一致，复制一份，避免人格与协作感陌生。
- 如后续职责变化，可在各自 workspace 内单独扩展，不影响其他 agent。

## Agent 映射总表

| Agent ID | 名称/标识 | 用途 | Workspace | 长期记忆 | 日常记忆目录 | 主模型 | 备注 |
|---|---|---|---|---|---|---|---|
| `oc_981e24884af3ed7ed6c16c5730c9bd02` | 主 agent | 主控 / 当前 Feishu 直聊 | `C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group` | `...\MEMORY.md` | `...\memory\` | `2603/gpt-5.4` | 当前主 agent |
| `oc_8f6fe7a8106b318e5d183817579bc8ea` | `LASER` | 激光雕刻机知识库 | `C:\Users\Administrator\.openclaw\workspaces\LASER` | `...\MEMORY.md` | `...\memory\` | `2603/gpt-5.4` | 独立记忆、独立规范 |
| `oc_baa6c26e80932344e32cf514de6acde3` | `DAQIAN` | 跨境运营 | `C:\Users\Administrator\.openclaw\workspaces\DAQIAN` | `...\MEMORY.md` | `...\memory\` | `2603/gpt-5.4` | 独立记忆、独立规范 |

## 展开路径

### 1) 主 agent
- **Agent ID**: `oc_981e24884af3ed7ed6c16c5730c9bd02`
- **Workspace**: `C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group`
- **长期记忆**: `C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group\MEMORY.md`
- **日常记忆目录**: `C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group\memory\`

### 2) LASER
- **Agent ID**: `oc_8f6fe7a8106b318e5d183817579bc8ea`
- **Workspace**: `C:\Users\Administrator\.openclaw\workspaces\LASER`
- **长期记忆**: `C:\Users\Administrator\.openclaw\workspaces\LASER\MEMORY.md`
- **日常记忆目录**: `C:\Users\Administrator\.openclaw\workspaces\LASER\memory\`

### 3) DAQIAN
- **Agent ID**: `oc_baa6c26e80932344e32cf514de6acde3`
- **Workspace**: `C:\Users\Administrator\.openclaw\workspaces\DAQIAN`
- **长期记忆**: `C:\Users\Administrator\.openclaw\workspaces\DAQIAN\MEMORY.md`
- **日常记忆目录**: `C:\Users\Administrator\.openclaw\workspaces\DAQIAN\memory\`
