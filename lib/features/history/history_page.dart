import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/auth/auth_state.dart';
import 'package:m18_residences/bloc/billing/billing_bloc.dart';
import 'package:m18_residences/bloc/billing/billing_event.dart';
import 'package:m18_residences/bloc/billing/billing_state.dart';
import 'package:m18_residences/features/history/widgets/electric_consumption_bar_chart.dart';
import 'package:m18_residences/models/billing.dart';
import 'package:m18_residences/models/reading.dart';
import 'package:m18_residences/models/tenant.dart';
import 'package:m18_residences/theme.dart';
import 'package:m18_residences/utils/custom_app_bar.dart';
import 'package:m18_residences/utils/custom_dropdown_form.dart';
import 'package:m18_residences/utils/widgets/widgets.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  late AuthBloc authBloc;
  late BillingBloc billingBloc;
  late Tenant tenant;

  List<Bill>? billingHistory;
  List<Reading>? electricityReadings;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
    tenant = authBloc.cachedTenant!;
    billingBloc = context.read<BillingBloc>();
    billingBloc.add(FetchBillingsByTenantId(tenant.id));
  }

  List<Reading> getCompleteReadingsForYear({required int selectedYear, required List<Reading> readings}) {
    return List.generate(12, (index) {
      final month = index + 1;
      final existingReading = readings.firstWhere(
        (reading) => reading.createdAt.year == selectedYear && reading.createdAt.month == month,
        orElse: () => Reading(id: 0, prevReading: 0, currReading: 0, consumption: 0, createdAt: DateTime(selectedYear, month)),
      );
      return existingReading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Billing History",
          showRefresh: true,
          onRefresh: () {
            billingBloc.add(FetchBillingsByTenantId(tenant.id));
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isMobile = maxWidth < 800;
            final horizontalPadding = isMobile ? 16.0 : 40.0;

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
                      return buildErrorWidget(context: context, message: billingState.message);
                    } else if (billingState is BillingsLoaded) {
                      billingHistory = billingState.bills;
                      if (billingHistory == null || billingHistory!.isEmpty) {
                        return buildErrorWidget(
                          context: context,
                          message: "No billing data available for this tenant.",
                          onRetry: () => billingBloc.add(FetchBillingByTenantId(tenant.id)),
                        );
                      }

                      electricityReadings =
                          billingHistory!.map((bill) {
                            return Reading(
                              id: bill.id,
                              prevReading: bill.prevReading,
                              currReading: bill.currReading,
                              consumption: bill.consumption,
                              createdAt: bill.createdAt,
                            );
                          }).toList();

                      _selectedYear ??=
                          electricityReadings!.any((r) => r.createdAt.year == DateTime.now().year)
                              ? DateTime.now().year
                              : electricityReadings!.first.createdAt.year;
                      final years = electricityReadings!.map((e) => e.createdAt.year).toSet().toList()..sort((a, b) => b.compareTo(a));
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (years.length > 1) SizedBox(width: isMobile ? 150 : 120, child: _buildDropdownYearSelector(context, years)),
                            _buildGraph(context, isMobile),
                            const SizedBox(height: 8),
                            Expanded(child: _buildBillingHistory(context, isMobile)),
                          ],
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

  Widget _buildDropdownYearSelector(BuildContext context, List<int> years) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: SizedBox(
          width: 100,
          child: CustomDropdownForm<int>(
            label: 'Year',
            value: _selectedYear,
            onChanged: (year) {
              setState(() {
                _selectedYear = year;
              });
            },
            items: years.map((year) => DropdownMenuItem<int>(value: year, child: Text('$year'))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(BuildContext context, bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double minBarWidth = 40;
    final int barCount = 12;
    final double minChartWidth = minBarWidth * barCount;
    final double graphWidth = isMobile ? minChartWidth : (screenWidth * 0.8);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 150,
        width: graphWidth,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(padding: const EdgeInsets.only(top: 5.0), child: SizedBox(width: graphWidth, child: _buildBarChart(context))),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final filteredReadings = electricityReadings!.where((reading) => reading.createdAt.year == _selectedYear).toList();

    final completeReadings = getCompleteReadingsForYear(selectedYear: _selectedYear!, readings: electricityReadings!);

    completeReadings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int maxReading = filteredReadings.isNotEmpty ? filteredReadings.map((e) => e.currReading).reduce((a, b) => a > b ? a : b) : 0;

    int yMax = ((maxReading / 50).ceil() * 50);

    final double barWidth = screenWidth < 800 ? 20 : 30;

    return ElectricConsumptionBarChart(completeReadings: completeReadings, yMax: yMax, barWidth: barWidth);
  }

  Widget _buildBillingHistory(BuildContext context, bool isMobile) {
    final maxListWidth = isMobile ? double.infinity : 800.0;

    if (billingHistory!.isEmpty) {
      return const Center(child: Text("No billing history available."));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 0 : 16),
      itemCount: billingHistory!.length,
      itemBuilder: (context, index) {
        final bill = billingHistory![index];

        return GestureDetector(
          onTap: () {
            showDialog(context: context, builder: (_) => _buildBillDialog(context, bill));
          },
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxListWidth),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), child: buildBillCardWidget(bill, context)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillDialog(BuildContext context, Bill bill) {
    final hasAdditionalCharges = (bill.additionalCharges ?? []).any((charge) => charge.amount != 0);
    final isWide = MediaQuery.of(context).size.width > 800;

    return AlertDialog(
      title: const Text("Billing Details", style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity, maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "Posting Date: ${DateFormat.yMMMMd().format(bill.createdAt)}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        bill.paid ? "Paid" : "Unpaid",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: bill.paid ? Colors.green : Colors.red),
                      ),
                      if (bill.receiptUrl != null) ...[const SizedBox(height: 8), buildReceipt(context, bill)],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1.2),
              const SizedBox(height: 12),

              buildReadingItemWidget("Previous Reading", bill.prevReading),
              const SizedBox(height: 8),
              buildReadingItemWidget("Current Reading", bill.currReading),
              const SizedBox(height: 8),
              buildReadingItemWidget("Consumption", bill.consumption),

              const SizedBox(height: 12),
              const Divider(thickness: 1.2),
              const SizedBox(height: 12),

              buildBillItemWidget("Room Charges", bill.roomCharges),
              const SizedBox(height: 8),
              buildBillItemWidget("Electric Charges", bill.electricCharges),

              if (hasAdditionalCharges) ...buildChargesDetails(bill.additionalCharges!),

              const SizedBox(height: 12),
              const Divider(thickness: 1.2),
              const SizedBox(height: 12),

              // Total
              buildBillItemWidget("Total Amount", bill.totalAmount, isTotal: true),
            ],
          ),
        ),
      ),
      actions: [TextButton(child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () => Navigator.of(context).pop())],
    );
  }
}
