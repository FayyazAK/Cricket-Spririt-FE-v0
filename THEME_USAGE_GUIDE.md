# 🎨 Cricket Spirit Theme Usage Guide

This guide explains how to use the Cricket Spirit theme system in your Flutter components and widgets.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Importing the Theme](#importing-the-theme)
3. [Using Colors](#using-colors)
4. [Using Typography](#using-typography)
5. [Using Spacing](#using-spacing)
6. [Using Border Radius](#using-border-radius)
7. [Using Gradients](#using-gradients)
8. [Using Shadows](#using-shadows)
9. [Component Examples](#component-examples)
10. [Best Practices](#best-practices)

---

## Quick Start

The theme is already applied globally in `main.dart`. You can access theme values directly or use the Material theme through `Theme.of(context)`.

```dart
import 'package:flutter/material.dart';
import 'theme/theme.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CricketSpiritColors.background,
      child: Text(
        'Hello Cricket Spirit',
        style: CricketSpiritTextStyles.bodyMedium,
      ),
    );
  }
}
```

---

## Importing the Theme

Always import the theme barrel file:

```dart
import 'theme/theme.dart';
```

This gives you access to:
- `CricketSpiritColors`
- `CricketSpiritGradients`
- `CricketSpiritSpacing`
- `CricketSpiritRadius`
- `CricketSpiritShadows`
- `CricketSpiritTextStyles`
- `CricketSpiritDurations`
- `CricketSpiritCurves`
- `CricketSpiritBreakpoints`
- `CricketSpiritIconSizes`

---

## Using Colors

### Direct Color Access

```dart
Container(
  color: CricketSpiritColors.background,      // Deep Navy
  child: Text(
    'Electric Lime Text',
    style: TextStyle(color: CricketSpiritColors.primary),
  ),
)
```

### Common Color Usage

```dart
// Backgrounds
backgroundColor: CricketSpiritColors.background
cardColor: CricketSpiritColors.card

// Text Colors
foreground: CricketSpiritColors.foreground
mutedText: CricketSpiritColors.mutedForeground

// Accents
primary: CricketSpiritColors.primary
error: CricketSpiritColors.error
success: CricketSpiritColors.success
warning: CricketSpiritColors.warning

// Borders
borderColor: CricketSpiritColors.border
```

### Using Theme Colors (Recommended)

For colors that might change with theme updates, use `Theme.of(context)`:

```dart
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: Text(
    'Themed Text',
    style: Theme.of(context).textTheme.bodyMedium,
  ),
)
```

---

## Using Typography

### Direct Text Style Access

```dart
Text(
  'Hero Title',
  style: CricketSpiritTextStyles.heroTitle,
)

Text(
  'Section Title',
  style: CricketSpiritTextStyles.sectionTitle,
)

Text(
  'Body Text',
  style: CricketSpiritTextStyles.bodyMedium,
)

Text(
  'Label',
  style: CricketSpiritTextStyles.sectionLabel,
)
```

### Using Theme Text Styles

```dart
Text(
  'Display Large',
  style: Theme.of(context).textTheme.displayLarge,
)

Text(
  'Body Medium',
  style: Theme.of(context).textTheme.bodyMedium,
)

Text(
  'Label Large',
  style: Theme.of(context).textTheme.labelLarge,
)
```

### Gradient Text

```dart
import 'dart:ui';

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

// Usage
gradientText(
  'CRICKET SPIRIT',
  CricketSpiritTextStyles.heroTitle,
)
```

---

## Using Spacing

### Padding and Margins

```dart
Container(
  padding: EdgeInsets.all(CricketSpiritSpacing.base),  // 16px
  margin: EdgeInsets.symmetric(
    horizontal: CricketSpiritSpacing.lg,  // 24px
    vertical: CricketSpiritSpacing.md,     // 12px
  ),
  child: Text('Spaced Content'),
)
```

### Common Spacing Patterns

```dart
// Card Padding
padding: EdgeInsets.all(CricketSpiritSpacing.cardPadding)  // 24px

// Section Padding
padding: EdgeInsets.all(CricketSpiritSpacing.sectionPadding)  // 40px

// Button Padding
padding: EdgeInsets.symmetric(
  horizontal: CricketSpiritSpacing.buttonPaddingH,  // 16px
  vertical: CricketSpiritSpacing.buttonPaddingV,    // 8px
)

// Input Padding
padding: EdgeInsets.all(CricketSpiritSpacing.inputPadding)  // 12px
```

### Spacing Scale Reference

```dart
CricketSpiritSpacing.xs      // 4px
CricketSpiritSpacing.sm      // 8px
CricketSpiritSpacing.md      // 12px
CricketSpiritSpacing.base    // 16px
CricketSpiritSpacing.lg      // 24px
CricketSpiritSpacing.xl      // 32px
CricketSpiritSpacing.xxl     // 48px
CricketSpiritSpacing.xxxl   // 64px
```

---

## Using Border Radius

### Container Border Radius

```dart
Container(
  decoration: BoxDecoration(
    color: CricketSpiritColors.card,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),  // 12px
  ),
)
```

### Common Radius Usage

```dart
// Cards
borderRadius: BorderRadius.circular(CricketSpiritRadius.card)  // 12px

// Buttons
borderRadius: BorderRadius.circular(CricketSpiritRadius.button)  // 8px

// Inputs
borderRadius: BorderRadius.circular(CricketSpiritRadius.input)  // 8px

// Badges
borderRadius: BorderRadius.circular(CricketSpiritRadius.badge)  // 6px

// Circular (Avatars, Pills)
borderRadius: BorderRadius.circular(CricketSpiritRadius.full)  // 999px
```

---

## Using Gradients

### Linear Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: CricketSpiritGradients.primaryTextGradient,
  ),
)

// Or use directly in widgets
Container(
  decoration: BoxDecoration(
    gradient: CricketSpiritGradients.blueGradient,
  ),
)
```

### Gradient Text Background

```dart
Container(
  decoration: BoxDecoration(
    gradient: CricketSpiritGradients.heroOverlay,
  ),
  child: YourContent(),
)
```

---

## Using Shadows

### Box Shadows

```dart
Container(
  decoration: BoxDecoration(
    color: CricketSpiritColors.card,
    boxShadow: [CricketSpiritShadows.cardShadow],
  ),
)

// Elevated Card
Container(
  decoration: BoxDecoration(
    color: CricketSpiritColors.card,
    boxShadow: [CricketSpiritShadows.elevatedShadow],
  ),
)

// Primary Button Glow
Container(
  decoration: BoxDecoration(
    color: CricketSpiritColors.primary,
    boxShadow: [CricketSpiritShadows.primaryGlow],
  ),
)
```

---

## Component Examples

### Card Component

```dart
Container(
  padding: EdgeInsets.all(CricketSpiritSpacing.cardPadding),
  decoration: BoxDecoration(
    color: CricketSpiritColors.card,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
    border: Border.all(
      color: CricketSpiritColors.border,
      width: 1,
    ),
    boxShadow: [CricketSpiritShadows.cardShadow],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Card Title',
        style: CricketSpiritTextStyles.cardTitle,
      ),
      SizedBox(height: CricketSpiritSpacing.md),
      Text(
        'Card content goes here',
        style: CricketSpiritTextStyles.bodyMedium,
      ),
    ],
  ),
)
```

### Primary Button

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    // Theme already applied, but you can override:
    padding: EdgeInsets.symmetric(
      horizontal: CricketSpiritSpacing.buttonPaddingH,
      vertical: CricketSpiritSpacing.buttonPaddingV,
    ),
  ),
  child: Text('PRIMARY BUTTON'),
)
```

### Outline Button

```dart
OutlinedButton(
  onPressed: () {},
  child: Text('OUTLINE BUTTON'),
)
```

### Text Input

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text...',
    // Theme already applied
  ),
)
```

### Badge Component

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: CricketSpiritSpacing.sm,
    vertical: CricketSpiritSpacing.xs,
  ),
  decoration: BoxDecoration(
    color: CricketSpiritColors.primary,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.badge),
  ),
  child: Text(
    'BADGE',
    style: CricketSpiritTextStyles.metaLabel.copyWith(
      color: CricketSpiritColors.primaryForeground,
    ),
  ),
)
```

### Live Status Badge (with pulse)

```dart
class LiveBadge extends StatefulWidget {
  @override
  _LiveBadgeState createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: CricketSpiritDurations.slower,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: CricketSpiritSpacing.sm,
            vertical: CricketSpiritSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: CricketSpiritColors.primary,
            borderRadius: BorderRadius.circular(CricketSpiritRadius.badge),
            boxShadow: [
              CricketSpiritShadows.liveIndicatorGlow.copyWith(
                blurRadius: 8 * (1 + _controller.value * 0.5),
              ),
            ],
          ),
          child: Text(
            'LIVE',
            style: CricketSpiritTextStyles.metaLabel.copyWith(
              color: CricketSpiritColors.primaryForeground,
            ),
          ),
        );
      },
    );
  }
}
```

### Glass Card Effect

```dart
import 'dart:ui';

Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: CricketSpiritColors.card.withOpacity(0.6),
          borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
          border: Border.all(
            color: CricketSpiritColors.white10,
            width: 1,
          ),
        ),
        child: child,
      ),
    ),
  );
}
```

---

## Best Practices

### 1. Use Theme.of(context) When Possible

Prefer using `Theme.of(context)` for colors and text styles that are part of the Material theme:

```dart
// ✅ Good
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyMedium,
)

// ⚠️ Also fine, but less flexible
Text(
  'Hello',
  style: CricketSpiritTextStyles.bodyMedium,
)
```

### 2. Use Direct Theme Values for Custom Components

For custom components not covered by Material theme, use direct theme values:

```dart
// ✅ Good for custom components
Container(
  padding: EdgeInsets.all(CricketSpiritSpacing.cardPadding),
  decoration: BoxDecoration(
    color: CricketSpiritColors.card,
    borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
  ),
)
```

### 3. Consistent Spacing

Always use spacing constants instead of magic numbers:

```dart
// ✅ Good
SizedBox(height: CricketSpiritSpacing.lg)

// ❌ Bad
SizedBox(height: 24.0)
```

### 4. Typography Hierarchy

Follow the typography hierarchy:
- **Display**: Hero titles, large numbers (Teko)
- **Headline**: Section titles (Teko)
- **Title**: Card titles (Inter)
- **Body**: Content text (Inter)
- **Label**: Tags, badges (Barlow Condensed)
- **Mono**: Technical data (JetBrains Mono)

### 5. Color Semantics

Use semantic color names:
- `primary` for brand actions
- `error` for errors
- `success` for success states
- `warning` for warnings
- `mutedForeground` for secondary text

### 6. Responsive Design

Use breakpoints for responsive layouts:

```dart
if (CricketSpiritBreakpoints.isMobile(context)) {
  // Mobile layout
} else if (CricketSpiritBreakpoints.isTablet(context)) {
  // Tablet layout
} else {
  // Desktop layout
}
```

### 7. Animation Durations

Use duration constants for consistent animations:

```dart
AnimatedContainer(
  duration: CricketSpiritDurations.normal,
  curve: CricketSpiritCurves.easeInOut,
  // ...
)
```

---

## Quick Reference

### Color Cheat Sheet

```dart
CricketSpiritColors.background        // #0F172A - App background
CricketSpiritColors.foreground         // #F8FAFC - Primary text
CricketSpiritColors.card               // #1E293B - Card background
CricketSpiritColors.primary           // #CDFF2F - Electric Lime
CricketSpiritColors.mutedForeground    // #94A3B8 - Secondary text
CricketSpiritColors.border             // #334155 - Borders
CricketSpiritColors.error              // #EF4444 - Error states
```

### Spacing Cheat Sheet

```dart
xs: 4px    sm: 8px    md: 12px   base: 16px
lg: 24px   xl: 32px   xxl: 48px  xxxl: 64px
```

### Radius Cheat Sheet

```dart
sm: 4px    md: 6px    base: 8px   lg: 12px
xl: 16px   xxl: 20px  full: 999px
```

---

## Need Help?

Refer to the main style guide: `FLUTTER_STYLE_GUIDE.md`

For component-specific examples, check the home page implementation: `lib/pages/home_page.dart`

