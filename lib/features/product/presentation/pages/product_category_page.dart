import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:groe_app_pad/gen/assets.gen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductCategoryPage extends StatefulWidget {
  const ProductCategoryPage({super.key});

  @override
  State<ProductCategoryPage> createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  // 仅在平台支持时初始化；不支持时保持 null 并展示降级文案。
  WebViewController? _controller;
  late final bool _canUseWebView;
  bool _isPageLoaded = false;
  DateTime? _loadStartAt;
  int _sendCounter = 1;

  @override
  void initState() {
    super.initState();
    _loadStartAt = DateTime.now();
    if (kIsWeb) {
      _canUseWebView = false;
      return;
    }
    // webview_flutter 当前主能力面向移动端/桌面端（Android/iOS/macOS）。
    // Web 端这里直接判为不支持，避免触发平台实现断言。
    _canUseWebView =
        defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS;

    if (!_canUseWebView) return;

    try {
      // 初始化 WebView 并加载本地 HTML 资源。
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        // 页面完成首帧后再隐藏 loading，减少白屏闪烁感。
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (!mounted) return;
              setState(() {
                _isPageLoaded = false;
                _loadStartAt = DateTime.now();
              });
            },
            onPageFinished: (_) => _markPageLoaded(),
          ),
        )
        // JS 通过 window.Toaster.postMessage('xxx') 回传消息给 Flutter。
        ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('来自 Web 的消息: ${message.message}')),
            );
          },
        )
        ..loadFlutterAsset(Assets.html.calendar);
    } catch (_) {
      // 测试环境/插件未注入实现时兜底，避免页面直接崩溃。
      _controller = null;
      _isPageLoaded = false;
    }
  }

  Future<void> _markPageLoaded() async {
    final start = _loadStartAt;
    if (start != null) {
      final elapsed = DateTime.now().difference(start);
      const minLoading = Duration(milliseconds: 400);
      if (elapsed < minLoading) {
        await Future<void>.delayed(minLoading - elapsed);
      }
    }
    if (!mounted) return;
    setState(() {
      _isPageLoaded = true;
    });
  }

  Future<void> _sendMessageToHtml() async {
    final controller = _controller;
    if (controller == null) return;

    final message = 'Flutter 消息 #$_sendCounter';
    final safeMessage = message
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n');

    await controller.runJavaScript(
      "window.onFlutterMessage && window.onFlutterMessage('$safeMessage');",
    );

    if (!mounted) return;
    setState(() {
      _sendCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(
        child: Text('Web 端暂不支持内嵌 WebView，请使用移动端或桌面端查看'),
      );
    }

    if (_controller == null) {
      // 降级视图：平台不支持或初始化失败时展示提示信息。
      return const Center(
        child: Text('当前平台不支持 WebView（或测试环境未注入平台实现）'),
      );
    }
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _isPageLoaded
              ? const SizedBox(height: 0)
              : SizedBox(
                  key: const ValueKey('webview_loading_banner'),
                  width: double.infinity,
                  height: 48,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
        ),
        Expanded(
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: WebViewWidget(controller: _controller!),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendMessageToHtml,
                icon: const Icon(Icons.send),
                label: const Text('Flutter -> HTML 发送消息'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
