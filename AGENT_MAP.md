# AGENT_MAP.md

_当前 OpenClaw agent / workspace / memory 映射梳理（2026-03-15）_

## 1. 当前主配置结论

- 全局已启用插件：`memory-lancedb-pro`
- 配置位置：`C:\Users\Administrator\.openclaw\openclaw.json`
- 关键配置：
  - `plugins.slots.memory = "memory-lancedb-pro"`
  - `plugins.entries.memory-lancedb-pro.enabled = true`
  - `sessionStrategy = "systemSessionMemory"`
- 当前主状态：`openclaw status` 显示 `Memory enabled (plugin memory-lancedb-pro)`

## 2. 当前已知 agent / workspace 映射

| Agent ID | Workspace | 备注 |
|---|---|---|
| `oc_981e24884af3ed7ed6c16c5730c9bd02` | `C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group` | 当前 Feishu 主 agent |
| `oc_baa6c26e80932344e32cf514de6acde3` | `C:\Users\Administrator\.openclaw\workspaces\DAQIAN` | 独立业务 agent |
| `oc_8f6fe7a8106b318e5d183817579bc8ea` | `C:\Users\Administrator\.openclaw\workspaces\LASER` | 激光雕刻机知识库 agent |

## 3. Subagent 现状判断

### 同一 Agent ID 下的 subagent

- 通过 `sessions_spawn(runtime="subagent", agentId="oc_981e24884af3ed7ed6c16c5730c9bd02")` 启动的 subagent
- 实测：**可以看到 memory 能力**
- 结论：在当前配置下，**同一 agent 下的 subagent 默认可使用 memory 插件能力**

### 为什么有时它会说“没有”

更可能的原因不是插件没装，而是以下之一：

1. 它那个回合没有真的拿到相关记忆命中
2. 它没有主动调用 `memory_recall`
3. 查询词不对，导致检索为空
4. 该子会话在回答时把“没有检索到结果”说成了“没有这个能力”

## 4. 未来默认标准（重要）

以后新增子 agent / 新 agent 时，默认按下面检查：

1. **先确认用途和命名**
   - 这个 agent 是干什么的？
   - 希望叫什么名字？
   - 优先调整 workspace 标识/路径，不随便改 agent ID

2. **确认 memory 插件继承**
   - `plugins.slots.memory` 已指向 `memory-lancedb-pro`
   - 对应 agent 启动后 `openclaw status` 能看到 memory enabled

3. **做一次实测，不只看配置**
   - 起一个诊断 subagent
   - 让它明确回答：是否能使用 `memory_recall`
   - 再做一次 harmless recall 测试

4. **确认记忆隔离边界**
   - 不同 agent 应有各自独立 workspace / memory 语义边界
   - 不把 A agent 的私有上下文默认混进 B agent

## 5. 推荐交付检查清单

新 agent / 子agent 完成后，至少确认：

- [ ] 能正常启动
- [ ] 能访问 memory 工具
- [ ] `memory_recall` 可调用
- [ ] 查询空结果时，不误报成“我没有 memory”
- [ ] workspace 路径和用途记录清楚

---

维护说明：
- 这个文件是人工维护的总览
- 后续新增 agent 时，同步补这张表
