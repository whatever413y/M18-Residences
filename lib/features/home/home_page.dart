import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/auth/auth_state.dart';
import 'package:m18_residences/bloc/billing/billing_bloc.dart';
import 'package:m18_residences/bloc/billing/billing_event.dart';
import 'package:m18_residences/bloc/billing/billing_state.dart';
import 'package:m18_residences/features/billing/billing_page.dart';
import 'package:m18_residences/models/billing.dart';
import 'package:m18_residences/models/tenant.dart';
import 'package:m18_residences/theme.dart';
import 'package:m18_residences/utils/custom_app_bar.dart';
import 'package:m18_residences/utils/widgets/widgets.dart';
import '../history/history_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late AuthBloc authBloc;
  late BillingBloc billingBloc;
  late Tenant tenant;
  Bill? bill;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
    tenant = authBloc.cachedTenant!;
    billingBloc = context.read<BillingBloc>();
    billingBloc.add(FetchBillingByTenantId(tenant.id));
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)).then((updated) {
      if (updated == true) {
        authBloc.add(CheckAuthStatus());
        billingBloc.add(FetchBillingByTenantId(tenant.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Welcome ${tenant.name}",
          logoutOnBack: true,
          showRefresh: true,
          onRefresh: () {
            billingBloc.add(FetchBillingByTenantId(tenant.id));
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isMobile = maxWidth < 600;

            final contentWidth = isMobile ? maxWidth : 600.0;

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Unauthenticated) {
                  return buildErrorWidget(context: context, message: authState.message);
                }
                return BlocBuilder<BillingBloc, BillingState>(
                  builder: (context, billingState) {
                    if (billingState is BillingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (billingState is BillingError) {
                      return buildErrorWidget(
                        context: context,
                        message: billingState.message,
                        onRetry: () => billingBloc.add(FetchBillingByTenantId(tenant.id)),
                      );
                    } else if (billingState is BillingLoaded) {
                      bill = billingState.bill;
                      if (bill == null) {
                        return buildErrorWidget(
                          context: context,
                          message: "No billing data available for this tenant.",
                          onRetry: () => billingBloc.add(FetchBillingByTenantId(tenant.id)),
                        );
                      }

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade900, Colors.blue.shade500],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Center(
                            child: SingleChildScrollView(
                              child: Container(
                                width: contentWidth,
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 24.0, vertical: 16.0),
                                child: _buildBody(context, isMobile),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 24.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(onTap: () => _navigateToPage(BillingPage()), child: buildBillCardWidget(bill!, context)),
          SizedBox(height: isMobile ? 16 : 20),
          _buildSquareButton("Billing History", Icons.history, HistoryPage(), isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildSquareButton(String text, IconData icon, Widget page, {required bool isMobile}) {
    return GestureDetector(
      onTap: () => _navigateToPage(page),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 40 : 50, color: Colors.blue.shade800),
            SizedBox(height: isMobile ? 8 : 10),
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
