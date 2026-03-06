import 'package:flutter/material.dart';
import 'dart:async';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool isBackingUp = false;
  bool isRestoring = false;
  double progress = 0;

  // 🔹 Simulate Backup Process
  void _startBackup() {
    if (isBackingUp || isRestoring) return;

    setState(() {
      isBackingUp = true;
      progress = 0;
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        progress += 0.05;
      });
      if (progress >= 1) {
        timer.cancel();
        setState(() => isBackingUp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Backup completed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // 🔹 Simulate Restore Process
  void _startRestore() {
    if (isBackingUp || isRestoring) return;

    setState(() {
      isRestoring = true;
      progress = 0;
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        progress += 0.05;
      });
      if (progress >= 1) {
        timer.cancel();
        setState(() => isRestoring = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Data restored successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Backup & Restore"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 🟢 Icon + Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isBackingUp
                    ? Icons.cloud_upload
                    : isRestoring
                    ? Icons.cloud_download
                    : Icons.cloud_outlined,
                size: 80,
                color: Colors.green.shade700,
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Progress Indicator
            if (isBackingUp || isRestoring) ...[
              LinearProgressIndicator(
                value: progress,
                color: Colors.green.shade700,
                backgroundColor: Colors.green.shade200,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 20),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
            ],

            // 🔹 Buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    title: "Backup Now",
                    icon: Icons.cloud_upload,
                    color: Colors.green.shade700,
                    onPressed: _startBackup,
                    disabled: isBackingUp || isRestoring,
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    title: "Restore Data",
                    icon: Icons.cloud_download,
                    color: Colors.teal.shade600,
                    onPressed: _startRestore,
                    disabled: isBackingUp || isRestoring,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Note Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "💡 Tip: Backup your data regularly to keep it safe. You can restore it anytime from cloud storage.",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Button Widget
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool disabled,
  }) {
    return ElevatedButton.icon(
      onPressed: disabled ? null : onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? Colors.grey : color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
    );
  }
}
