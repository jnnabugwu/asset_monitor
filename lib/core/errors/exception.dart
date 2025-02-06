 
 import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final String? statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}

class CacheException extends Equatable implements Exception {
  const CacheException({required this.message, this.statusCode = 500});

  final String message;
  final int statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}

class NetworkException extends Equatable implements Exception {
  const NetworkException({
    required this.message,
    this.statusCode = 'NO_INTERNET_CONNECTION'
  });

  final String message;
  final String statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}