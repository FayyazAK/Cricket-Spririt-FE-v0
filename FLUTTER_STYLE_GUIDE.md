# 🏏 Cricket Spirit - Flutter Style Guide

**Version:** 1.0  
**Based on:** Spirit-Design Web Prototype  
**Theme:** Modern T20 Cricket - Deep Navy & Electric Lime  

---

## Table of Contents

1. [Color System](#1-color-system)
2. [Typography](#2-typography)
3. [Spacing & Border Radius](#3-spacing--border-radius)
4. [Component Specifications](#4-component-specifications)
5. [Icons](#5-icons)
6. [Animations & Transitions](#6-animations--transitions)
7. [Layout Patterns](#7-layout-patterns)
8. [Custom Utilities & Effects](#8-custom-utilities--effects)
9. [Status Indicators](#9-status-indicators)
10. [Flutter Implementation Guide](#10-flutter-implementation-guide)

---

## 1. Color System

### Primary Theme Colors

```dart
class CricketSpiritColors {
  // === CORE COLORS ===
  
  // Background - Deep Navy
  static const Color background = Color(0xFF0F172A); // hsl(222, 47%, 11%)
  
  // Foreground - Off White
  static const Color foreground = Color(0xFFF8FAFC); // hsl(210, 40%, 98%)
  
  // === SURFACE COLORS ===
  
  // Card - Lighter Navy
  static const Color card = Color(0xFF1E293B); // hsl(217, 33%, 17%)
  static const Color cardForeground = Color(0xFFF8FAFC);
  
  // Popover
  static const Color popover = Color(0xFF0F172A);
  static const Color popoverForeground = Color(0xFFF8FAFC);
  
  // === ACCENT COLORS ===
  
  // Primary - Electric Lime (Main Brand Color)
  static const Color primary = Color(0xFFCDFF2F); // hsl(84, 100%, 59%)
  static const Color primaryForeground = Color(0xFF0F172A);
  
  // Secondary - Muted Blue Grey
  static const Color secondary = Color(0xFF374151); // hsl(217, 19%, 27%)
  static const Color secondaryForeground = Color(0xFFF8FAFC);
  
  // Muted
  static const Color muted = Color(0xFF374151); // hsl(217, 19%, 27%)
  static const Color mutedForeground = Color(0xFF94A3B8); // hsl(215, 20%, 65%)
  
  // Accent (Same as Primary)
  static const Color accent = Color(0xFFCDFF2F);
  static const Color accentForeground = Color(0xFF0F172A);
  
  // === SEMANTIC COLORS ===
  
  // Destructive / Error
  static const Color destructive = Color(0xFF7F1D1D); // hsl(0, 62%, 30%)
  static const Color destructiveForeground = Color(0xFFF8FAFC);
  static const Color error = Color(0xFFEF4444); // Red-500
  
  // Success
  static const Color success = Color(0xFF22C55E); // Green-500
  
  // Warning
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  
  // === BORDER & INPUT COLORS ===
  
  static const Color border = Color(0xFF334155); // hsl(217, 33%, 25%)
  static const Color input = Color(0xFF334155);
  static const Color ring = Color(0xFFCDFF2F); // Primary lime for focus rings
  
  // === CHART COLORS ===
  
  static const Color chart1 = Color(0xFFCDFF2F); // Lime
  static const Color chart2 = Color(0xFF0EA5E9); // Cyan - hsl(199, 89%, 48%)
  static const Color chart3 = Color(0xFFF97316); // Orange - hsl(24, 95%, 53%)
  static const Color chart4 = Color(0xFFA855F7); // Purple - hsl(280, 65%, 60%)
  static const Color chart5 = Color(0xFFEC4899); // Pink - hsl(340, 75%, 55%)
  
  // === SPECIAL COLORS ===
  
  // Orange Cap (Most Runs)
  static const Color orangeCap = Color(0xFFF97316);
  
  // Purple Cap (Most Wickets)
  static const Color purpleCap = Color(0xFFA855F7);
  
  // Live Status
  static const Color liveRed = Color(0xFFDC2626);
  
  // Free Hit
  static const Color freeHitYellow = Color(0xFFEAB308);
  
  // White Overlays
  static const Color white5 = Color(0x0DFFFFFF);   // 5% white
  static const Color white10 = Color(0x1AFFFFFF);  // 10% white
  static const Color white20 = Color(0x33FFFFFF);  // 20% white
  static const Color white30 = Color(0x4DFFFFFF);  // 30% white
  static const Color white60 = Color(0x99FFFFFF);  // 60% white
  
  // Black Overlays
  static const Color black20 = Color(0x33000000);  // 20% black
  static const Color black30 = Color(0x4D000000);  // 30% black
  static const Color black80 = Color(0xCC000000);  // 80% black (Dialog overlay)
}
```

### Gradient Definitions

```dart
class CricketSpiritGradients {
  // Primary Text Gradient
  static const LinearGradient primaryTextGradient = LinearGradient(
    colors: [
      Color(0xFFCDFF2F), // Primary Lime
      Color(0xFF34D399), // Emerald-400
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Hero Background Gradient (Over image)
  static const LinearGradient heroOverlay = LinearGradient(
    colors: [
      Color(0x00000000), // Transparent
      Color(0x99000000), // 60% black
      Color(0xF20F172A), // 95% background
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Score Display Gradient
  static const LinearGradient scoreDisplayGradient = LinearGradient(
    colors: [
      Color(0xFF1E293B), // Card
      Color(0xFF0F172A), // Background
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Tournament Card Gradients (Examples)
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Avatar Ring Gradient
  static const LinearGradient avatarRingGradient = LinearGradient(
    colors: [Color(0xFFCDFF2F), Color(0xFF059669)], // Primary to Emerald-600
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

---

## 2. Typography

### Font Families

```dart
// Add these to pubspec.yaml:
// google_fonts: ^6.1.0 (recommended)
// OR add font files manually

class CricketSpiritTypography {
  // Primary Font - Body Text
  static const String fontFamilySans = 'Inter';
  
  // Display Font - Headings, Scores, Large Numbers
  static const String fontFamilyDisplay = 'Teko';
  
  // Condensed Font - Labels, Tags, Metadata
  static const String fontFamilyCondensed = 'Barlow Condensed';
  
  // Monospace - Overs, Statistics, Technical Data
  static const String fontFamilyMono = 'JetBrains Mono'; // or 'Roboto Mono'
}
```

### Text Styles

```dart
class CricketSpiritTextStyles {
  // === DISPLAY / HEADINGS (Teko) ===
  
  // Hero Title - Large
  static TextStyle heroTitle = TextStyle(
    fontFamily: 'Teko',
    fontSize: 56, // 5xl mobile, 7xl desktop
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.foreground,
    height: 0.9, // Leading tight
    letterSpacing: 0.5,
  );
  
  // Section Title
  static TextStyle sectionTitle = TextStyle(
    fontFamily: 'Teko',
    fontSize: 30, // 3xl
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.foreground,
    letterSpacing: 0.5,
  );
  
  // Card Title
  static TextStyle cardTitle = TextStyle(
    fontFamily: 'Teko',
    fontSize: 24, // 2xl
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.foreground,
  );
  
  // Score Display - Large Numbers
  static TextStyle scoreDisplayLarge = TextStyle(
    fontFamily: 'Teko',
    fontSize: 60, // 6xl
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.foreground,
    letterSpacing: -1,
    height: 1.0,
  );
  
  // Score Display - Medium
  static TextStyle scoreDisplayMedium = TextStyle(
    fontFamily: 'Teko',
    fontSize: 32, // 4xl
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.foreground,
  );
  
  // Stat Number
  static TextStyle statNumber = TextStyle(
    fontFamily: 'Teko',
    fontSize: 24, // 2xl
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.foreground,
  );
  
  // === CONDENSED LABELS (Barlow Condensed) ===
  
  // Section Label
  static TextStyle sectionLabel = TextStyle(
    fontFamily: 'Barlow Condensed',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: CricketSpiritColors.primary,
    letterSpacing: 2.0,
    // Apply: .toUpperCase()
  );
  
  // Meta Label
  static TextStyle metaLabel = TextStyle(
    fontFamily: 'Barlow Condensed',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: CricketSpiritColors.mutedForeground,
    letterSpacing: 1.5,
    // Apply: .toUpperCase()
  );
  
  // === BODY TEXT (Inter) ===
  
  // Body Large
  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: CricketSpiritColors.mutedForeground,
    height: 1.6,
  );
  
  // Body Medium
  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: CricketSpiritColors.foreground,
    height: 1.5,
  );
  
  // Body Small
  static TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CricketSpiritColors.mutedForeground,
    height: 1.4,
  );
  
  // Caption / Helper Text
  static TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CricketSpiritColors.mutedForeground,
  );
  
  // Button Text
  static TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  
  // === MONOSPACE (Technical Data) ===
  
  // Overs Display
  static TextStyle oversDisplay = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CricketSpiritColors.mutedForeground,
    letterSpacing: 1.5,
  );
  
  // Stats Mono
  static TextStyle statsMono = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CricketSpiritColors.mutedForeground,
  );
}
```

### Typography Rules

| Element | Font | Weight | Size | Transform | Letter Spacing |
|---------|------|--------|------|-----------|----------------|
| Hero Title | Teko | 700 | 56-72px | UPPERCASE | 0.5px |
| Section Title | Teko | 700 | 30px | UPPERCASE | 0.5px |
| Card Title | Teko | 700 | 24px | Normal | 0 |
| Score (Large) | Teko | 700 | 60px | Normal | -1px |
| Score (Medium) | Teko | 700 | 32px | Normal | 0 |
| Label/Tag | Barlow Condensed | 700 | 12-14px | UPPERCASE | 1.5-2px |
| Body | Inter | 400-500 | 14-18px | Normal | 0 |
| Button | Inter | 700 | 14px | Normal/UPPER | 0.5px |
| Mono/Stats | Mono | 400 | 12-14px | Normal | 1.5px |

---

## 3. Spacing & Border Radius

### Spacing Scale

```dart
class CricketSpiritSpacing {
  static const double xs = 4.0;   // 0.25rem
  static const double sm = 8.0;   // 0.5rem
  static const double md = 12.0;  // 0.75rem
  static const double base = 16.0; // 1rem
  static const double lg = 24.0;  // 1.5rem
  static const double xl = 32.0;  // 2rem
  static const double xxl = 48.0; // 3rem
  static const double xxxl = 64.0; // 4rem
  
  // Component-specific
  static const double cardPadding = 24.0;
  static const double cardPaddingMobile = 16.0;
  static const double sectionPadding = 40.0;
  static const double containerPadding = 16.0;
  static const double buttonPaddingH = 16.0;
  static const double buttonPaddingV = 8.0;
  static const double inputPadding = 12.0;
  static const double bottomNavHeight = 64.0;
  static const double headerHeight = 64.0;
}
```

### Border Radius

```dart
class CricketSpiritRadius {
  static const double none = 0.0;
  static const double sm = 4.0;   // Buttons small
  static const double md = 6.0;   // Default buttons
  static const double base = 8.0; // 0.5rem - default radius
  static const double lg = 12.0;  // Cards, dialogs
  static const double xl = 16.0;  // Large cards
  static const double xxl = 20.0; // Scoring buttons
  static const double full = 999.0; // Circular/pills
  
  // Semantic
  static const double card = 12.0;
  static const double button = 8.0;
  static const double input = 8.0;
  static const double badge = 6.0;
  static const double avatar = 999.0;
  static const double dialog = 8.0;
  static const double bottomSheet = 12.0;
}
```

### Shadows

```dart
class CricketSpiritShadows {
  // Default Card Shadow
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000), // 10% black
    blurRadius: 10,
    offset: Offset(0, 4),
  );
  
  // Elevated Card Shadow
  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x33000000), // 20% black
    blurRadius: 20,
    offset: Offset(0, 8),
  );
  
  // Primary Button Glow
  static BoxShadow primaryGlow = BoxShadow(
    color: CricketSpiritColors.primary.withOpacity(0.3),
    blurRadius: 15,
    offset: Offset(0, 0),
  );
  
  // Control Shadow (Bottom bar)
  static const BoxShadow controlBarShadow = BoxShadow(
    color: Color(0x4D000000), // 30% black
    blurRadius: 20,
    offset: Offset(0, -5),
  );
  
  // Live Indicator Glow
  static BoxShadow liveIndicatorGlow = BoxShadow(
    color: CricketSpiritColors.primary.withOpacity(0.5),
    blurRadius: 8,
    spreadRadius: 0,
  );
}
```

---

## 4. Component Specifications

### 4.1 Buttons

```dart
// Button Variants
enum ButtonVariant {
  primary,     // Electric lime background
  secondary,   // Muted blue-grey background
  outline,     // Transparent with border
  ghost,       // Transparent, no border
  destructive, // Red for destructive actions
  link,        // Text-only with underline
}

