# 状态持久化策略

## 介质与恢复时机

- token（含站点 companyId）
  - 持久化介质：`FlutterSecureStorage`
  - 写入时机：登录成功后写入
  - 恢复时机：`sessionControllerProvider.build()`（应用启动阶段）

- 用户资料（`UserProfileInfoDto`）
  - 持久化介质：`FlutterSecureStorage`
  - 写入时机：用户资料拉取成功、资料更新后刷新成功
  - 恢复时机：`profileUserInfoProvider.build()` 先读本地缓存，再拉远端校准

- 购物车（`List<CartListDto>`，按站点聚合）
  - 持久化介质：`SharedPreferences`
  - 写入时机：购物车远端拉取成功与本地操作成功后回写缓存
  - 恢复时机：`cartControllerProvider.build()` 登录后先读本地缓存，再拉远端校准
    - 缓存键：统一聚合键（不区分 `companyId`）
    - 未登录：购物车为空（不启用游客购物车持久化）

## 用户切换与登出

- 用户登出时清空购物车缓存。
- 登录后刷新 `/store/cart/listsBySite`，确保跨站点购物车最终以服务端为准。
