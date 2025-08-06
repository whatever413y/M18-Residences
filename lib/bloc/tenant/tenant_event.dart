import 'package:equatable/equatable.dart';

abstract class TenantEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTenantByTenantName extends TenantEvent {
  final String tenantName;

  FetchTenantByTenantName(this.tenantName);

  @override
  List<Object> get props => [tenantName];
}
