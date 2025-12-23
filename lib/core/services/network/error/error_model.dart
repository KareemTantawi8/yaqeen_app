class ErrorModel {
  final int status;
  final String errorMessage;

  ErrorModel({
    required this.status,
    required this.errorMessage,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      status: json['status'] ?? 0,
      errorMessage: json['message'] ?? '',
    );
  }
}

// class ErrorModel {
//   final int status;
//   final List<String> message;

//   ErrorModel({required this.message, required this.status});

//   factory ErrorModel.fromJson(Map<String, dynamic> json) {
//     return ErrorModel(
//       status: json['status'] ?? 0,
//       message: json['message'] ,
//     );
//   }
// }
