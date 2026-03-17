# TEAM_SKILLS.md - 团队共用电商 Skills 说明

这份文档记录当前 workspace 已安装、默认可复用的电商 skills，以及推荐使用场景。

## 当前已安装（workspace 级）

这些 skill 已安装在当前工作区：

- `review-defect-miner`
- `review-analysis`
- `faq-generator-from-reviews`
- `listing-gap-audit`
- `creator-monetization-risk-checker`
- `tiktok-claim-rewriter`
- `content-source-to-markdown`
- `ima-skills`

安装位置：

- `./skills/review-defect-miner`
- `./skills/review-analysis`
- `./skills/faq-generator-from-reviews`
- `./skills/listing-gap-audit`
- `./skills/creator-monetization-risk-checker`
- `./skills/tiktok-claim-rewriter`
- `./skills/content-source-to-markdown`
- `./skills/ima-skills`

## 适用范围

### 谁能用
- 运行在**当前 workspace** 的助手 / agent / 子会话，可复用这批 skills。
- 在这个工作区里处理电商研究、评论分析、文案风控、竞品分析时，默认优先考虑调用它们。

### 谁默认不能用
- 其他 workspace 的 agent 默认**不会自动拥有**这些 skills。
- 如果需要跨 workspace 复用，需在对应 workspace 单独安装。

## 默认使用原则

- 用户只提需求，不需要手动点名具体 skill。
- 助手应根据任务目标自动选择最合适的 skill，必要时组合多个 skill 使用。
- 只有在以下情况才额外追问：
  - 输入材料明显不足
  - 涉及高风险决策或外部发送
  - 有多条可行路线需要用户拍板

## Skills 说明

---

## 1) `review-defect-miner`

**用途：**
从低星评论、差评、售后文本、退货说明中提取产品缺陷信号，按严重度、频率、修复优先级聚类。

**适合：**
- 竞品差评分析
- 找产品硬伤
- 区分产品问题 / 包装问题 / 物流问题 / 预期不符

**推荐输入：**
- 低星评论
- 用户吐槽
- 售后对话
- 退款/退货原因

**典型输出：**
- 缺陷聚类
- 严重度判断
- 高频问题
- 优先修复建议

---

## 2) `review-analysis`

**用途：**
把评论、投诉、退款原因整理成清晰模式和行动建议，比 `review-defect-miner` 更通用。

**适合：**
- 评论总览
- 投诉模式分析
- 问题归因
- 形成运营/产品改进建议

**推荐输入：**
- 评论合集
- 投诉记录
- 退款说明
- 客服摘要

**典型输出：**
- 主要模式摘要
- 证据片段
- 可能根因
- 建议动作

---

## 3) `faq-generator-from-reviews`

**用途：**
从真实评论和常见疑问里生成 FAQ，减少用户购买前犹豫。

**适合：**
- 商品页 FAQ
- 落地页 FAQ
- 飞书文档整理卖点问答
- 销售前异议预处理

**推荐输入：**
- 评论
- 投诉
- 常见问题
- 产品详情
- 约束性说法（禁用词/不能夸大）

**典型输出：**
- FAQ 问题主题
- 答案草稿
- 风险提示
- 证明点缺口

---

## 4) `listing-gap-audit`

**用途：**
对比我们商品 listing 和竞品 listing，找出标题、卖点、证据、结构、转化表达上的差距。

**适合：**
- 竞品详情页对比
- PDP / listing 改版
- 卖点表达优化
- 找缺失的证明材料和转化点

**推荐输入：**
- 我方 listing 文案
- 竞品 listing 文案
- 产品约束
- 不能说的话

**典型输出：**
- gap report
- 优先补强项
- 标题/卖点/证明建议
- 改写方向

---

## 5) `creator-monetization-risk-checker`

**用途：**
在内容发布前做变现风险与平台风险审查，判断是否容易影响分发或审核。

**适合：**
- TikTok / 短视频脚本检查
- 商品宣传文案审查
- 达人内容预审
- 广告口播风险筛查

**推荐输入：**
- 草稿脚本
- 标题/封面文案
- 产品 claim
- 平台上下文

**典型输出：**
- Green / Yellow / Red 风险结论
- 风险点清单
- 更安全的改写建议

---

## 6) `tiktok-claim-rewriter`

**用途：**
把高风险、容易夸大、可能违规的 TikTok 卖点改写成更安全但仍有说服力的话术。

**适合：**
- TikTok Shop 文案
- 短视频脚本
- 达人口播改写
- 风险 claim 降级处理

**推荐输入：**
- 原始脚本
- 产品事实边界
- 禁用词
- 受众描述

**典型输出：**
- 风险 claim 地图
- 安全改写版本
- 替代表达

---

## 7) `content-source-to-markdown`

**用途：**
把分散的链接、网页片段、社媒信息、素材摘要整理成结构化 markdown 研究简报。

**适合：**
- 多平台调研归档
- 竞品信息整理
- 飞书前的中间研究稿
- 把网页资料整理成可复用文档

**推荐输入：**
- URLs
- 社媒链接
- 网页片段
- 备注信息
- 输出用途

**典型输出：**
- 结构化 markdown brief
- 核心发现
- 待验证点
- 下一步动作

---

## 8) `ima-skills`

**用途：**
用于 IMA 个人笔记服务 API 的笔记访问与管理，包括搜索笔记、浏览笔记本、读取笔记内容、新建笔记、追加内容。

**适合：**
- 让我记一下某件事
- 查找过去记过的笔记/备忘
- 新建个人知识记录
- 向已有笔记追加内容

**推荐输入：**
- 笔记关键词
- 笔记本名称
- 要保存的正文内容
- 追加内容
- 查询目标

**典型输出：**
- 命中的笔记列表
- 笔记正文
- 新建/追加结果
- 可继续编辑的结构化记录

## 推荐自动调用映射

### 当用户说这些，就优先考虑：

- “帮我看差评/低分评论/退货原因”
  - `review-defect-miner`
  - `review-analysis`

- “帮我整理商品 FAQ / 用户都在问什么”
  - `faq-generator-from-reviews`

- “帮我对比我们的商品页和竞品差在哪”
  - `listing-gap-audit`

- “帮我看这个脚本/文案会不会违规、会不会影响投流/变现”
  - `creator-monetization-risk-checker`
  - `tiktok-claim-rewriter`

- “把这些网页/链接/资料整理成研究文档”
  - `content-source-to-markdown`

- “帮我记一下 / 查一下我之前记的笔记 / 新建笔记 / 追加到笔记里”
  - `ima-skills`

## 组合使用建议

常见组合：

1. **评论洞察链路**
   - `review-analysis` → `review-defect-miner` → `faq-generator-from-reviews`

2. **商品页优化链路**
   - `content-source-to-markdown` → `listing-gap-audit` → `faq-generator-from-reviews`

3. **文案风控链路**
   - `creator-monetization-risk-checker` → `tiktok-claim-rewriter`

## 注意事项

- 这些 skill 当前是 **workspace 级共用**；为了让团队常用 workspace 都能调用，已开始执行跨 workspace 同步安装。
- 后续新安装的共享型 skill，默认应继续同步到常用 workspace，而不是只停留在单一 workspace。
- 当前已提供批量同步脚本：`scripts/sync-shared-skills.ps1`
- 商业使用、对外发布、批量团队复用时，仍应注意来源仓库的许可证要求。
- 调用 skill 时优先使用真实输入，不要让模型自己脑补不存在的数据。
- 涉及平台规则判断时，应把结论视为“风险辅助判断”，不要当成最终法律或平台官方裁定。

---

_Last updated: 2026-03-17_
