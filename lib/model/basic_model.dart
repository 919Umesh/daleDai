class BasicModel {
  BasicModel({
    required this.message,
    required this.statusCode,
    required this.data,
    required this.status,
  });

  final String message;
  final int statusCode;
  final String data;
  final bool status;

  factory BasicModel.fromJson(Map<String, dynamic> json) {
    return BasicModel(
      message: json["message"] ?? "",
      statusCode: json["status_code"] ?? 0,
      data: json["data"] ?? "",
      status: json["status"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "status_code": statusCode,
        "data": data,
        "status": status,
      };
}
