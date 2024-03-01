abstract class TaskMakerException implements Exception {
  final String message;
  final int code;

  TaskMakerException({required this.message, required this.code});
}

class RemoteException extends TaskMakerException {
  RemoteException({required super.message, required super.code});
}

class LocalException extends TaskMakerException {
  LocalException({required super.message, required super.code});
}