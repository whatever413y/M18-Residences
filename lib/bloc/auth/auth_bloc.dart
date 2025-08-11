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
    try {
      final isAuth = await authService.isAuthenticated();
      if (!isAuth) {
        return emit(Unauthenticated('Session has expired. Please try again'));
      }

      final token = await authService.getSavedToken();
      final tenantId = await authService.getSavedTenantId();
      final tenant = await authService.getByTenantId(int.parse(tenantId!));
      _cachedTenant = tenant;

      if (token == null || _cachedTenant == null) {
        return emit(Unauthenticated('Token or user missing'));
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
