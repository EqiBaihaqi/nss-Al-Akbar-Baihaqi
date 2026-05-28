import 'package:flutter/material.dart';

class CameraSimulatorDialog extends StatelessWidget {
  final String sideName;
  final VoidCallback onCapture;

  const CameraSimulatorDialog({
    super.key,
    required this.sideName,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.black,
            height: 300,
            width: double.infinity,
            alignment: Alignment.center,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, color: Colors.grey, size: 80),
                      Text(
                        "Kamera: Sisi $sideName",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.black54,
                    child: Text(
                      "GPS: -6.1754, 106.8272\nWaktu: ${DateTime.now().toLocal()}\nSurveyor: Budi (Mock)",
                      style: const TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "INFO: Mengambil foto dengan watermark otomatis GPS + Waktu.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  onCapture();
                  Navigator.pop(context);
                },
                child: const Text("AMBIL FOTO"),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
