import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 8,
        backgroundColor: Colors.black.withOpacity(0.2),
        shadowColor: Colors.greenAccent.withOpacity(0.3),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B5E20), // Deep green
              Color(0xFF2E7D32), // Forest
              Color(0xFF43A047), // Bright emerald
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                icon: Icons.lock,
                title: "Privacy Policy Overview",
                content:
                "We respect your privacy. Your personal data, including your name and email, is safely stored "
                    "and never shared without your consent. We comply with modern data protection laws to keep "
                    "your information secure.",
              ),
              _buildSection(
                icon: Icons.cloud,
                title: "Data Usage",
                content:
                "Your data is only used to enhance app functionality and improve user experience. "
                    "We never sell or share your information with third parties. Analytics help us optimize "
                    "Smart Dustbin features like fill-level alerts.",
              ),
              _buildSection(
                icon: Icons.verified_user,
                title: "User Rights",
                content:
                "You can view, edit, or delete your personal details anytime from your profile. "
                    "We ensure transparency and full control over your information.",
              ),
              _buildSection(
                icon: Icons.security,
                title: "Security Measures",
                content:
                "Advanced encryption, authentication, and secure storage are used to protect your data. "
                    "Our servers are constantly monitored to prevent unauthorized access.",
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  label: const Text(
                    "Back to Dashboard",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withOpacity(0.25),
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 45, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "🔒 Last Updated: October 2025",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Section Widget
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.92),
      elevation: 8,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: Colors.green.shade800, size: 26),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
