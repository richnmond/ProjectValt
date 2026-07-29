// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'config/app_theme.dart';
import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/upload_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  final savedTheme = await AdaptiveTheme.getThemeMode();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
      ],
      child: MyApp(savedTheme: savedTheme),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedTheme;
  
  const MyApp({super.key, this.savedTheme});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: savedTheme ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp.router(
        title: 'ProjectVault',
        theme: theme,
        darkTheme: darkTheme,
        routerConfig: AppRouter.createRouter(authProvider),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Remove splash screen after first frame
          FlutterNativeSplash.remove();
          return child!;
        },
      ),
    );
  }
}