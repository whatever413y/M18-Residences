import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/auth/auth_state.dart';
import 'package:m18_shared/m18_shared.dart';

class PaymentPage extends StatefulWidget {
  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  late AuthBloc authBloc;

  final List<Map<String, String>> paymentMethods = [
    {"name": "BPI", "icon": "assets/icons/payments/bpi.png"},
    {"name": "GCash", "icon": "assets/icons/payments/gcash.png"},
    {"name": "Maya", "icon": "assets/icons/payments/maya.png"},
  ];

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: "Payment Methods", centerTitle: true),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Unauthenticated) {
              return ErrorView(message: authState.message);
            }

            return Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: paymentMethods.map((method) => _buildPaymentCard(context, method["name"]!, method["icon"]!)).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, String name, String iconPath) {
    return InkWell(
      onTap: () => SignedImageDialog.show(context, fetchUrl: () => authBloc.authApi.signedPaymentUrl(name.toLowerCase()), subject: 'image'),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: SizedBox(
          width: 250,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(iconPath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
