import 'package:flutter/material.dart';
import 'package:groe_app_pad/shared/extensions/build_context_x.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message ?? context.l10n.commonNoData));
  }
}
