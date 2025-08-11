import 'package:flutter_bloc/flutter_bloc.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import 'package:m18_residences/services/billing_service.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingService billingService;

  BillingBloc({required this.billingService}) : super(BillingInitial()) {
    on<FetchBillingsByTenantId>(_onFetchBillingsByTenantId);
    on<FetchBillingByTenantId>(_onFetchBillingByTenantId);
  }

  Future<void> _onFetchBillingsByTenantId(FetchBillingsByTenantId event, Emitter<BillingState> emit) async {
    emit(BillingLoading());
    await Future.delayed(const Duration(seconds: 1));
    final bills = await billingService.getAllByTenantId(event.tenantId);

    if (bills.isEmpty) {
      emit(BillingError('No bills found for tenant.'));
    } else {
      emit(BillingsLoaded(bills));
    }
  }

  Future<void> _onFetchBillingByTenantId(FetchBillingByTenantId event, Emitter<BillingState> emit) async {
    emit(BillingLoading());
    await Future.delayed(const Duration(seconds: 1));
    final bill = await billingService.getById(event.tenantId);

    if (bill == null) {
      emit(BillingError('Bill not found.'));
    } else {
      emit(BillingLoaded(bill));
    }
  }
}
