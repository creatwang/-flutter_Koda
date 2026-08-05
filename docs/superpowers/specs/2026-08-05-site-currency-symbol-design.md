# 站点货币符号设计

**日期**：2026-08-05  
**状态**：已确认并实施  
**来源**：`GET /store/siteInfo` → `result.currency`

## 背景

应用内价格展示多处硬编码 `$`。后台站点信息已提供 `currency`（`CurrencyCode`），需按币种展示对应符号。

## 目标

1. 从 `siteInfo.currency` 解析币种并映射为货币符号。
2. 所有现有硬编码 `$` 的价格展示改为使用站点符号。
3. `currency` 缺失、未知或不在枚举内时：**不显示符号，只显示数字**。

## 非目标

- 不新增独立 currency HTTP 接口（复用现有 `/store/siteInfo`）。
- 不统一金额小数位策略（各调用点保留现有精度）。
- 不自动 git commit / push。

## 数据与映射

`CurrencyCode`：

| Code | 符号 |
| --- | --- |
| RMB | ¥ |
| USD | $ |
| EUR | € |
| GBP | £ |
| HKD | HK$ |
| AUD | A$ |
| CAD | C$ |
| PHP | ₱ |

未知 / null / 空字符串 → 符号 `''`。

## 架构落位

| 层 | 路径 | 职责 |
| --- | --- | --- |
| Model | `features/auth/models/site_info_dto.dart` | 增加 `currency` 字段，参与 fromJson/toJson |
| Shared | `shared/currency/currency_code.dart` | 枚举 + 符号 Map + `currencySymbolOf` |
| Shared | `shared/currency/price_format.dart` | `formatPrice(amount, symbol, …)` |
| Provider | `features/auth/controllers/session_providers.dart`（或邻近 providers） | `siteCurrencySymbolProvider` 读本地 siteInfo |
| Presentation | 现有价格 UI（约 8 处） | 改用 provider 符号 + `formatPrice` |
| L10n | `app_en.arb` / `app_zh.arb` 的 `cartTotal` | 去掉字面 `$`，由调用方传入已格式化金额或符号占位 |

调用链保持：`presentation → providers → services → api`。货币映射为纯逻辑，放 `shared`，不新建完整 feature 模块。

## 同步与失效

- 继续复用 `syncSiteInfoToLocal`（登录 / 切站 / resume）。
- 在现有 `ref.invalidate(canExportQuotationProvider)` 处同步 invalidate `siteCurrencySymbolProvider`。

## 展示规则

- 有符号：`{symbol}{formattedAmount}`（如 `$12.00`、`¥12.00`、`HK$12.00`）。
- 无符号：`{formattedAmount}`（如 `12.00`）。
- 金额格式化参数（小数位、千分位）由调用点按现状传入，本需求只替换符号来源。

## 验收标准

1. siteInfo 返回 `USD` 时价格前缀为 `$`；`RMB` 为 `¥`；其余枚举与表一致。
2. 无 currency / 未知值时价格无前缀符号。
3. 切站并同步 siteInfo 后，符号随本地缓存更新。
4. `dart analyze lib` 无本次引入的 error。

## 风险与假设

- 假设响应字段名为 `currency`（与前端约定一致）；若实际在 `result` 包装层，沿用现有 `SiteInfoDto.fromDio` 解包逻辑。
- 旧本地缓存无 `currency` 时按无符号处理，直到下次成功 sync。
