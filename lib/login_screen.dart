import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart'; // ✅ Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      String enteredEmail = emailController.text.trim();
      String enteredPassword = passwordController.text.trim();

      if (enteredEmail == localEmail && enteredPassword == localPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Successful!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C), // Dark premium background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Card(
            color: const Color(0xFF1F1B38), // Dark card color
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.cyanAccent),
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.cyanAccent),
                        filled: true,
                        fillColor: const Color(0xFF2E1A47),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter email";
                        if (!value.contains("@") || !value.contains(".")) return "Enter valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.cyanAccent),
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.cyanAccent),
                        filled: true,
                        fillColor: const Color(0xFF2E1A47),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                              color: Colors.cyanAccent),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter password";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Remember Me + Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              checkColor: Colors.black,
                              fillColor: MaterialStateProperty.all(Colors.cyanAccent),
                              onChanged: (value) => setState(() => _rememberMe = value ?? false),
                            ),
                            const Text("Remember me", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        GestureDetector(
                          onTap: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Login Button
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Signup link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
