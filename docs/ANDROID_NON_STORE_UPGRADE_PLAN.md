# Android 非商店自动升级方案

本文用于沉淀当前确认的方案：应用不上架应用商店，仅适配 Android，
实现「应用内检查更新 + 下载 APK + 引导安装」。

## 目标与边界

- 目标：提供接近自动升级的体验，减少用户手动操作成本。
- 边界：普通应用权限下无法实现完全静默安装，最终仍需用户确认安装。
- 平台：当前仅针对 Android 设计，iOS 不在本方案范围内。

## 方案总览

采用以下链路：

`App 启动/前台恢复 -> 请求版本接口 -> 比较版本 -> 弹窗提示 -> 下载 APK -> 校验包完整性 -> 调起系统安装器`

其中：

- 软更新（可跳过）：提示更新，用户可稍后处理。
- 强更新（不可跳过）：拦截主要业务流程，仅允许升级或退出。

## 服务端接口建议

建议提供统一版本检查接口，例如：

- `GET /app/version/check?platform=android&channel=official`

返回字段建议：

- `hasUpdate`：是否有新版本。
- `latestVersionName`：如 `1.2.3`。
- `latestVersionCode`：如 `123`。
- `forceUpdate`：是否强更。
- `downloadUrl`：APK 下载地址（HTTPS）。
- `sha256`：APK 文件哈希（用于下载后校验）。
- `changelog`：更新说明。
- `minSupportedVersionCode`（可选）：最小可用版本，用于强更兜底。

## 客户端实现步骤（Flutter）

1. 启动时读取当前安装包版本（`package_info_plus`）。
2. 调用版本检查接口，基于 `versionCode` 进行比较。
3. 若需更新，展示更新弹窗（支持软更/强更）。
4. 用户确认后下载 APK 到应用可访问目录。
5. 下载完成后进行 `sha256` 校验。
6. 校验通过后拉起系统安装器安装。
7. 安装失败或取消时，保留重试入口。

## 推荐依赖（按需）

- `package_info_plus`：读取当前版本信息。
- `dio`：下载 APK 和上报进度。
- `path_provider`：获取下载保存目录。
- `open_filex`：拉起系统安装器打开 APK。
- `permission_handler`（按 Android 版本按需）：处理必要权限。

## 项目内落位建议

按现有分层约定，建议新增 `app_upgrade` 功能模块：

- `lib/features/app_upgrade/api/app_upgrade_requests.dart`
- `lib/features/app_upgrade/services/app_upgrade_services.dart`
- `lib/features/app_upgrade/controllers/app_upgrade_providers.dart`
- `lib/features/app_upgrade/presentation/widgets/update_dialog_widget.dart`

调用链保持：

`presentation -> controllers -> services -> api -> network client`

## 关键交互建议

- 应用冷启动后检查一次版本。
- App 回到前台时按节流策略再检查一次（避免频繁请求）。
- 强更弹窗不可关闭，仅保留「立即更新」。
- 软更可提供「稍后再说」并记录忽略时间（避免重复打扰）。
- 下载中展示进度与失败重试按钮。

## 安全与合规建议

- 下载地址必须使用 HTTPS。
- 客户端必须执行 `sha256` 校验。
- 接口建议增加签名或鉴权，避免升级包地址被篡改。
- 仅安装你方签名的 APK，避免来源不可信风险。
- 记录升级过程日志，便于追踪失败原因。

## 失败场景兜底

- 下载失败：提示网络异常并支持重试。
- 校验失败：删除本地文件并重新下载。
- 安装取消：回到更新弹窗并提示用户继续安装。
- 强更场景：限制进入核心页面，直至完成更新。

## 后续实施清单

- [ ] 确定版本接口协议与字段。
- [ ] 完成 `app_upgrade` 模块代码。
- [ ] 在应用入口接入版本检查时机。
- [ ] 完成强更/软更交互与下载进度 UI。
- [ ] 联调真实 APK 下载与安装流程。
- [ ] 增加异常埋点与日志监控。
