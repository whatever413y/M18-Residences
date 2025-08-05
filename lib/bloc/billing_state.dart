import 'package:equatable/equatable.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

abstract class BillingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingLoaded extends BillingState {
  final List<Bill> bills;

  BillingLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

class BillingError extends BillingState {
  final String message;

  BillingError(this.message);

  @override
  List<Object?> get props => [message];
}
