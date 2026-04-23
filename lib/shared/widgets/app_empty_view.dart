import 'package:flutter/material.dart';
import 'package:george_pick_mate/shared/extensions/build_context_x.dart';
import 'package:george_pick_mate/gen/assets.gen.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, this.message, this.width, this.height});

  final String? message;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: AlignmentGeometry.center,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.images.empty.image(
            width: width ?? 180,
            height: height ?? 180,
          ),
          const SizedBox(height: 20),
          Text(message ?? context.l10n.commonNoData),
        ],
    ));
  }
}
