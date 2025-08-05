import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'features/login/login_page.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M18 Residences',
      theme: AppTheme.lightTheme,
      home: LoginPage(),
    );
  }
}
