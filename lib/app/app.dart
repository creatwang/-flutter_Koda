import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groe_app_pad/app/router/app_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'iPad Mall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 599, name: MOBILE),
            Breakpoint(start: 600, end: 1023, name: TABLET),
            Breakpoint(start: 1024, end: 3000, name: DESKTOP),
          ],
        );
      },
    );
  }
}
