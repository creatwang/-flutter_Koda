# flutter pad端商城最佳实践

删除资源之后执行清理 `flutter pub run build_runner build --delete-conflicting-outputs`

`flutter pub get`
`flutter pub run build_runner -w`

修改国际化之后
flutter gen-l10n

打包
flutter clean
删 android/.gradle 和 项目根 .dart_tool（可选）
重新拉依赖并打包
flutter pub get
flutter build apk --release


只有产品和首页装修会区分站点company_id