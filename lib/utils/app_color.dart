import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF7038FF);  // PICTO 로고, 마커 색상
  static const Color primaryLight = Color(0xFFE3CFFF);  // 선택된 태그 배경색
  static const Color primaryDark = Color(0xFF5C2DE0);  // 진한 보라색 (강조)

  // Secondary Colors
  static const Color secondary = Color(0xFF8E8EA9);  // 보조 색상
  static const Color secondaryLight = Color(0xFFF7F7FC);  // 연한 회색 (배경)
  static const Color secondaryDark = Color(0xFF6E6E85);  // 진한 회색 (텍스트)

  // Status Colors
  static const Color success = Color(0xFF4CAF50);  // 성공
  static const Color warning = Color(0xFFFFC107);  // 경고
  static const Color error = Color(0xFFFF4E4E);    // 에러
  static const Color info = Color(0xFF2196F3);     // 정보

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFAFAFC);  // 앱 배경색
  
  // Border Colors
  static const Color border = Color(0xFFE4E4E9);  // 기본 테두리
  static const Color borderLight = Color(0xFFF1F1F5);  // 연한 테두리

  // Text Colors
  static const Color textPrimary = Color(0xFF14142B);    // 주요 텍스트
  static const Color textSecondary = Color(0xFF6E6E85);  // 보조 텍스트
  static const Color textTertiary = Color(0xFFA0A0B0);   // 부가 텍스트
  static const Color textDisabled = Color(0xFFCFCFDF);   // 비활성화 텍스트

  // Marker Colors
  static const Color myMarker = primary;        // 내 마커 색상 (7038FF)
  static const Color otherMarker = white;       // 다른 사용자 마커 색상
  static const Color markerBorder = border;     // 마커 테두리 색상

  // Tag Colors
  static const Color selectedTagBg = primaryLight;  // 선택된 태그 배경색 (E3CFFF)
  static const Color selectedTagText = primary;     // 선택된 태그 텍스트 색상
  static const Color unselectedTagBg = white;       // 미선택 태그 배경색
  static const Color unselectedTagText = textSecondary;  // 미선택 태그 텍스트 색상

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7038FF),
      Color(0xFF8B5CFF),
    ],
  );

  // Opacity Colors
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => white.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => black.withOpacity(opacity);

  // Material Color for Theme
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF7038FF,
    <int, Color>{
      50: Color(0xFFF3EBFF),
      100: Color(0xFFE3CFFF),  // primaryLight
      200: Color(0xFFCBAFFF),
      300: Color(0xFFB38FFF),
      400: Color(0xFF9B6FFF),
      500: Color(0xFF7038FF),  // primary
      600: Color(0xFF5C2DE0),  // primaryDark
      700: Color(0xFF4822B3),
      800: Color(0xFF341786),
      900: Color(0xFF200B59),
    },
  );
}

// Theme Extension
extension AppThemeExtension on ThemeData {
  static ThemeData get appTheme => ThemeData(
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

// 이제 태그 선택기에서 다음과 같이 사용할 수 있습니다:
// Container(
//   decoration: BoxDecoration(
//     color: isSelected ? AppColors.selectedTagBg : AppColors.unselectedTagBg,
//     borderRadius: BorderRadius.circular(20),
//     border: Border.all(
//       color: isSelected ? AppColors.primary : AppColors.border,
//     ),
//   ),
//   child: Text(
//     tag,
//     style: TextStyle(
//       color: isSelected ? AppColors.selectedTagText : AppColors.unselectedTagText,
//     ),
//   ),
// )