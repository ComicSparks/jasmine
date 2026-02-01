import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _seedColor = Color(0xFF6750A4);

final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.light,
);

final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.dark,
);

final ThemeData _lightTheme =
    _buildAppTheme(_lightColorScheme, Brightness.light);
final ThemeData _darkTheme = _buildAppTheme(_darkColorScheme, Brightness.dark);

ThemeData get lightTheme => theme != "2" ? _lightTheme : _darkTheme;

ThemeData get darkTheme => theme != "1" ? _darkTheme : _lightTheme;

const _propertyName = "theme";
late String theme = "0";

Map<String, String> _nameMap = {
  "0": "自动 (如果设备支持)",
  "1": "保持亮色",
  "2": "保持暗色",
};

ThemeData _buildAppTheme(ColorScheme scheme, Brightness brightness) {
  final typography = Typography.material2021();
  final textTheme =
      brightness == Brightness.light ? typography.black : typography.white;
  final navLabelStyle = (textTheme.labelSmall ??
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))
      .copyWith(fontWeight: FontWeight.w600);
  final statusBarIconBrightness =
      brightness == Brightness.light ? Brightness.dark : Brightness.light;
  final statusBarBrightness = statusBarIconBrightness;
  final statusBarOverlay = SystemUiOverlayStyle(
    statusBarColor: scheme.surface,
    statusBarIconBrightness: statusBarIconBrightness,
    statusBarBrightness: statusBarBrightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    typography: typography,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: scheme.background,
    dialogBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: statusBarOverlay,
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      foregroundColor: scheme.onSurface,
      elevation: 1,
      centerTitle: true,
      titleTextStyle:
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: scheme.surface,
      elevation: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      indicatorColor: scheme.primaryContainer,
      elevation: 3,
      height: 70,
      labelTextStyle: MaterialStatePropertyAll(navLabelStyle),
      iconTheme: MaterialStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 4,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      surfaceTintColor: scheme.surfaceTint,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle:
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceVariant,
      contentTextStyle: textTheme.bodyMedium
          ?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w500),
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary),
      ),
      labelStyle:
          textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(scheme.secondary),
        foregroundColor: MaterialStatePropertyAll(scheme.onSecondary),
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textStyle: MaterialStatePropertyAll(
          (textTheme.labelLarge ?? const TextStyle(fontWeight: FontWeight.w600))
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(scheme.primary),
        foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textStyle: MaterialStatePropertyAll(
          (textTheme.labelLarge ?? const TextStyle(fontWeight: FontWeight.w600))
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStatePropertyAll(scheme.primary),
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        overlayColor: MaterialStatePropertyAll(scheme.primary.withOpacity(.12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStatePropertyAll(scheme.primary),
        textStyle: MaterialStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceVariant,
      selectedColor: scheme.secondaryContainer,
      secondarySelectedColor: scheme.primaryContainer,
      labelStyle: textTheme.bodyMedium,
      secondaryLabelStyle:
          textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.onSurface.withOpacity(.2),
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withOpacity(.16),
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(scheme.primary),
      trackColor: MaterialStatePropertyAll(scheme.primary.withOpacity(.5)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStatePropertyAll(scheme.primary),
      checkColor: MaterialStatePropertyAll(scheme.onPrimary),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStatePropertyAll(scheme.primary),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 0.8,
    ),
  );
}

Future initTheme() async {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );
  theme = await methods.loadProperty(_propertyName);
  if (theme == "") {
    theme = "0";
  }
  themeEvent.broadcast();
  _reloadBarColor();
}

String themeName() {
  return _nameMap[theme] ?? "-";
}

Future chooseTheme(BuildContext context) async {
  String? choose = await chooseMapDialog(context,
      title: "选择主题",
      values: _nameMap.map((key, value) => MapEntry(value, key)));
  if (choose != null) {
    await methods.saveProperty(_propertyName, choose);
    theme = choose;
    themeEvent.broadcast();
    _reloadBarColor();
  }
}

void reloadBarColor({bool op = false}) {
  _reloadBarColor(op: op);
}

void _reloadBarColor({bool op = false}) {
  if (op) {
    switch (theme) {
      case '0':
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: true,
          systemNavigationBarContrastEnforced: true,
        ));
        break;
      case '1':
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarContrastEnforced: true,
        ));
        break;
      case '2':
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarContrastEnforced: true,
        ));
        break;
    }
  } else {
    switch (theme) {
      case '0':
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: true,
          systemNavigationBarContrastEnforced: true,
        ));
        break;
      case '1':
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarContrastEnforced: true,
        ));
        break;
      case '2':
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black87,
          systemNavigationBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarContrastEnforced: true,
        ));
        break;
    }
  }
}

final themeEvent = Event();

Widget themeSetting(BuildContext context) {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          await chooseTheme(context);
          setState(() => {});
        },
        title: const Text("主题"),
        subtitle: Text(_nameMap[theme] ?? ""),
      );
    },
  );
}
