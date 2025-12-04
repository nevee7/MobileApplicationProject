// lib/theme.dart
import 'package:flutter/material.dart';

const Color primaryPurple = Color(0xFF9333EA);
const Color primaryViolet = Color(0xFF7C3AED);
const Color accentPink = Color(0xFFE879F9);
const Color lightPurple = Color(0xFFF7EEFF);
const Color backgroundColor = Color(0xFFFFFBFF);
const Color cardBg = Colors.white;
const Color textPrimary = Color(0xFF22303C);
const Color textSecondary = Color(0xFF6B7280);

const LinearGradient cuteGradient = LinearGradient(
  colors: [primaryPurple, primaryViolet],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final BoxDecoration softCardDecoration = BoxDecoration(
  color: cardBg,
  borderRadius: BorderRadius.circular(18),
  boxShadow: [
    BoxShadow(
      color: primaryPurple.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ],
);
