import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/server_provider.dart';
import 'providers/vpn_provider.dart';
import 'views/main_layout.dart';

class CPRayGamingApp extends StatelessWidget {
  const CPRayGamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VpnProvider()),
        ChangeNotifierProvider(create: (_) => ServerProvider()),
      ],
      child: MaterialApp(
        title: 'CPRay Gaming',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF090B10),
          primaryColor: const Color(0xFF00D4FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00D4FF),
            secondary: Color(0xFF00FF88),
            surface: Color(0xFF10131E),
            background: Color(0xFF090B10),
          ),
          fontFamily: 'Segoe UI',
          useMaterial3: true,
        ),
        home: const MainLayout(),
      ),
    );
  }
}
