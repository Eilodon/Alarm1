class Platform {
  static const Map<String, String> environment = {};
}

class SocketException implements Exception {
  final String message;
  SocketException([this.message = '']);
  @override
  String toString() => 'SocketException: $message';
}
