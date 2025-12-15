class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(String error) =>
      Result._(error: error, isSuccess: false);

  void when({
    required void Function(T data) success,
    required void Function(String error) failure,
  }) {
    if (isSuccess) {
      success(data!);
    } else {
      failure(error!);
    }
  }
}
