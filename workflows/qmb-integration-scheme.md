# QMB 集成方案草案（初版）

> 结论先说：基于本次可验证信息，**无法确认任务中给出的 `qmb` 项目地址 `https://github.com/qmb-search/qmb` 当前可访问或存在**。因此，下面方案分为：
> 1. **已验证事实**
> 2. **高风险不确定项**
> 3. **一旦拿到正确仓库/发行包后可直接落地的集成模板**

---

## 1. 已验证事实

### 1.1 GitHub 仓库地址当前不可验证
- 访问 `https://github.com/qmb-search/qmb`，页面返回 **GitHub 404 / Page not found**。
- 使用 GitHub 搜索 `qmb semantic search`，**Repositories 结果为 0**。
- 用 `gh repo view qmb-search/qmb` 查询，也返回：
  - `Could not resolve to a Repository with the name 'qmb-search/qmb'`

**结论：** 当前不能把 `qmb-search/qmb` 当成一个已确认存在的公开 GitHub 仓库。

### 1.2 `npm qmb` 与本任务目标不是同一个东西
本机环境里存在 `qmb.cmd` 启动器，但它指向的是 npm 包名 `qmb`。经 `npm view qmb --json` 验证：
- `name`: `qmb`
- `version`: `0.3.7`
- `description`: `Qunar Mobile Builder`

这说明 npm 上的 `qmb` 是 **Qunar Mobile Builder**，**不是本任务描述中的“本地语义搜索引擎”**。

此外，本机 `qmb.cmd` 目前调用失败：
- 目标脚本 `...\node_modules\qmb\bin\qmb` 不存在
- 当前安装看起来是不完整/损坏的 npm 安装残留

**结论：**
- 不能把 `npm install -g qmb` 当成语义搜索引擎安装方案。
- 还要警惕后续自动化中出现“同名误装”。

### 1.3 Windows `.exe` / 可执行二进制：当前无证据
由于目标仓库不可访问、也无法拿到 release 页面或文档，**目前没有证据证明该语义搜索引擎提供 Windows 原生 `.exe` 或其它可执行二进制**。

当前状态只能记为：
- **Windows 原生支持：未证实**
- **Windows 可执行文件（.exe / zip / msi）：未证实**
- **可通过 WSL / Docker 运行：也未证实**

---

## 2. 与 OpenClaw 集成时最关键的判断点

在拿到真正项目之前，最关键的是先确认 `qmb` 属于哪一类服务。OpenClaw 能接入的方式，基本取决于它暴露的接口形态：

### 2.1 如果 `qmb` 提供 HTTP API
这是最适合集成成 MCP Server 或 OpenClaw 外部服务的形态。

**优点：**
- 跨平台最好
- 最容易调试
- OpenClaw / MCP 可通过 stdio 包装器或现成 HTTP MCP 转接
- 日志、健康检查、重试都更方便

**OpenClaw 数据交互方式：**
- 本地启动 `qmb` 服务
- 通过 HTTP 请求提交：
  - 索引文档
  - 查询语义搜索
  - 删除/刷新索引
- 再由 MCP Server 把这些操作暴露成工具

### 2.2 如果 `qmb` 只支持 CLI + 本地文件
这是第二可行方案。

**典型模式：**
- 文档放在指定目录
- 通过命令行执行 `index/search` 等操作
- 输出 JSON / text

**OpenClaw 数据交互方式：**
- MCP Server 用 stdio 启动一个 Node/Python 包装器
- 包装器内部执行 `qmb search ... --json`
- 再把结果转换为 MCP tool 输出

**风险：**
- CLI 输出格式不稳定
- 错误码/编码/路径在 Windows 上容易出问题
- 并发与索引锁要额外处理

### 2.3 如果 `qmb` 提供 gRPC
也能做，但实施复杂度会更高。

**OpenClaw 数据交互方式：**
- 自建一个本地桥接层（Node/Python）
- 桥接层把 MCP tool 调用转成 gRPC 请求

