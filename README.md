# george_pick_mate（Flutter Pad 端选品助手）

## 文档

- [Dio 请求选项（extra、simpleResponse、noCache、noRetry）](docs/DIO_OPTIONS.md)
- [Android 非商店自动升级方案](docs/ANDROID_NON_STORE_UPGRADE_PLAN.md)

---

## 业务约定

- **站点维度**：仅**商品**与**首页装修**相关接口会按 `company_id` 区分站点；其它模块不按站点拆分（以实际接口为准）。

---

## 国际化（ARB）

配置见根目录 `l10n.yaml`（`arb-dir`、`template-arb-file` 等）。

修改 `lib/l10n/*.arb` 后执行：

```bash
flutter gen-l10n
```

生成物在 `.dart_tool/flutter_gen/gen_l10n/`，通过 `flutter: generate: true` 参与编译；若 IDE 未刷新，可执行一次 `flutter pub get`。

---

## 代码生成（build_runner / FlutterGen）

本项目在 `pubspec.yaml` 中配置了 **FlutterGen**（`flutter_gen_runner`），与 Freezed 等共用 **build_runner**。

| 场景 | 命令 |
| --- | --- |
| 单次生成（推荐，避免冲突文件报错） | `dart run build_runner build --delete-conflicting-outputs` |
| 监听文件变化持续生成 | `dart run build_runner watch --delete-conflicting-outputs` |

修改 **静态资源声明**（`pubspec.yaml` → `flutter.assets`）或 **FlutterGen 配置**（`pubspec.yaml` → `flutter_gen`）后，需要重新跑上述命令以更新 `lib/gen/`（例如 `assets.gen.dart`）。

**修改国际化后若还需更新其它生成代码**，可依次执行：

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

---

## FlutterGen：资源与 SVG

### 配置位置（本项目）

- 资源目录：在 `pubspec.yaml` 的 `flutter.assets` 中声明（如 `assets/images/`、`assets/svg/`）。
- FlutterGen：同文件末尾 `flutter_gen:` 段，例如 `output: lib/gen/`、`integrations.flutter_svg: true`。

开启 `flutter_svg` 集成后，会为 SVG 生成 `SvgGenImage`，普通位图仍为 `AssetGenImage`。

### 使用方式

```dart
import 'package:george_pick_mate/gen/assets.gen.dart';

// 位图
Assets.images.empty.image(width: 120, fit: BoxFit.contain);

// SVG（需已配置 integrations.flutter_svg）
Assets.svg.profileSetting.svg(width: 24, height: 24);
```

新增文件：放入已声明的目录 → 运行 `dart run build_runner build --delete-conflicting-outputs` → 使用 `Assets` 上新生成的 getter。

---

## 发版打包（Release APK）

遇到依赖或生成物异常时，可按需「深度清理」后再打：

```bash
flutter clean
```

可选（Gradle / Dart 工具缓存，磁盘不足或顽固报错时再删）：

- 删除 `android/.gradle`
- 删除项目根目录 `.dart_tool`

然后重新拉依赖并打包：

```bash
flutter pub get
flutter build apk --release
```

需要切换后端地址时，可使用（示例）：

```bash
flutter build apk --release --dart-define=BASE_URL=https://your-api.example.com/api
```

关闭 Debug 下的网络追踪日志（仍受 `kDebugMode` 限制，Release 默认无控制台输出）：

```bash
flutter run --dart-define=NET_TRACE_ENABLED=false
```

---

## 清理缓存（含义区分）

| 类型 | 说明 |
| --- | --- |
| **GET 内存缓存** | `MemoryCacheInterceptor` 对成功 GET 的短期内存缓存；业务侧可通过 `DioClient` 的 `clearAllMemoryCaches` / `evictMemoryCacheByPrefix` 清理（见 `lib/core/network/dio_client.dart`）。 |
| **Flutter / Gradle 构建缓存** | `flutter clean`，必要时再删 `android/.gradle`、根目录 `.dart_tool`。 |
| **网络日志** | 由 `Env.netTraceEnabled` 与 `kDebugMode` 控制，见下文。 |

---

## Windows Kotlin `different roots` 排查（C: / D: 跨盘）

当报错包含 `Daemon compilation failed`、`Could not close incremental caches`、
`this and base files have different roots` 时，通常是：

- 工程在 `D:`（如 `D:/webstormProject/...`）
- Pub 缓存在 `C:`（如 `C:/Users/<you>/AppData/Local/Pub/Cache`）
- Kotlin 增量编译在处理插件源码相对路径时触发跨盘异常

