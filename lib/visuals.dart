import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'site_theme.dart';

const _trace = purple;
const _metal = ink;

/// Original circuit traces with a quiet, compass-like geometric construction.
class CircuitPainter extends CustomPainter {
  const CircuitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 500, size.height / 455);
    const center = Offset(250, 224);

    final traces = <List<Offset>>[
      [const Offset(6, 52), const Offset(99, 52), const Offset(140, 93)],
      [const Offset(5, 69), const Offset(91, 69), const Offset(129, 107)],
      [const Offset(496, 56), const Offset(405, 56), const Offset(367, 94)],
      [const Offset(497, 74), const Offset(413, 74), const Offset(379, 108)],
      [const Offset(8, 366), const Offset(87, 366), const Offset(127, 326)],
      [const Offset(5, 384), const Offset(94, 384), const Offset(140, 338)],
      [const Offset(497, 361), const Offset(413, 361), const Offset(376, 324)],
      [const Offset(497, 380), const Offset(404, 380), const Offset(363, 339)],
      [const Offset(250, 8), const Offset(250, 37)],
      [const Offset(250, 410), const Offset(250, 440)],
      [const Offset(5, 224), const Offset(62, 224)],
      [const Offset(438, 224), const Offset(495, 224)],
    ];
    for (var i = 0; i < traces.length; i++) {
      final points = traces[i];
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        _stroke(
          (i.isEven ? _metal : _trace).withValues(alpha: i.isEven ? 0.42 : 0.6),
        ),
      );
      canvas.drawRect(
        Rect.fromCenter(center: points.first, width: 4, height: 4),
        Paint()..color = bloodRedEdge,
      );
    }

    canvas.drawCircle(center, 182, _stroke(bloodRedEdge));
    canvas.drawCircle(center, 174, _stroke(_metal.withValues(alpha: 0.48)));
    canvas.drawCircle(center, 150, _stroke(_trace.withValues(alpha: 0.18)));

    // Six intersecting circles reference sacred geometry without adding symbols.
    const radius = 86.0;
    final geometry = _stroke(_trace.withValues(alpha: 0.42));
    canvas.drawCircle(center, radius, geometry);
    final hexagon = Path();
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawCircle(center + direction * radius, radius, geometry);
      final vertex = center + direction * 172;
      if (i == 0) {
        hexagon.moveTo(vertex.dx, vertex.dy);
      } else {
        hexagon.lineTo(vertex.dx, vertex.dy);
      }
    }
    hexagon.close();
    canvas.drawPath(hexagon, _stroke(_metal.withValues(alpha: 0.27)));

    for (var i = 0; i < 48; i++) {
      final angle = i * math.pi / 24;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * 178,
        center + direction * (i % 4 == 0 ? 187 : 181),
        _stroke(_metal.withValues(alpha: i % 4 == 0 ? 0.6 : 0.28)),
      );
    }
    canvas.drawCircle(center, 66, Paint()..color = bloodRed);
    canvas.drawCircle(center, 66, _stroke(bloodRedEdge));
    canvas.drawCircle(center, 61, _stroke(_metal.withValues(alpha: 0.22)));

    // The split Y retains the angled letterform of the business card.
    final mark = Path()
      ..moveTo(211, 184)
      ..lineTo(229, 184)
      ..lineTo(249, 212)
      ..lineTo(239, 226)
      ..close()
      ..moveTo(274, 184)
      ..lineTo(293, 184)
      ..lineTo(261, 228)
      ..lineTo(261, 265)
      ..lineTo(242, 265)
      ..lineTo(242, 225)
      ..close();
    canvas.drawPath(mark, Paint()..color = ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) => false;
}

/// A signal trace and circular construction connect audio with the visual theme.
class MediaPainter extends CustomPainter {
  const MediaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.43);
    final radius = size.height * 0.29;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        center,
        radius + i * 12,
        _stroke((i == 0 ? bloodRedEdge : _trace).withValues(alpha: 0.45)),
      );
    }
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 3 * i;
      final offset = Offset(math.cos(angle), math.sin(angle)) * radius / 2;
      canvas.drawCircle(
        center + offset,
        radius / 2,
        _stroke(_metal.withValues(alpha: 0.19)),
      );
    }
    final waveform = Path();
    final y = size.height * 0.54;
    for (var x = 0.0; x <= size.width; x += 2) {
      final t = x / size.width;
      final envelope = math.pow(math.sin(t * math.pi), 4);
      final amplitude = math.sin(t * math.pi * 24) * envelope * 20;
      if (x == 0) {
        waveform.moveTo(x, y);
      } else {
        waveform.lineTo(x, y + amplitude);
      }
    }
    canvas.drawPath(waveform, _stroke(_trace.withValues(alpha: 0.3)));
    canvas.drawCircle(
      center,
      3,
      Paint()..color = _metal.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant MediaPainter oldDelegate) => false;
}

Paint _stroke(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1;

/// Layered ridge lines echo the Appalachian landscape without a stock image.
class AppalachiaPainter extends CustomPainter {
  const AppalachiaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 500, size.height / 330);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 500, 330));
    const moon = Offset(354, 75);
    canvas.drawCircle(moon, 28, Paint()..color = bloodRed);
    canvas.drawCircle(moon, 28, _stroke(bloodRedEdge));
    canvas.drawCircle(moon, 36, _stroke(_metal.withValues(alpha: 0.12)));
    for (var i = 0; i < 7; i++) {
      final offset = i * 22.0;
      final path = Path()
        ..moveTo(0, 187 + offset)
        ..cubicTo(45, 190 + offset, 69, 116 + offset, 114, 130 + offset)
        ..cubicTo(145, 139 + offset, 155, 169 + offset, 185, 150 + offset)
        ..cubicTo(218, 124 + offset, 242, 83 + offset, 274, 112 + offset)
        ..cubicTo(305, 136 + offset, 328, 188 + offset, 366, 155 + offset)
        ..cubicTo(421, 113 + offset, 449, 158 + offset, 500, 169 + offset);
      canvas.drawPath(
        path,
        _stroke(_trace.withValues(alpha: 0.42 - i * 0.045)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AppalachiaPainter oldDelegate) => false;
}
