import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:rental_management_system_flutter/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  Tenant? _cachedTenant;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithAccountId>(_onLoginWithAccountId);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final isAuth = await authService.isAuthenticated();
      if (!isAuth) {
        return emit(Unauthenticated('Session has expired. Please try again'));
      }

      final tenantId = await authService.getSavedTenantId();
      if (tenantId == null) {
        return emit(Unauthenticated('Tenant ID is missing. Please try again.'));
      }

      final tenant = _cachedTenant ?? await authService.getByTenantId(int.parse(tenantId));
      _cachedTenant = tenant;

      final token = await authService.getSavedToken();
      if (token == null) {
        return emit(Unauthenticated('Token is unexpectedly missing. Please try again.'));
      }

      emit(Authenticated(token: token, tenant: tenant));
    } catch (e) {
      emit(Unauthenticated('An error occurred while checking authentication status: $e'));
    }
  }

  Future<void> _onLoginWithAccountId(LoginWithAccountId event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authService.login(event.accountId);
      final tenant = authService.cachedTenant!;
      _cachedTenant = tenant;
      emit(Authenticated(token: token!, tenant: tenant));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    _cachedTenant = null;
    emit(Unauthenticated('You have been logged out.'));
  }

  Tenant? get cachedTenant => _cachedTenant;
}
