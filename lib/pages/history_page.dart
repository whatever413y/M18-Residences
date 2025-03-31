import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>>? billingHistory;
  List<Map<String, dynamic>>? electricityReadings;

  @override
  void initState() {
    super.initState();
    _fetchBillingHistory();
    _fetchElectricityReadings();
  }

  Future<void> _fetchBillingHistory() async {
    try {
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
        {
          "room_charges": 4800.00,
          "electric_charges": 1200.75,
          "additional_charges": 250.00,
          "total_amount": 6150.75,
          "created_at": DateTime.now().subtract(Duration(days: 60)),
        },
      ];
      setState(() {});
    } catch (e) {
      print("Error fetching billing history: $e");
    }
  }

  Future<void> _fetchElectricityReadings() async {
    try {
      await Future.delayed(Duration(seconds: 2));
      electricityReadings = [
        {"curr_reading": 320, "created_at": DateTime(2024, 01, 01)},
        {"curr_reading": 350, "created_at": DateTime(2024, 02, 01)},
        {"curr_reading": 400, "created_at": DateTime(2024, 03, 01)},
        {"curr_reading": 450, "created_at": DateTime(2024, 04, 01)},
        {"curr_reading": 500, "created_at": DateTime(2024, 05, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 06, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 07, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 08, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 09, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 10, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 11, 01)},
        {"curr_reading": 300, "created_at": DateTime(2024, 12, 01)},
        {"curr_reading": 300, "created_at": DateTime(2025, 1, 01)},
      ];
      setState(() {});
    } catch (e) {
      print("Error fetching electricity readings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Billing History')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGraph(),
            SizedBox(height: 20),
            Expanded(child: _buildBillingHistory()),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph() {
    if (electricityReadings == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (electricityReadings!.isEmpty) {
      return Center(child: Text("No electricity readings available."));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    electricityReadings!.sort((a, b) => b["created_at"].compareTo(a["created_at"]));
    
    double maxReading =
        electricityReadings!
            .map((e) => e["curr_reading"])
            .reduce((a, b) => a > b ? a : b)
            .toDouble();
    double yMax = ((maxReading / 5).ceil() * 5).toDouble();

    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.3,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            margin: EdgeInsets.only(top: 5),
            child: SizedBox(
              width: electricityReadings!.length * 90.0,
              height: screenHeight * 0.3,
              child: BarChart(
                BarChartData(
                  maxY: yMax,
                  minY: 0,
                  barGroups:
                      electricityReadings!.asMap().entries.map((entry) {
                        int index = entry.key;
                        double value = entry.value["curr_reading"].toDouble();
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              color: Colors.blue,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: yMax / 4,
                        getTitlesWidget:
                            (value, meta) => Text("${value.toInt()} kWh"),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 &&
                              index < electricityReadings!.length) {
                            DateTime date =
                                electricityReadings![index]["created_at"];
                            return Text(DateFormat("yyyyMM").format(date));
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingHistory() {
    if (billingHistory == null)
      return Center(child: CircularProgressIndicator());
    if (billingHistory!.isEmpty)
      return Center(child: Text("No billing history available."));

    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return ListView.builder(
      itemCount: billingHistory!.length,
      itemBuilder: (context, index) {
        final bill = billingHistory![index];
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bill Date: ${DateFormat.yMMMMd().format(bill["created_at"])}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            ),
          ),
        ],
      ),
    );
  }
}
