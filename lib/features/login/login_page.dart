import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/bloc/tenant/tenant_bloc.dart';
import 'package:rental_management_system_flutter/bloc/tenant/tenant_event.dart';
import 'package:rental_management_system_flutter/bloc/tenant/tenant_state.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _submittedName;
  String? _accountIdError;

  void _searchTenant() {
    if (_formKey.currentState?.validate() ?? false) {
      final inputText = _controller.text.trim();
      _submittedName = inputText;
      context.read<TenantBloc>().add(FetchTenantByTenantName(inputText));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width * 0.5;

    return Theme(
      data: theme,
      child: Scaffold(
        body: BlocListener<TenantBloc, TenantState>(
          listener: (context, state) {
            if (state is TenantLoaded) {
              if (state.tenant.name.toLowerCase() == _submittedName?.toLowerCase()) {
                _controller.clear();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomePage(tenant: state.tenant)));
              }
            } else if (state is TenantError) {
              setState(() {
                _accountIdError = "Account ID not found.";
              });
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.blue.shade500],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: screenWidth),
                        child: Padding(padding: const EdgeInsets.all(16.0), child: _buildCard(context)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Welcome", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              const SizedBox(height: 10),
              Text("Enter your Account ID to continue", style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _buildAccountIDInput(),
              const SizedBox(height: 20),
              _buildSearchButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountIDInput() {
    return CustomTextFormField(
      controller: _controller,
      labelText: 'Account ID',
      prefixIcon: const Icon(Icons.person),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your Account ID';
        }
        return _accountIdError;
      },
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _searchTenant,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.blue.shade700,
          elevation: 5,
        ),
        child: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
