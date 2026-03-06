import 'package:flutter/material.dart';
import 'about_app_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool autoUpdate = true;
  String selectedLanguage = "English";

  // 🌐 Texts for both languages (Backup removed)
  final Map<String, Map<String, String>> texts = {
    "English": {
      "settings": "Settings",
      "account": "Account",
      "change_pass": "Change Password",
      "change_pass_sub": "Update your login password",
      "preferences": "Preferences",
      "notifications": "Notifications",
      "notifications_sub": "Receive important alerts",
      "language": "App Language",
      "auto_update": "Auto Updates",
      "auto_update_sub": "Keep the app up to date automatically",
      "more": "More",
      "privacy": "Privacy Policy",
      "privacy_sub": "View data privacy terms",
      "about": "About App",
      "version": "Version 1.0.0",
      "select_lang": "Select Language",
      "english": "English",
      "urdu": "Urdu",
      "noti_on": "Notifications enabled",
      "noti_off": "Notifications turned off",
      "auto_on": "Auto updates enabled",
      "auto_off": "Auto updates disabled",
    },
    "Urdu": {
      "settings": "سیٹنگز",
      "account": "اکاؤنٹ",
      "change_pass": "پاس ورڈ تبدیل کریں",
      "change_pass_sub": "اپنا لاگ ان پاس ورڈ اپ ڈیٹ کریں",
      "preferences": "ترجیحات",
      "notifications": "اطلاعات",
      "notifications_sub": "اہم الرٹس حاصل کریں",
      "language": "ایپ کی زبان",
      "auto_update": "خودکار اپ ڈیٹس",
      "auto_update_sub": "ایپ کو خود بخود تازہ ترین رکھیں",
      "more": "مزید",
      "privacy": "پرائیویسی پالیسی",
      "privacy_sub": "ڈیٹا کی پرائیویسی کی تفصیلات دیکھیں",
      "about": "ایپ کے بارے میں",
      "version": "ورژن 1.0.0",
      "select_lang": "زبان منتخب کریں",
      "english": "انگریزی",
      "urdu": "اردو",
      "noti_on": "اطلاعات فعال کر دی گئیں",
      "noti_off": "اطلاعات بند کر دی گئیں",
      "auto_on": "خودکار اپ ڈیٹس فعال ہیں",
      "auto_off": "خودکار اپ ڈیٹس غیر فعال ہیں",
    },
  };

  @override
  Widget build(BuildContext context) {
    final t = texts[selectedLanguage]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t["settings"]!),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Directionality(
        textDirection: selectedLanguage == "Urdu"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🟩 Account Section
              _buildSectionTitle(t["account"]!),
              _buildSettingTile(
                icon: Icons.lock,
                title: t["change_pass"]!,
                subtitle: t["change_pass_sub"],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🟩 Preferences Section
              _buildSectionTitle(t["preferences"]!),
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: t["notifications"]!,
                subtitle: t["notifications_sub"],
                value: notificationsEnabled,
                onChanged: (val) {
                  setState(() => notificationsEnabled = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? t["noti_on"]! : t["noti_off"]!),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.language,
                title: t["language"]!,
                subtitle:
                "${t["language"]!}: ${t[selectedLanguage.toLowerCase()]!}",
                onTap: () => _showLanguageDialog(context, t),
              ),
              _buildSwitchTile(
                icon: Icons.system_update,
                title: t["auto_update"]!,
                subtitle: t["auto_update_sub"],
                value: autoUpdate,
                onChanged: (val) {
                  setState(() => autoUpdate = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? t["auto_on"]! : t["auto_off"]!),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🟩 More Section
              _buildSectionTitle(t["more"]!),
              _buildSettingTile(
                icon: Icons.privacy_tip,
                title: t["privacy"]!,
                subtitle: t["privacy_sub"],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${t["privacy"]!} coming soon")),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: t["about"]!,
                subtitle: t["version"],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutAppScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Language Dialog
  void _showLanguageDialog(BuildContext context, Map<String, String> t) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t["select_lang"]!),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(t["english"]!),
                value: "English",
                groupValue: selectedLanguage,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() => selectedLanguage = val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text(t["urdu"]!),
                value: "Urdu",
                groupValue: selectedLanguage,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() => selectedLanguage = val!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Reusable Widgets
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.green, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }
}
