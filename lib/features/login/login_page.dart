import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_bloc.dart';
import 'package:m18_residences/bloc/auth/auth_event.dart';
import 'package:m18_residences/bloc/auth/auth_state.dart';
import 'package:m18_residences/theme.dart';
import 'package:m18_residences/utils/custom_form_field.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _accountIdError;

  void _searchTenant() {
    setState(() {
      _accountIdError = null;
    });
    if (_formKey.currentState?.validate() ?? false) {
      final inputText = _controller.text.trim();
      context.read<AuthBloc>().add(LoginWithAccountId(inputText));
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              setState(() {
                _accountIdError = "Account ID not found.";
              });
              _formKey.currentState?.validate();
            } else if (state is Authenticated) {
              _controller.clear();
              _navigateToPage(HomePage());
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              final cardWidth = maxWidth < 500 ? maxWidth * 0.9 : 400.0;

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
                        constraints: BoxConstraints(maxWidth: cardWidth),
                        child: Padding(padding: const EdgeInsets.all(16.0), child: _buildCard(context, maxWidth)),
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

  Widget _buildCard(BuildContext context, double maxWidth) {
    final isMobile = maxWidth < 400;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Welcome", style: TextStyle(fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              SizedBox(height: isMobile ? 8 : 10),
              Text(
                "Enter your Account ID to continue",
                style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _buildAccountIDInput(),
              SizedBox(height: isMobile ? 16 : 20),
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