**风险：**
- 要处理 proto、版本兼容、流式调用、Windows 证书/端口问题
- 比 HTTP 方案更重

### 2.4 如果 `qmb` 是嵌入式库（而非独立服务）
也可集成，但不适合作为“独立本地搜索引擎进程”直接接 OpenClaw。

**更合理方式：**
- 写一个独立包装服务
- 由包装服务管理索引与查询
- OpenClaw 只对接包装服务

---

## 3. 推荐的 OpenClaw 集成方向

在未确认项目前，**推荐优先级如下：**

1. **HTTP API 方案**（最优）
2. **CLI + JSON 输出包装方案**
3. **gRPC 桥接方案**
4. **直接嵌入库方案**（除非官方就是 SDK-first）

也就是说：
- 如果真正的 `qmb` 已有服务端模式，就直接围绕 API 做 MCP。
- 如果没有服务端，但有稳定 CLI，就做一个轻量包装器。
- 如果什么都没有，只是库，那就自己封装成服务。

---

## 4. 安装与运行指令（模板，待真实项目校正）

> 注意：下面是**落地模板**，不是已验证命令。只有在拿到真实仓库 README / release 后才能替换成最终版。

### 4.1 若有 Windows 原生二进制
```powershell
# 例：下载 release 压缩包后解压
mkdir C:\tools\qmb
# Expand-Archive qmb-windows-amd64.zip C:\tools\qmb

# 查看帮助
C:\tools\qmb\qmb.exe --help

# 启动服务（示例）
C:\tools\qmb\qmb.exe serve --host 127.0.0.1 --port 7210
```

### 4.2 若通过 Cargo / Rust 安装
```powershell
cargo install qmb
qmb --help
qmb serve --host 127.0.0.1 --port 7210
```

### 4.3 若通过 Go 安装
```powershell
go install github.com/<owner>/<repo>/cmd/qmb@latest
qmb --help
qmb serve --host 127.0.0.1 --port 7210
```

### 4.4 若通过 Docker 运行
```powershell
docker run --rm -p 7210:7210 -v C:\data\qmb:/data <image> --help
docker run -d --name qmb -p 7210:7210 -v C:\data\qmb:/data <image> serve
```

---

## 5. 打印 `qmb` Usage / Help 信息（当前状态）

### 5.1 当前本机 `qmb --help` 结果
当前机器上执行 `qmb --help`，报错如下：
- `Cannot find module 'C:\Users\Administrator\AppData\Roaming\npm\node_modules\qmb\bin\qmb'`

这进一步说明：
- 本机上的 `qmb` 不是目标语义搜索引擎
- 且这个 npm 包安装本身还已经损坏

### 5.2 正确做法
拿到真正项目后，应优先记录以下输出：
```powershell
qmb --help
qmb version
qmb serve --help
qmb search --help
qmb index --help
```

建议把这些原始输出完整保存到：
- `workflows/qmb-help.txt`
- 或本文件附录中

---

## 6. 建议的 OpenClaw MCP 配置（模板）

> 由于当前无法确认 `qmb` 的真实接口，这里给两个最可能的配置草案：HTTP 包装方案 与 CLI 包装方案。

### 6.1 方案 A：`qmb` 已提供 HTTP API
推荐思路：
- `qmb` 自己跑本地服务，如 `http://127.0.0.1:7210`
- 再写一个极薄的 MCP Server，把 HTTP 接口映射为工具

**建议暴露的 MCP tools：**
- `qmb_search(query, top_k, scope)`
- `qmb_index(paths | documents)`
- `qmb_delete(ids)`
- `qmb_health()`

**建议配置字段（示意）**
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

### 6.2 方案 B：`qmb` 只有 CLI
做一个 stdio MCP 包装器，在包装器内部调用 `qmb.exe` 或 `qmb`。

**建议配置字段（示意）**
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

### 6.3 MCP 包装器最少应处理的事情
无论 HTTP 还是 CLI，包装层都建议支持：
- 超时控制
- 健康检查
- 统一 JSON 输出
- Windows 路径规范化
- UTF-8 编码处理
- 查询失败时返回结构化错误
- 索引构建期间的锁/忙状态提示

