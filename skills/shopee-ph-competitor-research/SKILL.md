---
name: shopee-ph-competitor-research
description: Research a Shopee Philippines store or product page with the automation browser, extract product structure and competitive signals, then organize the findings into a Feishu doc and a Bitable for competitor research and product development decisions. Use when the user shares a Shopee PH store/product URL and wants competitor analysis, product selection insight, a Feishu report, a Bitable tracker, or a reusable PH local-store research workflow.
---

# Shopee PH Competitor Research

Research Shopee Philippines competitors with a fixed delivery workflow:
1. open the Shopee URL with the automation browser
2. inspect the store / product listing
3. extract visible product and store signals
4. create a Feishu doc report
5. create a Bitable tracker
6. fill decision fields for PH local-store product development

## Use this workflow

Apply it when the user wants any of the following from a Shopee Philippines URL:
- competitor research
- store/product analysis
- product selection / 开发选品
- Feishu doc output
- Bitable output
- PH local-store suitability judgment

## Core workflow

### 1. Open the target URL in the automation browser
- Prefer the browser tool, host target.
- Browser automation priority:
  1. `profile="user"` first
  2. only if attach/existing-session fails, or the user explicitly asks, fall back to `chrome-relay`
  3. if relay is unavailable or the user explicitly wants the isolated browser, fall back to `openclaw`
- Treat `profile="user"` as the default existing-session / Chrome DevTools MCP path.
- If `profile="user"` requires user confirmation / attach approval and the user has not confirmed yet, pause and ask for that confirmation instead of silently switching routes.
- Open the provided Shopee PH store or product URL.
- Capture the page title and confirm whether the page is accessible.
- If browser status is down, start the browser first.
- Do not choose `chrome-relay` or `openclaw` first unless the user asked for them or `profile="user"` attach failed.

### 2. Capture the store-level signals
From the store homepage, collect if visible:
- store name
- product count
- followers
- rating and rating count
- chat performance
- joined time
- visible categories

### 3. Capture the product list
Use page evaluation or snapshot extraction to collect visible products.
For each product, try to capture:
- product name
- category
- price
- rating
- sold count
- sold per month if visible
- product URL
- rough role in the assortment

Important:
- de-duplicate by product id / URL
- accept partial extraction when Shopee lazy-loads
- do not wait forever for full-page perfection; aim for a decision-useful set

### 4. Build the competitor judgment
Analyze:
- assortment structure
- low-price traffic products
- core mid-ticket products
- high-ticket profit products
- content-friendly / visual products
- risky products with weak ratings or likely after-sales burden

### 5. Create the Feishu doc
Create a Feishu doc and grant requester access.
Write a structured report with these sections:
- store basic info
- positioning summary
- assortment structure
- top products worth studying
- risks
- competitor conclusion
- product-development recommendations
- PH local-store recommendations

### 6. Create the Bitable
Create a Bitable app for the SKU tracker.
Build fields for SKU-level judgment.
Minimum recommended fields:
- product name
- category
- price
- rating
- sold
- sold per month
- positioning
- notes
- url text
- product stage
- worth copying
- development priority
- core pain point
- use case
- differentiation point
- risk level
- development suggestion
- traffic source
- fit for PH local store
- recommended action
- creative performance
- after-sales pressure
- shipping complexity
- search vs content
- PH local-store play suggestion

### 7. Fill the Bitable
At minimum, fill the core / high-value SKUs first.
If the user asks for full completion, continue filling all visible products.

### 8. Full-SKU completion standard
When the user asks for `全量 SKU 补表`, `补全量`, `补完整`, or equivalent intent, use this completion standard.

#### Goal
Turn the table from a core-SKU tracker into a near-complete visible SKU database for decision-making.

#### Scope
- Include all unique visible SKUs that can be extracted from the Shopee page during the current browsing session.
- De-duplicate repeated cards, top-product duplicates, and ranking duplicates.
- Prefer unique product id / URL as the de-duplication key.
- If the store page shows `28 products` but only `27` unique visible SKUs are extractable, record `27 visible / 28 claimed by store` instead of pretending full certainty.

#### Required fill rate
For full-SKU completion, every included SKU should have these fields whenever visible:
- product name
- category or best-fit category
- price
- rating
- sold count
- sold per month if visible
- product URL text
- positioning
- product stage
- worth copying
- development priority
- core pain point
- use case
- differentiation point
- risk level
- development suggestion
- traffic source
- fit for PH local store
- recommended action
- creative performance
- after-sales pressure
- shipping complexity
- search vs content
- PH local-store play suggestion

#### Allowed partials
If Shopee does not expose a field clearly, leave it blank or mark it conservatively.
Do not invent precision.
Examples:
- rating not visible -> blank
- sold per month not visible -> blank
- category not explicit -> infer a practical best-fit category from product type

