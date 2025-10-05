class ApiResponse {
  ApiResponse({
    this.success,
    this.data,
    this.error,
    this.value,
  });

  ApiResponse.fromJson(Map<String?, dynamic> json) {
    data = json;
    success =
        json['success'] ?? json['error'] == null && json['error_code'] == null;
    value = json['value'];
  }

  bool? success;
  dynamic data;
  String? error;
  dynamic value;
  bool isSuccess() => success ?? false;
}
