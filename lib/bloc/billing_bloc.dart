import 'package:flutter_bloc/flutter_bloc.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingService billingService;

  BillingBloc({required this.billingService}) : super(BillingInitial()) {
    on<FetchBillingByTenantId>(_onFetchBillingByTenantId);
    on<FetchBillingById>(_onFetchBillingById);
  }

  Future<void> _onFetchBillingByTenantId(
    FetchBillingByTenantId event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());

    try {
      final bills = await billingService.getAllByTenantId(event.tenantId);
      emit(BillingLoaded(bills));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onFetchBillingById(
    FetchBillingById event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());

    try {
      final bill = await billingService.getById(event.id);
      emit(BillingLoaded([bill]));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }
}
