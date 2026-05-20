import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  ActivityScreen({super.key});

  final List<Map<String, dynamic>> recentCalls = [
    {
      "name": "Ramesh Bhai",
      "tool": "Mahindra Tractor",
      "time": "Today, 10:30 AM",
      "category": "Tractor",
    },
    {
      "name": "Kishan Bhai",
      "tool": "Swaraj Tractor",
      "time": "Yesterday, 6:15 PM",
      "category": "Tractor",
    },
    {
      "name": "Amit Bhai",
      "tool": "Bolero Pickup",
      "time": "Yesterday, 2:40 PM",
      "category": "Pickup",
    },
    {
      "name": "Jayesh Bhai",
      "tool": "Power Sprayer",
      "time": "2 days ago",
      "category": "Sprayer",
    },
  ];

  IconData getIcon(String category) {
    switch (category) {
      case "Tractor":
        return Icons.agriculture;
      case "Pickup":
        return Icons.local_shipping;
      case "Sprayer":
        return Icons.water_drop;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text(
          "Recent Activity",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),

      body: recentCalls.isEmpty
          ? const Center(
              child: Text("No recent calls", style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: recentCalls.length,
              itemBuilder: (context, index) {
                final item = recentCalls[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          getIcon(item["category"]),
                          color: Colors.green,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              item["tool"],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              item["time"],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Icon(
                            Icons.call_made,
                            color: Colors.green.shade700,
                            size: 22,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Call Again"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
