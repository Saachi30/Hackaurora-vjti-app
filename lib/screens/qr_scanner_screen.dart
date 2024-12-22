import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hackaurora_vjti/screens/product_journey_screen.dart';
import 'package:hackaurora_vjti/providers/accessibility_provider.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Bar Code'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            // Navigate to product journey with dummy data
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductJourneyScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}