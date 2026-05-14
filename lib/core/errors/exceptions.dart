class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);
  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);
  @override
  String toString() => message;
}

class LocationException implements Exception {
  final String message;
  const LocationException([this.message = 'Unable to get location']);
  @override
  String toString() => message;
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'File upload failed']);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found']);
  @override
  String toString() => message;
}
