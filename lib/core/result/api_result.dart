import 'package:groe_app_pad/core/result/app_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self.data);
    return failure((self as ApiFailure<T>).exception);
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
