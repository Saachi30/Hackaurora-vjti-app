import 'package:flutter/material.dart';
import 'package:hackaurora_vjti/config/theme.dart';
import 'package:hackaurora_vjti/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:hackaurora_vjti/providers/accessibility_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: const SupplyChainApp(),
    ),
  );
}

class SupplyChainApp extends StatelessWidget {
  const SupplyChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethical Supply Chain',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}