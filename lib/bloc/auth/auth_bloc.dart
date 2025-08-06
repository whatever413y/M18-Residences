import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:rental_management_system_flutter/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  Tenant? _cachedTenant;

  AuthBloc({required this.authService}) : super(Unauthenticated()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithAccountId>(_onLoginWithAccountId);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isAuth = await authService.isAuthenticated();

    if (isAuth) {
      final tenantId = await authService.getSavedTenantId();
      if (tenantId != null) {
        try {
          final tenant = await authService.getByTenantName('admin');
          _cachedTenant = tenant;
          emit(Authenticated(token: 'dummy_token_123', tenant: tenant));
          return;
        } catch (_) {}
      }
    }

    emit(Unauthenticated());
  }

  Future<void> _onLoginWithAccountId(LoginWithAccountId event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tenant = await authService.getByTenantName(event.accountId);
      final token = await authService.login(tenant.name, tenant.id.toString());
      _cachedTenant = tenant;
      emit(Authenticated(token: token!, tenant: tenant));
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await authService.logout();
      _cachedTenant = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Tenant? get cachedTenant => _cachedTenant;
}
