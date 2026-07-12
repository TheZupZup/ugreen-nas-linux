import 'package:flutter/material.dart';

import 'features/installer/presentation/installer_page.dart';

class UgreenNasLinuxApp extends StatelessWidget {
  const UgreenNasLinuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UGREEN NAS for Linux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E9B4B)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF70D88A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const InstallerPage(),
    );
  }
}
