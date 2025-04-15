import 'package:flutter/material.dart';
import '../billing/billing_page.dart';
import '../history/history_page.dart';

class HomePage extends StatefulWidget {
  final String inputText;

  HomePage({required this.inputText});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Home",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue.shade900,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade500],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSquareButton("Current Bill", Icons.receipt, BillingPage()),
              SizedBox(height: 20),
              _buildSquareButton(
                "Billing History",
                Icons.history,
                HistoryPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(String text, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(page),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.blue.shade800),
            SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
