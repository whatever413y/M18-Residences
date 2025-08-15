import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginWithAccountId extends AuthEvent {
  final String accountId;

  LoginWithAccountId(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class LogoutRequested extends AuthEvent {}

class FetchReceiptUrl extends AuthEvent {
  final String tenantName;
  final String filename;

  FetchReceiptUrl(this.tenantName, this.filename);
}

class FetchPaymentImageUrl extends AuthEvent {
  final String filename;

  FetchPaymentImageUrl(this.filename);
}
