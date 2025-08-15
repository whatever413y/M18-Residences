import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/auth/auth_state.dart';
import 'package:m18_residences/theme.dart';
import 'package:m18_residences/utils/custom_app_bar.dart';
import 'package:m18_residences/utils/widgets/widgets.dart';

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
        appBar: CustomAppBar(title: "Payment Methods"),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Unauthenticated) {
              return buildErrorWidget(context: context, message: authState.message);
            } else if (authState is UrlError) {
              return buildErrorWidget(context: context, message: authState.message);
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

  void _showPaymentImage(BuildContext context, String mode) {
    authBloc.add(FetchPaymentImageUrl(mode));
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is UrlLoading) {
                return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
              } else if (state is UrlLoaded) {
                return InteractiveViewer(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: Image.network(
                      state.url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load image'));
                      },
                    ),
                  ),
                );
              } else if (state is UrlError) {
                return Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('Error loading image: ${state.message}')));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(BuildContext context, String name, String iconPath) {
    return InkWell(
      onTap: () => _showPaymentImage(context, name.toLowerCase()),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: SizedBox(
          width: 250,
          height: 100,
          child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(iconPath, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
