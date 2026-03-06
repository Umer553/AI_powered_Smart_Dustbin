import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'privacy_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'record_screen.dart';
import 'login_screen.dart';

class SmartDustbinApp extends StatefulWidget {
  const SmartDustbinApp({super.key});

  @override
  _SmartDustbinAppState createState() => _SmartDustbinAppState();
}

class _SmartDustbinAppState extends State<SmartDustbinApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Dustbin Dashboard",
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _themeMode,
      home: DashboardWrapper(onThemeToggle: toggleTheme),
    );
  }
}

// ==================== Dashboard Wrapper ====================
class DashboardWrapper extends StatefulWidget {
  final Function(bool) onThemeToggle;
  const DashboardWrapper({super.key, required this.onThemeToggle});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  bool isLoggedIn = true;

  void logout() {
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? HomeScreen(
      onThemeToggle: widget.onThemeToggle,
      onLogout: logout,
    )
        : const LoginScreen();
  }
}

// ==================== Home Screen ====================
class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final VoidCallback onLogout;
  const HomeScreen(
      {super.key, required this.onThemeToggle, required this.onLogout});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int fillLevel = 65;
  bool isVacuumOn = false;
  bool isDarkMode = false;
  late AnimationController _vacuumController;
  late AnimationController _waveController;

  File? profileImage;

  @override
  void initState() {
    super.initState();
    _vacuumController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0,
      upperBound: 0.1,
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _vacuumController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void toggleVacuum() {
    setState(() {
      isVacuumOn = !isVacuumOn;
      if (isVacuumOn) {
        _vacuumController.repeat(reverse: true);
      } else {
        _vacuumController.stop();
        _vacuumController.reset();
      }
    });
  }

  void goHome() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Already on Home Screen")));
  }

  void logout() {
    widget.onLogout();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged Out Successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1B5E20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : const AssetImage('assets/profile_placeholder.png')
                    as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "User/Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Record'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecordScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
              },
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                  widget.onThemeToggle(isDarkMode);
                });
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

      // ===================== BODY (CARDS) =====================
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: DustbinCard(fillLevel, _waveController)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: VacuumCard(
                          isVacuumOn: isVacuumOn,
                          toggleVacuum: toggleVacuum,
                          controller: _vacuumController)),
                ],
              ),
              const SizedBox(height: 16),

              // ========== UPDATED ROW ==========
              Row(
                children: [
                  Expanded(child: NotificationCard(fillLevel: fillLevel)),
                  const SizedBox(width: 16),
                  Expanded(child: NextCollectionCard(fillLevel: fillLevel)),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== Bottom Navbar ====================
  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F2C), Color(0xFF2E1A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: "Home",
            child: IconButton(
                icon:
                const Icon(Icons.home, color: Colors.cyanAccent, size: 36),
                onPressed: goHome),
          ),
          Tooltip(
            message: "Search",
            child: IconButton(
                icon: const Icon(Icons.search,
                    color: Colors.cyanAccent, size: 36),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Search clicked")));
                }),
          ),
          Tooltip(
            message: "Notifications",
            child: IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.cyanAccent, size: 36),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notification clicked")));
                }),
          ),
          Tooltip(
            message: "Messages",
            child: IconButton(
                icon: const Icon(Icons.message,
                    color: Colors.cyanAccent, size: 36),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Message clicked")));
                }),
          ),
          Builder(
            builder: (context) => Tooltip(
              message: "Menu",
              child: IconButton(
                icon: const Icon(Icons.menu,
                    color: Colors.cyanAccent, size: 36),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Dustbin Card ====================
class DustbinCard extends StatelessWidget {
  final int fillLevel;
  final AnimationController controller;
  const DustbinCard(this.fillLevel, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Dustbin Level",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return SizedBox(
                  height: 120,
                  width: 120,
                  child: CustomPaint(
                    painter: WaveProgressPainter(
                        progress: fillLevel / 100,
                        color: Colors.white,
                        wavePhase: controller.value * 2 * pi),
                    child: Center(
                        child: Text(
                          "$fillLevel%",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              fillLevel >= 100
                  ? "Full"
                  : fillLevel >= 50
                  ? "Half"
                  : "Safe",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Next Collection Card ====================
class NextCollectionCard extends StatelessWidget {
  final int fillLevel;
  const NextCollectionCard({super.key, required this.fillLevel});

  @override
  Widget build(BuildContext context) {
    int hoursLeft = ((100 - fillLevel) * 0.5).ceil();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      shadowColor: Colors.purpleAccent.withOpacity(0.5),
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFE040FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Next Collection",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.access_time_filled,
                size: 60, color: Colors.white),
            const SizedBox(height: 15),
            Text(
              "$hoursLeft hours left",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Vacuum, Notification Cards ====================
class VacuumCard extends StatelessWidget {
  final bool isVacuumOn;
  final VoidCallback toggleVacuum;
  final AnimationController controller;

  const VacuumCard(
      {super.key,
        required this.isVacuumOn,
        required this.toggleVacuum,
        required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      shadowColor: Colors.tealAccent.withOpacity(0.5),
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Vacuum System",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isVacuumOn ? "ON" : "OFF",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            RotationTransition(
              turns: controller,
              child: const Icon(
                Icons.air,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleVacuum,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(isVacuumOn ? "Turn OFF" : "Turn ON"),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final int fillLevel;
  const NotificationCard({super.key, required this.fillLevel});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      shadowColor: Colors.lightGreenAccent.withOpacity(0.5),
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Notification",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: fillLevel >= 100 ? 1.0 : 0.7,
              duration: const Duration(seconds: 1),
              child: Icon(
                fillLevel >= 100
                    ? Icons.notification_important
                    : Icons.notifications_none,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              fillLevel >= 100 ? "Dustbin Full! 🚨" : "No Alerts",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Wave Painter ====================
class WaveProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double wavePhase;

  WaveProgressPainter(
      {required this.progress, required this.color, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.6);
    final path = Path();
    double waveHeight = 8;
    double baseHeight = size.height * (1 - progress);

    path.moveTo(0, baseHeight);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
          i,
          baseHeight +
              sin((i / size.width * 2 * pi) * 2 + wavePhase) * waveHeight);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(60)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.color != color;
  }
}
