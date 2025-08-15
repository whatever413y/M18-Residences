import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/models/tenant.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:m18_residences/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  Tenant? _cachedTenant;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithAccountId>(_onLoginWithAccountId);
    on<LogoutRequested>(_onLogout);
    on<FetchReceiptUrl>(_onFetchReceiptUrl);
    on<FetchPaymentImageUrl>(_onFetchPaymentImageUrl);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isAuth = await authService.isAuthenticated();
    if (!isAuth) {
      return emit(Unauthenticated('Session has expired. Please try again'));
    }

    final token = await authService.getSavedToken();
    final tenantIdStr = await authService.getSavedTenantId();
    if (token == null || tenantIdStr == null) {
      return emit(Unauthenticated('Token or user missing'));
    }

    final tenantId = int.tryParse(tenantIdStr);
    if (tenantId == null) {
      return emit(Unauthenticated('Invalid tenant ID'));
    }

    final tenant = await authService.getByTenantId(tenantId);
    if (tenant == null) {
      return emit(Unauthenticated('Tenant not found'));
    }

    _cachedTenant = tenant;
    emit(Authenticated(token: token, tenant: tenant));
  }

  Future<void> _onLoginWithAccountId(LoginWithAccountId event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final token = await authService.login(event.accountId);

      if (token == null) {
        emit(AuthError('Account ID not found.'));
        return;
      }

      final tenant = authService.cachedTenant;
      if (tenant == null) {
        emit(AuthError('User data missing after login.'));
        return;
      }

      _cachedTenant = tenant;
      emit(Authenticated(token: token, tenant: tenant));
    } on TimeoutException {
      emit(AuthError('Connection timed out. Please try again.'));
    } on SocketException {
      emit(AuthError('Network error. Please check your connection.'));
    } catch (e) {
      emit(AuthError('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    _cachedTenant = null;
    emit(Unauthenticated('You have been logged out.'));
  }

  Future<void> _onFetchReceiptUrl(FetchReceiptUrl event, Emitter<AuthState> emit) async {
    emit(UrlLoading());
    try {
      final url = await authService.fetchReceiptUrl(event.tenantId, event.filename);
      if (url == null) throw Exception('URL not found');
      emit(UrlLoaded(url));
    } catch (e) {
      emit(UrlError(e.toString()));
    }
  }

  Future<void> _onFetchPaymentImageUrl(FetchPaymentImageUrl event, Emitter<AuthState> emit) async {
    emit(UrlLoading());
    try {
      final url = await authService.fetchPaymentImageUrl(event.filename);
      if (url == null) throw Exception('URL not found');
      emit(UrlLoaded(url));
    } catch (e) {
      emit(UrlError(e.toString()));
    }
  }

  Tenant? get cachedTenant => _cachedTenant;
}