// Button Sizes
enum ButtonSize {
  sm,      // Height: 32px, Padding: 12px H
  md,      // Height: 36px, Padding: 16px H (default)
  lg,      // Height: 40px, Padding: 32px H
  icon,    // 36x36px square
}

class ButtonStyles {
  // Primary Button
  static final primaryButton = BoxDecoration(
    color: CricketSpiritColors.primary,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
    boxShadow: [CricketSpiritShadows.primaryGlow],
  );
  
  // Primary Button Text
  static final primaryButtonText = CricketSpiritTextStyles.buttonText.copyWith(
    color: CricketSpiritColors.primaryForeground,
  );
  
  // Outline Button
  static final outlineButton = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
    border: Border.all(
      color: CricketSpiritColors.border,
      width: 1,
    ),
  );
  
  // Ghost Button
  static final ghostButton = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
  );
  
  // Destructive Button
  static final destructiveButton = BoxDecoration(
    color: CricketSpiritColors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
    border: Border.all(
      color: CricketSpiritColors.error.withOpacity(0.2),
      width: 1,
    ),
  );
  
  // Scoring Pad Run Button (Large)
  static BoxDecoration scoringRunButton({bool isHighlight = false}) {
    return BoxDecoration(
      color: isHighlight 
          ? CricketSpiritColors.primary 
          : CricketSpiritColors.white5,
      borderRadius: BorderRadius.circular(CricketSpiritRadius.xxl),
      border: Border.all(
        color: isHighlight 
            ? Colors.transparent 
            : CricketSpiritColors.white20,
        width: 2,
      ),
      boxShadow: isHighlight ? [CricketSpiritShadows.primaryGlow] : null,
    );
  }
}
```

### 4.2 Cards

```dart
class CardStyles {
  // Standard Card
  static BoxDecoration standardCard = BoxDecoration(
    color: CricketSpiritColors.card,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
    border: Border.all(
      color: CricketSpiritColors.border,
      width: 1,
    ),
    boxShadow: [CricketSpiritShadows.cardShadow],
  );
  