---

## 7. 可能的陷阱与依赖问题

### 7.1 同名冲突（已确认）
这是当前最大坑。
- `qmb` 这个名字在 npm 上已被别的项目占用（Qunar Mobile Builder）
- 如果脚本里直接写 `npm install -g qmb`，大概率会装错

**建议：**
- 不要按名字猜安装方式
- 必须以真实仓库 README / release 页为准

### 7.2 Windows 路径与编码
如果 `qmb` 来自 Rust/Go/Linux-first 项目，常见问题有：
- 仅测试了 POSIX 路径
- 对中文路径兼容差
- 输出不是 UTF-8
- 依赖 mmap / symlink / fork 语义，Windows 行为不同

### 7.3 本地模型依赖
如果该语义引擎内置 embedding / reranker，需确认：
- 模型下载方式
- 首次启动是否联网
- 模型缓存目录
- CPU / GPU 要求
- Windows 下 CUDA / DirectML / ONNX Runtime 支持

### 7.4 服务模式 vs 一次性命令模式
如果只支持一次性 CLI：
- 每次查询启动进程可能很慢
- 索引状态管理麻烦
- 并发查询不稳定

因此更推荐常驻服务模式。

### 7.5 数据目录与锁文件
语义索引类工具常见问题：
- 索引目录损坏
- 多进程同时写入
- 升级后索引格式不兼容

建议从一开始就固定：
- 数据目录
- 日志目录
- 备份/重建策略

---

## 8. 当前可执行的下一步

### 8.1 必须先补齐的关键信息
要把方案从“草案”升级为“可执行集成”，至少还需要以下任一项：
1. 正确的 GitHub 仓库地址
2. 官方文档地址
3. release 下载页
4. 安装说明（README）
5. 可执行文件或容器镜像名

### 8.2 拿到真实项目后第一轮核验清单
```text
[ ] 仓库是否真实存在且可访问
[ ] License
[ ] 最近提交时间 / 维护状态
[ ] Windows 是否在 CI / release 中被明确支持
[ ] 是否提供 .exe / zip / msi
[ ] 是否提供 HTTP API
[ ] 是否提供 gRPC
[ ] 是否提供 CLI JSON 输出
[ ] 索引命令 / 查询命令 / 服务启动命令
[ ] 数据目录与模型目录配置方式
[ ] 最小运行依赖（VC++、CUDA、Docker、WSL、Rust、Go、Node）
```

---

## 9. 初步结论

### 可行性结论（当前）
- **理论可行**：如果真实 `qmb` 是本地语义搜索引擎，并且至少提供 HTTP API 或稳定 CLI，则与 OpenClaw 集成是可行的。
- **实操暂不可落地**：因为当前给定项目地址无法验证，且 `qmb` 名称存在严重同名冲突。

### 当前判断
- **Windows 支持**：未证实
- **Windows 原生可执行文件**：未证实
- **OpenClaw 对接方式**：
  - 最推荐 HTTP API
  - 其次 CLI 包装
  - gRPC 可做但成本更高

### 风险评级
- **项目识别风险：高**
- **安装误装风险：高**
- **接口不确定风险：高**
- **一旦接口明确后的集成难度：中等**

---

## 10. 附录：本次核验摘要
- GitHub 直达 `qmb-search/qmb`：404
- GitHub 搜索 `qmb semantic search`：Repositories 0 条
- `gh repo view qmb-search/qmb`：仓库不存在
- `npm view qmb`：`Qunar Mobile Builder`
- 本机 `qmb --help`：指向损坏的 npm 安装，不是语义搜索引擎

---

如果后续能拿到**正确仓库地址**，下一轮我可以直接补齐：
1. 真正的安装命令
2. 真正的 `--help` 输出
3. 真正的 Windows 支持判断
4. 可直接拷贝的 OpenClaw MCP 配置
