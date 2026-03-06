import 'package:flutter/material.dart';
import 'dart:math';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> dustbins = [
    {"name": "Dustbin 1", "fill": 45, "location": "Sector A"},
    {"name": "Dustbin 2", "fill": 80, "location": "Sector B"},
    {"name": "Dustbin 3", "fill": 20, "location": "Sector C"},
    {"name": "Dustbin 4", "fill": 100, "location": "Sector D"},
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getFillColor(int fill) {
    if (fill >= 80) return Colors.redAccent;
    if (fill >= 50) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  Widget buildDustbinCard(Map<String, dynamic> dustbin) {
    final fill = dustbin['fill'];
    final isFull = fill >= 80;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress = fill / 100 * _controller.value;
          return Card(
            elevation: 10,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            shadowColor: isFull ? Colors.redAccent : Colors.black26,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFull
                      ? [Colors.red.shade100, Colors.red.shade300]
                      : [Colors.green.shade100, Colors.green.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          color: getFillColor(fill),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (isFull)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(Icons.warning,
                              color: Colors.red.shade700, size: 22),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dustbin['name'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dustbin['location'],
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade800),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            color: getFillColor(fill),
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dustbin Records"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: dustbins.length,
          itemBuilder: (context, index) {
            return buildDustbinCard(dustbins[index]);
          },
        ),
      ),
    );
  }
}
