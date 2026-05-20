import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.agriculture,
                  size: 55,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome to Farmzo",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Login with mobile number",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 50),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
                  ],
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: "",
                    prefixIcon: Icon(Icons.phone, color: Colors.green),
                    hintText: "Enter mobile number",
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    String phone = phoneController.text.trim();

                    if (phone.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter valid mobile number"),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continue", style: TextStyle(fontSize: 17)),
                ),
              ),

              const Spacer(),

              Text(
                "Helping Farmers Connect Easily 🌾",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