  // Glass Card (Glassmorphism effect)
  static BoxDecoration glassCard = BoxDecoration(
    color: CricketSpiritColors.card.withOpacity(0.6),
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
    border: Border.all(
      color: CricketSpiritColors.white10,
      width: 1,
    ),
  );
  // Note: Apply BackdropFilter with ImageFilter.blur(sigmaX: 12, sigmaY: 12)
  
  // Live Score Card
  static BoxDecoration liveScoreCard = BoxDecoration(
    color: CricketSpiritColors.card.withOpacity(0.6),
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
    border: Border.all(
      color: CricketSpiritColors.white10,
      width: 1,
    ),
  );
  
  // Stat Card (Small stat display)
  static BoxDecoration statCard = BoxDecoration(
    color: CricketSpiritColors.white5,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.base),
  );
}
```

### 4.3 Badges

```dart
// Badge Variants
enum BadgeVariant {
  primary,    // Lime background
  secondary,  // Muted background
  destructive, // Red background
  outline,    // Border only
  live,       // Pulsing red for live status
}

class BadgeStyles {
  static const double height = 22.0;
  static const double paddingH = 10.0;
  static const double paddingV = 2.0;
  static const double fontSize = 12.0;
  
  // Primary Badge
  static BoxDecoration primaryBadge = BoxDecoration(
    color: CricketSpiritColors.primary,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.badge),
  );
  
  // Live Badge
  static BoxDecoration liveBadge = BoxDecoration(
    color: CricketSpiritColors.primary,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.badge),
  );
  // Note: Add AnimatedContainer with animation for pulse effect
  
  // Status Badge (UPCOMING, COMPLETED, etc.)
  static BoxDecoration statusBadge = BoxDecoration(
    color: CricketSpiritColors.white10,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.badge),
  );
}
```

### 4.4 Input Fields

```dart
class InputStyles {
  // Standard Input
  static InputDecoration standardInput({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: CricketSpiritTextStyles.bodySmall.copyWith(
        color: CricketSpiritColors.mutedForeground,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: CricketSpiritColors.white5,
      contentPadding: EdgeInsets.symmetric(
        horizontal: CricketSpiritSpacing.inputPadding,
        vertical: CricketSpiritSpacing.inputPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(
          color: CricketSpiritColors.border,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(
          color: CricketSpiritColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(
          color: CricketSpiritColors.ring,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(
          color: CricketSpiritColors.error,
          width: 1,
        ),
      ),
    );
  }
}
```

### 4.5 Tabs

```dart
class TabStyles {
  // Underline Tab (Scoring page style)
  static BoxDecoration underlineTabActive = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: CricketSpiritColors.primary,
        width: 2,
      ),
    ),
  );
  
  static TextStyle tabTextActive = CricketSpiritTextStyles.buttonText.copyWith(
    color: CricketSpiritColors.primary,
    letterSpacing: 1.0,
    // Apply: .toUpperCase()
  );
  
  static TextStyle tabTextInactive = CricketSpiritTextStyles.buttonText.copyWith(
    color: CricketSpiritColors.mutedForeground,
    letterSpacing: 1.0,
  );
  
  // Pill Tab (Match center style)
  static BoxDecoration pillTabActive = BoxDecoration(
    color: CricketSpiritColors.primary,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.md),
  );
  
