import 'package:equatable/equatable.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';

abstract class TenantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class TenantLoaded extends TenantState {
  final Tenant tenant;

  TenantLoaded(this.tenant);

  @override
  List<Object?> get props => [tenant];
}

class TenantError extends TenantState {
  final String message;

  TenantError(this.message);

  @override
  List<Object?> get props => [message];
}
