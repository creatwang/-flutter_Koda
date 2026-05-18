import 'package:flutter/material.dart';
import 'package:george_pick_mate/shared/base_widget/toast/yn_toast_widget.dart';

/// YnToast 用法演示（examples 入口：CustomMenu → user）。
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  YnToastController? _persistController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE6),
      appBar: AppBar(
        title: const Text('YnToast 示例'),
        backgroundColor: const Color(0xFF20231D),
        foregroundColor: const Color(0xFFF6F1E6),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _sectionTitle('一、快捷静态（无 loading）'),
          _hint('YnToast.success / info / warning / error'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Success', () => YnToast.success(context, message: 'success')),
              _btn('Info', () => YnToast.info(context, message: 'info')),
              _btn(
                'Warning',
                () => YnToast.warning(context, message: 'warning'),
              ),
              _btn('Error', () => YnToast.error(context, message: 'error')),
              _btn(
                '默认文案',
                () => YnToast.success(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('二、show + 自动 loading → 结果'),
          _hint('YnToast.show，loadingDuration 结束后切到 initialType'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn(
                'Show Success',
                () => YnToast.show(
                  context,
                  type: YnToastType.success,
                  message: 'saved',
                ),
              ),
              _btn(
                'Show Error',
                () => YnToast.show(
                  context,
                  type: YnToastType.error,
                  message: 'request failed',
                ),
              ),
              _btn(
                '慢 Loading(3s)',
                () => YnToast.show(
                  context,
                  type: YnToastType.info,
                  message: 'slow finish',
                  options: const YnToastShowOptions(
                    loadingDuration: Duration(seconds: 3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('三、手动 Controller'),
          _hint('loading 持久化，由 done / hide 结束'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Loading → Success', _manualLoadingToSuccess),
              _btn('Loading → Error', _manualLoadingToError),
              _btn('Loading → Hide', _manualLoadingHide),
            ],
          ),
          const SizedBox(height: 12),
          _hint('长时间 loading，便于观察双弧起步加速与巡航转速'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('长时间 Loading (8s)', _longLoadingForSpinDemo),
              _btn('长时间 Loading+Mask (8s)', _longLoadingForSpinDemoWithMask),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('四、YnToast.task'),
          _hint('内置 loading；成功需 controller.done；异常自动 error'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Task 成功', _taskSuccess),
              _btn('Task 失败', _taskFailure),
              _btn('Task + Mask', _taskWithMask),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('五、持久 / 长文案'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Persist 成功', _persistSuccess),
              _btn('关闭 Persist', () => _persistController?.hide()),
              _btn(
                '长文案换行',
                () => YnToast.warning(
                  context,
                  message:
                      'THIS IS A VERY LONG WARNING MESSAGE FOR WRAP TEST THIS IS A VERY LONG WARNING MESSAGE FOR WRAP TEST THIS IS A VERY LONG WARNING MESSAGE FOR WRAP TEST THIS IS A VERY LONG WARNING MESSAGE FOR WRAP TEST',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('六、Overlay API'),
          _hint('showOnOverlay / showLoadingOnOverlay（需 Overlay 上下文）'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Overlay 快捷 Error', _overlayShortcut),
              _btn('Overlay Loading→Done', _overlayManual),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF20231D),
        ),
      ),
    );
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF20231D).withValues(alpha: 0.65),
          height: 1.35,
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onPressed) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF20231D),
        foregroundColor: const Color(0xFFF6F1E6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void _manualLoadingToSuccess() {
    final controller = YnToast.show(
      context,
      type: YnToastType.success,
      options: const YnToastShowOptions(
        loadingDuration: Duration(days: 1),
        persist: true,
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      controller.done(YnToastType.success, message: 'manual success');
    });
  }

  void _manualLoadingToError() {
    final controller = YnToast.show(
      context,
      type: YnToastType.error,
      options: const YnToastShowOptions(
        loadingDuration: Duration(days: 1),
        persist: true,
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      controller.done(YnToastType.error, message: 'manual error');
    });
  }

  void _manualLoadingHide() {
    final controller = YnToast.show(
      context,
      type: YnToastType.info,
      message: 'loading…',
      options: const YnToastShowOptions(
        loadingDuration: Duration(days: 1),
        persist: true,
      ),
    );
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      controller.hide();
    });
  }

  /// 持久 loading 8s，结束后 success，用于调试旋转加速曲线。
  void _longLoadingForSpinDemo() {
    final controller = YnToast.show(
      context,
      type: YnToastType.info,
      options: const YnToastShowOptions(
        loadingDuration: Duration(days: 1),
        persist: true,
      ),
    );
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      controller.done(
        YnToastType.success,
        message: '8s loading done',
      );
    });
  }

  void _longLoadingForSpinDemoWithMask() {
    final controller = YnToast.show(
      context,
      type: YnToastType.info,
      options: const YnToastShowOptions(
        loadingDuration: Duration(days: 1),
        persist: true,
        mask: true,
      ),
    );
    Future<void>.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      controller.done(
        YnToastType.success,
        message: '8s masked loading done',
      );
    });
  }

  Future<void> _taskSuccess() async {
    await YnToast.task<void>(
      context,
      (controller) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        controller.done(YnToastType.success, message: 'task finished');
      },
      type: YnToastType.info,
    );
  }

  Future<void> _taskFailure() async {
    try {
      await YnToast.task<void>(
        context,
        (_) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          throw StateError('task failed');
        },
        type: YnToastType.info,
      );
    } on StateError {
      // task 内已 done(error) 并 rethrow
    }
  }

  Future<void> _taskWithMask() async {
    await YnToast.task<void>(
      context,
      (controller) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        controller.done(YnToastType.success, message: 'masked ok');
      },
      type: YnToastType.warning,
      mask: true,
    );
  }

  void _persistSuccess() {
    _persistController?.hide();
    _persistController = YnToast.success(
      context,
      message: 'persist toast',
      options: const YnToastDoneOptions(persist: true),
    );
  }

  void _overlayShortcut() {
    final overlay = Overlay.of(context, rootOverlay: true);
    YnToast.showOnOverlay(
      overlay,
      type: YnToastType.error,
      message: 'overlay error',
    );
  }

  void _overlayManual() {
    final overlay = Overlay.of(context, rootOverlay: true);
    final controller = YnToast.showLoadingOnOverlay(
      overlay,
      type: YnToastType.info,
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      controller.done(YnToastType.success, message: 'overlay done');
    });
  }
}
