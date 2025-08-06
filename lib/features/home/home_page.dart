import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/bloc/billing/billing_bloc.dart';
import 'package:rental_management_system_flutter/bloc/billing/billing_event.dart';
import 'package:rental_management_system_flutter/bloc/billing/billing_state.dart';
import 'package:rental_management_system_flutter/features/billing/billing_page.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/widgets/widgets.dart';
import '../history/history_page.dart';

class HomePage extends StatefulWidget {
  final Tenant tenant;

  HomePage({required this.tenant});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late BillingBloc billingBloc;
  late int tenantId;
  Bill? bill;

  @override
  void initState() {
    super.initState();
    tenantId = widget.tenant.id!;
    billingBloc = context.read<BillingBloc>();
    billingBloc.add(FetchBillingByTenantId(tenantId));
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)).then((updated) {
      if (updated == true) {
        billingBloc.add(FetchBillingByTenantId(tenantId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: "Welcome ${widget.tenant.name}"),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 800;

            return BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state is BillingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BillingError) {
                  return buildErrorWidget(context: context, message: state.message, onRetry: () => billingBloc.add(FetchBillingByTenantId(tenantId)));
                } else if (state is BillingLoaded) {
                  bill = state.bill;

                  if (bill == null) {
                    return const Center(child: CircularProgressIndicator());
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
                            width: isMobile ? double.infinity : 800,
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            padding: const EdgeInsets.all(16.0),
                            child: _buildBody(context),
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
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(onTap: () => _navigateToPage(BillingPage()), child: buildBillCardWidget(bill!, context)),
          const SizedBox(height: 20),
          _buildSquareButton("Billing History", Icons.history, HistoryPage()),
        ],
      ),
    );
  }

  Widget _buildSquareButton(String text, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(page),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.blue.shade800),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
