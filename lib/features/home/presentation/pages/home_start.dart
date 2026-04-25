import 'package:flutter/material.dart';
import 'package:george_pick_mate/shared/widgets/home_main_content_slot_widget.dart';

class HomeStartPage extends StatefulWidget {
  const HomeStartPage({
    super.key,
    this.showSwitchSiteEntry = false,
    required this.onStartShopping,
  });

  /// 由首页「Profile」入口长按 10s 切换；为 `true` 时在设置中展示切换站点按钮。
  final bool showSwitchSiteEntry;

  /// 进入产品列表（由 [HomePage] 切换分区）。
  final VoidCallback onStartShopping;

  @override
  State<HomeStartPage> createState() => _HomeStartPageState();
}

class _HomeStartPageState extends State<HomeStartPage> {


  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/home_bgc.webp',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: Color(0xFFE8ECEF)),
        ),
        HomeMainContentSlot(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      Color(0xFFFFFFFF),
                      Color(0xFF8E8E8E),
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  'Modern Furniture',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ConstrainedBox(
                // 关键：使用 maxWidth 限制最大宽度，超过这个宽度就会换行
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  textAlign: TextAlign.center,
                  'Turn your room with panto into a lot more minimalist with ease and speed',
                  style: TextStyle(color: Colors.grey),
                  softWrap: true, // 默认为 true，即允许换行
                ),
              ),
              const SizedBox(
                height: 67,
              ),
              FilledButton(
                onPressed: widget.onStartShopping,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Start Shopping', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
              )
            ],
          ),
        ),
      ],
    );
  }
}
