import 'package:flutter/material.dart';

class DarkColors {
  // ── Background hierarchy (deep forest night palette) ──
  static const Color scaffold        = Color(0xFF0E1C19); // page background
  static const Color surface         = Color(0xFF162820); // cards & surfaces
  static const Color surfaceElevated = Color(0xFF1C3430); // elevated cards / dialogs
  static const Color navBar          = Color(0xFF0A1512); // bottom nav (deepest)
  static const Color inputFill       = Color(0xFF0F2320); // input fields

  // ── Primary brand (vibrant teal – pops on dark) ──
  static const Color primary          = Color(0xFF2DC5A2);
  static const Color primaryDim       = Color(0xFF1E9E83);
  static const Color primaryContainer = Color(0xFF0D3028);

  // ── Text hierarchy ──
  static const Color textHigh   = Color(0xFFE2F0EC); // primary text
  static const Color textMedium = Color(0xFF7DAAA4); // secondary text
  static const Color textLow    = Color(0xFF4A7068); // hints / disabled

  // ── Accent ──
  static const Color gold       = Color(0xFFD4A843);
  static const Color lightAccent = Color(0xFF0D2B24); // dark twin of #EAF9F4

  // ── Utility ──
  static const Color divider = Color(0xFF1A2E2A);
  static const Color border  = Color(0xFF1E3530);
  static const Color error   = Color(0xFFFF6B6B);

  // ── Hadith card (dark twin of cream palette) ──
  static const Color hadithCard     = Color(0xFF1A2E28);
  static const Color hadithCardDeep = Color(0xFF142825);
  static const Color hadithInk      = Color(0xFFE2F0EC);
}
