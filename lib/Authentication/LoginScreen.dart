import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;
  bool isLoading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> sendOTP() async {
    setState(() {
      isLoading = true;
    });

    await auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text.trim()}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Verification Failed")),
        );
      },

      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          otpSent = true;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP Sent")));
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> verifyOTP() async {
    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await auth.signInWithCredential(credential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful")));

      // Navigate to Bottom Navigation Screen
      // Navigator.pushReplacement(...);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget customField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.green),
          hintText: hint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.green,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Farmzo Login",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                otpSent ? "Enter OTP" : "Login with mobile number",
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 35),

              if (!otpSent)
                customField(
                  controller: phoneController,
                  hint: "Enter Mobile Number",
                  icon: Icons.phone,
                  type: TextInputType.phone,
                ),

              if (otpSent)
                customField(
                  controller: otpController,
                  hint: "Enter OTP",
                  icon: Icons.lock,
                  type: TextInputType.number,
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : otpSent
                      ? verifyOTP
                      : sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          otpSent ? "Verify OTP" : "Send OTP",
                          style: const TextStyle(fontSize: 17),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
