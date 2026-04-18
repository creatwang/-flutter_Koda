# 状态持久化策略

## 介质与恢复时机

- token（含站点 companyId）
  - 持久化介质：`FlutterSecureStorage`
  - 写入时机：登录成功后写入
  - 恢复时机：`sessionControllerProvider.build()`（应用启动阶段）

- 用户资料（`UserInfoBase`）
  - 持久化介质：`FlutterSecureStorage`
  - 存储键：`user_info_base`
  - 写入时机：
    - 登录成功后写入登录接口返回的用户信息
    - 前台回归同步（`SessionSyncController.refreshOnResume()`）请求
      `/store/user/info` 成功后覆盖写回
    - Settings 右上角手动刷新成功后覆盖写回
  - 恢复时机：`profileUserInfoProvider.build()` 直接读取本地 `user_info_base`
  - 说明：进入 Settings 不强制立即请求；优先展示本地缓存，再按策略同步

- 站点信息（`SiteInfoDto`）
  - 持久化介质：`SharedPreferences`
  - 存储键：`site_info_v1`
  - 写入时机：
    - 登录成功后请求 `/store/siteInfo?company_id=...` 成功时写入
    - 前台回归同步成功时覆盖写入
  - 恢复时机：按需通过 `readSiteInfoFromLocal()` 读取

- 导出报价权限（由站点信息派生）
  - 持久化介质：`SharedPreferences`
  - 计算来源：`SiteInfoDto.pluginUniqid` 是否包含 `export_quotation`
  - 写入时机：随 `site_info_v1` 一并更新（不单独存布尔键）
  - 消费方式：`canExportQuotationProvider` 读取本地站点信息并按插件 key 计算

- 购物车（`List<CartListDto>`，按站点聚合）
  - 持久化介质：`SharedPreferences`
  - 写入时机：购物车远端拉取成功与本地操作成功后回写缓存
  - 恢复时机：
    - `cartControllerProvider.build()` 登录后先读本地缓存
    - 本地无缓存时，再请求远端拉取并回写
    - 缓存键：统一聚合键（不区分 `companyId`）
    - 未登录：购物车为空（不启用游客购物车持久化）
  - 页面策略：
    - 采用懒加载：不在登录完成时强制请求购物车列表
    - 进入购物车页面时触发 provider 初始化并请求
    - 购物车页支持下拉刷新（`RefreshIndicator -> refresh()`）

## 前台回归同步策略

- 触发条件：应用生命周期进入 `AppLifecycleState.resumed`
- 同步入口：`sessionSyncProvider.notifier.refreshOnResume()`
- 同步内容：
  - 用户信息：`/store/user/info`
  - 站点信息：`/store/siteInfo`
- 同步控制：
  - 节流窗口：60 秒
  - 并发保护：同一时刻仅允许一个同步任务
- 失败策略：静默降级（不弹错、不改登录态，继续使用本地缓存）
- UI 刷新：同步后失效 `canExportQuotationProvider` /
  `profileUserInfoProvider`，页面读到新值后自动重建

## 用户切换与登出

- 用户登出时清空购物车缓存。
- 用户登出时清空站点信息缓存（`site_info_v1`），导出权限随之失效。
- 用户登出时清空登录态存储（包含 `user_info_base`、`company_id`、`token_map` 等）。
- 登录后按需刷新 `/store/cart/listsBySite`，确保跨站点购物车最终以服务端为准。
