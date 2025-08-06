import 'package:flutter_bloc/flutter_bloc.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingService billingService;

  BillingBloc({required this.billingService}) : super(BillingInitial()) {
    on<FetchBillingsByTenantId>(_onFetchBillingsByTenantId);
    on<FetchBillingByTenantId>(_onFetchBillingByTenantId);
  }

  Future<void> _onFetchBillingsByTenantId(FetchBillingsByTenantId event, Emitter<BillingState> emit) async {
    emit(BillingLoading());
    await Future.delayed(Duration(seconds: 1));
    try {
      final bills = await billingService.getAllByTenantId(event.tenantId);
      emit(BillingsLoaded(bills));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onFetchBillingByTenantId(FetchBillingByTenantId event, Emitter<BillingState> emit) async {
    emit(BillingLoading());
    await Future.delayed(Duration(seconds: 1));
    try {
      final bill = await billingService.getById(event.tenantId);
      emit(BillingLoaded(bill));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }
}
