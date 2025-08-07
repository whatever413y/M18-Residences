import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/bloc/auth/auth_event.dart';
import 'package:rental_management_system_flutter/features/login/login_page.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

Widget buildBillItemWidget(String label, int amount, NumberFormat currencyFormat, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
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

Widget buildReadingItemWidget(String label, int value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text("$value kWh", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

Widget buildErrorWidget({required BuildContext context, required String message, VoidCallback? onRetry}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed:
              onRetry ??
              () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
              },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    ),
  );
}

Widget buildBillCardWidget(Bill bill, BuildContext context) {
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          Divider(),
          buildReadingItemWidget("Consumption", bill.consumption),
          Divider(),
          buildBillItemWidget("Total Amount", bill.totalAmount, currencyFormat, isTotal: true),
        ],
      ),
    ),
  );
}
