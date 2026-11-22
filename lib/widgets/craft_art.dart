import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Product artwork drawn in code, in one flat cut-paper style: an arched
/// niche, a soft shadow and the object with its craft's pattern band.
///
/// Products describe their art as `art:<kind>:<base>:<accent>:<pattern>`,
/// for example `art:vase:B5532C:E9D8BE:waves`.
class CraftArtSpec {
  const CraftArtSpec(this.kind, this.base, this.accent, this.pattern);

  final String kind;
  final Color base;
  final Color accent;
  final String pattern;

  static CraftArtSpec? parse(String value) {
    final parts = value.split(':');
    if (parts.length != 5 || parts[0] != 'art') return null;
    Color hex(String h) => Color(int.tryParse('FF$h', radix: 16) ?? 0xFFB5532C);
    return CraftArtSpec(parts[1], hex(parts[2]), hex(parts[3]), parts[4]);
  }
}

class CraftArt extends StatelessWidget {
  const CraftArt({super.key, required this.spec, this.niche = true});

  final CraftArtSpec spec;

  /// Draws the arched niche behind the object (off for small thumbnails).
  final bool niche;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(painter: _CraftPainter(spec, niche: niche, dark: dark)),
    );
  }
}

class _CraftPainter extends CustomPainter {
  _CraftPainter(this.spec, {required this.niche, required this.dark});

