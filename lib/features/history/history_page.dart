import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/features/history/widgets/electric_consumption_bar_chart.dart';
import 'package:rental_management_system_flutter/utils/widgets/custom_app_bar.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>>? billingHistory;
  List<Map<String, dynamic>>? electricityReadings;

  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _fetchBillingHistory();
    _fetchElectricityReadings();
  }

  Future<void> _fetchBillingHistory() async {
    await Future.delayed(Duration(seconds: 2));
    billingHistory = [
      {
        "room_charges": 5000.00,
        "electric_charges": 1200.50,
        "additional_charges": 300.00,
        "total_amount": 6500.50,
        "created_at": DateTime.now().subtract(Duration(days: 30)),
      },
      {
        "room_charges": 4800.00,
        "electric_charges": 1100.75,
        "additional_charges": 250.00,
        "total_amount": 6150.75,
        "created_at": DateTime.now().subtract(Duration(days: 60)),
      },
    ];
    setState(() {});
  }

  Future<void> _fetchElectricityReadings() async {
    await Future.delayed(Duration(seconds: 2));

    electricityReadings = [
      {"curr_reading": 300, "created_at": DateTime(2024, 1, 1)},
      {"curr_reading": 320, "created_at": DateTime(2024, 2, 1)},
      {"curr_reading": 300, "created_at": DateTime(2024, 3, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 4, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 5, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 8, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 9, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 10, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 11, 1)},
      {"curr_reading": 290, "created_at": DateTime(2024, 12, 1)},
      {"curr_reading": 340, "created_at": DateTime(2023, 3, 1)},
      {"curr_reading": 360, "created_at": DateTime(2021, 4, 1)},
    ];

    setState(() {});
  }

  List<Map<String, dynamic>> getCompleteReadingsForYear({
    required int selectedYear,
    required List<Map<String, dynamic>> readings,
  }) {
    return List.generate(12, (index) {
      final month = index + 1;
      final existingReading = readings.firstWhere(
        (reading) =>
            (reading["created_at"] as DateTime).year == selectedYear &&
            (reading["created_at"] as DateTime).month == month,
        orElse: () => {},
      );

      if (existingReading.isNotEmpty) {
        return existingReading;
      } else {
        return {"created_at": DateTime(selectedYear, month), "curr_reading": 0};
      }
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
        electricityReadings!.map((e) => e["created_at"].year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    _selectedYear ??=
        years.contains(DateTime.now().year) ? DateTime.now().year : years.first;

    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedYear,
            onChanged: (year) {
              setState(() {
                _selectedYear = year;
              });
            },
            style: const TextStyle(fontSize: 14, color: Colors.black),
            icon: const Icon(Icons.keyboard_arrow_down),
            items:
                years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text('$year'),
                  );
                }).toList(),
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
        electricityReadings
            ?.where(
              (reading) =>
                  (reading["created_at"] as DateTime).year == _selectedYear,
            )
            .toList();
    final completeReadings = getCompleteReadingsForYear(
      selectedYear: _selectedYear!,
      readings: electricityReadings!,
    );

    completeReadings.sort(
      (a, b) =>
          (b["created_at"] as DateTime).compareTo(a["created_at"] as DateTime),
    );

    double maxReading =
        filteredReadings!
            .map((e) => e["curr_reading"])
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    double yMax = ((maxReading / 50).ceil() * 50).toDouble();

    return ElectricConsumptionBarChart(completeReadings: completeReadings, yMax: yMax);
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
                  "Posting Date: ${DateFormat.yMMMMd().format(bill["created_at"])}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Divider(),
                _buildBillItem(
                  "Room Charges",
                  bill["room_charges"],
                  currencyFormat,
                ),
                _buildBillItem(
                  "Electric Charges",
                  bill["electric_charges"],
                  currencyFormat,
                ),
                _buildBillItem(
                  "Additional Charges",
                  bill["additional_charges"],
                  currencyFormat,
                ),
                Divider(),
                _buildBillItem(
                  "Total Amount",
                  bill["total_amount"],
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
    double amount,
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
}
