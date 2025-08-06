import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchBillingsByTenantId extends BillingEvent {
  final int tenantId;

  FetchBillingsByTenantId(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}

class FetchBillingByTenantId extends BillingEvent {
  final int tenantId;

  FetchBillingByTenantId(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}
