import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RadarMapDialog extends StatelessWidget {
  final String cityName;

  const RadarMapDialog({super.key, required this.cityName});

  static void show(BuildContext context, String cityName) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1B1C33).withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Live Weather Radar',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
            content: RadarMapDialogContent(cityName: cityName),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RadarMapDialogContent(cityName: cityName);
  }
}

class RadarMapDialogContent extends StatefulWidget {
  final String cityName;
  const RadarMapDialogContent({super.key, required this.cityName});

  @override
  State<RadarMapDialogContent> createState() => _RadarMapDialogContentState();
}

class _RadarMapDialogContentState extends State<RadarMapDialogContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _radarMode = 'rain'; // 'rain', 'temp', 'wind'
  bool _isPlaying = true;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode Selector Toggles
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeTab('rain', 'Rain Radar'),
              _buildModeTab('temp', 'Temperature'),
              _buildModeTab('wind', 'Wind Flow'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Radar Canvas Window
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0E1C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Stack(
              children: [
                // Simulated radar drawings
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: RadarMapPainter(
                          mode: _radarMode,
                          animationVal: _controller.value,
                          isPlaying: _isPlaying,
                          zoomLevel: _zoomLevel,
                        ),
                      );
                    },
                  ),
                ),
                
                // Radar Scan Center Dot & Ring Indicators
                const Center(
                  child: Icon(Icons.location_searching_rounded, color: Color(0xFF38BDF8), size: 18),
                ),
                
                // Zoom Control Buttons on the bottom right of canvas
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _buildCanvasControl(Icons.add_rounded, () {
                        setState(() {
                          _zoomLevel = (_zoomLevel + 0.2).clamp(0.6, 2.0);
                        });
                      }),
                      const SizedBox(height: 6),
                      _buildCanvasControl(Icons.remove_rounded, () {
                        setState(() {
                          _zoomLevel = (_zoomLevel - 0.2).clamp(0.6, 2.0);
                        });
                      }),
                    ],
                  ),
                ),

                // City indicator overlay top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.cityName} (Live)',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Controls bar (Play/Pause, Zoom readout)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                      if (_isPlaying) {
                        _controller.repeat();
                      } else {
                        _controller.stop();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: const Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isPlaying ? 'Radar Scanning...' : 'Scan Paused',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            Text(
              'Zoom: ${(_zoomLevel * 100).round()}%',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeTab(String mode, String label) {
    final bool active = _radarMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _radarMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF38BDF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: active ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class RadarMapPainter extends CustomPainter {
  final String mode;
  final double animationVal;
  final bool isPlaying;
  final double zoomLevel;

  RadarMapPainter({
    required this.mode,
    required this.animationVal,
    required this.isPlaying,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(zoomLevel);
    canvas.translate(-center.dx, -center.dy);

    // Grid background
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const int gridCount = 6;
    for (int i = 1; i <= gridCount; i++) {
      canvas.drawCircle(center, radius * (i / gridCount), gridPaint);
    }
    
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), gridPaint);

    if (mode == 'rain') {
      final blobPaint1 = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.green.withOpacity(0.4),
            Colors.green.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(center.dx - 40, center.dy + 30), radius: 35));
      canvas.drawCircle(Offset(center.dx - 40, center.dy + 30), 35, blobPaint1);

      final blobPaint2 = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.yellow.withOpacity(0.5),
            Colors.yellow.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(center.dx + 50, center.dy - 20), radius: 45));
      canvas.drawCircle(Offset(center.dx + 50, center.dy - 20), 45, blobPaint2);

      final blobPaint3 = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.redAccent.withOpacity(0.4),
            Colors.redAccent.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(center.dx + 40, center.dy - 25), radius: 20));
      canvas.drawCircle(Offset(center.dx + 40, center.dy - 25), 20, blobPaint3);

      final sweepAngle = animationVal * 2 * pi;
      final sweepPaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.4)
        ..strokeWidth = 2.0;

      final sweepEnd = Offset(
        center.dx + radius * cos(sweepAngle),
        center.dy + radius * sin(sweepAngle),
      );
      canvas.drawLine(center, sweepEnd, sweepPaint);

      final sweepArcPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: sweepAngle - 0.5,
          endAngle: sweepAngle,
          colors: [
            Colors.transparent,
            const Color(0xFF38BDF8).withOpacity(0.15),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        sweepAngle - 0.5,
        0.5,
        true,
        sweepArcPaint,
      );
    } else if (mode == 'temp') {
      final tempPaint1 = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.orangeAccent.withOpacity(0.5),
            Colors.orangeAccent.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(center.dx + 20, center.dy + 10), radius: radius * 0.7));
      canvas.drawCircle(Offset(center.dx + 20, center.dy + 10), radius * 0.7, tempPaint1);

      final tempPaint2 = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.4),
            Colors.blueAccent.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(center.dx - 50, center.dy - 40), radius: radius * 0.5));
      canvas.drawCircle(Offset(center.dx - 50, center.dy - 40), radius * 0.5, tempPaint2);

      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, radius * 0.5, linePaint);
      canvas.drawCircle(center, radius * 0.8, linePaint);
    } else if (mode == 'wind') {
      final windPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < 4; i++) {
        final path = Path();
        final startY = (size.height * 0.2) + (i * size.height * 0.2);
        final offset = animationVal * size.width;
        
        path.moveTo(-50 + offset, startY);
        path.quadraticBezierTo(
          size.width * 0.25 + offset, startY - 30,
          size.width * 0.5 + offset, startY
        );
        path.quadraticBezierTo(
          size.width * 0.75 + offset, startY + 30,
          size.width + 50 + offset, startY
        );
        
        final path2 = Path();
        path2.moveTo(-50 - size.width + offset, startY);
        path2.quadraticBezierTo(
          size.width * 0.25 - size.width + offset, startY - 30,
          size.width * 0.5 - size.width + offset, startY
        );
        path2.quadraticBezierTo(
          size.width * 0.75 - size.width + offset, startY + 30,
          size.width + 50 - size.width + offset, startY
        );

        canvas.drawPath(path, windPaint);
        canvas.drawPath(path2, windPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RadarMapPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.animationVal != animationVal ||
        oldDelegate.isPlaying != isPlaying;
  }
}
