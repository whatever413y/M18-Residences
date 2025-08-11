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

    final token = await authService.login(event.accountId);
    if (token == null) {
      emit(AuthError('Login failed. Please check your account ID and try again.'));
      return;
    }

    final tenant = authService.cachedTenant;
    if (tenant == null) {
      emit(AuthError('User data missing after login.'));
      return;
    }

    _cachedTenant = tenant;
    emit(Authenticated(token: token, tenant: tenant));
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    _cachedTenant = null;
    emit(Unauthenticated('You have been logged out.'));
  }

  Tenant? get cachedTenant => _cachedTenant;
}
