import 'package:flutter/material.dart';

class CurvedBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double startY = size.height * 0.85;
    path.lineTo(0, size.height * 0.80);

    path.quadraticBezierTo(
      size.width * 0.25, startY,
      size.width * 0.5, startY,
    );
    
    path.quadraticBezierTo(
      size.width * 0.75, startY,
      size.width, size.height * 0.80,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}