import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/features/history/widgets/electric_consumption_bar_chart.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final BillingService billingService = BillingService();
  List<Bill>? billingHistory;
  List<Reading>? electricityReadings;

  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _fetchBillingHistory();
  }

  Future<void> _fetchBillingHistory() async {
    try {
      int tenantId = 7;
      List<Bill> bills = await billingService.getAllByTenantId(tenantId);

      billingHistory = bills;
      electricityReadings =
          bills.map((bill) {
            return Reading(
              id: bill.id,
              prevReading: bill.prevReading,
              currReading: bill.currReading,
              consumption: bill.consumption,
              createdAt: bill.createdAt,
            );
          }).toList();

      setState(() {});
    } catch (e) {
      print('Failed to fetch billing history: $e');
      billingHistory = [];
      electricityReadings = [];
      setState(() {});
    }
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
    return Scaffold(
      appBar: CustomAppBar(title: "Billing History"),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (electricityReadings == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildDropdownYearSelector(context),
          _buildGraph(context),
          SizedBox(height: 10),
          Expanded(child: _buildBillingHistory(context)),
        ],
      ),
    );
  }

  Widget _buildDropdownYearSelector(BuildContext context) {
    final years =
        electricityReadings!.map((e) => e.createdAt.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
    _selectedYear ??=
        years.contains(DateTime.now().year) ? DateTime.now().year : years.first;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0, top: 8.0),
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
    return SizedBox(
      height: 250,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: SizedBox(width: 500, child: _buildBarChart(context)),
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

    completeReadings.sort((a, b) => (b.createdAt).compareTo(a.createdAt));

    int maxReading = filteredReadings
        .map((e) => e.currReading)
        .reduce((a, b) => a > b ? a : b);

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

    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return ListView.builder(
      itemCount: billingHistory!.length,
      itemBuilder: (context, index) {
        final bill = billingHistory![index];

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

                // Readings
                _buildReadingItem("Previous Reading", bill.prevReading),
                _buildReadingItem("Current Reading", bill.currReading),
                _buildReadingItem("Consumption", bill.consumption),

                Divider(),

                // Charges
                _buildBillItem(
                  "Room Charges",
                  bill.roomCharges,
                  currencyFormat,
                ),
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
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ),

                Divider(),

                // Total
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
      },
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
