import 'package:george_pick_mate/core/result/app_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    final self = this;
    /**
     * @Description self is ApiSuccess<T> : 这是一个类型检查。它在判断当前的 ApiResult 实例（即 self ）是不是 ApiSuccess 类型。
     * @date 2026/04/08 18:04:12
     */
    if (self is ApiSuccess<T>) return success(self.data);
    return failure((self as ApiFailure<T>).exception);
  }

  T getOrThrow() {
    final self = this;
    if (self is ApiSuccess<T>) return self.data;
    throw (self as ApiFailure<T>).exception;
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);
  final AppException exception;
}