  static BoxDecoration pillTabInactive = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.md),
  );
  
  // Tab Container
  static BoxDecoration tabContainer = BoxDecoration(
    color: CricketSpiritColors.white5,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.lg),
    border: Border.all(
      color: CricketSpiritColors.white5,
      width: 1,
    ),
  );
}
```

### 4.6 Dialog / Modal

```dart
class DialogStyles {
  // Overlay
  static const Color overlayColor = CricketSpiritColors.black80;
  
  // Dialog Container
  static BoxDecoration dialogContainer = BoxDecoration(
    color: CricketSpiritColors.card.withOpacity(0.95),
    borderRadius: BorderRadius.circular(CricketSpiritRadius.dialog),
    border: Border.all(
      color: CricketSpiritColors.white10,
      width: 1,
    ),
  );
  // Note: Apply BackdropFilter for glass effect
  
  // Dialog Title Style
  static TextStyle dialogTitle = CricketSpiritTextStyles.cardTitle.copyWith(
    fontSize: 18,
    color: CricketSpiritColors.foreground,
  );
  
  // Dialog Content Padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
}
```

### 4.7 Bottom Sheet

```dart
class BottomSheetStyles {
  static BoxDecoration container = BoxDecoration(
    color: CricketSpiritColors.card,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(CricketSpiritRadius.bottomSheet),
    ),
    border: Border(
      top: BorderSide(
        color: CricketSpiritColors.white10,
        width: 1,
      ),
    ),
  );
  
  // Handle indicator
  static BoxDecoration handle = BoxDecoration(
    color: CricketSpiritColors.white20,
    borderRadius: BorderRadius.circular(3),
  );
  static const Size handleSize = Size(40, 4);
}
```

### 4.8 Switch / Toggle

```dart
class SwitchStyles {
  static const double width = 36.0;
  static const double height = 20.0;
  static const double thumbSize = 16.0;
  
