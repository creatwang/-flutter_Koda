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
  - 与 `main_user_info` 的分工见下节「主账号快照」：后者不替代本键，仅用于
    代客态下切回主账号。

- 主账号快照（`main_user_info`，仅业务员代客场景）
  - 持久化介质：`FlutterSecureStorage`
  - 存储键：`main_user_info`
  - 内容形态：与 `user_info_base` 相同，整份 `UserInfoBase` JSON（含当时主账号的
    `token`、`company_id`、`is_auth_account` 等）。
  - 写入时机：
    - 在调用 `POST /store/account/customerLogin` **之前**，从当前
      `user_info_base` 读出业务员快照并写入；
    - 若本地**已有** `main_user_info`（已在代客态），则**不再覆盖**，避免把
      当前客户资料误写成主快照。
  - 读取与消费：
    - `mainUserInfoProvider` 异步读取该键；
    - Profile → Settings：存在快照时展示 **Switch Account**，否则仅展示
      **Sign Out**。
  - 清除时机：
    - **切回主账号**（Switch Account）：用快照写回当前会话（`user_info_base`
      / `company_id` / `token_map` 等与登录落盘一致）后**删除**该键；
    - **代客登录失败**：若本轮曾新写入过 `main_user_info`，则回滚删除；
    - **整包登出**：`secureStorageService.clear()` 会一并删除（与
      `user_info_base` 等同级别清理）。
  - 与当前用户资料的关系：
    - 代客成功后，接口返回的客户 `UserInfoBase` 写入 `user_info_base` 并更新
      会话；此时 `is_auth_account` 等以接口为准（通常客户为 `false`，侧栏
      「My Customers」等业务员入口随之隐藏）。
    - `main_user_info` 与 `user_info_base` 分工：**前者**只用于「能否切回
      主账号」；**后者**始终表示**当前登录身份**。
  - 代码入口（编排与存储 API）：
    - `lib/features/auth/controllers/session_providers.dart`：
      `SessionController.loginAsStoreCustomer`（代客前写入/失败回滚、成功后
      `persistAuthenticatedUserSnapshot` 更新当前用户与会话）；
      `SessionController.switchBackToMainUser`（读快照恢复会话后
      `clearMainUserInfo`）。
    - `lib/core/storage/secure_storage_service.dart`：
      `saveMainUserInfo` / `readMainUserInfo` / `clearMainUserInfo`（键名
      `main_user_info`）。
    - `lib/features/auth/controllers/main_user_providers.dart`：
      `mainUserInfoProvider`（供 UI 判断是否存在主账号快照）。
    - `lib/features/profile/presentation/pages/profile_page.dart`：
      `_onSwitchAccount` 调用 `switchBackToMainUser`。

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

## Provider 生命周期策略（autoDispose 对照）

- 自动销毁（`autoDispose`，离开页面/无监听后释放）：
  - `profileMyOrderListProvider`
  - `profileCustomerOrderListProvider`
  - `storeCustomersProvider`
  - `productDetailProvider`
  - `mainUserInfoProvider`
  - `profileCartServerNumProvider`
  - `storeCompanyListProvider`
  - `myCustomerOrdersViewUserIdProvider`
  - `myCustomerUserOrdersProvider`

- 非自动销毁（保留内存态，按需手动 `invalidate/refresh`）：
  - `productsProvider`
  - `favoriteProductsProvider`
  - `cartControllerProvider`
  - `profileUserInfoProvider`
  - `sessionControllerProvider`

## 内存网络缓存策略（Dio Interceptor）

- 介质：`MemoryCacheInterceptor`（进程内 `Map`，应用重启后清空）
- 作用范围：`publicDioClient` 与 `protectedDioClient`
- 默认 TTL：2 分钟（在 `network_clients.dart` 注入时配置）
- 缓存键：`path + '?' + queryParameters`
- 命中前提：
  - 请求为 `GET`
  - 且 `extra['noCache'] != true`
  - 且缓存项存在且未过期

### Session 变更时的统一清理（已落地）

以下场景会调用 `clearAllNetworkMemoryCaches()`，直接清空两套 Dio
客户端内存缓存，避免跨会话串读：

- 切换站点：`SessionController.switchShop`
- 退出登录：`SessionController._clearLocalSessionAfterLogout`（`signOut` /
  `signOutWithRemoteLogout` 共用）
- 代客登录切换账号：`SessionController.loginAsStoreCustomer`
- 切回主账号：`SessionController.switchBackToMainUser`

### 手动失效 API（A 方案）

`MemoryCacheInterceptor` 提供：

- `clearAll()`
- `evictKey(String key)`
- `evictByPrefix(String prefix)`

平台层暴露：

- `clearAllNetworkMemoryCaches()`：清理 public/protected 全部缓存
- `evictProtectedNetworkCacheByPrefix(prefix)`：定向清理鉴权客户端缓存

### 写后失效映射（首批：用户列表）

为避免“写操作成功后 refresh 仍读到旧缓存”，已对客户列表采用「写后
按前缀失效」：

- 列表 GET 接口：`/store/account/customer`
- 失效前缀：`/store/account/customer?`
- 写操作成功后清理：
  - `createStoreCustomerService`
  - `updateStoreCustomerService`
  - `deleteStoreCustomerService`

说明：

- 该链路已移除 `requestStoreCustomerList` 的 `noCache:true`
- 依赖写后前缀失效 + session 切换全清，保证一致性与命中率平衡

## 用户切换与登出

- 用户登出时清空购物车缓存。
- 用户登出时清空站点信息缓存（`site_info_v1`），导出权限随之失效。
- 用户登出时清空登录态存储（包含 `user_info_base`、`company_id`、`token_map`、
  `main_user_info` 等，以 `secureStorageService.clear()` 为准）。
- 登出路径的 Riverpod 约定（避免登出后再打业务接口）：
  - **不** `invalidate` 商品列表、收藏、分类树、订单列表等会触发 `build` 拉
    网的 provider；
  - `profileUserInfoProvider` 使用 `resetAfterLogout()` 仅清空**内存态**，不
    `invalidate` 该 provider（避免再走 `build → /store/user/info`）；
  - 可 `invalidate(mainUserInfoProvider)`：其 `build` 仅**重读安全存储**，无
    网络请求，用于登出后主账号快照 UI 立即与本地一致。
- 登录后按需刷新 `/store/cart/listsBySite`，确保跨站点购物车最终以服务端为准。
- 登录成功、切店、代客登录、切回主账号等会话仍有效且需刷新列表数据时，通过
  `_invalidateAfterStoreContextChanged()` 统一失效相关 provider（含
  `profileUserInfoProvider` 等），与「登出仅清存储」区分。
