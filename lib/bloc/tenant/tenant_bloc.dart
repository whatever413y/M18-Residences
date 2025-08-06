import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'tenant_event.dart';
import 'tenant_state.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantService tenantService;

  TenantBloc({required this.tenantService}) : super(TenantInitial()) {
    on<FetchTenantByTenantName>(_onFetchTenantByTenantName);
  }

  Future<void> _onFetchTenantByTenantName(FetchTenantByTenantName event, Emitter<TenantState> emit) async {
    emit(TenantLoading());
    try {
      final tenant = await tenantService.getByTenantName(event.tenantName);
      emit(TenantLoaded(tenant));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
}
