import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Custom SVG-style icons matching web app's iOS design
/// Thin strokes (1.5-2px), rounded caps, elegant proportions
class AppIcons {
  AppIcons._();

  static Widget clock({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ClockPainter(color: color ?? AppColors.textPrimary),
    );
  }

  static Widget checkCircle({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckCirclePainter(color: color ?? AppColors.textPrimary),
    );
  }

  static Widget calendar({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CalendarPainter(color: color ?? AppColors.textPrimary),
    );
  }

  static Widget plusCircle({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PlusCirclePainter(color: color ?? AppColors.textPrimary),
    );
  }

  static Widget home({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HomePainter(color: color ?? AppColors.textPrimary),
    );
  }

  static Widget trendUp({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrendUpPainter(color: color ?? AppColors.productive),
    );
  }

  static Widget trendDown({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrendDownPainter(color: color ?? AppColors.accent),
    );
  }

  static Widget chevronLeft({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChevronLeftPainter(color: color ?? AppColors.textSecondary),
    );
  }

  static Widget chevronRight({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChevronRightPainter(color: color ?? AppColors.textSecondary),
    );
  }

  static Widget check({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckPainter(color: color ?? Colors.white),
    );
  }

  static Widget x({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _XPainter(color: color ?? AppColors.textMuted),
    );
  }

  static Widget dollar({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DollarPainter(color: color ?? AppColors.accent),
    );
  }

  static Widget book({
    double size = 24,
    Color? color,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BookPainter(color: color ?? AppColors.productive),
    );
  }
}

// ============ PAINTERS ============

class _ClockPainter extends CustomPainter {
  final Color color;
  _ClockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.375;

    // Circle
    canvas.drawCircle(center, radius, paint);

    // Clock hands
    final handPath = Path();
    handPath.moveTo(center.dx, center.dy);
    handPath.lineTo(center.dx, center.dy - radius * 0.5);
    handPath.moveTo(center.dx, center.dy);
    handPath.lineTo(center.dx + radius * 0.35, center.dy + radius * 0.2);
    
