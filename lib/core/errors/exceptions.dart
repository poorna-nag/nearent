class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);
}

class LocationException implements Exception {
  final String message;
  const LocationException([this.message = 'Unable to get location']);
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'File upload failed']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found']);
}
