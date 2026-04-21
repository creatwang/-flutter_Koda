# Dio 请求选项（`Options.extra` 与 `DioClient`）

本文说明项目里鉴权/公开客户端共用的请求级开关：响应形态、全局错误
提示、内存缓存与重试。实现分布在 `DioClient`、`ResponseDataModeInterceptor`、
`MemoryCacheInterceptor`、`RetryInterceptor`。

## `DioClient.get` / `DioClient.post` 与 `simpleResponse`

业务接口多数返回 `{ code, message, result }`。`DioClient` 会在每次请求上写入
`extra[ResponseDataModeInterceptor.responseDataModeExtraKey]`（即
`response_data_mode`），默认 **`simpleResponse: true`**，表示在业务成功且
`data` 为带 `result` 字段的 Map 时，拦截器会把 **`response.data` 替换为
`data['result']`**，便于 service 层直接解析业务体。

- **默认**：`simpleResponse: true`（与 `ResponseDataMode.simple` 一致）。
- **需要完整外层**（含 `code` / `message` / `result`）：传
  `simpleResponse: false`，或在 `Options.extra` 中显式设置
  `ResponseDataMode.origin`（见下节字符串写法）。

```dart
await protectedDioClient.get(
  '/some/path',
  simpleResponse: false,
);

// 或与已有 extra 合并（由 DioClient 合并 response_data_mode）
await protectedDioClient.post(
  '/some/path',
  data: body,
  options: Options(
    extra: <String, dynamic>{
      'requestId': 'optional-trace-id',
    },
  ),
  simpleResponse: false,
);
```

`response_data_mode` 也支持字符串枚举名：`simple`、`origin`，与
`ResponseDataModeInterceptor._resolveRequestMode` 一致。

## 抑制全局 SnackBar：`suppress_global_error_message`

`ResponseDataModeInterceptor` 在业务错误（`code != 0` 等）或 `onError` 时会调用
`showGlobalErrorMessage`，通过根级 `ScaffoldMessenger` 弹出 SnackBar。若页面或
BottomSheet 已展示同一错误，可对该请求设置：

- **键名常量**：
  `ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey`
- **extra 取值**：`true`

效果：**不再**调用 `showGlobalErrorMessage`；请求仍会按原逻辑 `reject` /
抛出，由 service / UI 处理。**会话过期**仍走 `showSessionExpiredDialog`，**不**
受此开关影响。

```dart
import 'package:dio/dio.dart';
import 'package:groe_app_pad/core/network/interceptors/response_data_mode_interceptor.dart';

options: Options(
  extra: <String, dynamic>{
    ResponseDataModeInterceptor.suppressGlobalErrorMessageExtraKey: true,
  },
),
```

客户创建/更新请求见
`lib/features/profile/api/customer_account_requests.dart` 中的用法。

## 内存缓存：`noCache`（`MemoryCacheInterceptor`）

仅对 **GET** 生效：

- **`extra['noCache'] == true`**：本次请求**不读**内存缓存，仍发网络；成功
  后仍会**写入/覆盖**缓存，避免刷新后其它未带 `noCache` 的 GET 读到旧数据。
- 未设置 `noCache`：在 TTL 内可能直接命中内存缓存而不发请求。

```dart
options: Options(
  extra: <String, dynamic>{'noCache': true},
);
```

## 重试：`noRetry`（`RetryInterceptor`）

对可重试错误（网络类错误、5xx）且方法为 **GET** 时，拦截器会做有限次重试。

- **`extra['noRetry'] == true`**：本次请求**不参与**重试逻辑。

```dart
options: Options(
  extra: <String, dynamic>{'noRetry': true},
);
```

参考：`lib/features/product/api/product_requests.dart`（收藏相关 POST 上同时
带了 `noCache` / `noRetry`；其中 `noCache` 对非 GET 无读缓存行为，仅为与其它
请求风格一致或预留）。

## 其它：`requestId`

`RequestTraceInterceptor` / 缓存与重试日志会使用
`extra['requestId']` 便于排查，可选。

## 客户端装配

公开与鉴权 Dio 均在 `lib/core/platform_services/network_clients.dart` 中装配
拦截器顺序；根 `ScaffoldMessenger` 见 `lib/shared/services/app_message_service.dart`。
