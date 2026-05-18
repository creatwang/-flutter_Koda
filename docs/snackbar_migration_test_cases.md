# SnackBar 直调迁移 — 手动测试用例

迁移规则：

| 原语义 | 新 API | 视觉 |
|--------|--------|------|
| 成功 / 中性完成 | `showGlobalSnackBar` | 底部 SnackBar |
| 错误 / 失败 | `showGlobalErrorMessage` | 底部 SnackBar |
| 约束 / 校验 / 需登录等 | `showGlobalWarningMessage` | 顶部 YnToast 警告 |

---

## 0. 冒烟（全局 API）

| ID | 步骤 | 预期 |
|----|------|------|
| S0-1 | 在 examples 首页或临时入口分别触发三种全局 API（若无可跳过，以下用业务场景覆盖） | 成功=底栏 SnackBar；错误=底栏 SnackBar；警告=顶栏橙色 YnToast，约 2.6s 消失 |

---

## 1. 认证 `login_page.dart`

| ID | 前置 | 操作 | 预期 API / 表现 |
|----|------|------|-----------------|
| A1 | 注册模式 | 用户名为空点提交 | **警告** Toast：用户名必填文案 |
| A2 | 注册模式 | 密码 &lt; 6 位 | **警告** Toast：密码长度 |
| A3 | 注册模式 | 确认密码 &lt; 6 位 | **警告** Toast：密码长度 |
| A4 | 注册模式 | 两次密码不一致 | **警告** Toast：不一致 |
| A5 | 注册模式 | 服务端返回失败 | **错误** SnackBar：失败原因或默认注册失败 |
| A6 | 登录模式 | 错误账号密码 | **错误** SnackBar：登录失败 |

---

## 2. 首页 `home_page.dart`

| ID | 前置 | 操作 | 预期 |
|----|------|------|------|
| H1 | 已登录 | 点击退出；模拟远端登出接口失败 | **错误** SnackBar 显示 exception.message |
| H2 | 已登录 | 登出成功 | 跳转登录页，无错误 SnackBar |

---

## 3. 购物车 / 预订单

### 3.1 `cart_page.dart`

| ID | 操作 | 预期 |
|----|------|------|
| C1 | 购物车改规格，故意让详情加载失败（断网/无效商品） | **错误** SnackBar：`productDetailLoadFailed` |

### 3.2 `pre_order_page.dart`

| ID | 操作 | 预期 |
|----|------|------|
| P1 | 预订单改规格失败 | **错误** SnackBar |
| P2 | Checkout 接口返回失败 | **错误** SnackBar：`Checkout failed` |
| P3 | Checkout 成功 | **成功** SnackBar：`Order created successfully` |

### 3.3 `cart_clear_all_confirm_flow.dart`

| ID | 操作 | 预期 |
|----|------|------|
| C2 | 清空购物车 / 删除选中 — 成功 | **成功** SnackBar：已清空 / 已删除选中 |
| C3 | 同上 — 接口失败 | **错误** SnackBar：清空失败 / 删除选中失败 |

---

## 4. 商品

### 4.1 `product_list_page.dart`

| ID | 前置 | 操作 | 预期 |
|----|------|------|------|
| PL1 | 未登录 | 列表加购 | **警告** Toast → 跳转登录 |
| PL2 | 已登录 | 加购成功 | **成功** SnackBar：已加入购物车 |
| PL3 | 已登录 | 详情加载异常 | **错误** SnackBar |

### 4.2 `product_scan_fab_flow.dart`

| ID | 操作 | 预期 |
|----|------|------|
| SC1 | 未登录点扫码 FAB | **警告** Toast → 登录页 |
| SC2 | 扫码后详情解析失败 | **错误** SnackBar |
| SC3 | 扫码无匹配 SKU | **警告** Toast |
| SC4 | 扫码加购成功 | **成功** SnackBar |

---

## 5. 个人中心 / Profile

### 5.1 `profile_page.dart`

| ID | 操作 | 预期 |
|----|------|------|
| PR1 | 保存资料成功 | **成功** SnackBar：`Updated successfully.` |
| PR2 | 子账号切回主账号成功 | **成功** SnackBar → 首页 |
| PR3 | 切回主账号失败 | **错误** SnackBar |

### 5.2 `profile_favorites_section_widget.dart`

| ID | 操作 | 预期 |
|----|------|------|
| F1 | 未登录收藏加购 | **警告** Toast → 登录 |
| F2 | 加购成功 | **成功** SnackBar |
| F3 | 详情失败 | **错误** SnackBar |

### 5.3 `profile_my_customers_section_widget.dart`

| ID | 操作 | 预期 |
|----|------|------|
| MC1 | 代客登录成功 | 进首页后 **成功** SnackBar：`Logged in as customer.` |
| MC2 | 代客登录失败 | **错误** SnackBar |
| MC3 | 删除客户成功 | **成功** SnackBar：`Deleted` |
| MC4 | 删除客户失败（对话框内） | **错误** SnackBar |
| MC5 | 展开客户订单加载失败 | **错误** SnackBar |

### 5.4 客户表单 / 站点

| ID | 文件 | 操作 | 预期 |
|----|------|------|------|
| SF1 | `store_customer_form_bottom_sheet` | 新增/编辑成功 | **成功** SnackBar `Success` 并关闭 sheet |
| SF2 | `store_customer_common_password_bottom_sheet` | 重置通用密码成功 | **成功** SnackBar |
| SF3 | `switch_site_bottom_sheet` | 切换站点失败 | **错误** SnackBar |
| SF4 | `switch_site_bottom_sheet` | 切换成功 | 关闭 sheet 并回首页，无错误提示 |

---

## 6. 回归（不应受影响）

| ID | 场景 | 预期 |
|----|------|------|
| R1 | 网络拦截器业务错误 | 仍走 `showGlobalErrorMessage`（非本次直调范围） |
| R2 | 购物车 provider 未登录加购 | 仍走全局错误 SnackBar |
| R3 | 商品详情页加购成功 | 仍走 `showGlobalSnackBar` |
| R4 | 会话过期 | 仍弹 `showSessionExpiredDialog`，非 SnackBar |

---

## 7. 验收检查清单

- [ ] `lib/features/` 下无 `ScaffoldMessenger.of(...).showSnackBar`
- [ ] 约束类场景均为顶部 **警告** YnToast（非底部 SnackBar）
- [ ] 成功/错误仍为底部 SnackBar，且连发时旧 SnackBar 被 hide（全局封装行为）
- [ ] 导航后提示仍可见（如代客登录成功、切主账号、未登录加购后跳转）

---

## 8. 修改文件一览（便于 Code Review）

- `lib/shared/services/app_message_service.dart` — 新增 `showGlobalWarningMessage`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/cart/presentation/pages/cart_page.dart`
- `lib/features/cart/presentation/pages/pre_order_page.dart`
- `lib/features/cart/presentation/widgets/cart_clear_all_confirm_flow.dart`
- `lib/features/product/presentation/pages/product_list_page.dart`
- `lib/features/product/presentation/widgets/product_scan_fab_flow.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/profile/presentation/widgets/profile_favorites_section_widget.dart`
- `lib/features/profile/presentation/widgets/profile_my_customers_section_widget.dart`
- `lib/features/profile/presentation/widgets/switch_site_bottom_sheet.dart`
- `lib/features/profile/presentation/widgets/store_customer_form_bottom_sheet.dart`
- `lib/features/profile/presentation/widgets/store_customer_common_password_bottom_sheet.dart`
