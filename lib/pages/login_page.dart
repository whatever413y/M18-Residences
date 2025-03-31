import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _controller = TextEditingController();

  void _navigateToNextPage() {
    String inputText = _controller.text.trim();
    if (inputText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(inputText: inputText),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            // Image.asset(
            //   'assets/logo.png', 
            //   height: 100,        
            // ),
            Image.network('https://as2.ftcdn.net/v2/jpg/06/18/70/35/1000_F_618703552_WeVTEs8XmeEb1hGiEZ5ZjJXSbx4yiiPm.jpg', height: 200),
            SizedBox(height: 30),

            // Account ID Input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Account ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Search Button
            ElevatedButton(
              onPressed: _navigateToNextPage,
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