  // Track colors
  static const Color trackActive = CricketSpiritColors.primary;
  static const Color trackInactive = CricketSpiritColors.input;
  
  // Thumb colors
  static const Color thumbColor = CricketSpiritColors.background;
}
```

### 4.9 Progress Indicator

```dart
class ProgressStyles {
  static const double height = 8.0;
  
  static BoxDecoration trackDecoration = BoxDecoration(
    color: CricketSpiritColors.primary.withOpacity(0.2),
    borderRadius: BorderRadius.circular(CricketSpiritRadius.full),
  );
  
  static BoxDecoration indicatorDecoration = BoxDecoration(
    color: CricketSpiritColors.primary,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.full),
  );
}
```

### 4.10 Avatar

```dart
class AvatarStyles {
  // Sizes
  static const double sm = 32.0;
  static const double md = 40.0;
  static const double lg = 64.0;
  static const double xl = 128.0;
  
  // Team Avatar (circular with initial)
  static BoxDecoration teamAvatar = BoxDecoration(
    color: CricketSpiritColors.white10,
    shape: BoxShape.circle,
    border: Border.all(
      color: CricketSpiritColors.white10,
      width: 1,
    ),
  );
  
  // Player Avatar with gradient border
  static BoxDecoration playerAvatarWithBorder = BoxDecoration(
    shape: BoxShape.circle,
    gradient: CricketSpiritGradients.avatarRingGradient,
  );
  // Use with padding of 2px and inner white/card circle
  
  // Avatar Placeholder
  static BoxDecoration avatarPlaceholder = BoxDecoration(
    color: CricketSpiritColors.muted,
    shape: BoxShape.circle,
  );
}
```

---

## 5. Icons

### Icon Library

Use **Lucide Icons** for Flutter. Package: `lucide_icons`

```yaml
# pubspec.yaml
dependencies:
  lucide_icons: ^0.257.0
