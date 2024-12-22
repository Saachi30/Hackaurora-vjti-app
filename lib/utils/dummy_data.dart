import 'package:hackaurora_vjti/models/product.dart';
import 'package:hackaurora_vjti/models/scan_history.dart';

class DummyData {
  static final List<ScanHistory> scanHistory = [
    ScanHistory(
      productName: 'Oxycool Drinking Water',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Verified',
    ),
    ScanHistory(
      productName: 'Fair Trade Coffee Beans',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Verified',
    ),
  ];

  static final Product currentProduct = Product(
    id: 'PRD001',
    name: 'Oxycool Drinking Water',
    category: 'Beverages',
  );

  static final List<JourneyStep> journeySteps = [
    JourneyStep(
      title: 'Raw Material Sourcing',
      description: 'Design bottle',
      location: 'Gujarat, India',
    ),
    JourneyStep(
      title: 'Processing',
      description: 'Bottle and label processing',
      location: 'Mumbai, India',
    ),
    JourneyStep(
      title: 'Manufacturing',
      description: 'Filling water with ethical labor practices',
      location: 'Bangalore, India',
    ),
    JourneyStep(
      title: 'Distribution',
      description: 'Eco-friendly shipping to retail centers',
      location: 'Multiple Locations',
    ),
  ];

  static final List<CarbonData> carbonData = [
    CarbonData(stage: 'Raw', emission: 2.5),
    CarbonData(stage: 'Process', emission: 1.8),
    CarbonData(stage: 'Manufac', emission: 3.2),
    CarbonData(stage: 'Distrib', emission: 2.1),
  ];
}

class JourneyStep {
  final String title;
  final String description;
  final String location;

  JourneyStep({
    required this.title,
    required this.description,
    required this.location,
  });
}

class CarbonData {
  final String stage;
  final double emission;

  CarbonData({
    required this.stage,
    required this.emission,
  });
}