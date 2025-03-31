import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingPage extends StatefulWidget {
  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  Map<String, dynamic>? latestBill;

  @override
  void initState() {
    super.initState();
    _fetchLatestBill();
  }

  Future<void> _fetchLatestBill() async {
    try {
      await Future.delayed(Duration(seconds: 2));

      // Mock Data (Replace with actual DB fetch)
      Map<String, dynamic> bill = {
        "room_charges": 5000.00,
        "electric_charges": 1200.50,
        "additional_charges": 300.00,
        "additional_description": "Internet and water charges",
        "total_amount": 6500.50,
        "created_at": DateTime.now(),
      };

      setState(() {
        latestBill = bill;
      });
    } catch (e) {
      print("Error fetching bill: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Billing Statement')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: latestBill == null
            ? Center(child: CircularProgressIndicator()) 
            : _buildBillCard(),
      ),
    );
  }

  Widget _buildBillCard() {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Latest Bill",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),
            _buildBillItem("Room Charges", latestBill!["room_charges"], currencyFormat),
            _buildBillItem("Electric Charges", latestBill!["electric_charges"], currencyFormat),
            _buildBillItem("Additional Charges", latestBill!["additional_charges"], currencyFormat),
            if (latestBill!["additional_description"] != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Note: ${latestBill!["additional_description"]}",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Divider(),
            _buildBillItem("Total Amount", latestBill!["total_amount"], currencyFormat, isTotal: true),
            SizedBox(height: 10),
            Text(
              "Date Posted: ${DateFormat.yMMMMd().format(latestBill!["created_at"])}",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(String label, double amount, NumberFormat currencyFormat, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(currencyFormat.format(amount), style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
