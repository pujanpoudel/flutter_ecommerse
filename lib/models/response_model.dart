class ResponseModel {
  final bool isSuccess;
  final String message;

  const ResponseModel(this.isSuccess, this.message);

  // Named constructor for success responses
  const ResponseModel.success(String message) : this(true, message);

  // Named constructor for error responses
  const ResponseModel.error(String message) : this(false, message);
}
