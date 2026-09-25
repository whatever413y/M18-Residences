import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/billing/billing_bloc.dart';
import 'package:m18_shared/m18_shared.dart';

import 'features/login/login_page.dart';

void main() {
  // Throws a clear StateError at startup, rather than on the first request, when the build has no API_URL
  // (build/run with --dart-define-from-file=.env).
  ApiConfig.baseUrl;

  final client = ApiClient(tokens: TokenStore('tenant_id'));
  runApp(MyApp(authApi: AuthApi(client), billApi: BillApi(client), tenantApi: TenantApi(client)));

  // Browser e2e builds (--dart-define=E2E=true) keep the accessibility tree on: the tests find widgets through it.
  if (const bool.fromEnvironment('E2E')) SemanticsBinding.instance.ensureSemantics();
}

class MyApp extends StatelessWidget {
  final AuthApi authApi;
  final BillApi billApi;
  final TenantApi tenantApi;

  MyApp({required this.authApi, required this.billApi, required this.tenantApi});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authApi: authApi, tenantApi: tenantApi)..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => BillingBloc(billApi: billApi)),
      ],
      child: LogoutScope(
        onLogout: (context) {
          context.read<AuthBloc>().add(LogoutRequested());
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
        },
        child: MaterialApp(debugShowCheckedModeBanner: false, title: 'M18 Residences', theme: AppTheme.lightTheme, home: LoginPage()),
      ),
    );
  }
}
