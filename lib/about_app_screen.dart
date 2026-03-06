import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About App"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🌿 App Logo
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/1.jpg', // 👈 your logo path
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),

            // 🌟 App Name
            Text(
              "Smart Dustbin App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 10),

            // 🔢 Version
            Text(
              "Version 1.0.0",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // 🧭 Divider
            Divider(
              color: Colors.green.shade300,
              thickness: 1.2,
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 20),

            // 📝 Description
            Text(
              "The Smart Dustbin App is an AI-powered waste management solution designed to make cities cleaner and smarter. "
                  "It uses sensors to detect fill levels, notifies municipal authorities when full, and displays real-time bin data on your screen. "
                  "With features like data backup, user profiles, and notifications, it ensures efficient and eco-friendly waste handling.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 👨‍💻 Developer Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person, color: Colors.green, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    "Developed by",
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Haseeb Sulman",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Final Year Project - AI Powered Smart Dustbin",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🌍 Footer
            Text(
              "© 2025 Smart Dustbin Inc. All rights reserved.",
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