### 1) 先检查当前项目是否仍在用 C 盘缓存

```powershell
Select-String -Path .dart_tool\package_config.json -Pattern '"pubCache"'
```

若输出是 `C:/Users/.../Pub/Cache`，就会持续触发该问题。

### 2) 迁移到同盘缓存（推荐）

```powershell
# 仅需执行一次（用户级环境变量）
setx PUB_CACHE "D:\pub_cache"
```

重开终端后，在项目根目录执行：

```powershell
flutter clean
Remove-Item -Recurse -Force .dart_tool, build, android\.gradle -ErrorAction SilentlyContinue
flutter pub get --offline
flutter run
```

再次检查：

```powershell
Select-String -Path .dart_tool\package_config.json -Pattern '"pubCache"'
```

应显示 `D:/pub_cache`。

### 3) 临时兜底（不推荐长期）

若短期无法迁移缓存，可在 `android/gradle.properties` 临时关闭 Kotlin 增量编译：

```properties
kotlin.incremental=false
```

---

## 网络日志说明与过滤

仅在 **Debug** 且 **`Env.netTraceEnabled == true`**（默认 `true`，可用 `--dart-define=NET_TRACE_ENABLED=false` 关闭）时，`debugPrint` 输出下列前缀。

### `[NET][TRACE]`（`RequestTraceInterceptor`）

| 片段 | 含义 |
| --- | --- |
| `[REQ]` | 请求发出：`method`、`path`、脱敏后的 `headers`、`query`。 |
| `[RES]` | 响应返回：`statusCode`、`path`、耗时 `(Nms)`；若带 **`(cache)`** 表示本次响应来自内存缓存短路，未走真实 HTTP。 |
| `[ERR]` | 请求失败：`DioException` 类型、`method`、`path`、耗时、错误 `message`。 |

同一请求用 **`requestId`**（日志里 `[NET][TRACE][<id>]` 段）串联 REQ / RES / ERR。

### `[NET][CACHE]`（`MemoryCacheInterceptor`）

| 关键字 | 含义 |
| --- | --- |
| **`hit`** | 在 TTL 内命中内存缓存，**直接返回缓存体**，不发网络请求；日志中带 `key=...`（路径 + query）。 |
| **`miss`** | 未命中缓存，继续走真实请求。 |
| **`expired`** | 键曾存在但已超过 TTL，已删除该条并走网络。 |
| **`bypass`** | 非 GET 或本次带 `noCache`，**不读**缓存（GET 成功后仍可能 `save` 写入）。 |
| **`save`** | 成功 GET 后写入/覆盖缓存条目。 |
| **`skip save`** | 未写入缓存（非 GET 或非成功响应等）。 |

### 过滤示例

只关心缓存相关：

```bash
# macOS / Linux（grep）
flutter run 2>&1 | grep "\[NET\]\[CACHE\]"

# Windows PowerShell
flutter run 2>&1 | Select-String "\[NET\]\[CACHE\]"
```

只关心追踪行：

```bash
flutter run 2>&1 | grep "\[NET\]\[TRACE\]"
```

---

## 应用图标（flutter_launcher_icons）

本项目已接入 `flutter_launcher_icons`，用于从一张源图自动生成
Android/iOS 启动器图标。

### 1) 配置位置

在 `pubspec.yaml` 中包含以下两部分：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/images/app.png
```

说明：

- `image_path` 指向图标源文件（当前为 `assets/images/app.png`）。
- 建议使用 1024x1024 PNG，主体居中，减少边缘留白。
- iOS 上架建议使用无透明背景图片（避免审核风险）。

### 2) 首次生成 / 重新生成

当你替换了 `assets/images/app.png`，或调整了
`flutter_launcher_icons` 配置后，执行：

```bash
flutter pub get
dart run flutter_launcher_icons
```

这两个命令可重复执行；`dart run flutter_launcher_icons`
会覆盖旧图标产物。

### 3) 本次会改动哪些文件

执行生成后，通常会改动以下文件：

- Android 图标：
  `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS 图标资源集：
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`
- iOS 图标清单：
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- 依赖锁文件（首次引入依赖时）：
  `pubspec.lock`

另外，本次已手动修改应用名称为“选品助手”：

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

---

## 常用命令速查

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart run flutter_launcher_icons
flutter build apk --release
```
