import 'package:flutter/material.dart';
import 'package:groe_app_pad/shared/widgets/app_loading_view.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppLoadingView(message: '初始化会话...'));
  }
}
