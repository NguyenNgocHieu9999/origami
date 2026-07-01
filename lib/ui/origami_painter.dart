import 'dart:math';
import 'package:flutter/material.dart';

class OrigamiStepDiagram extends StatelessWidget {
  final String modelKey;
  final int stepOrder;
  final Color themeColor;

  const OrigamiStepDiagram({
    super.key,
    required this.modelKey,
    required this.stepOrder,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: OrigamiStepPainter(
          modelKey: modelKey,
          stepOrder: stepOrder,
          themeColor: themeColor,
        ),
      ),
    );
  }
}

class OrigamiStepPainter extends CustomPainter {
  final String modelKey;
  final int stepOrder;
  final Color themeColor;

  OrigamiStepPainter({
    required this.modelKey,
    required this.stepOrder,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = min(w, h) * 0.38;

    final paintPaper = Paint()
      ..color = themeColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final paintPaperBack = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintCrease = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintArrow = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Helper to draw a dashed crease line
    void drawCrease(Offset p1, Offset p2) {
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final len = sqrt(dx * dx + dy * dy);
      final numDashes = (len / 6).floor();
      for (var i = 0; i < numDashes; i++) {
        if (i % 2 == 0) {
          final t1 = i / numDashes;
          final t2 = (i + 1) / numDashes;
          canvas.drawLine(
            Offset(p1.dx + dx * t1, p1.dy + dy * t1),
            Offset(p1.dx + dx * t2, p1.dy + dy * t2),
            paintCrease,
          );
        }
      }
    }

    // Helper to draw an arrow with a curve
    void drawFoldArrow(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);
      // Curve control point
      final mx = (start.dx + end.dx) / 2;
      final my = (start.dy + end.dy) / 2 - 20;
      path.quadraticBezierTo(mx, my, end.dx, end.dy);
      canvas.drawPath(path, paintArrow);

      // Draw arrow head
      final angle = atan2(end.dy - my, end.dx - mx);
      final headLen = 10.0;
      final headAngle = pi / 6;
      final arrowHead = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - headLen * cos(angle - headAngle), end.dy - headLen * sin(angle - headAngle))
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - headLen * cos(angle + headAngle), end.dy - headLen * sin(angle + headAngle));
      canvas.drawPath(arrowHead, paintArrow);
    }

    // Draw grid coordinate helpers relative to center
    Offset offset(double dx, double dy) => Offset(cx + dx * r, cy + dy * r);

    // Let's paint based on modelKey and stepOrder
    switch (modelKey) {
      case 'boat':
        _paintBoat(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'tulip':
        _paintTulip(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'frog':
        _paintFrog(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'box':
        _paintBox(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'dragon':
        _paintDragon(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'shuriken':
        _paintShuriken(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'swan':
        _paintSwan(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'butterfly':
        _paintButterfly(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'dinosaur':
        _paintDinosaur(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'turtle':
        _paintTurtle(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'cactus':
        _paintCactus(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      case 'lion':
        _paintLion(canvas, stepOrder, paintPaper, paintPaperBack, paintLine, drawCrease, drawFoldArrow, offset);
        break;
      default:
        // Generic fallback square
        final path = Path()
          ..moveTo(offset(-1, -1).dx, offset(-1, -1).dy)
          ..lineTo(offset(1, -1).dx, offset(1, -1).dy)
          ..lineTo(offset(1, 1).dx, offset(1, 1).dy)
          ..lineTo(offset(-1, 1).dx, offset(-1, 1).dy)
          ..close();
        canvas.drawPath(path, paintPaper);
        canvas.drawPath(path, paintLine);
    }
  }

  void _paintBoat(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      // Vertical rectangle
      final p = Path()
        ..moveTo(offset(-0.7, -1).dx, offset(-0.7, -1).dy)
        ..lineTo(offset(0.7, -1).dx, offset(0.7, -1).dy)
        ..lineTo(offset(0.7, 1).dx, offset(0.7, 1).dy)
        ..lineTo(offset(-0.7, 1).dx, offset(-0.7, 1).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.7, 0), offset(0.7, 0));
      arrow(offset(0, -0.6), offset(0, 0.4));
    } else if (step == 2) {
      // Horizontal rectangle folded half
      final p = Path()
        ..moveTo(offset(-0.7, 0).dx, offset(-0.7, 0).dy)
        ..lineTo(offset(0.7, 0).dx, offset(0.7, 0).dy)
        ..lineTo(offset(0.7, 1).dx, offset(0.7, 1).dy)
        ..lineTo(offset(-0.7, 1).dx, offset(-0.7, 1).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Creases for triangle top
      crease(offset(-0.7, 0), offset(0, 0.7));
      crease(offset(0.7, 0), offset(0, 0.7));
      arrow(offset(-0.4, 0.2), offset(-0.2, 0.5));
      arrow(offset(0.4, 0.2), offset(0.2, 0.5));
    } else if (step == 3) {
      // House shape
      final p = Path()
        ..moveTo(offset(-0.7, 0.7).dx, offset(-0.7, 0.7).dy)
        ..lineTo(offset(0, 0).dx, offset(0, 0).dy)
        ..lineTo(offset(0.7, 0.7).dx, offset(0.7, 0.7).dy)
        ..lineTo(offset(0.7, 1).dx, offset(0.7, 1).dy)
        ..lineTo(offset(-0.7, 1).dx, offset(-0.7, 1).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.7, 0.7), offset(0.7, 0.7));
      arrow(offset(0, 0.9), offset(0, 0.6));
    } else if (step == 4) {
      // Triangle base
      final p = Path()
        ..moveTo(offset(0, 0).dx, offset(0, 0).dy)
        ..lineTo(offset(0.7, 0.7).dx, offset(0.7, 0.7).dy)
        ..lineTo(offset(-0.7, 0.7).dx, offset(-0.7, 0.7).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Arrow showing opening from bottom
      arrow(offset(0, 0.6), offset(-0.3, 0.4));
      arrow(offset(0, 0.6), offset(0.3, 0.4));
    } else if (step == 5) {
      // Diamond shape
      final p = Path()
        ..moveTo(offset(0, -0.7).dx, offset(0, -0.7).dy)
        ..lineTo(offset(0.7, 0).dx, offset(0.7, 0).dy)
        ..lineTo(offset(0, 0.7).dx, offset(0, 0.7).dy)
        ..lineTo(offset(-0.7, 0).dx, offset(-0.7, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      arrow(offset(-0.5, 0), offset(-0.8, 0));
      arrow(offset(0.5, 0), offset(0.8, 0));
    } else {
      // Boat shape
      final p = Path()
        ..moveTo(offset(-1, 0.2).dx, offset(-1, 0.2).dy)
        ..lineTo(offset(1, 0.2).dx, offset(1, 0.2).dy)
        ..lineTo(offset(0.7, 0.7).dx, offset(0.7, 0.7).dy)
        ..lineTo(offset(-0.7, 0.7).dx, offset(-0.7, 0.7).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Sail
      final sail = Path()
        ..moveTo(offset(0, 0.2).dx, offset(0, 0.2).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..close();
      canvas.drawPath(sail, back);
      canvas.drawPath(sail, border);
    }
  }

  void _paintTulip(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      // Red diamond square rotated 45 degrees
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, 0), offset(0.8, 0));
      arrow(offset(0, 0.5), offset(0, -0.3));
    } else if (step == 2) {
      // Triangle pointing up
      final p = Path()
        ..moveTo(offset(-0.8, 0.4).dx, offset(-0.8, 0.4).dy)
        ..lineTo(offset(0.8, 0.4).dx, offset(0.8, 0.4).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, 0.4), offset(-0.3, -0.3));
      crease(offset(0.8, 0.4), offset(0.3, -0.3));
      arrow(offset(-0.5, 0.2), offset(-0.3, -0.1));
      arrow(offset(0.5, 0.2), offset(0.3, -0.1));
    } else if (step == 3) {
      // Triangle with left flap folded
      final p = Path()
        ..moveTo(offset(-0.8, 0.4).dx, offset(-0.8, 0.4).dy)
        ..lineTo(offset(0.8, 0.4).dx, offset(0.8, 0.4).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Left flap
      final flap = Path()
        ..moveTo(offset(0, 0.4).dx, offset(0, 0.4).dy)
        ..lineTo(offset(-0.5, -0.5).dx, offset(-0.5, -0.5).dy)
        ..lineTo(offset(-0.8, 0.4).dx, offset(-0.8, 0.4).dy)
        ..close();
      canvas.drawPath(flap, paper);
      canvas.drawPath(flap, border);
    } else if (step == 4) {
      // Both petals folded up-outward
      final p = Path()
        ..moveTo(offset(0, 0.4).dx, offset(0, 0.4).dy)
        ..lineTo(offset(-0.5, -0.5).dx, offset(-0.5, -0.5).dy)
        ..lineTo(offset(0, -0.2).dx, offset(0, -0.2).dy)
        ..lineTo(offset(0.5, -0.5).dx, offset(0.5, -0.5).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(0, 0.4), offset(0, -0.2));
      arrow(offset(0, 0.3), offset(0.1, 0.3));
    } else if (step == 5) {
      // Bottom corner folded back
      final p = Path()
        ..moveTo(offset(-0.5, -0.5).dx, offset(-0.5, -0.5).dy)
        ..lineTo(offset(0, -0.2).dx, offset(0, -0.2).dy)
        ..lineTo(offset(0.5, -0.5).dx, offset(0.5, -0.5).dy)
        ..lineTo(offset(0.3, 0.3).dx, offset(0.3, 0.3).dy)
        ..lineTo(offset(-0.3, 0.3).dx, offset(-0.3, 0.3).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else {
      // Finished Tulip with Green Stem
      final greenPaint = Paint()
        ..color = Colors.green.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
      // Draw stem
      canvas.drawLine(offset(0, 0), offset(0, 0.9), greenPaint);
      // Leaf
      final leaf = Path()
        ..moveTo(offset(0, 0.6).dx, offset(0, 0.6).dy)
        ..quadraticBezierTo(offset(0.4, 0.3).dx, offset(0.4, 0.3).dy, offset(0.3, 0.1).dx, offset(0.3, 0.1).dy)
        ..quadraticBezierTo(offset(0.1, 0.4).dx, offset(0.1, 0.4).dy, offset(0, 0.6).dx, offset(0, 0.6).dy);
      canvas.drawPath(leaf, Paint()..color = Colors.green.shade500..style = PaintingStyle.fill);
      canvas.drawPath(leaf, Paint()..color = Colors.green.shade700..style = PaintingStyle.stroke..strokeWidth = 1.5);
      // Flower head
      final head = Path()
        ..moveTo(offset(-0.4, -0.5).dx, offset(-0.4, -0.5).dy)
        ..lineTo(offset(0, -0.2).dx, offset(0, -0.2).dy)
        ..lineTo(offset(0.4, -0.5).dx, offset(0.4, -0.5).dy)
        ..lineTo(offset(0.2, 0.1).dx, offset(0.2, 0.1).dy)
        ..lineTo(offset(-0.2, 0.1).dx, offset(-0.2, 0.1).dy)
        ..close();
      canvas.drawPath(head, paper);
      canvas.drawPath(head, border);
    }
  }

  void _paintFrog(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(-0.8, -0.8).dx, offset(-0.8, -0.8).dy)
        ..lineTo(offset(0.8, -0.8).dx, offset(0.8, -0.8).dy)
        ..lineTo(offset(0.8, 0.8).dx, offset(0.8, 0.8).dy)
        ..lineTo(offset(-0.8, 0.8).dx, offset(-0.8, 0.8).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, 0), offset(0.8, 0));
      arrow(offset(0, -0.4), offset(0, 0.4));
    } else if (step == 2) {
      // Triangle top, flat bottom
      final p = Path()
        ..moveTo(offset(0, -0.6).dx, offset(0, -0.6).dy)
        ..lineTo(offset(0.8, 0.2).dx, offset(0.8, 0.2).dy)
        ..lineTo(offset(-0.8, 0.2).dx, offset(-0.8, 0.2).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      final p2 = Path()
        ..moveTo(offset(-0.8, 0.2).dx, offset(-0.8, 0.2).dy)
        ..lineTo(offset(0.8, 0.2).dx, offset(0.8, 0.2).dy)
        ..lineTo(offset(0.8, 0.8).dx, offset(0.8, 0.8).dy)
        ..lineTo(offset(-0.8, 0.8).dx, offset(-0.8, 0.8).dy)
        ..close();
      canvas.drawPath(p2, paper);
      canvas.drawPath(p2, border);
      arrow(offset(-0.6, 0.2), offset(-0.4, -0.2));
    } else if (step == 3) {
      // Triangle top with two leg flaps pointing up-outward
      final p = Path()
        ..moveTo(offset(0, -0.6).dx, offset(0, -0.6).dy)
        ..lineTo(offset(0.8, 0.2).dx, offset(0.8, 0.2).dy)
        ..lineTo(offset(-0.8, 0.2).dx, offset(-0.8, 0.2).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Legs
      final leg1 = Path()
        ..moveTo(offset(0, 0.2).dx, offset(0, 0.2).dy)
        ..lineTo(offset(-0.4, -0.4).dx, offset(-0.4, -0.4).dy)
        ..lineTo(offset(-0.2, 0.2).dx, offset(-0.2, 0.2).dy)
        ..close();
      final leg2 = Path()
        ..moveTo(offset(0, 0.2).dx, offset(0, 0.2).dy)
        ..lineTo(offset(0.4, -0.4).dx, offset(0.4, -0.4).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..close();
      canvas.drawPath(leg1, paper);
      canvas.drawPath(leg1, border);
      canvas.drawPath(leg2, paper);
      canvas.drawPath(leg2, border);
    } else if (step == 4) {
      // Body narrower
      final p = Path()
        ..moveTo(offset(0, -0.6).dx, offset(0, -0.6).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0.4, 0.8).dx, offset(0.4, 0.8).dy)
        ..lineTo(offset(-0.4, 0.8).dx, offset(-0.4, 0.8).dy)
        ..lineTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      arrow(offset(0, 0.7), offset(0, 0.4));
    } else if (step == 5) {
      // Folded Z shape
      final p = Path()
        ..moveTo(offset(-0.4, -0.2).dx, offset(-0.4, -0.2).dy)
        ..lineTo(offset(0.4, -0.2).dx, offset(0.4, -0.2).dy)
        ..lineTo(offset(0.4, 0.3).dx, offset(0.4, 0.3).dy)
        ..lineTo(offset(-0.4, 0.3).dx, offset(-0.4, 0.3).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.4, 0.1), offset(0.4, 0.1));
    } else {
      // Finished Frog
      final p = Path()
        ..moveTo(offset(-0.3, -0.3).dx, offset(-0.3, -0.3).dy)
        ..lineTo(offset(0.3, -0.3).dx, offset(0.3, -0.3).dy)
        ..lineTo(offset(0.4, 0.4).dx, offset(0.4, 0.4).dy)
        ..lineTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Legs back
      final legB1 = Path()
        ..moveTo(offset(-0.3, 0.3).dx, offset(-0.3, 0.3).dy)
        ..lineTo(offset(-0.7, 0.6).dx, offset(-0.7, 0.6).dy)
        ..lineTo(offset(-0.5, 0.2).dx, offset(-0.5, 0.2).dy)
        ..close();
      final legB2 = Path()
        ..moveTo(offset(0.3, 0.3).dx, offset(0.3, 0.3).dy)
        ..lineTo(offset(0.7, 0.6).dx, offset(0.7, 0.6).dy)
        ..lineTo(offset(0.5, 0.2).dx, offset(0.5, 0.2).dy)
        ..close();
      canvas.drawPath(legB1, paper);
      canvas.drawPath(legB1, border);
      canvas.drawPath(legB2, paper);
      canvas.drawPath(legB2, border);
    }
  }

  void _paintBox(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(-0.8, -0.8).dx, offset(-0.8, -0.8).dy)
        ..lineTo(offset(0.8, -0.8).dx, offset(0.8, -0.8).dy)
        ..lineTo(offset(0.8, 0.8).dx, offset(0.8, 0.8).dy)
        ..lineTo(offset(-0.8, 0.8).dx, offset(-0.8, 0.8).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, 0), offset(0.8, 0));
      crease(offset(0, -0.8), offset(0, 0.8));
    } else if (step == 2) {
      // Blintz folding
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      arrow(offset(-0.4, -0.4), offset(-0.1, -0.1));
    } else if (step == 3) {
      // 3x3 grid creases
      final p = Path()
        ..moveTo(offset(-0.6, -0.6).dx, offset(-0.6, -0.6).dy)
        ..lineTo(offset(0.6, -0.6).dx, offset(0.6, -0.6).dy)
        ..lineTo(offset(0.6, 0.6).dx, offset(0.6, 0.6).dy)
        ..lineTo(offset(-0.6, 0.6).dx, offset(-0.6, 0.6).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.6, -0.2), offset(0.6, -0.2));
      crease(offset(-0.6, 0.2), offset(0.6, 0.2));
      crease(offset(-0.2, -0.6), offset(-0.2, 0.6));
      crease(offset(0.2, -0.6), offset(0.2, 0.6));
    } else if (step == 4) {
      // Extended corners
      final p = Path()
        ..moveTo(offset(-0.6, -0.6).dx, offset(-0.6, -0.6).dy)
        ..lineTo(offset(0.6, -0.6).dx, offset(0.6, -0.6).dy)
        ..lineTo(offset(0.6, 0.6).dx, offset(0.6, 0.6).dy)
        ..lineTo(offset(-0.6, 0.6).dx, offset(-0.6, 0.6).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      final ext1 = Path()
        ..moveTo(offset(-0.6, -0.6).dx, offset(-0.6, -0.6).dy)
        ..lineTo(offset(0, -1).dx, offset(0, -1).dy)
        ..lineTo(offset(0.6, -0.6).dx, offset(0.6, -0.6).dy)
        ..close();
      final ext2 = Path()
        ..moveTo(offset(-0.6, 0.6).dx, offset(-0.6, 0.6).dy)
        ..lineTo(offset(0, 1).dx, offset(0, 1).dy)
        ..lineTo(offset(0.6, 0.6).dx, offset(0.6, 0.6).dy)
        ..close();
      canvas.drawPath(ext1, paper);
      canvas.drawPath(ext1, border);
      canvas.drawPath(ext2, paper);
      canvas.drawPath(ext2, border);
    } else if (step == 5) {
      // 3D Box Open - Isometric
      final face1 = Path()
        ..moveTo(offset(-0.5, 0).dx, offset(-0.5, 0).dy)
        ..lineTo(offset(0, 0.3).dx, offset(0, 0.3).dy)
        ..lineTo(offset(0, 0.7).dx, offset(0, 0.7).dy)
        ..lineTo(offset(-0.5, 0.4).dx, offset(-0.5, 0.4).dy)
        ..close();
      final face2 = Path()
        ..moveTo(offset(0, 0.3).dx, offset(0, 0.3).dy)
        ..lineTo(offset(0.5, 0).dx, offset(0.5, 0).dy)
        ..lineTo(offset(0.5, 0.4).dx, offset(0.5, 0.4).dy)
        ..lineTo(offset(0, 0.7).dx, offset(0, 0.7).dy)
        ..close();
      canvas.drawPath(face1, paper);
      canvas.drawPath(face1, border);
      canvas.drawPath(face2, paper);
      canvas.drawPath(face2, border);
    } else {
      // Finished 3D Box
      final box = Path()
        ..moveTo(offset(-0.5, -0.2).dx, offset(-0.5, -0.2).dy)
        ..lineTo(offset(0.5, -0.2).dx, offset(0.5, -0.2).dy)
        ..lineTo(offset(0.5, 0.4).dx, offset(0.5, 0.4).dy)
        ..lineTo(offset(-0.5, 0.4).dx, offset(-0.5, 0.4).dy)
        ..close();
      canvas.drawPath(box, paper);
      canvas.drawPath(box, border);
    }
  }

  void _paintDragon(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(-0.8, -0.8).dx, offset(-0.8, -0.8).dy)
        ..lineTo(offset(0.8, -0.8).dx, offset(0.8, -0.8).dy)
        ..lineTo(offset(0.8, 0.8).dx, offset(0.8, 0.8).dy)
        ..lineTo(offset(-0.8, 0.8).dx, offset(-0.8, 0.8).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, -0.8), offset(0.8, 0.8));
    } else if (step == 2) {
      final p = Path()
        ..moveTo(offset(0, -0.5).dx, offset(0, -0.5).dy)
        ..lineTo(offset(0.5, 0).dx, offset(0.5, 0).dy)
        ..lineTo(offset(0, 0.5).dx, offset(0, 0.5).dy)
        ..lineTo(offset(-0.5, 0).dx, offset(-0.5, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 3) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.3, 0).dx, offset(0.3, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.3, 0).dx, offset(-0.3, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 4) {
      final p = Path()
        ..moveTo(offset(0, -0.6).dx, offset(0, -0.6).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0, 0.4).dx, offset(0, 0.4).dy)
        ..lineTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 5) {
      final p = Path()
        ..moveTo(offset(-0.5, -0.2).dx, offset(-0.5, -0.2).dy)
        ..lineTo(offset(0, -0.5).dx, offset(0, -0.5).dy)
        ..lineTo(offset(0.5, 0.2).dx, offset(0.5, 0.2).dy)
        ..lineTo(offset(0, 0.5).dx, offset(0, 0.5).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 6) {
      final p = Path()
        ..moveTo(offset(-0.5, -0.2).dx, offset(-0.5, -0.2).dy)
        ..lineTo(offset(0.4, 0).dx, offset(0.4, 0).dy)
        ..lineTo(offset(0.1, 0.4).dx, offset(0.1, 0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 7) {
      final p = Path()
        ..moveTo(offset(-0.4, -0.2).dx, offset(-0.4, -0.2).dy)
        ..lineTo(offset(0.4, -0.2).dx, offset(0.4, -0.2).dy)
        ..lineTo(offset(0.2, 0.3).dx, offset(0.2, 0.3).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else {
      final dragon = Path()
        ..moveTo(offset(-0.7, -0.1).dx, offset(-0.7, -0.1).dy)
        ..lineTo(offset(-0.5, -0.3).dx, offset(-0.5, -0.3).dy)
        ..lineTo(offset(-0.2, 0.1).dx, offset(-0.2, 0.1).dy)
        ..lineTo(offset(0.4, 0.1).dx, offset(0.4, 0.1).dy)
        ..lineTo(offset(0.6, 0.5).dx, offset(0.6, 0.5).dy)
        ..lineTo(offset(0.4, 0.3).dx, offset(0.4, 0.3).dy)
        ..close();
      canvas.drawPath(dragon, paper);
      canvas.drawPath(dragon, border);
    }
  }

  void _paintShuriken(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p1 = Path()
        ..moveTo(offset(-0.6, -0.8).dx, offset(-0.6, -0.8).dy)
        ..lineTo(offset(-0.1, -0.8).dx, offset(-0.1, -0.8).dy)
        ..lineTo(offset(-0.1, 0.8).dx, offset(-0.1, 0.8).dy)
        ..lineTo(offset(-0.6, 0.8).dx, offset(-0.6, 0.8).dy)
        ..close();
      final p2 = Path()
        ..moveTo(offset(0.1, -0.8).dx, offset(0.1, -0.8).dy)
        ..lineTo(offset(0.6, -0.8).dx, offset(0.6, -0.8).dy)
        ..lineTo(offset(0.6, 0.8).dx, offset(0.6, 0.8).dy)
        ..lineTo(offset(0.1, 0.8).dx, offset(0.1, 0.8).dy)
        ..close();
      canvas.drawPath(p1, paper);
      canvas.drawPath(p1, border);
      canvas.drawPath(p2, back);
      canvas.drawPath(p2, border);
    } else if (step == 2) {
      final p1 = Path()
        ..moveTo(offset(-0.4, -0.8).dx, offset(-0.4, -0.8).dy)
        ..lineTo(offset(-0.1, -0.8).dx, offset(-0.1, -0.8).dy)
        ..lineTo(offset(-0.1, 0.8).dx, offset(-0.1, 0.8).dy)
        ..lineTo(offset(-0.4, 0.8).dx, offset(-0.4, 0.8).dy)
        ..close();
      final p2 = Path()
        ..moveTo(offset(0.1, -0.8).dx, offset(0.1, -0.8).dy)
        ..lineTo(offset(0.4, -0.8).dx, offset(0.4, -0.8).dy)
        ..lineTo(offset(0.4, 0.8).dx, offset(0.4, 0.8).dy)
        ..lineTo(offset(0.1, 0.8).dx, offset(0.1, 0.8).dy)
        ..close();
      canvas.drawPath(p1, paper);
      canvas.drawPath(p1, border);
      canvas.drawPath(p2, back);
      canvas.drawPath(p2, border);
    } else if (step == 3) {
      final p1 = Path()
        ..moveTo(offset(-0.4, -0.4).dx, offset(-0.4, -0.4).dy)
        ..lineTo(offset(-0.1, -0.8).dx, offset(-0.1, -0.8).dy)
        ..lineTo(offset(-0.1, 0.4).dx, offset(-0.1, 0.4).dy)
        ..lineTo(offset(-0.4, 0.8).dx, offset(-0.4, 0.8).dy)
        ..close();
      canvas.drawPath(p1, paper);
      canvas.drawPath(p1, border);
    } else if (step == 4) {
      final p1 = Path()
        ..moveTo(offset(-0.4, -0.4).dx, offset(-0.4, -0.4).dy)
        ..lineTo(offset(-0.1, -0.4).dx, offset(-0.1, -0.4).dy)
        ..lineTo(offset(-0.1, 0.4).dx, offset(-0.1, 0.4).dy)
        ..lineTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..close();
      canvas.drawPath(p1, paper);
      canvas.drawPath(p1, border);
    } else if (step == 5) {
      final p1 = Path()
        ..moveTo(offset(-0.4, -0.4).dx, offset(-0.4, -0.4).dy)
        ..lineTo(offset(0.4, -0.4).dx, offset(0.4, -0.4).dy)
        ..lineTo(offset(0.4, 0.4).dx, offset(0.4, 0.4).dy)
        ..lineTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..close();
      canvas.drawPath(p1, paper);
      canvas.drawPath(p1, border);
    } else {
      final star = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.2, -0.2).dx, offset(0.2, -0.2).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.2, 0.2).dx, offset(-0.2, 0.2).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..lineTo(offset(-0.2, -0.2).dx, offset(-0.2, -0.2).dy)
        ..close();
      canvas.drawPath(star, paper);
      canvas.drawPath(star, border);
    }
  }

  void _paintSwan(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(0, -0.8), offset(0, 0.8));
    } else if (step == 2) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.4, 0).dx, offset(0.4, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.4, 0).dx, offset(-0.4, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 3) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.25, 0.1).dx, offset(0.25, 0.1).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.25, 0.1).dx, offset(-0.25, 0.1).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 4) {
      final p = Path()
        ..moveTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..lineTo(offset(0, -0.1).dx, offset(0, -0.1).dy)
        ..lineTo(offset(0.4, 0.4).dx, offset(0.4, 0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 5) {
      final p = Path()
        ..moveTo(offset(-0.3, 0.3).dx, offset(-0.3, 0.3).dy)
        ..lineTo(offset(-0.1, -0.3).dx, offset(-0.1, -0.3).dy)
        ..lineTo(offset(0.1, -0.3).dx, offset(0.1, -0.3).dy)
        ..lineTo(offset(0.3, 0.3).dx, offset(0.3, 0.3).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else {
      final swan = Path()
        ..moveTo(offset(-0.6, 0.3).dx, offset(-0.6, 0.3).dy)
        ..quadraticBezierTo(offset(-0.2, 0.3).dx, offset(-0.2, 0.3).dy, offset(0.2, 0.3).dx, offset(0.2, 0.3).dy)
        ..lineTo(offset(0.4, -0.2).dx, offset(0.4, -0.2).dy)
        ..lineTo(offset(0.1, -0.4).dx, offset(0.1, -0.4).dy)
        ..lineTo(offset(0.1, 0.1).dx, offset(0.1, 0.1).dy)
        ..close();
      canvas.drawPath(swan, paper);
      canvas.drawPath(swan, border);
    }
  }

  void _paintButterfly(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(-0.8, -0.8).dx, offset(-0.8, -0.8).dy)
        ..lineTo(offset(0.8, -0.8).dx, offset(0.8, -0.8).dy)
        ..lineTo(offset(0.8, 0.8).dx, offset(0.8, 0.8).dy)
        ..lineTo(offset(-0.8, 0.8).dx, offset(-0.8, 0.8).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, -0.8), offset(0.8, 0.8));
      crease(offset(0.8, -0.8), offset(-0.8, 0.8));
    } else if (step == 2) {
      final p = Path()
        ..moveTo(offset(-0.8, 0.4).dx, offset(-0.8, 0.4).dy)
        ..lineTo(offset(0.8, 0.4).dx, offset(0.8, 0.4).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 3) {
      final p = Path()
        ..moveTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..lineTo(offset(0.4, 0.4).dx, offset(0.4, 0.4).dy)
        ..lineTo(offset(0, 0).dx, offset(0, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 4) {
      final p = Path()
        ..moveTo(offset(-0.5, 0).dx, offset(-0.5, 0).dy)
        ..lineTo(offset(0.5, 0).dx, offset(0.5, 0).dy)
        ..lineTo(offset(0, -0.6).dx, offset(0, -0.6).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 5) {
      final p = Path()
        ..moveTo(offset(-0.5, 0).dx, offset(-0.5, 0).dy)
        ..lineTo(offset(0.5, 0).dx, offset(0.5, 0).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else {
      final b = Path()
        ..moveTo(offset(0, 0.2).dx, offset(0, 0.2).dy)
        ..quadraticBezierTo(offset(-0.6, -0.6).dx, offset(-0.6, -0.6).dy, offset(-0.6, -0.3).dx, offset(-0.6, -0.3).dy)
        ..quadraticBezierTo(offset(-0.3, 0.3).dx, offset(-0.3, 0.3).dy, offset(0, 0.2).dx, offset(0, 0.2).dy)
        ..quadraticBezierTo(offset(0.3, 0.3).dx, offset(0.3, 0.3).dy, offset(0.6, -0.3).dx, offset(0.6, -0.3).dy)
        ..quadraticBezierTo(offset(0.6, -0.6).dx, offset(0.6, -0.6).dy, offset(0, 0.2).dx, offset(0, 0.2).dy)
        ..close();
      canvas.drawPath(b, paper);
      canvas.drawPath(b, border);
    }
  }

  void _paintDinosaur(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.8, 0), offset(0.8, 0));
    } else if (step == 2) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.4, 0).dx, offset(0.4, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.4, 0).dx, offset(-0.4, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 3) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.2, 0).dx, offset(0.2, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.2, 0).dx, offset(-0.2, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 4) {
      final p = Path()
        ..moveTo(offset(-0.6, 0.2).dx, offset(-0.6, 0.2).dy)
        ..lineTo(offset(0.6, 0.2).dx, offset(0.6, 0.2).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 5) {
      final p = Path()
        ..moveTo(offset(-0.6, 0.2).dx, offset(-0.6, 0.2).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..lineTo(offset(0.4, -0.3).dx, offset(0.4, -0.3).dy)
        ..lineTo(offset(0, -0.4).dx, offset(0, -0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 6) {
      final p = Path()
        ..moveTo(offset(-0.6, 0.5).dx, offset(-0.6, 0.5).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..lineTo(offset(0.4, -0.3).dx, offset(0.4, -0.3).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step == 7) {
      final p = Path()
        ..moveTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..lineTo(offset(0.3, 0.5).dx, offset(0.3, 0.5).dy)
        ..lineTo(offset(-0.1, 0.6).dx, offset(-0.1, 0.6).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else {
      final tRex = Path()
        ..moveTo(offset(-0.6, 0.6).dx, offset(-0.6, 0.6).dy) // tail
        ..quadraticBezierTo(offset(-0.2, 0.2).dx, offset(-0.2, 0.2).dy, offset(0.1, 0.1).dx, offset(0.1, 0.1).dy) // back
        ..lineTo(offset(0.3, -0.4).dx, offset(0.3, -0.4).dy) // head
        ..lineTo(offset(0.1, -0.3).dx, offset(0.1, -0.3).dy) // snout
        ..lineTo(offset(0, 0.2).dx, offset(0, 0.2).dy) // chest
        ..lineTo(offset(-0.2, 0.7).dx, offset(-0.2, 0.7).dy) // legs
        ..lineTo(offset(-0.4, 0.7).dx, offset(-0.4, 0.7).dy) // legs bottom
        ..close();
      canvas.drawPath(tRex, paper);
      canvas.drawPath(tRex, border);
    }
  }

  void _paintTurtle(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step <= 2) {
      // Diamond base
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      if (step == 1) {
        crease(offset(0, -0.8), offset(0, 0.8));
        arrow(offset(-0.5, 0), offset(0.5, 0));
      } else {
        crease(offset(-0.8, 0), offset(0.8, 0));
        arrow(offset(0, -0.5), offset(0, 0.5));
      }
    } else if (step <= 6) {
      // Half-folded square shapes
      final p = Path()
        ..moveTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..lineTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Triangle opened
      final tri = Path()
        ..moveTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..lineTo(offset(-0.4, -0.4).dx, offset(-0.4, -0.4).dy)
        ..lineTo(offset(0, 0).dx, offset(0, 0).dy)
        ..close();
      canvas.drawPath(tri, back);
      canvas.drawPath(tri, border);
      if (step == 3 || step == 4) {
        arrow(offset(-0.6, -0.2), offset(-0.2, -0.2));
      }
    } else if (step <= 9) {
      // Squashed kite forms
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.5, 0.1).dx, offset(0.5, 0.1).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.5, 0.1).dx, offset(-0.5, 0.1).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.5, 0.1), offset(0, 0.4));
      crease(offset(0.5, 0.1), offset(0, 0.4));
    } else if (step == 10) {
      // Cut line in the middle
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0, 0.7).dx, offset(0, 0.7).dy)
        ..lineTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Show cut line down the center of top flap
      final cutLine = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawLine(offset(0, -0.4), offset(0, 0.1), cutLine);
    } else if (step <= 13) {
      // Flippers folded out
      final p = Path()
        ..moveTo(offset(0, -0.6).dx, offset(0, -0.6).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0, 0.7).dx, offset(0, 0.7).dy)
        ..lineTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Flippers
      final f1 = Path()
        ..moveTo(offset(0, -0.2).dx, offset(0, -0.2).dy)
        ..lineTo(offset(-0.6, -0.4).dx, offset(-0.6, -0.4).dy)
        ..lineTo(offset(-0.2, 0.1).dx, offset(-0.2, 0.1).dy)
        ..close();
      final f2 = Path()
        ..moveTo(offset(0, -0.2).dx, offset(0, -0.2).dy)
        ..lineTo(offset(0.6, -0.4).dx, offset(0.6, -0.4).dy)
        ..lineTo(offset(0.2, 0.1).dx, offset(0.2, 0.1).dy)
        ..close();
      canvas.drawPath(f1, paper);
      canvas.drawPath(f1, border);
      canvas.drawPath(f2, paper);
      canvas.drawPath(f2, border);
    } else if (step <= 15) {
      // Back legs added
      final p = Path()
        ..moveTo(offset(-0.3, -0.4).dx, offset(-0.3, -0.4).dy)
        ..lineTo(offset(0.3, -0.4).dx, offset(0.3, -0.4).dy)
        ..lineTo(offset(0.3, 0.5).dx, offset(0.3, 0.5).dy)
        ..lineTo(offset(-0.3, 0.5).dx, offset(-0.3, 0.5).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Back legs
      final l1 = Path()
        ..moveTo(offset(-0.2, 0.4).dx, offset(-0.2, 0.4).dy)
        ..lineTo(offset(-0.5, 0.7).dx, offset(-0.5, 0.7).dy)
        ..lineTo(offset(-0.1, 0.5).dx, offset(-0.1, 0.5).dy)
        ..close();
      final l2 = Path()
        ..moveTo(offset(0.2, 0.4).dx, offset(0.2, 0.4).dy)
        ..lineTo(offset(0.5, 0.7).dx, offset(0.5, 0.7).dy)
        ..lineTo(offset(0.1, 0.5).dx, offset(0.1, 0.5).dy)
        ..close();
      canvas.drawPath(l1, paper);
      canvas.drawPath(l1, border);
      canvas.drawPath(l2, paper);
      canvas.drawPath(l2, border);
    } else {
      // Finished green sea turtle (Octagonal shell + flippers)
      final shell = Path()
        ..moveTo(offset(-0.4, -0.3).dx, offset(-0.4, -0.3).dy)
        ..lineTo(offset(0.4, -0.3).dx, offset(0.4, -0.3).dy)
        ..lineTo(offset(0.6, 0).dx, offset(0.6, 0).dy)
        ..lineTo(offset(0.4, 0.4).dx, offset(0.4, 0.4).dy)
        ..lineTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..lineTo(offset(-0.6, 0).dx, offset(-0.6, 0).dy)
        ..close();
      // Flippers
      final f1 = Path()
        ..moveTo(offset(-0.3, -0.2).dx, offset(-0.3, -0.2).dy)
        ..lineTo(offset(-0.8, -0.5).dx, offset(-0.8, -0.5).dy)
        ..lineTo(offset(-0.4, 0).dx, offset(-0.4, 0).dy)
        ..close();
      final f2 = Path()
        ..moveTo(offset(0.3, -0.2).dx, offset(0.3, -0.2).dy)
        ..lineTo(offset(0.8, -0.5).dx, offset(0.8, -0.5).dy)
        ..lineTo(offset(0.4, 0).dx, offset(0.4, 0).dy)
        ..close();
      final l1 = Path()
        ..moveTo(offset(-0.3, 0.3).dx, offset(-0.3, 0.3).dy)
        ..lineTo(offset(-0.6, 0.6).dx, offset(-0.6, 0.6).dy)
        ..lineTo(offset(-0.2, 0.4).dx, offset(-0.2, 0.4).dy)
        ..close();
      final l2 = Path()
        ..moveTo(offset(0.3, 0.3).dx, offset(0.3, 0.3).dy)
        ..lineTo(offset(0.6, 0.6).dx, offset(0.6, 0.6).dy)
        ..lineTo(offset(0.2, 0.4).dx, offset(0.2, 0.4).dy)
        ..close();
      canvas.drawPath(f1, paper);
      canvas.drawPath(f1, border);
      canvas.drawPath(f2, paper);
      canvas.drawPath(f2, border);
      canvas.drawPath(l1, paper);
      canvas.drawPath(l1, border);
      canvas.drawPath(l2, paper);
      canvas.drawPath(l2, border);
      canvas.drawPath(shell, paper);
      canvas.drawPath(shell, border);
    }
  }

  void _paintCactus(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    final potColor = Paint()
      ..color = Colors.orange.shade400
      ..style = PaintingStyle.fill;

    if (step == 1) {
      final p = Path()
        ..moveTo(offset(-0.8, -0.8).dx, offset(-0.8, -0.8).dy)
        ..lineTo(offset(0.8, -0.8).dx, offset(0.8, -0.8).dy)
        ..lineTo(offset(0.8, 0.8).dx, offset(0.8, 0.8).dy)
        ..lineTo(offset(-0.8, 0.8).dx, offset(-0.8, 0.8).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(0, -0.8), offset(0, 0.8));
    } else if (step == 2) {
      // Kite shape
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.6, 0).dx, offset(0.6, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.6, 0).dx, offset(-0.6, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(-0.6, 0), offset(0, 0.8));
      crease(offset(0.6, 0), offset(0, 0.8));
    } else if (step <= 4) {
      // Bottom corner folded
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.6, 0).dx, offset(0.6, 0).dy)
        ..lineTo(offset(0.3, 0.4).dx, offset(0.3, 0.4).dy)
        ..lineTo(offset(-0.3, 0.4).dx, offset(-0.3, 0.4).dy)
        ..lineTo(offset(-0.6, 0).dx, offset(-0.6, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step <= 7) {
      // Left and right branches
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.5, 0.1).dx, offset(0.5, 0.1).dy)
        ..lineTo(offset(0.3, 0.5).dx, offset(0.3, 0.5).dy)
        ..lineTo(offset(-0.3, 0.5).dx, offset(-0.3, 0.5).dy)
        ..lineTo(offset(-0.5, 0.1).dx, offset(-0.5, 0.1).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      // Branch left
      final bl = Path()
        ..moveTo(offset(-0.3, 0).dx, offset(-0.3, 0).dy)
        ..lineTo(offset(-0.7, -0.3).dx, offset(-0.7, -0.3).dy)
        ..lineTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..close();
      // Branch right
      final br = Path()
        ..moveTo(offset(0.3, 0.1).dx, offset(0.3, 0.1).dy)
        ..lineTo(offset(0.6, -0.2).dx, offset(0.6, -0.2).dy)
        ..lineTo(offset(0.4, 0.3).dx, offset(0.4, 0.3).dy)
        ..close();
      canvas.drawPath(bl, paper);
      canvas.drawPath(bl, border);
      canvas.drawPath(br, paper);
      canvas.drawPath(br, border);
    } else if (step <= 11) {
      // Pleated neck and pot shape
      final stem = Path()
        ..moveTo(offset(-0.2, 0.2).dx, offset(-0.2, 0.2).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..lineTo(offset(0.2, -0.6).dx, offset(0.2, -0.6).dy)
        ..lineTo(offset(-0.2, -0.6).dx, offset(-0.2, -0.6).dy)
        ..close();
      final pot = Path()
        ..moveTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0.3, 0.8).dx, offset(0.3, 0.8).dy)
        ..lineTo(offset(-0.3, 0.8).dx, offset(-0.3, 0.8).dy)
        ..close();
      canvas.drawPath(stem, paper);
      canvas.drawPath(stem, border);
      canvas.drawPath(pot, potColor);
      canvas.drawPath(pot, border);
    } else {
      // Completed cactus in a pot
      final stem = Path()
        ..moveTo(offset(-0.2, 0.2).dx, offset(-0.2, 0.2).dy)
        ..lineTo(offset(0.2, 0.2).dx, offset(0.2, 0.2).dy)
        ..lineTo(offset(0.2, -0.7).dx, offset(0.2, -0.7).dy)
        ..lineTo(offset(-0.2, -0.7).dx, offset(-0.2, -0.7).dy)
        ..close();
      // Side branches
      final bl = Path()
        ..moveTo(offset(-0.2, -0.1).dx, offset(-0.2, -0.1).dy)
        ..lineTo(offset(-0.5, -0.1).dx, offset(-0.5, -0.1).dy)
        ..lineTo(offset(-0.5, -0.4).dx, offset(-0.5, -0.4).dy)
        ..lineTo(offset(-0.2, -0.3).dx, offset(-0.2, -0.3).dy)
        ..close();
      final br = Path()
        ..moveTo(offset(0.2, -0.3).dx, offset(0.2, -0.3).dy)
        ..lineTo(offset(0.4, -0.3).dx, offset(0.4, -0.3).dy)
        ..lineTo(offset(0.4, -0.5).dx, offset(0.4, -0.5).dy)
        ..lineTo(offset(0.2, -0.4).dx, offset(0.2, -0.4).dy)
        ..close();
      final pot = Path()
        ..moveTo(offset(-0.4, 0.2).dx, offset(-0.4, 0.2).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0.3, 0.8).dx, offset(0.3, 0.8).dy)
        ..lineTo(offset(-0.3, 0.8).dx, offset(-0.3, 0.8).dy)
        ..close();
      canvas.drawPath(stem, paper);
      canvas.drawPath(stem, border);
      canvas.drawPath(bl, paper);
      canvas.drawPath(bl, border);
      canvas.drawPath(br, paper);
      canvas.drawPath(br, border);
      canvas.drawPath(pot, potColor);
      canvas.drawPath(pot, border);
    }
  }

  void _paintLion(Canvas canvas, int step, Paint paper, Paint back, Paint border, Function crease, Function arrow, Function offset) {
    if (step == 1) {
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0, 0.8).dx, offset(0, 0.8).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
      crease(offset(0, -0.8), offset(0, 0.8));
    } else if (step == 2) {
      // Kite shape
      final p = Path()
        ..moveTo(offset(0, -0.8).dx, offset(0, -0.8).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(0.4, 0.4).dx, offset(0.4, 0.4).dy)
        ..lineTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..lineTo(offset(-0.8, 0).dx, offset(-0.8, 0).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step <= 4) {
      // Flaps folded back
      final p = Path()
        ..moveTo(offset(-0.4, -0.4).dx, offset(-0.4, -0.4).dy)
        ..lineTo(offset(0.8, 0).dx, offset(0.8, 0).dy)
        ..lineTo(offset(-0.4, 0.4).dx, offset(-0.4, 0.4).dy)
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step <= 6) {
      // Raised neck profile
      final p = Path()
        ..moveTo(offset(-0.5, 0.1).dx, offset(-0.5, 0.1).dy) // head
        ..lineTo(offset(-0.2, -0.5).dx, offset(-0.2, -0.5).dy) // mane top
        ..lineTo(offset(0.6, 0.2).dx, offset(0.6, 0.2).dy) // back
        ..lineTo(offset(0.2, 0.5).dx, offset(0.2, 0.5).dy) // belly
        ..close();
      canvas.drawPath(p, paper);
      canvas.drawPath(p, border);
    } else if (step <= 9) {
      // Broad mane
      final body = Path()
        ..moveTo(offset(-0.2, 0).dx, offset(-0.2, 0).dy)
        ..lineTo(offset(0.6, 0.2).dx, offset(0.6, 0.2).dy)
        ..lineTo(offset(0.3, 0.5).dx, offset(0.3, 0.5).dy)
        ..close();
      final mane = Path()
        ..moveTo(offset(-0.5, 0.1).dx, offset(-0.5, 0.1).dy)
        ..lineTo(offset(-0.2, -0.6).dx, offset(-0.2, -0.6).dy)
        ..lineTo(offset(0.1, -0.3).dx, offset(0.1, -0.3).dy)
        ..lineTo(offset(-0.1, 0.3).dx, offset(-0.1, 0.3).dy)
        ..close();
      canvas.drawPath(body, paper);
      canvas.drawPath(body, border);
      canvas.drawPath(mane, paper);
      canvas.drawPath(mane, border);
    } else if (step <= 13) {
      // Standing legs and tail
      final body = Path()
        ..moveTo(offset(-0.2, 0).dx, offset(-0.2, 0).dy)
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy)
        ..lineTo(offset(0.3, 0.7).dx, offset(0.3, 0.7).dy)
        ..lineTo(offset(0.2, 0.5).dx, offset(0.2, 0.5).dy)
        ..lineTo(offset(-0.1, 0.6).dx, offset(-0.1, 0.6).dy)
        ..close();
      final mane = Path()
        ..moveTo(offset(-0.5, 0.1).dx, offset(-0.5, 0.1).dy)
        ..lineTo(offset(-0.2, -0.6).dx, offset(-0.2, -0.6).dy)
        ..lineTo(offset(0.1, -0.3).dx, offset(0.1, -0.3).dy)
        ..lineTo(offset(-0.1, 0.3).dx, offset(-0.1, 0.3).dy)
        ..close();
      canvas.drawPath(body, paper);
      canvas.drawPath(body, border);
      canvas.drawPath(mane, paper);
      canvas.drawPath(mane, border);
    } else {
      // Completed lion with facial features
      final body = Path()
        ..moveTo(offset(-0.2, 0).dx, offset(-0.2, 0).dy) // neck base
        ..lineTo(offset(0.4, 0.2).dx, offset(0.4, 0.2).dy) // back
        ..lineTo(offset(0.4, 0.7).dx, offset(0.4, 0.7).dy) // back leg
        ..lineTo(offset(0.2, 0.7).dx, offset(0.2, 0.7).dy)
        ..lineTo(offset(0.1, 0.4).dx, offset(0.1, 0.4).dy) // belly
        ..lineTo(offset(-0.1, 0.7).dx, offset(-0.1, 0.7).dy) // front leg
        ..lineTo(offset(-0.2, 0.7).dx, offset(-0.2, 0.7).dy)
        ..close();
      final mane = Path()
        ..moveTo(offset(-0.5, -0.2).dx, offset(-0.5, -0.2).dy)
        ..lineTo(offset(-0.2, -0.6).dx, offset(-0.2, -0.6).dy)
        ..lineTo(offset(0.1, -0.4).dx, offset(0.1, -0.4).dy)
        ..lineTo(offset(0.1, 0.1).dx, offset(0.1, 0.1).dy)
        ..lineTo(offset(-0.2, 0.3).dx, offset(-0.2, 0.3).dy)
        ..close();
      canvas.drawPath(body, paper);
      canvas.drawPath(body, border);
      canvas.drawPath(mane, paper);
      canvas.drawPath(mane, border);

      // Draw eyes & whiskers
      final paintFeatures = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset(-0.2, -0.25), 3, paintFeatures); // eye
      final paintWhisker = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(offset(-0.3, -0.15), offset(-0.45, -0.12), paintWhisker);
      canvas.drawLine(offset(-0.3, -0.15), offset(-0.45, -0.18), paintWhisker);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
