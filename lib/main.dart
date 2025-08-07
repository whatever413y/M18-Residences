import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/billing/billing_bloc.dart';
import 'package:m18_residences/services/auth_service.dart';
import 'package:m18_residences/services/billing_service.dart';
import 'package:m18_residences/theme.dart';
import 'features/login/login_page.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authService: AuthService())..add(CheckAuthStatus())),
        BlocProvider(create: (context) => BillingBloc(billingService: BillingService())),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, title: 'M18 Residences', theme: AppTheme.lightTheme, home: LoginPage()),
    );
  }
}
