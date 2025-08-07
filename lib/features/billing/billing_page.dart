import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_event.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_state.dart';
import 'package:rental_management_system_flutter/bloc/billing/billing_bloc.dart';
import 'package:rental_management_system_flutter/bloc/billing/billing_event.dart';
import 'package:rental_management_system_flutter/bloc/billing/billing_state.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/widgets/widgets.dart';

class BillingPage extends StatefulWidget {
  @override
  BillingPageState createState() => BillingPageState();
}

class BillingPageState extends State<BillingPage> {
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
    billingBloc.add(FetchBillingByTenantId(tenant.id!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: "Billing Statement"),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 800;

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Unauthenticated) {
                  return buildErrorWidget(context: context, message: 'You are not authenticated. Please log in.');
                }

                return BlocBuilder<BillingBloc, BillingState>(
                  builder: (context, billingState) {
                    if (billingState is BillingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (billingState is BillingError) {
                      return buildErrorWidget(
                        context: context,
                        message: billingState.message,
                        onRetry: () => billingBloc.add(FetchBillingByTenantId(tenant.id!)),
                      );
                    } else if (billingState is BillingLoaded) {
                      bill = billingState.bill;
                      if (bill == null) {
                        return buildErrorWidget(
                          context: context,
                          message: "No billing data available for this tenant.",
                          onRetry: () => billingBloc.add(FetchBillingByTenantId(tenant.id!)),
                        );
                      }

                      return Center(
                        child: SingleChildScrollView(
                          child: Container(
                            width: isMobile ? double.infinity : 800,
                            padding: const EdgeInsets.all(16.0),
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: _buildBillCard(bill!),
                          ),
                        ),
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

  Widget _buildBillCard(Bill bill) {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Latest Bill", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
            Divider(thickness: 1.2),
            buildReadingItemWidget("Previous Reading", bill.prevReading),
            buildReadingItemWidget("Current Reading", bill.currReading),
            buildReadingItemWidget("Consumption", bill.consumption),
            Divider(thickness: 1.2),
            buildBillItemWidget("Room Charges", bill.roomCharges, currencyFormat),
            buildBillItemWidget("Electric Charges", bill.electricCharges, currencyFormat),
            buildBillItemWidget("Additional Charges", bill.additionalCharges, currencyFormat),

            if (bill.additionalDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Note: ${bill.additionalDescription}",
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              ),

            Divider(thickness: 1.2),
            buildBillItemWidget("Total Amount", bill.totalAmount, currencyFormat, isTotal: true),
            const SizedBox(height: 15),

            Align(
              alignment: Alignment.centerRight,
              child: Text("Date Posted: ${DateFormat.yMMMMd().format(bill.createdAt)}", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
