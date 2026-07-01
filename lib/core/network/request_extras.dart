import 'package:dio/dio.dart';

/// Dio [Options.extra] 约定键。
abstract final class RequestExtras {
  static const String forwardedHost = 'forwardedHost';
}

Options mergeRequestOptions({Options? base, String? forwardedHost}) {
  if (forwardedHost == null || forwardedHost.trim().isEmpty) {
    return base ?? Options();
  }
  return (base ?? Options()).copyWith(
    extra: <String, dynamic>{
      ...?base?.extra,
      RequestExtras.forwardedHost: forwardedHost.trim(),
    },
  );
}