```

### Icon Usage Map

| UI Element | Icon Name | Size | Color |
|------------|-----------|------|-------|
| Home | `LucideIcons.home` | 20-24px | muted → primary (active) |
| Matches | `LucideIcons.calendar` | 20-24px | muted → primary |
| Tournaments | `LucideIcons.trophy` | 20-24px | muted → primary |
| Profile | `LucideIcons.user` | 20-24px | muted → primary |
| Notifications | `LucideIcons.bell` | 20px | mutedForeground |
| Menu | `LucideIcons.menu` | 20px | mutedForeground |
| Settings | `LucideIcons.settings` | 20px | mutedForeground |
| Back Arrow | `LucideIcons.arrowLeft` | 20px | mutedForeground |
| Forward Arrow | `LucideIcons.arrowRight` | 16px | primary |
| Chevron Right | `LucideIcons.chevronRight` | 16px | primary |
| Play | `LucideIcons.playCircle` | 20px | foreground |
| Share | `LucideIcons.share2` | 16px | mutedForeground |
| Location | `LucideIcons.mapPin` | 16px | mutedForeground |
| Users/Teams | `LucideIcons.users` | 16-20px | primary/mutedForeground |
| Award | `LucideIcons.award` | 16px | amber/purple |
| Mic | `LucideIcons.mic` | 16-20px | primary |
| Undo | `LucideIcons.rotateCcw` | 20px | mutedForeground |
| More | `LucideIcons.moreHorizontal` | 20px | mutedForeground |
| Check | `LucideIcons.check` | 16px | primary |
| Close (X) | `LucideIcons.x` | 16px | mutedForeground |
| Warning | `LucideIcons.alertTriangle` | 24px | warning |
| Coin/Toss | `LucideIcons.coins` | 40px | amber |
| Retire Player | `LucideIcons.userMinus` | 24px | error |
| Add Player | `LucideIcons.userPlus` | 24px | primary |
| Flag | `LucideIcons.flag` | 24px | warning |

### Icon Sizes

```dart
class CricketSpiritIconSizes {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double hero = 80.0;
}
```

---

## 6. Animations & Transitions

### Duration Constants

```dart
class CricketSpiritDurations {
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration animation = Duration(milliseconds: 800);
}
```

### Animation Curves

```dart
class CricketSpiritCurves {
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}
```

### Key Animations

```dart
// Live Badge Pulse
class PulsingWidget extends StatefulWidget {
  // Implement with AnimationController
  // Scale: 1.0 → 1.05 → 1.0
  // Duration: 1500ms
  // Repeat: infinite
}

// Ball Event Indicator (Recent balls)
// Slide in from right with fade
// Duration: 300ms

// Score Update
// Scale up briefly on change
// Duration: 200ms

// Button Press
// Scale: 1.0 → 0.95 on press
// Duration: 100ms

// Card Hover (Desktop)
// Background lightens slightly
// Duration: 300ms

// Sheet/Modal Entry
// Slide up + fade in
// Duration: 500ms (open), 300ms (close)
```

---

## 7. Layout Patterns

### App Structure

```dart
// Main Scaffold Pattern
Scaffold(
  backgroundColor: CricketSpiritColors.background,
  appBar: AppBar(...), // Sticky header
  body: SafeArea(
    child: Column(
      children: [
        Expanded(child: content),
      ],
    ),
  ),
  bottomNavigationBar: BottomNavBar(...), // Mobile only
)
```

### Header/AppBar

```dart
AppBar(
  backgroundColor: CricketSpiritColors.background.withOpacity(0.8),
  elevation: 0,
  toolbarHeight: 64,
  // Add: BackdropFilter for blur effect
  leading: Logo(),
  title: BrandText(),
  actions: [NotificationIcon(), MenuIcon()],
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(color: CricketSpiritColors.white10),
  ),
)
```

### Bottom Navigation

```dart
BottomNavigationBar(
  backgroundColor: CricketSpiritColors.background.withOpacity(0.95),
  selectedItemColor: CricketSpiritColors.primary,
  unselectedItemColor: CricketSpiritColors.mutedForeground,
  type: BottomNavigationBarType.fixed,
  selectedLabelStyle: TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  // Items: Home, Matches, Tournaments, Profile
)
// Height: 64px
// Apply: BackdropFilter with blur
```

### Grid Layouts

```dart
// Tournament Cards Grid
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3, // 1 on mobile, 2 on tablet, 3 on desktop
    crossAxisSpacing: 24,
    mainAxisSpacing: 24,
    childAspectRatio: 0.85,
  ),
);

