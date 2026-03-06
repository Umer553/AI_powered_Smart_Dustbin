import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscuredOld = true;
  bool _isObscuredNew = true;
  bool _isObscuredConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔒 Old Password
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _isObscuredOld,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscuredOld
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _isObscuredOld = !_isObscuredOld);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your old password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 🔑 New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isObscuredNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscuredNew
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _isObscuredNew = !_isObscuredNew);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a new password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // ✅ Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscuredConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscuredConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _isObscuredConfirm = !_isObscuredConfirm);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // 🔘 Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Password changed successfully ✅")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
