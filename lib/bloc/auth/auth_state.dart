import 'package:equatable/equatable.dart';
import 'package:m18_residences/models/tenant.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String token;
  final Tenant tenant;

  Authenticated({required this.token, required this.tenant});

  @override
  List<Object?> get props => [token, tenant];
}

class Unauthenticated extends AuthState {
  final String message;

  Unauthenticated(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReceiptUrlLoading extends AuthState {}

class ReceiptUrlLoaded extends AuthState {
  final String url;
  ReceiptUrlLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class ReceiptUrlError extends AuthState {
  final String message;

  ReceiptUrlError(this.message);

  @override
  List<Object?> get props => [message];
}
