# QMB 集成调研报告（最终版）

> **调研结论：** `qmb` 作为一个"本地语义搜索引擎"的身份目前**无法验证**。给定仓库地址 `qmb-search/qmb` 在公开 GitHub 上不存在，同名 npm 包是无关的老项目（Qunar Mobile Builder）。因此，建议先确认项目的真实身份和可访问性，再推进集成。

---

## ✅ 本次调研已核验的事实

### 1. GitHub 仓库 `qmb-search/qmb` 不存在
- 访问 `https://github.com/qmb-search/qmb` → 404 Page not found
- GitHub 内部搜索 "qmb semantic search" → 0 个仓库结果
- `gh repo view qmb-search/qmb` → "Could not resolve to a Repository"

**结论：** 该地址当前无法用于集成。

### 2. npm 上的 `qmb` 包与任务目标无关
```bash
npm view qmb --json
# name: "qmb"
# description: "Qunar Mobile Builder"
# version: "0.3.7" (published 2015-07-09)
```
这不是一个语义搜索引擎，且当前本机的 `qmb` 调用已损坏（指向不存在的文件）。

**风险：** 如果在脚本中使用 `npm install -g qmb` 或 `qmb.cmd`，会误装无关工具，无法完成语义搜索任务。

### 3. 当前无法证实 `qmb` 的任何技术特征
- ❌ Windows 原生支持：未证实
- ❌ 可执行二进制文件 (.exe/.zip/.msi)：未证实
- ❌ HTTP API 接口：未证实
- ❌ gRPC 接口：未证实
- ❌ CLI + JSON 输出：未证实
- ❌ Docker 镜像：未证实（本机无 docker 命令）

---

## 🔍 可能的 `qmb` 身份推测

基于"本地语义搜索引擎"这一描述，`qmb` 可能是：

1. **GitHub 私有仓库**：组织内部项目，未公开
2. **Rust/Go 新项目**：尚未发布 release，或名称/组织不同
3. **内部工具代号**：非正式开源名称
4. **拼写或缩写差异**：可能是 `qdrant`、`milvus`、`weaviate`、`semantic-search` 等
5. **商业软件**：需要授权下载，不在公开渠道

建议在继续前先向项目来源方（可能是内部团队或合作伙伴）确认：
- 确切的 GitHub 仓库地址或下载链接
- 官方文档地址
- License 和发布渠道
- Windows 支持情况

---

## 📦 如果 `qmb` 是典型的本地语义搜索引擎

一旦拿到正确的项目，它通常会提供以下几种接口之一。以下是**面向未来的集成准备建议**：

### A. HTTP API 方案（最优）
如果 `qmb` 提供 localhost HTTP 服务（常见于 Rust/Go 项目）：

**安装示例（待填充真实命令）**
```powershell
# 待替换：真实的下载/安装命令
# 如：choco install qmb 或直接下载 .zip 解压
```

**运行示例**
```powershell
# 启动服务
qmb serve --host 127.0.0.1 --port 7210

# 或直接执行二进制
C:\tools\qmb\qmb.exe serve --data-dir C:\data\qmb
```

**OpenClaw MCP 配置（模板）**
```json
{
  "mcpServers": {
    "qmb": {
      "command": "node",
      "args": [
        "C:/openclaw-integrations/qmb-mcp/server.js"
      ],
      "env": {
        "QMB_BASE_URL": "http://127.0.0.1:7210",
        "QMB_TIMEOUT_MS": "15000"
      }
    }
  }
}
```

**暴露的 MCP Tools（建议）**
- `qmb_search(query, top_k, filter)`
- `qmb_index(file_paths | documents)`
- `qmb_status()` - 健康检查
- `qmb_delete(ids)` - 可选

### B. CLI + JSON 输出方案（次优）
如果 `qmb` 只支持命令行操作：