// Stats Grid
GridView.count(
  crossAxisCount: 4, // 2 on mobile
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
);
```

### Responsive Breakpoints

```dart
class CricketSpiritBreakpoints {
  static const double mobile = 0;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1280;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;
      
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;
      
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}
```

### Container Max Widths

```dart
class CricketSpiritContainers {
  static const double maxWidthSm = 640;   // Small forms
  static const double maxWidthMd = 768;   // Match detail
  static const double maxWidthLg = 1024;  // Lists
  static const double maxWidthXl = 1280;  // Full pages
  static const double maxWidthFull = double.infinity;
}
```

---

## 8. Custom Utilities & Effects

### Glass Card Effect

```dart
Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: CardStyles.glassCard,
        child: child,
      ),
    ),
  );
}
```

### Gradient Text

```dart
Widget gradientText(String text, TextStyle style) {
  return ShaderMask(
    shaderCallback: (bounds) => CricketSpiritGradients.primaryTextGradient
        .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
    child: Text(
      text,
      style: style.copyWith(color: Colors.white),
    ),
  );
}
```

### Ball Event Indicator

```dart
Widget ballEventIndicator(String value) {
  Color bgColor;
  Color textColor = CricketSpiritColors.foreground;
  
  if (value == 'W') {
    bgColor = CricketSpiritColors.error;
  } else if (value == '4' || value == '6') {
    bgColor = CricketSpiritColors.primary;
    textColor = CricketSpiritColors.primaryForeground;
  } else if (value.contains('wd') || value.contains('nb')) {
    bgColor = CricketSpiritColors.warning.withOpacity(0.2);
    textColor = CricketSpiritColors.warning;
  } else {
    bgColor = CricketSpiritColors.white10;
  }
  
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
      border: value.contains('wd') || value.contains('nb')
          ? Border.all(color: CricketSpiritColors.warning.withOpacity(0.5))
          : null,
    ),
    child: Center(
      child: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: textColor,
        ),
      ),
    ),
  );
}
```

### Striker Indicator

```dart
Widget strikerIndicator() {
  return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: CricketSpiritColors.primary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: CricketSpiritColors.primary.withOpacity(0.5),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    ),
  );
  // Note: Wrap with AnimatedContainer for pulse effect
}
```

---

## 9. Status Indicators

### Match Status

| Status | Background | Text Color | Animation |
|--------|------------|------------|-----------|
| LIVE | `primary` | `primaryForeground` | Pulse |
| UPCOMING | `white10` | `foreground` | None |
| COMPLETED | `white10` | `mutedForeground` | None |
| CANCELLED | `error.withOpacity(0.1)` | `error` | None |

### Commentary Event Types

| Type | Background | Border | Icon/Indicator |
|------|------------|--------|----------------|
| Boundary (4/6) | `primary.withOpacity(0.1)` | `primary.withOpacity(0.3)` | Primary text |
| Wicket | `error.withOpacity(0.1)` | `error.withOpacity(0.3)` | Red badge |
| Normal | `white5` | `white5` | None |
| Dot | `white5` | `white5` | None |

### Free Hit Indicator

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: CricketSpiritColors.freeHitYellow,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    'FREE HIT',
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  ),
)
// Add: AnimatedOpacity for pulsing effect
```

---

## 10. Flutter Implementation Guide

