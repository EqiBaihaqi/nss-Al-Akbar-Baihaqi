import 'package:flutter/material.dart';

class FaceVerificationBox extends StatelessWidget {
  final bool isVerified;
  final String verificationMessage;
  final VoidCallback onFailTrigger;
  final VoidCallback onBypassTrigger;

  const FaceVerificationBox({
    super.key,
    required this.isVerified,
    required this.verificationMessage,
    required this.onFailTrigger,
    required this.onBypassTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "8. SISTEM VALIDASI WAJAH DEBITUR (COMPLICATED FEATURE)",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 5),
          Text(
            "Status: $verificationMessage",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 5),
          const Text(
            "Melakukan Face Match 1-ke-1 antara foto Selfie Debitur dan foto e-KTP di database leasing untuk mencegah fraud.",
            style: TextStyle(fontSize: 10),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: onFailTrigger,
                child: const Text("Cek Face Match"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: onBypassTrigger,
                child: const Text("Bypass Manual", style: TextStyle(color: Colors.black87)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
