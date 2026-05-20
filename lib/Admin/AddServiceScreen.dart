import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  String selectedCategory = "Tractor";
  bool isLoading = false;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("services");

  final List<String> categories = [
    "Tractor",
    "Pickup",
    "Sprayer",
    "Harvester",
    "Seeder",
  ];

  Future<void> addService() async {
    if (serviceController.text.isEmpty ||
        mobileController.text.isEmpty ||
        rateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      await dbRef.child(id).set({
        "id": id,
        "serviceName": serviceController.text.trim(),
        "category": selectedCategory,
        "mobileNumber": mobileController.text.trim(),
        "rate": rateController.text.trim(),
        "createdAt": DateTime.now().toString(),
      });

      serviceController.clear();
      mobileController.clear();
      rateController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service Added")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget customField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.green),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),

      appBar: AppBar(
        title: const Text("Add Service"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.add_business,
                color: Colors.green,
                size: 40,
              ),
            ),

            const SizedBox(height: 25),

            customField(
              controller: serviceController,
              hint: "Service Name",
              icon: Icons.agriculture,
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),

            customField(
              controller: mobileController,
              hint: "Mobile Number",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            customField(
              controller: rateController,
              hint: "Rate Per Hour",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: addService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Service",
                        style: TextStyle(fontSize: 17),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