### Theme Setup

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData cricketSpiritTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Colors
    colorScheme: ColorScheme.dark(
      primary: CricketSpiritColors.primary,
      onPrimary: CricketSpiritColors.primaryForeground,
      secondary: CricketSpiritColors.secondary,
      onSecondary: CricketSpiritColors.secondaryForeground,
      surface: CricketSpiritColors.card,
      onSurface: CricketSpiritColors.foreground,
      error: CricketSpiritColors.error,
      onError: CricketSpiritColors.foreground,
    ),
    scaffoldBackgroundColor: CricketSpiritColors.background,
    
    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.teko(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: CricketSpiritColors.foreground,
      ),
      displayMedium: GoogleFonts.teko(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: CricketSpiritColors.foreground,
      ),
      displaySmall: GoogleFonts.teko(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: CricketSpiritColors.foreground,
      ),
      headlineLarge: GoogleFonts.teko(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: CricketSpiritColors.foreground,
      ),
      headlineMedium: GoogleFonts.teko(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: CricketSpiritColors.foreground,
      ),
      headlineSmall: GoogleFonts.teko(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: CricketSpiritColors.foreground,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CricketSpiritColors.foreground,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: CricketSpiritColors.foreground,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CricketSpiritColors.foreground,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: CricketSpiritColors.foreground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CricketSpiritColors.foreground,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: CricketSpiritColors.mutedForeground,
      ),
      labelLarge: GoogleFonts.barlowCondensed(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: CricketSpiritColors.primary,
      ),
      labelMedium: GoogleFonts.barlowCondensed(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: CricketSpiritColors.mutedForeground,
      ),
      labelSmall: GoogleFonts.barlowCondensed(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: CricketSpiritColors.mutedForeground,
      ),
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: CricketSpiritColors.background.withOpacity(0.8),
      foregroundColor: CricketSpiritColors.foreground,
      elevation: 0,
      titleTextStyle: GoogleFonts.teko(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: CricketSpiritColors.foreground,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: CricketSpiritColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        side: BorderSide(color: CricketSpiritColors.border),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CricketSpiritColors.white5,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(color: CricketSpiritColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(color: CricketSpiritColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        borderSide: BorderSide(color: CricketSpiritColors.ring),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: CricketSpiritColors.mutedForeground,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CricketSpiritColors.primary,
        foregroundColor: CricketSpiritColors.primaryForeground,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CricketSpiritColors.foreground,
        side: BorderSide(color: CricketSpiritColors.border),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CricketSpiritColors.primary,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: CricketSpiritColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CricketSpiritRadius.dialog),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CricketSpiritColors.foreground,
      ),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: CricketSpiritColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CricketSpiritRadius.bottomSheet),
        ),
      ),
    ),
    
    // Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelColor: CricketSpiritColors.primary,
      unselectedLabelColor: CricketSpiritColors.mutedForeground,
      indicatorColor: CricketSpiritColors.primary,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: CricketSpiritColors.white10,
      thickness: 1,
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(CricketSpiritColors.background),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CricketSpiritColors.primary;
        }
        return CricketSpiritColors.input;
      }),
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: CricketSpiritColors.primary,
      linearTrackColor: CricketSpiritColors.primary.withOpacity(0.2),
    ),
  );
}
```

### Recommended Packages

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
    
  # Fonts
  google_fonts: ^6.1.0
  
  # Icons
  lucide_icons: ^0.257.0
  
  # State Management (choose one)
  flutter_riverpod: ^2.4.0
  # OR provider: ^6.1.0
  # OR flutter_bloc: ^8.1.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Animations
  flutter_animate: ^4.3.0
  
  # Effects
  glassmorphism: ^3.0.0
  shimmer: ^3.0.0
  
  # HTTP & Data
  dio: ^5.4.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  
  # Storage
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0
  
  # Utilities
  intl: ^0.18.0
  cached_network_image: ^3.3.0
```

---

## Quick Reference Card

### Color Hex Values

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0F172A` | App background |
| `foreground` | `#F8FAFC` | Primary text |
| `card` | `#1E293B` | Card backgrounds |
| `primary` | `#CDFF2F` | Accents, buttons, highlights |
| `muted` | `#374151` | Secondary backgrounds |
| `mutedForeground` | `#94A3B8` | Secondary text |
| `border` | `#334155` | Borders, dividers |
| `error` | `#EF4444` | Error states |

### Font Stack

| Purpose | Font | Weight |
|---------|------|--------|
| Headings, Scores | Teko | 700 |
| Body Text | Inter | 400-600 |
| Labels, Tags | Barlow Condensed | 600-700 |
| Technical Data | JetBrains Mono | 400 |

### Key Dimensions

| Element | Value |
|---------|-------|
| Border Radius (default) | 8px |
| Border Radius (card) | 12px |
| Border Radius (button) | 8px |
| Header Height | 64px |
| Bottom Nav Height | 64px |
| Button Height (default) | 36px |
| Input Height | 36px |

---

## Brand Assets

### Logo Treatment

- **Icon Mark**: Circle with "CS" initials
  - Background: `primary` (#CDFF2F)
  - Text: `background` (#0F172A)
  - Font: Teko Bold
  
- **Wordmark**: "CRICKET" (white) + "SPIRIT" (primary)
  - Font: Teko Bold
  - Letter Spacing: 1-2px
  - Transform: UPPERCASE

### App Tagline

> "The Spirit of the Game"

---

**Document Created:** December 2024  
**For:** Cricket Spirit Flutter App Development  
**Source:** Spirit-Design Web Prototype