    canvas.drawPath(handPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckCirclePainter extends CustomPainter {
  final Color color;
  _CheckCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.375;

    canvas.drawCircle(center, radius, paint);

    final checkPath = Path();
    checkPath.moveTo(size.width * 0.35, size.height * 0.52);
    checkPath.lineTo(size.width * 0.44, size.height * 0.6);
    checkPath.lineTo(size.width * 0.65, size.height * 0.4);
    
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CalendarPainter extends CustomPainter {
  final Color color;
  _CalendarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.125, size.height * 0.21, size.width * 0.75, size.height * 0.67),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);

    // Top line
    canvas.drawLine(
      Offset(size.width * 0.125, size.height * 0.42),
      Offset(size.width * 0.875, size.height * 0.42),
      paint,
    );

    // Top pins
    canvas.drawLine(
      Offset(size.width * 0.33, size.height * 0.125),
      Offset(size.width * 0.33, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.67, size.height * 0.125),
      Offset(size.width * 0.67, size.height * 0.25),
      paint,
    );

    // Dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.625), size.width * 0.0625, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlusCirclePainter extends CustomPainter {
  final Color color;
  _PlusCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.375;

    canvas.drawCircle(center, radius, paint);

    // Plus
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.4),
      Offset(center.dx, center.dy + radius * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.4, center.dy),
      Offset(center.dx + radius * 0.4, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomePainter extends CustomPainter {
  final Color color;
  _HomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Roof
    path.moveTo(size.width * 0.125, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.167);
    path.lineTo(size.width * 0.875, size.height * 0.5);

    // House
    path.moveTo(size.width * 0.167, size.height * 0.438);
    path.lineTo(size.width * 0.167, size.height * 0.79);
    path.quadraticBezierTo(
      size.width * 0.167, size.height * 0.833,
      size.width * 0.208, size.height * 0.833,
    );
    path.lineTo(size.width * 0.375, size.height * 0.833);
    path.lineTo(size.width * 0.375, size.height * 0.625);
    path.quadraticBezierTo(
      size.width * 0.375, size.height * 0.583,
      size.width * 0.417, size.height * 0.583,
    );
    path.lineTo(size.width * 0.583, size.height * 0.583);
    path.quadraticBezierTo(
      size.width * 0.625, size.height * 0.583,
      size.width * 0.625, size.height * 0.625,
    );
    path.lineTo(size.width * 0.625, size.height * 0.833);
    path.lineTo(size.width * 0.792, size.height * 0.833);
    path.quadraticBezierTo(
      size.width * 0.833, size.height * 0.833,
      size.width * 0.833, size.height * 0.79,
    );
    path.lineTo(size.width * 0.833, size.height * 0.438);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendUpPainter extends CustomPainter {
  final Color color;
  _TrendUpPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.29, size.height * 0.71);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.625, size.height * 0.625);
    path.lineTo(size.width * 0.875, size.height * 0.375);

    canvas.drawPath(path, paint);

    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.67, size.height * 0.375);
    arrowPath.lineTo(size.width * 0.875, size.height * 0.375);
    arrowPath.lineTo(size.width * 0.875, size.height * 0.583);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendDownPainter extends CustomPainter {
  final Color color;
  _TrendDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.29, size.height * 0.29);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.625, size.height * 0.375);
    path.lineTo(size.width * 0.875, size.height * 0.625);

    canvas.drawPath(path, paint);

    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.67, size.height * 0.625);
    arrowPath.lineTo(size.width * 0.875, size.height * 0.625);
    arrowPath.lineTo(size.width * 0.875, size.height * 0.417);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChevronLeftPainter extends CustomPainter {
  final Color color;
  _ChevronLeftPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.625, size.height * 0.25);
    path.lineTo(size.width * 0.375, size.height * 0.5);
    path.lineTo(size.width * 0.625, size.height * 0.75);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChevronRightPainter extends CustomPainter {
  final Color color;
  _ChevronRightPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.375, size.height * 0.25);
    path.lineTo(size.width * 0.625, size.height * 0.5);
    path.lineTo(size.width * 0.375, size.height * 0.75);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckPainter extends CustomPainter {
  final Color color;
  _CheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.21, size.height * 0.54);
    path.lineTo(size.width * 0.375, size.height * 0.71);
    path.lineTo(size.width * 0.79, size.height * 0.29);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _XPainter extends CustomPainter {
  final Color color;
  _XPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.75),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DollarPainter extends CustomPainter {
  final Color color;
  _DollarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.375;

    canvas.drawCircle(center, radius, paint);

    // Dollar sign
    canvas.drawLine(
      Offset(center.dx, size.height * 0.25),
      Offset(center.dx, size.height * 0.75),
      paint,
    );

    final sPath = Path();
    sPath.moveTo(size.width * 0.625, size.height * 0.4);
    sPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.29,
      size.width * 0.375, size.height * 0.4,
    );
    sPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.5,
      size.width * 0.625, size.height * 0.6,
    );
    sPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.71,
      size.width * 0.375, size.height * 0.6,
    );

    canvas.drawPath(sPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookPainter extends CustomPainter {
  final Color color;
  _BookPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Book spine
    path.moveTo(size.width * 0.167, size.height * 0.79);
    path.quadraticBezierTo(
      size.width * 0.167, size.height * 0.71,
      size.width * 0.27, size.height * 0.71,
    );
    path.lineTo(size.width * 0.833, size.height * 0.71);

    // Book cover
    path.moveTo(size.width * 0.27, size.height * 0.083);
    path.lineTo(size.width * 0.833, size.height * 0.083);
    path.lineTo(size.width * 0.833, size.height * 0.917);
    path.lineTo(size.width * 0.27, size.height * 0.917);
    path.quadraticBezierTo(
      size.width * 0.167, size.height * 0.917,
      size.width * 0.167, size.height * 0.81,
    );
    path.lineTo(size.width * 0.167, size.height * 0.188);
    path.quadraticBezierTo(
      size.width * 0.167, size.height * 0.083,
      size.width * 0.27, size.height * 0.083,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




