import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchBillingByTenantId extends BillingEvent {
  final int tenantId;

  FetchBillingByTenantId(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}

class FetchBillingById extends BillingEvent {
  final int id;

  FetchBillingById(this.id);

  @override
  List<Object> get props => [id];
}
