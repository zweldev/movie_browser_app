class CustomException implements Exception {
  final String message;
  final int? statusCode;

  CustomException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NoInternetConnectionException extends CustomException {
  NoInternetConnectionException() : super("No Internet Connection!");
}

class InternalServerErrorException extends CustomException {
  InternalServerErrorException() : super("Internal Server Error!");
}

class ConnectionTimeoutException extends CustomException {
  ConnectionTimeoutException() : super("Connection Timeout!");
}

class BadRequestException extends CustomException {
  BadRequestException() : super("Bad request");
}

class UnauthorizedException extends CustomException {
  UnauthorizedException() : super("Unauthorized");
}

class ForbiddenException extends CustomException {
  ForbiddenException() : super("Forbidden");
}

class NotFoundException extends CustomException {
  NotFoundException() : super("Not found");
}

class TooManyRequestsException extends CustomException {
  TooManyRequestsException() : super("Too many requests");
}

class CacheException extends CustomException {
  CacheException([super.message = "Cache error occurred"]);
}

class CacheReadException extends CacheException {
  CacheReadException() : super("Failed to read local data");
}

class CacheWriteException extends CacheException {
  CacheWriteException() : super("Failed to save data");
}

class CacheCorruptionException extends CacheException {
  CacheCorruptionException() : super("Local data is corrupted");
}

class CustomResponse {
  final dynamic data;
  final int statusCode;

  CustomResponse({required this.data, required this.statusCode});
}
