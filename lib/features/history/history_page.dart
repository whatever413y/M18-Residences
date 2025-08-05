import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/bloc/billing_bloc.dart';
import 'package:rental_management_system_flutter/bloc/billing_event.dart';
import 'package:rental_management_system_flutter/bloc/billing_state.dart';
import 'package:rental_management_system_flutter/features/history/widgets/electric_consumption_bar_chart.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  late BillingBloc billingBloc;
  List<Bill>? billingHistory;
  List<Reading>? electricityReadings;
  int? _selectedYear;
  final int tenantId = 7; // Example tenant ID, replace with actual tenant ID

  @override
  void initState() {
    super.initState();
    billingBloc = context.read<BillingBloc>();
    billingBloc.add(FetchBillingByTenantId(tenantId));
  }

  List<Reading> getCompleteReadingsForYear({
    required int selectedYear,
    required List<Reading> readings,
  }) {
    return List.generate(12, (index) {
      final month = index + 1;
      final existingReading = readings.firstWhere(
        (reading) =>
            reading.createdAt.year == selectedYear &&
            reading.createdAt.month == month,
        orElse:
            () => Reading(
              id: 0,
              prevReading: 0,
              currReading: 0,
              consumption: 0,
              createdAt: DateTime(selectedYear, month),
            ),
      );
      return existingReading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isWideScreen = screenWidth >= 800;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: "Billing History"),
        body: BlocBuilder<BillingBloc, BillingState>(
          builder: (context, state) {
            if (state is BillingLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BillingError) {
              return _buildError(state.message);
            } else if (state is BillingLoaded) {
              billingHistory = state.bills;

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
                  electricityReadings!.any(
                        (r) => r.createdAt.year == DateTime.now().year,
                      )
                      ? DateTime.now().year
                      : electricityReadings!.first.createdAt.year;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 40 : 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        width: isWideScreen ? 150 : 120,
                        child: _buildDropdownYearSelector(context),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildGraph(context),
                    SizedBox(height: 16),
                    Expanded(child: _buildBillingHistory(context)),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<BillingBloc>().add(FetchBillingByTenantId(tenantId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownYearSelector(BuildContext context) {
    final years =
        electricityReadings!.map((e) => e.createdAt.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0, top: 8.0),
        child: SizedBox(
          width: 120,
          child: CustomDropdownForm<int>(
            label: 'Year',
            value: _selectedYear,
            onChanged: (year) {
              setState(() {
                _selectedYear = year;
              });
            },
            items:
                years
                    .map(
                      (year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final graphWidth = screenWidth * 0.8;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 250,
        width: graphWidth,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SizedBox(width: graphWidth, child: _buildBarChart(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final filteredReadings =
        electricityReadings!
            .where((reading) => reading.createdAt.year == _selectedYear)
            .toList();

    final completeReadings = getCompleteReadingsForYear(
      selectedYear: _selectedYear!,
      readings: electricityReadings!,
    );

    completeReadings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int maxReading =
        filteredReadings.isNotEmpty
            ? filteredReadings
                .map((e) => e.currReading)
                .reduce((a, b) => a > b ? a : b)
            : 0;

    int yMax = ((maxReading / 50).ceil() * 50);

    return ElectricConsumptionBarChart(
      completeReadings: completeReadings,
      yMax: yMax,
    );
  }

  Widget _buildBillingHistory(BuildContext context) {
    if (billingHistory!.isEmpty) {
      return Center(child: Text("No billing history available."));
    }

    return ListView.builder(
      itemCount: billingHistory!.length,
      itemBuilder: (context, index) {
        final bill = billingHistory![index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => _buildBillDialog(context, bill),
            );
          },
          child: _buildBillCard(bill, context),
        );
      },
    );
  }

  Widget _buildBillCard(Bill bill, BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Posting Date: ${DateFormat.yMMMMd().format(bill.createdAt)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            Divider(),

            // _buildReadingItem("Previous Reading", bill.prevReading),
            // _buildReadingItem("Current Reading", bill.currReading),
            _buildReadingItem("Consumption", bill.consumption),

            Divider(),

            // _buildBillItem("Room Charges", bill.roomCharges, currencyFormat),
            // _buildBillItem(
            //   "Electric Charges",
            //   bill.electricCharges,
            //   currencyFormat,
            // ),
            // _buildBillItem(
            //   "Additional Charges",
            //   bill.additionalCharges,
            //   currencyFormat,
            // ),

            // Divider(),
            _buildBillItem(
              "Total Amount",
              bill.totalAmount,
              currencyFormat,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDialog(BuildContext context, Bill bill) {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return AlertDialog(
      title: Text("Billing Details"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Posting Date: ${DateFormat.yMMMMd().format(bill.createdAt)}"),
            Divider(),

            _buildReadingItem("Previous Reading", bill.prevReading),
            _buildReadingItem("Current Reading", bill.currReading),
            _buildReadingItem("Consumption", bill.consumption),

            Divider(),

            _buildBillItem("Room Charges", bill.roomCharges, currencyFormat),
            _buildBillItem(
              "Electric Charges",
              bill.electricCharges,
              currencyFormat,
            ),
            _buildBillItem(
              "Additional Charges",
              bill.additionalCharges,
              currencyFormat,
            ),

            if (bill.additionalDescription.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "Note: ${bill.additionalDescription}",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),

            Divider(),

            _buildBillItem(
              "Total Amount",
              bill.totalAmount,
              currencyFormat,
              isTotal: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildBillItem(
    String label,
    int amount,
    NumberFormat currencyFormat, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue.shade900 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingItem(String label, int value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            "$value kWh",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
