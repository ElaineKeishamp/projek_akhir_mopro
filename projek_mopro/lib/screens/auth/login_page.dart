import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/snackbar_helper.dart';
import '../main_page.dart';
import '../admin/admin_dashboard.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorSnackbar(context, "Email dan Password harus diisi");
      return;
    }

    setState(() => _isLoading = true);
    
    final res = await FirebaseService.login(_emailController.text, _passwordController.text);
    
    setState(() => _isLoading = false);

    if (res['status'] == 'success') {
      if (!mounted) return;
      UserData user = UserData.fromMap(res);
      if (user.role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage(user: user)));
      }
    } else {
      if (!mounted) return;
      showErrorSnackbar(context, res['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school, size: 80, color: primaryColor),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: titleStyle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login to access your CampusStore account",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textLight, fontSize: 16),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  label: "Email Address",
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: textLight)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
