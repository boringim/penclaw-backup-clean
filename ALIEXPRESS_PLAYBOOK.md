# ALIEXPRESS_PLAYBOOK.md

## 目标
把 AliExpress 搜索页处理成稳定、可复用的选品流程，默认用于大哥直接甩搜索链接过来的场景。

## 默认流程
1. 确认是不是正常搜索结果页
2. 找有没有 `Orders` / 销量排序
3. 切到销量排序
4. 抓前 10 条
5. 写进飞书并返回链接

## 当前已验证可行的做法
- 用 browser 打开搜索页
- 通过页面文本 / DOM 判断是否存在 `Orders`
- 点击排序项后，URL 会出现：`sortType=total_tranpro_desc`
- 再从页面链接中提取包含 `sold` 的商品项
- 用 feishu_doc 写成报告

## 当前已知问题
1. 结果会混入广告（Ad）
2. 结果会混入 welcome gift / bundle / SSR 聚合页
3. 页面上的高销量不等于最适合买给猫
4. 报告已经可用，但还不够像真正的采购结论

## 下一版升级方向
### A. 结果清洗
- 排除带 `Ad` 标识的项
- 排除 `welcomegiftspmpc` / `BundleDeals` / `ssr` 聚合链接
- 尽量优先保留真正单品页（如 `/item/`）

### B. 结构化字段
每条尽量统一输出：
- 标题
- 当前价
- 原价（如有）
- 评分
- 销量
- 链接
- 是否广告
- 是否聚合页
- 是否 steam/spray 噱头款
- 是否更像正经猫梳

### C. 选品判断
更适合优先推荐：
- self-cleaning
- one-click
- slicker
- round-tip
- bent needles
- rating >= 4.8
- sold 高

谨慎项：
- steam / spray / steamy
- massage 噱头词过多但缺少梳毛核心结构描述
- 角落蹭毛刷 / 洗澡刷 / 手套刷混进普通猫梳搜索结果

### D. 飞书报告升级
建议输出结构：
1. 页面与排序确认
2. 清洗后的前 10 条表
3. 推荐 3 条
4. 不推荐 3 条
5. 原因总结

## 默认回复策略
当大哥直接发 AliExpress 搜索链接时：
- 默认不再问“要不要继续”
- 直接按这套流程执行
- 如果页面异常（验证、登录墙、无 Orders），再汇报阻塞点

## 备注
后续如果把这套流程正式做成 skill：
- skill 名可考虑：`aliexpress-sourcing`
- 触发语义：AliExpress 搜索链接、选品、销量排序、抓前10、写飞书
