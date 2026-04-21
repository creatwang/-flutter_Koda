# flutter pad端商城最佳实践

## 文档

- [Dio 请求选项（extra、simpleResponse、noCache、noRetry）](docs/DIO_OPTIONS.md)

`flutter pub run build_runner build --delete-conflicting-outputs`

`flutter pub get`
`flutter pub run build_runner -w`

修改国际化之后
flutter gen-l10n
dart run build_runner
打包
flutter clean
删 android/.gradle 和 项目根 .dart_tool（可选）
重新拉依赖并打包
flutter pub get
flutter build apk --release


只有产品和首页装修会区分站点company_id


清理缓存
 

添加静态资源
单次
dart run build_runner build
监听
dart run build_runner watch --delete-conflicting-outputs
#过滤日志
hit 是缓存日志