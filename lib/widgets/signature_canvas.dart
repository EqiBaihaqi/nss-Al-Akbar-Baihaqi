import 'package:flutter/material.dart';

class SignatureCanvas extends StatelessWidget {
  final List<Offset?> points;
  final Function(Offset?) onPointAdded;
  final VoidCallback onClear;

  const SignatureCanvas({
    super.key,
    required this.points,
    required this.onPointAdded,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            color: Colors.white,
          ),
          child: GestureDetector(
            onPanStart: (details) {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              onPointAdded(renderBox.globalToLocal(details.globalPosition));
            },
            onPanUpdate: (details) {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              onPointAdded(renderBox.globalToLocal(details.globalPosition));
            },
            onPanEnd: (details) {
              onPointAdded(null);
            },
            child: CustomPaint(
              painter: SignaturePainter(points: points),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              points.isEmpty ? "Belum Tanda Tangan" : "Tanda Tangan Terisi",
              style: TextStyle(
                color: points.isEmpty ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            ElevatedButton(
              onPressed: onClear,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
              child: const Text("Bersihkan Canvas"),
            )
          ],
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final drawPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          Offset(points[i]!.dx, points[i]!.dy - 200), 
          Offset(points[i + 1]!.dx, points[i + 1]!.dy - 200), 
          drawPaint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) => oldDelegate.points != points;
}