**MCP 包装器实现要点**
- 用 Node.js/Python 启动一个 stdio MCP 服务器
- 内部调用 `qmb.exe search ... --json`
- 处理 Windows 路径、编码、超时
- 缓存进程状态（避免每次查询都启动新进程）

**配置（模板）**
```json
{
  "mcpServers": {
    "qmb": {
      "command": "node",
      "args": [
        "C:/openclaw-integrations/qmb-cli-mcp/server.js"
      ],
      "env": {
        "QMB_BIN": "C:/tools/qmb/qmb.exe",
        "QMB_DATA_DIR": "C:/data/qmb",
        "QMB_TIMEOUT_MS": "20000"
      }
    }
  }
}
```

### C. gRPC / 嵌入式库方案
需要自建桥接层，复杂度较高，建议仅在无其他选项时采用。

---

## ⚠️ 常见陷阱与依赖检查清单

- [ ] **同名冲突**：确认安装源，避免安装到 Qunar Mobile Builder 或其他无关包
- [ ] **Windows 兼容性**：确认 CI/release 中包含 Windows，或需 WSL/Docker
- [ ] **模型依赖**：如果内置 embedding 模型，确认首次运行是否自动下载、是否支持 Windows CPU/GPU
- [ ] **数据目录**：固定索引目录位置，避免位置漂移导致索引丢失
- [ ] **输出编码**：确保 CLI 输出为 UTF-8（Windows 默认可能是 GBK）
- [ ] **路径格式**：Windows 反斜杠与 POSIX 斜杠的转换处理
- [ ] **服务模式**：推荐常驻服务，避免每次查询启动开销

---

## 📋 后续行动建议

### 第一步：确认真实项目
获取以下任一信息：
- ✅ 正确的 GitHub 仓库完整地址（如 `https://github.com/<org>/<repo>`）
- ✅ 官方下载页面或容器镜像名
- ✅ 安装文档或 README 链接

### 第二步：验证基本功能
拿到项目后，先本地手动验证：
```powershell
# 1. 安装
# 2. 查看帮助
qmb --help
# 或
qmb.exe --help

# 3. 查看版本
qmb version

# 4. 启动服务（如果有）
qmb serve --help
```

将以上输出保存为 `workflows/qmb-help.txt` 以便后续参考。

### 第三步：Windows 兼容性验证
- 尝试在纯 Windows 环境运行（无需 WSL）
- 检查是否依赖 Visual C++ Redistributable、.NET、Java 等
- 如有缺失依赖，记录安装链接和命令

### 第四步：设计 MCP 包装器
根据 `qmb` 提供的接口（HTTP/CLI/gRPC），选择对应的包装方案：

- **HTTP**：编写简单的 `server.js` 转发 HTTP 请求
- **CLI**：编写 `server.js` 调用子进程并解析输出
- **gRPC**：使用 `@grpc/grpc-js` 建立桥接

所有包装器都应包含：
- 健康检查端点（或命令）
- 超时控制
- 统一错误处理
- 调试日志（可选）

---

## 📌 本报告状态

- **调研对象**：qmb（本地语义搜索引擎）
- **指定仓库**：qmb-search/qmb
- **验证结果**：仓库不存在
- **建议状态**：暂停集成，先确认项目身份
- **已准备素材**：完整的集成方案模板（HTTP/CLI/gRPC）

---

如需继续推进，请提供：
1. 正确的仓库地址或下载链接
2. 官方文档或 README 的访问方式
3. 是否需要从其他源（如内部镜像）获取

我会在收到上述信息后，立即完成：
- 真实的安装步骤
- 真实的 `--help` 输出归档
- 可直接拷贝的 OpenClaw MCP 配置
- 针对 Windows 的具体注意事项

---

**报告生成时间**：2026-03-18 10:45 (Asia/Shanghai)
**任务模型**：siliconflow/Qwen/Qwen3-30B-A3B-Instruct-2507
**执行时长**：调研耗时 ~5 分钟，信息验证耗时因 API 限制使用手动方式完成
