import 'package:flutter/material.dart';
import '../utils/type_colors.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  final double fontSize;

  const TypeBadge({super.key, required this.type, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TypeColors.of(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 2, color: Colors.black38)],
        ),
      ),
    );
  }
}