  final CraftArtSpec spec;
  final bool niche;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    if (niche) {
      final arch = Path()
        ..moveTo(s * .16, s * .92)
        ..lineTo(s * .16, s * .42)
        ..arcToPoint(Offset(s * .84, s * .42), radius: Radius.circular(s * .34))
        ..lineTo(s * .84, s * .92)
        ..close();
      canvas.drawPath(arch, Paint()..color = spec.base.withValues(alpha: dark ? .16 : .10));
    }
    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s * .5, s * .86), width: s * .52, height: s * .06),
      Paint()..color = Colors.black.withValues(alpha: dark ? .35 : .10),
    );

    final body = _shape(s);
    canvas.drawPath(body, Paint()..color = spec.base);
    canvas.save();
    canvas.clipPath(body);
    _pattern(canvas, body.getBounds(), s);
    // A soft highlight on the left gives the paper shapes some volume.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s * .5, s),
      Paint()..color = Colors.white.withValues(alpha: .07),
    );
    canvas.restore();
    _details(canvas, s);
    canvas.restore();
  }

  Path _shape(double s) {
    switch (spec.kind) {
      case 'vase':
        return Path()
          ..moveTo(s * .42, s * .2)
          ..lineTo(s * .58, s * .2)
          ..quadraticBezierTo(s * .56, s * .32, s * .66, s * .44)
          ..quadraticBezierTo(s * .78, s * .62, s * .62, s * .86)
          ..lineTo(s * .38, s * .86)
          ..quadraticBezierTo(s * .22, s * .62, s * .34, s * .44)
          ..quadraticBezierTo(s * .44, s * .32, s * .42, s * .2)
          ..close();
      case 'bowl':
        return Path()
          ..moveTo(s * .2, s * .52)
          ..lineTo(s * .8, s * .52)
          ..quadraticBezierTo(s * .78, s * .82, s * .5, s * .86)
          ..quadraticBezierTo(s * .22, s * .82, s * .2, s * .52)
          ..close();
      case 'plate':
        return Path()..addOval(Rect.fromCenter(center: Offset(s * .5, s * .58), width: s * .6, height: s * .5));
      case 'rug':
        return Path()..addRect(Rect.fromLTWH(s * .26, s * .22, s * .48, s * .64));
      case 'cushion':
        return Path()
          ..moveTo(s * .24, s * .36)
          ..quadraticBezierTo(s * .5, s * .3, s * .76, s * .36)
          ..quadraticBezierTo(s * .7, s * .6, s * .76, s * .84)
          ..quadraticBezierTo(s * .5, s * .78, s * .24, s * .84)
          ..quadraticBezierTo(s * .3, s * .6, s * .24, s * .36)
          ..close();
      case 'scarf':
        return Path()
          ..moveTo(s * .36, s * .2)
          ..lineTo(s * .64, s * .2)
          ..quadraticBezierTo(s * .58, s * .52, s * .66, s * .84)
          ..lineTo(s * .34, s * .84)
          ..quadraticBezierTo(s * .42, s * .52, s * .36, s * .2)
          ..close();
      case 'basket':
        return Path()
          ..moveTo(s * .24, s * .46)
          ..lineTo(s * .76, s * .46)
          ..lineTo(s * .68, s * .86)
          ..lineTo(s * .32, s * .86)
          ..close();
      case 'lamp':
        return Path()
          ..moveTo(s * .5, s * .3)
          ..quadraticBezierTo(s * .78, s * .34, s * .8, s * .62)
          ..lineTo(s * .2, s * .62)
          ..quadraticBezierTo(s * .22, s * .34, s * .5, s * .3)
          ..close();
      case 'lantern':
        return Path()
          ..moveTo(s * .5, s * .2)
          ..lineTo(s * .64, s * .36)
          ..lineTo(s * .64, s * .72)
          ..lineTo(s * .56, s * .86)
          ..lineTo(s * .44, s * .86)
          ..lineTo(s * .36, s * .72)
          ..lineTo(s * .36, s * .36)
          ..close();
      case 'glass':
        return Path()
          ..moveTo(s * .38, s * .3)
          ..lineTo(s * .62, s * .3)
          ..lineTo(s * .59, s * .86)
          ..lineTo(s * .41, s * .86)
          ..close();
      case 'necklace':
        return Path()..addOval(Rect.fromCenter(center: Offset(s * .5, s * .74), width: s * .16, height: s * .16));
      case 'bracelet':
        final outer = Rect.fromCenter(center: Offset(s * .5, s * .6), width: s * .5, height: s * .4);
        return Path()
          ..fillType = PathFillType.evenOdd
          ..addOval(outer)
          ..addOval(outer.deflate(s * .07));
      default:
        return Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * .3, s * .3, s * .4, s * .5), Radius.circular(s * .06)));
    }
  }

  void _pattern(Canvas canvas, Rect b, double s) {
    final p = Paint()
      ..color = spec.accent
      ..strokeWidth = s * .018
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final band = Rect.fromLTWH(b.left, b.top + b.height * .42, b.width, b.height * .2);
    switch (spec.pattern) {
      case 'dots':
        final fill = Paint()..color = spec.accent;
        for (var x = band.left + s * .04; x < band.right; x += s * .06) {
          canvas.drawCircle(Offset(x, band.center.dy), s * .014, fill);
        }
      case 'zigzag':
        final path = Path()..moveTo(band.left, band.bottom);
        var up = true;
        for (var x = band.left; x <= band.right + s * .05; x += s * .05) {
          path.lineTo(x, up ? band.top + band.height * .25 : band.bottom - band.height * .25);
          up = !up;
        }
        canvas.drawPath(path, p);
      case 'stripes':
        for (var y = b.top + s * .05; y < b.bottom; y += s * .07) {
          canvas.drawLine(Offset(b.left, y), Offset(b.right, y), p..strokeWidth = s * .014);
        }
      case 'diamond':
        final fill = Paint()..color = spec.accent;
        for (var x = band.left + s * .05; x < band.right; x += s * .1) {
          final c = Offset(x, band.center.dy);
          canvas.drawPath(
            Path()
              ..moveTo(c.dx, c.dy - s * .04)
              ..lineTo(c.dx + s * .03, c.dy)
              ..lineTo(c.dx, c.dy + s * .04)
              ..lineTo(c.dx - s * .03, c.dy)
              ..close(),
            fill,
          );
        }
      case 'waves':
        final path = Path()..moveTo(band.left, band.center.dy);
        for (var x = band.left; x < band.right; x += s * .08) {
          path.quadraticBezierTo(x + s * .02, band.top, x + s * .04, band.center.dy);
          path.quadraticBezierTo(x + s * .06, band.bottom, x + s * .08, band.center.dy);
        }
        canvas.drawPath(path, p);
    }
  }

  void _details(Canvas canvas, double s) {
    final line = Paint()
      ..color = spec.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .014
      ..strokeCap = StrokeCap.round;
    final dark = Paint()..color = Color.lerp(spec.base, Colors.black, .35)!;
    switch (spec.kind) {
      case 'basket':
        // Handle and a lid band.
        canvas.drawArc(Rect.fromLTWH(s * .3, s * .26, s * .4, s * .4), math.pi, math.pi, false,
            Paint()
              ..color = Color.lerp(spec.base, Colors.black, .3)!
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * .025);
      case 'lamp':
        canvas.drawLine(Offset(s * .5, s * .06), Offset(s * .5, s * .3), line..color = Colors.grey.shade600);
        canvas.drawCircle(Offset(s * .5, s * .68), s * .05, Paint()..color = const Color(0xFFF7D774));
      case 'lantern':
        canvas.drawCircle(Offset(s * .5, s * .16), s * .03, dark);
        canvas.drawCircle(Offset(s * .5, s * .56), s * .05, Paint()..color = const Color(0xFFF7D774).withValues(alpha: .9));
      case 'necklace':
        canvas.drawArc(Rect.fromLTWH(s * .24, s * .12, s * .52, s * .62), .15, math.pi - .3, false, line..color = spec.base);
        for (var i = 0; i < 7; i++) {
          final a = .4 + i * (math.pi - .8) / 6;
          canvas.drawCircle(Offset(s * .5 + math.cos(a) * s * .26, s * .43 + math.sin(a) * s * .31), s * .018, Paint()..color = spec.accent);
        }
      case 'bowl':
        canvas.drawOval(Rect.fromLTWH(s * .2, s * .48, s * .6, s * .08), dark);
      case 'glass':
        canvas.drawOval(Rect.fromLTWH(s * .38, s * .28, s * .24, s * .04), Paint()..color = Colors.white.withValues(alpha: .35));
      case 'rug':
        for (var x = s * .28; x <= s * .72; x += s * .04) {
          canvas.drawLine(Offset(x, s * .86), Offset(x, s * .9), line..color = spec.accent);
          canvas.drawLine(Offset(x, s * .18), Offset(x, s * .22), line..color = spec.accent);
        }
      case 'plate':
        canvas.drawOval(Rect.fromCenter(center: Offset(s * .5, s * .58), width: s * .34, height: s * .28),
            Paint()
              ..color = spec.accent.withValues(alpha: .6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * .01);
    }
  }

  @override
  bool shouldRepaint(_CraftPainter old) => old.spec != spec || old.dark != dark || old.niche != niche;
}
