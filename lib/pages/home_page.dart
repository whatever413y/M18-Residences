import 'package:flutter/material.dart';
import 'billing_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  final String inputText;

  HomePage({required this.inputText});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.inputText)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSquareButton("Current Bill", Icons.receipt, BillingPage()),
            SizedBox(height: 20),
            _buildSquareButton("Billing History", Icons.history, HistoryPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(String text, IconData icon, Widget page) {
    return ElevatedButton(
      onPressed: () => _navigateToPage(page),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(double.infinity, 120),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
