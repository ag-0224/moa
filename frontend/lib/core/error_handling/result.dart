/// 성공/실패를 명시적으로 표현하는 결과 타입.
/// 기능(feature) 계층(Repository)의 반환 타입으로 사용해, 예외를 던지는 대신
/// 호출자가 [when]으로 두 경우를 모두 처리하도록 강제한다.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Object error) = Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Object error) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final error) => failure(error),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final Object error;
}
