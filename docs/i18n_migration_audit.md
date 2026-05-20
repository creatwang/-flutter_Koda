# 国际化（i18n）遗漏排查报告

> 排查日期：2026-05-19  
> 范围：`lib/app`、`lib/core`、`lib/shared`、`lib/features`（**不含** `lib/examples`）  
> 原则：凡 **Flutter 前端写死**、会展示给用户的文案（页面、弹窗、Toast、校验、业务错误 fallback）均应走 ARB；**接口返回的 `message`** 原样展示。

---

## 1. 排查方法

| 手段 | 说明 |
|------|------|
| 全文检索 | `Text('…')`、`hintText`/`tooltip`、`AppException('…')`、`showGlobal*Message('…')`、中英文字面量 |
| 分层核对 | `presentation` → `controllers` → `services` → `core` 拦截器 |
| 静态分析 | `dart analyze lib`（无 error） |
| 生成校验 | `flutter gen-l10n`，`app_en.arb` / `app_zh.arb` 键一致 |

---

## 2. 架构约定（已实现）

| 场景 | 用法 |
|------|------|
| 有 `BuildContext` | `context.l10n.xxx`（`lib/shared/extensions/build_context_x.dart`） |
| 无 Context（service、拦截器、启动早期） | `appL10n.xxx`（`lib/shared/l10n/app_localizations_accessor.dart`） |
| 文案源 | `lib/l10n/app_en.arb`（模板）、`app_zh.arb` |
| 语言切换与持久化 | Profile → Settings → `LocaleDropdown`；`SharedPreferences` + `main.dart` 启动注入 |

---

## 3. 已覆盖模块（摘要）

- **应用壳**：`app_shell`、`locale_provider`、`main.dart` 早期 `bindAppLocalizationsResolver`
- **认证**：登录/注册页、会话 provider、auth/store/site 等 services
- **首页**：导航、登出、Debug FAB tooltip（`debugSecureStorageTitle`）
- **商品**：列表/详情/筛选/扫码/ SKU 侧栏、product services 错误 fallback
- **购物车 / 预订单**：页面、清空确认流、加购拦截、cart services / providers
- **个人中心**：侧栏、设置、客户、收藏、订单、切站 BottomSheet、表单校验
- **全局组件**：`YnToast` 默认文案、`show_george_*_dialog` 默认按钮、会话过期弹窗、未下单引导
- **网络层**：`response_data_mode_interceptor` 请求失败/网络错误/会话过期默认文案
- **调试页**：`secure_storage_debug_page`（仅 `kDebugMode` 入口）

---

## 4. 本轮补漏项

| 文件 | 问题 | 处理 |
|------|------|------|
| `home_page.dart` | Debug FAB `tooltip: 'Secure Storage Debug'` | → `l10n.debugSecureStorageTitle` |
| `auth_session_snapshot_services.dart` | `StateError('Missing company_id/token')` 可能进入 `e.toString()` 展示 | → `appL10n.errorMissingCompanyId` / `errorMissingToken` |
| （前序会话已做） | auth/cart/profile/product services、session/cart providers、yn_toast、secure_storage_debug 等 | 已接 `appL10n` / `l10n` |

---

## 5. 刻意不纳入 i18n 的范围

| 类型 | 示例 | 原因 |
|------|------|------|
| 接口业务文案 | `showGlobalErrorMessage(exception.message)`、`map['message']` | 服务端原文，按产品约定保留 |
| 日志 / 开发追踪 | `log('Quotation preview ignored…')`、`name: 'pre_order.export…'` | 不面向终端用户 |
| JSON / 存储键 / 路由 | `'company_id'`、`AppRoutes.login` | 非 UI 文案 |
| 注释与文档字符串 | `/// 拉取客户列表` | 不展示 |
| 注释掉的 UI | `login_page.dart` 内 Terms 区块（`/* … */`） | 未启用；若恢复需先加 ARB 键 |
| 示例工程 | `lib/examples/**` | 演示代码，非主应用交付面 |
| 内部断言（可选） | `product_providers.dart` 的 `Stale products refresh response` | 仅开发期 StateError，极少触达 UI |

---

## 6. 残留与维护建议

1. **新增文案**：只改 `app_en.arb` / `app_zh.arb`，执行 `flutter gen-l10n`（见根目录 `README.md`），禁止临时合并脚本。
2. **Code Review 检查项**：PR 中不得新增用户可见英文字面量（除 ARB 与测试）。
3. **启用登录页底部条款**：取消注释前增加 `authTermsNotice`、`authCopyright` 等键并中英翻译。
4. **定期扫描命令**（PowerShell）：

```powershell
cd d:\webstormProject\george_pick_mate
rg "Text\(\s*['\`"]" lib\features lib\shared lib\app lib\core --glob "*.dart"
rg "AppException\(\s*['\`"]" lib --glob "*.dart"
rg "showGlobal\w+Message\(\s*['\`"]" lib --glob "*.dart"
```

---

## 7. 结论

主应用 `lib/features` + `lib/shared` + `lib/core` + `lib/app` 内 **用户可见写死文案已迁移至 ARB**；展示层无 `Text('英文…')` 命中；services/controllers 业务 fallback 已统一 `appL10n`。  

请配合 [i18n_test_plan.md](./i18n_test_plan.md) 做人工验证，并用 [i18n_regression_checklist.md](./i18n_regression_checklist.md) 做发版前回归。
