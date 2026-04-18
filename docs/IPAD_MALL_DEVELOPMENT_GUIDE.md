# iPad 商城开发文档

## 1. 项目定位

本项目是基于 Flutter 的 iPad 商城基础架构，目标是提供一套可直接扩展到生产项目的工程骨架，覆盖以下链路：

- API 请求与统一错误处理
- Token 持久化、自动注入、401 刷新与重放
- DTO/Entity 模型分层与代码生成
- Riverpod 状态管理（含分页、刷新、加载更多）
- GoRouter 类型安全路由
- iPad 端 Header 菜单化导航

---

## 2. 技术栈

- Flutter
- 网络：`dio`
- 响应式：`responsive_framework`
- 状态管理：`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
- 模型：`freezed` + `freezed_annotation`
- JSON：`json_serializable` + `json_annotation`
- 路由：`go_router` + `go_router_builder`
- 资源生成：`flutter_gen_runner`
- 安全存储：`flutter_secure_storage`

---

## 3. 目录结构

```text
lib/
  app/
    app.dart
    router/
      app_router.dart
      app_routes.dart
  core/
    config/
      env.dart
    network/
      dio_client.dart
      interceptors/
    providers/
      core_providers.dart
    result/
      api_result.dart
      app_exception.dart
    storage/
      secure_storage_service.dart
      token_pair.dart
  features/
    auth/
    home/
    product/
    cart/
    order/
  shared/
    widgets/
      adaptive_scaffold.dart
      header_menu_button.dart
      app_loading_view.dart
      app_error_view.dart
      app_empty_view.dart
```

---

## 4. 分层约束

- `presentation`：页面与组件，读取 provider，禁止直接调 Dio
- `domain`：实体与仓储接口
- `data`：DTO、远程数据源、仓储实现
- `core`：可复用基建（网络、缓存、重试、错误、存储）

---

## 5. 从 API 到渲染的数据流

1. UI 触发行为（加载商品、登录、下单）
2. Provider 调用 Repository
3. Repository 调用 RemoteDataSource
4. RemoteDataSource 调用 `DioClient`
5. Interceptor 链自动处理认证、重试、缓存、请求追踪
6. DTO 转 Domain Entity
7. Provider 更新状态
8. UI 根据 `AsyncValue` 渲染 loading/error/data

---

## 6. Header 规范（当前实现）

### 6.1 统一 Header 组件

- 所有主页面使用 `AdaptiveScaffold` 构建 Header
- 菜单按钮使用 `HeaderMenuButton`

### 6.2 菜单选中态

- 选中按钮使用圆角胶囊背景
- 选中态带阴影（圆形/胶囊阴影视觉）
- 通过 `selected` 参数控制

### 6.3 商品详情页 Header

- 与首页复用同一套 Header 样式
- 商品详情通过 `ProductDetailRoute(...).push(context)` 进入
- 因为 `push`，详情页自动显示返回键（`AppBar` 默认 back）

---

## 7. 路由规范

- 文件：`lib/app/router/app_routes.dart`
- 所有跳转使用类型安全路由对象：
  - `HomeRoute(tab: 'cart').go(context)`
  - `ProductDetailRoute(id: 1).push(context)`

说明：
- `go`：切换主场景
- `push`：进入详情并保留返回栈

---

## 8. Token 与认证流程

1. 登录成功后保存 `accessToken/refreshToken`
2. `AuthInterceptor` 自动附加 `Authorization`
3. 接口返回 401 时触发 `RefreshTokenInterceptor`
4. 刷新成功后自动重放失败请求
5. 刷新失败则清会话并回登录态

---

## 9. 网络增强（当前实现）

- `RequestTraceInterceptor`：请求链路日志与 `X-Request-Id`
- `RetryInterceptor`：GET 请求网络错误/5xx 自动重试（指数延迟）
- `MemoryCacheInterceptor`：GET 内存缓存（TTL）

---

## 10. 业务模块说明

## 10.1 商品（Product）
- 分页状态：`PaginatedProductsState`
- 支持：初次加载 / 下拉刷新 / 滚动加载更多
- 商品卡片支持加入购物车
- 点击卡片进入商品详情

## 10.2 购物车（Cart）
- 状态：`CartController`
- 能力：加购、减购、删除、清空
- 结算按钮触发创建订单流程
- 采用懒加载：不在登录成功后立即拉取购物车列表
- 进入购物车页时触发首次加载
- 购物车页支持下拉刷新（`RefreshIndicator`）
- 导出按钮显示由站点权限控制（`export_quotation`）

## 10.3 订单（Order）
- 支持获取订单列表
- 支持由购物车发起创建订单
- 创建成功后即时插入订单列表状态

## 10.4 会话与状态持久化（当前实现）
- 登录态与用户资料持久化到 `FlutterSecureStorage`
- 购物车与站点信息持久化到 `SharedPreferences`
- 站点插件权限由 `SiteInfoDto.pluginUniqid` 派生并统一由
  `shared/business_plugin/business_plugin_services.dart` 管理
- 应用回到前台（`resumed`）时会触发统一同步：
  - 用户信息（`/store/user/info`）
  - 站点信息（`/store/siteInfo`）
- 同步策略包含：
  - 60 秒节流
  - 并发保护（同一时刻仅一个同步任务）
  - 失败静默降级（不打断用户）

---

## 11. 代码生成命令

开发时持续生成：

```bash
dart run build_runner watch -d
```

一次性生成：

```bash
dart run build_runner build -d
```

---

## 12. 启动与验证

```bash
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
flutter run
```

---

## 13. 常见问题排查

### 13.1 `_$XXX` / `provider` 找不到
- 原因：未生成代码
- 处理：执行 `dart run build_runner build -d`

### 13.2 详情页没有返回键
- 原因：详情使用了 `go` 导航，替换了路由栈
- 处理：详情入口改为 `push`

### 13.3 Header 菜单样式不一致
- 处理：统一使用 `HeaderMenuButton`，不要在页面内写临时按钮样式

---

## 14. 后续推荐扩展

- 商品筛选、排序、搜索关键词状态持久化
- 购物车角标独立接口与状态解耦（避免依赖购物车列表初始化）
- 下单流程增加地址、优惠券、支付状态
- 引入埋点（页面曝光、点击、转化）
- 增加集成测试与关键路径 Golden Test
