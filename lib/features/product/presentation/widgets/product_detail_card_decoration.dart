import 'package:flutter/material.dart';

/// 详情页主内容区卡片描边与底色（媒体区 / 信息区共用）。
BoxDecoration productDetailCardDecoration() {
  return BoxDecoration(
    color: Colors.black.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
  );
}
