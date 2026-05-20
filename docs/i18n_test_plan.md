# 国际化（i18n）测试方案

> 适用版本：全面 i18n 迁移完成后  
> 关联文档：[i18n_migration_audit.md](./i18n_migration_audit.md)、[i18n_regression_checklist.md](./i18n_regression_checklist.md)

---

## 1. 测试目标

- 验证 **中文 / 英文** 切换后，主流程 UI 与 **前端 fallback 错误/Toast/弹窗** 文案正确。
- 验证语言选择 **持久化**（杀进程重启仍生效）。
- 确认 **接口返回 message** 仍以服务端原文展示（不被错误覆盖为英文 fallback）。

---

## 2. 环境与前置

| 项 | 要求 |
|----|------|
| 构建 | `flutter pub get` → `flutter gen-l10n` → Debug 运行 |
| 账号 | 至少 1 个可登录业务员账号；可选客户账号用于代客登录 |
| 设备 | 建议手机 + 平板（或桌面宽屏）各测一轮 |
| 网络 | 正常网络 + 可切换飞行模式测离线 fallback |

---

## 3. 语言切换基础（必测）

| ID | 步骤 | 预期（中文） | 预期（English） |
|----|------|----------------|-----------------|
| L-01 | Profile → Settings → 语言选 **中文** | 侧栏、按钮等为中文 | — |
| L-02 | 同上选 **English** | — | 侧栏、按钮等为英文 |
| L-03 | 选 **跟随系统**，系统语言分别为 zh / en | 与应用系统语言一致 | 同左 |
| L-04 | 选中文后 **强杀进程** 再打开 | 仍为中文 | — |
| L-05 | 选英文后强杀再打开 | — | 仍为英文 |
| L-06 | 切换语言时位于购物车 Tab | 购物车标题、空态、按钮随语言更新，无残留英文 | 同左 |

---

## 4. 模块功能测试

### 4.1 认证

| ID | 操作 | 预期 |
|----|------|------|
| A-01 | 登录模式：空用户名提交 | 顶部 **警告** Toast：必填类中文/英文 |
| A-02 | 注册模式：密码 &lt; 6、两次不一致 | 对应校验文案为当前语言 |
| A-03 | 错误密码登录 | **错误** Toast：接口 message 或 `authLoginFailed` 类 fallback |
| A-04 | 注册成功 / 失败 | 成功跳转首页；失败为当前语言错误提示 |
| A-05 | Token 失效（或 mock 1000 业务码） | 会话过期弹窗：标题/正文/按钮为当前语言 |

### 4.2 首页

| ID | 操作 | 预期 |
|----|------|------|
| H-01 | 顶栏：Home / Products / Cart / Profile | 文案随语言 |
| H-02 | 登出失败（可断网后点登出） | 错误 Toast 为当前语言或接口 message |
| H-03 | Debug 构建：Secure Storage FAB | Tooltip 为 `debugSecureStorageTitle` 对应语言 |

### 4.3 商品

| ID | 操作 | 预期 |
|----|------|------|
| P-01 | 未登录：列表加购 / 扫码 | 警告 Toast「请先登录」类 + 跳转登录 |
| P-02 | 已登录：加购成功 | 底部 SnackBar「已加入购物车」类 |
| P-03 | 详情：Buy Now / Add to Cart / 规格侧栏 **确认** | 按钮为当前语言 |
| P-04 | 筛选、排序、空列表 | 面板与 `commonNoData` 为当前语言 |
| P-05 | 断网打开列表 | 错误区 + 重试按钮 `commonRetry` |

### 4.4 购物车 / 预订单

| ID | 操作 | 预期 |
|----|------|------|
| C-01 | 未登录加购（若可触发） | `errorPleaseSignInFirst` |
| C-02 | 清空 / 删除选中：确认弹窗 + 成功 SnackBar | 全文案当前语言 |
| C-03 | 改规格：侧栏 Confirm | `commonConfirm` |
| C-04 | 预订单 Checkout 成功 | `preOrderOrderCreated` 类 SnackBar |
| C-05 | 仍有未下单商品加购（code 100000） | 未下单引导弹窗为当前语言 |

### 4.5 个人中心

| ID | 操作 | 预期 |
|----|------|------|
| R-01 | 修改密码：校验必填、长度、不一致 | `commonRequired` / `commonMinSixCharsShort` / `commonNotMatch` |
| R-02 | 我的客户：增删改、代客登录、重置公共密码 | 表单标签、成功/失败 Toast |
| R-03 | 切换站点 BottomSheet | 标题、按钮、失败提示 |
| R-04 | 收藏 / 订单列表空态 | `commonNoData` |

### 4.6 全局反馈

| ID | 操作 | 预期 |
|----|------|------|
| G-01 | 触发无 message 的 `YnToast.success/error` | 默认 `toastSuccess` / `toastError`（非 `success!`） |
| G-02 | 业务接口返回 `code != 0` 且带 message | 展示 **接口 message**（可与 UI 语言不同） |
| G-03 | 业务接口失败且无 message | `errorRequestFailed` 等 fallback 为当前语言 |

---

## 5. 无 Context 层抽测（开发/QA 可选）

通过断网或 mock 触发下列接口失败，确认 Toast/异常文案为**当前应用语言**（非固定英文）：

- 登录 / 注册 / 登出  
- 商品列表、详情、收藏  
- 购物车增删改、报价导出  
- 客户列表 CRUD、代客登录  
- 切换站点  

---

## 6. 通过标准

- [ ] L-01～L-06 全部通过  
- [ ] 第 4 节每模块至少执行 **80%** 用例且无 **P0** 文案错误（整屏英文残留、按钮仍为写死英文）  
- [ ] `dart analyze lib` 无 error  
- [ ] 发版前完成 [i18n_regression_checklist.md](./i18n_regression_checklist.md)

---

## 7. 缺陷记录模板

| 编号 | 语言 | 页面 | 操作 | 实际 | 期望 | 严重度 |
|------|------|------|------|------|------|--------|
| I18N-001 | en | … | … | … | … | P0/P1/P2 |