#### Full-completion note in delivery
When reporting back to the user, explicitly label one of these:
- `核心 SKU 已补齐，非全量`
- `全量可见 SKU 已补齐`
- `已补齐当前可见全量 SKU，仍少于店铺声称总数`

#### Priority order for full completion
When filling many rows, work in this order:
1. finish all high-signal visible SKUs first
2. fill remaining visible SKUs with core commercial fields
3. then add judgment / PH-local-store fields to all rows
4. finally add notes about gaps, duplicates, or visibility limits

#### Recommended-product sorting standard
When the user asks for full completion, also sort / present the SKU table by recommendation strength whenever the table structure allows it.
If manual row ordering is the practical option, place the strongest recommendations first.
If a sortable field is better, add / use a ranking field conceptually equivalent to `推荐排序`.

Use this ranking logic from strongest to weakest:
1. **A1** = best overall recommendation for PH local store
2. **A2** = strong recommendation
3. **B1** = worth tracking / secondary development option
4. **B2** = can be used as a supporting / content SKU
5. **C1** = observe only / later-stage candidate
6. **C2** = risky / not recommended early

Determine ranking by combining:
- fit for PH local store
- pain point clarity
- search demand clarity
- creative performance
- after-sales pressure
- shipping complexity
- differentiation point
- price-band role in the assortment

Practical interpretation:
- put small, clear, easy-to-ship, easy-to-convert SKUs near the top
- put high-complexity, high-after-sales, weak-rating, or unclear-local-advantage SKUs near the bottom
- if two SKUs are close, rank the one with stronger `搜索+内容双强` or clearer local-store advantage higher

#### Delivery requirement for sorted full table
When delivering the result, explicitly state that the full SKU table is sorted by recommended priority if that sorting was applied.
Suggested wording:
- `已按最推荐商品优先排序`
- `全量可见 SKU 已补齐，并按开发优先级排序`

#### Quality rule
A full-SKU table does not mean perfect scraping completeness.
It means the table is decision-useful, transparent about gaps, complete for the visible unique SKU set, and ordered in a way that helps product-selection decisions.

## PH local-store judgment rules

For Shopee Philippines local-store decisions, weigh these factors more heavily:
- fast local fulfillment advantage
- small/light items are preferred early
- low after-sales burden is preferred early
- clear visual demonstration helps conversion
- clear search intent helps stable daily orders

Use these practical interpretations:
- **适合PH本土店**: simple, clear, easy to ship, easy to explain
- **可做但非优先**: can work, but not ideal as an early core SKU
- **不建议优先 / 谨慎**: higher support burden, rating risk, complexity, or unclear local advantage

## Output standard

When replying to the user after delivery, include:
- Feishu doc link
- Bitable link
- 2-5 bullet summary of the strongest conclusions
- explicit note if the table is core-SKU complete vs full-SKU complete
- if requested or useful for product-selection decisions, include a candidate-development list summary

### Candidate-development list standard
When the user is doing `开发选品`, `候选品筛选`, `竞品转开发`, or equivalent product-selection work, produce a candidate-development list in addition to the doc / table when useful.

Use this structure:
- **A1-A2 优先开发清单**
- **B1-B2 备选清单**
- **C1-C2 谨慎/观察清单**

For each candidate item, include:
- product name
- recommendation tier
- why it is placed there
- suggested development direction
- whether it is better for search, content, or both

#### Candidate-list decision logic
Rank candidates by combining:
- fit for PH local store
- pain point clarity
- conversion clarity
- creative performance
- shipping simplicity
- after-sales pressure
- differentiation potential
- whether the SKU helps build a balanced assortment

#### Candidate-list output style
Keep it decision-oriented.
Do not just repeat the table.
Summarize what should be developed first, what can be tested next, and what should be delayed.

Suggested wording style:
- `优先开发` = suitable to move into active sourcing / development discussion now
- `备选` = worth keeping in the pipeline after first-priority items
- `谨慎/观察` = not ideal for early rollout, or needs more validation

## Quality bar

- Optimize for decision usefulness, not perfect scraping completeness.
- Be honest about visibility limits and lazy-loaded gaps.
- Separate引流款 / 主销款 / 利润款 / 内容款 / 测试款.
- Tie recommendations to PH local-store operations, not generic ecommerce advice.
- Prefer concrete judgments over vague summaries.

## If the user asks to solidify / reuse / template the workflow
Treat this skill itself as the reusable standard workflow.
When improving it later, keep the same delivery contract:
- browser research
- Feishu doc
- Bitable tracker
- PH local-store decision fields

## Resources

Read `references/output-template.md` before writing the final report structure if you need a ready-made outline.
