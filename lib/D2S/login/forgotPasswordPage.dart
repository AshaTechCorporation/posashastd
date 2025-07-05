import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลืมรหัสผ่าน', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('กรุณากรอกอีเมลเพื่อรีเซ็ตรหัสผ่าน', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'อีเมล'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: ส่งอีเมลรีเซ็ตรหัสผ่าน
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('ส่งคำขอสำเร็จ'),
                            content: const Text('กรุณาตรวจสอบอีเมลของคุณเพื่อรีเซ็ตรหัสผ่าน'),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง'))],
                          ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8BC34A), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('รีเซ็ตรหัสผ่าน', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
