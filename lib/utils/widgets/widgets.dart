import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/auth/auth_state.dart';
import 'package:m18_residences/features/login/login_page.dart';
import 'package:m18_residences/models/additional_charrges.dart';
import 'package:m18_residences/models/billing.dart';

Widget buildBillItemWidget(String label, int amount, {bool isTotal = false}) {
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
            softWrap: true,
          ),
        ),

        const SizedBox(width: 8),

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
  final numberFormat = NumberFormat.decimalPattern();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700]), softWrap: true)),
        const SizedBox(width: 8),
        Text("${numberFormat.format(value)} kWh", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
  return Card(
    elevation: 4,
    margin: EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Posting Date: ${DateFormat.yMMMMd().format(bill.createdAt)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
              Text(
                bill.paid ? "Paid" : "Unpaid",
                style: TextStyle(fontSize: 14, color: bill.paid ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Divider(),
          buildReadingItemWidget("Consumption", bill.consumption),
          Divider(),
          buildBillItemWidget("Total Amount", bill.totalAmount, isTotal: true),
        ],
      ),
    ),
  );
}

Widget buildReceipt(BuildContext context, String tenantName, Bill bill) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: InkWell(
      onTap: () {
        if (bill.receiptUrl != null) {
          context.read<AuthBloc>().add(FetchReceiptUrl(tenantName, bill.receiptUrl!));
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: SizedBox(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is UrlLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is UrlLoaded) {
                        return InteractiveViewer(
                          child: Image.network(
                            state.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load image'));
                            },
                          ),
                        );
                      } else if (state is UrlError) {
                        return Center(child: Text('Error loading receipt: ${state.message}'));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      },
      child: Text(Uri.parse(bill.receiptUrl!).pathSegments.last, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
    ),
  );
}

List<Widget> buildChargesDetails(List<AdditionalCharge> charges) {
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
  final additionalCharges = charges.where((c) => c.amount >= 0).toList();
  final discounts = charges.where((c) => c.amount < 0).toList();

  List<Widget> detailRows = [];

  if (additionalCharges.isNotEmpty) {
    detailRows.add(const SizedBox(height: 12));
    detailRows.add(const Text('Additional Charges', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)));
    detailRows.add(const SizedBox(height: 8));

    for (final charge in additionalCharges) {
      detailRows.add(buildChargeRow(charge.description, currencyFormat.format(charge.amount)));
    }
  }

  if (discounts.isNotEmpty) {
    detailRows.add(const SizedBox(height: 16));
    detailRows.add(const Text('Discounts', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)));
    detailRows.add(const SizedBox(height: 8));

    for (final charge in discounts) {
      detailRows.add(buildChargeRow(charge.description, currencyFormat.format(charge.amount.abs())));
    }
  }

  return detailRows;
}

Widget buildChargeRow(String description, String amount) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(description.isNotEmpty ? description : '-', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
        Text(amount),
      ],
    ),
  );
}
