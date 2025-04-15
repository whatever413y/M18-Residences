import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>>? billingHistory;
  List<Map<String, dynamic>>? electricityReadings;

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
    electricityReadings = List.generate(
      12,
      (index) => {
        "curr_reading": 300 + (index * 20),
        "created_at": DateTime(2024, index + 1, 1),
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billing History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildGraph(),
            SizedBox(height: 10),
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

  electricityReadings!.sort(
    (a, b) => b["created_at"].compareTo(a["created_at"]),
  );
  
  double maxReading = electricityReadings!
      .map((e) => e["curr_reading"])
      .reduce((a, b) => a > b ? a : b)
      .toDouble();
  
  double yMax = ((maxReading / 50).ceil() * 50).toDouble();

  return SizedBox(
    height: 250,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(top: 25.0),
        child: SizedBox(
          width: electricityReadings!.length * 60.0,
          child: BarChart(
            BarChartData(
              maxY: yMax,
              minY: 0,
              barGroups: electricityReadings!.asMap().entries.map((entry) {
                int index = entry.key;
                double value = entry.value["curr_reading"].toDouble();
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: Colors.blue,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: yMax,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    interval: yMax / 4,
                    getTitlesWidget: (value, meta) => Text("${value.toInt()} kWh"),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < electricityReadings!.length) {
                        DateTime date = electricityReadings![index]["created_at"];
                        return Text(DateFormat("yyyyMM").format(date));
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true, 
                  fitInsideVertically: true, 
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      "${rod.toY.toStringAsFixed(1)} kWh",
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (event is FlTapUpEvent && barTouchResponse != null) {
                  }
                },
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
    {
      return Center(child: CircularProgressIndicator());
    }
    if (billingHistory!.isEmpty)
    {
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
                  "Bill Date: ${DateFormat.yMMMMd().format(bill["created_at"])}",
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
