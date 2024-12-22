import 'package:flutter/material.dart';
import 'package:hackaurora_vjti/widgets/journey_timeline.dart';
import 'package:hackaurora_vjti/widgets/carbon_emission_chart.dart';
import 'package:hackaurora_vjti/utils/dummy_data.dart';
import 'package:hackaurora_vjti/providers/accessibility_provider.dart';
import 'package:provider/provider.dart';

class JourneyStep {
  final String title;
  final String description;
  final String location;

  const JourneyStep({
    required this.title,
    required this.description,
    required this.location,
  });
}

class ProductJourneyScreen extends StatefulWidget {
  const ProductJourneyScreen({super.key});

  @override
  State<ProductJourneyScreen> createState() => _ProductJourneyScreenState();
}

class _ProductJourneyScreenState extends State<ProductJourneyScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readScreenContent();
    });
  }

  void _readScreenContent() {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context, listen: false);
    if (accessibilityProvider.isBlindModeEnabled) {
      final journeyDetails = journeySteps.map((step) =>
          "Step: ${step.title}, ${step.description}, Location: ${step.location}.").join(" ");

      accessibilityProvider.speak(
        "Product Journey Screen. "
        "Product Information: ${DummyData.currentProduct.name}, "
        "ID: ${DummyData.currentProduct.id}, "
        "Category: ${DummyData.currentProduct.category}. "
        "Supply Chain Journey: $journeyDetails"
      );
    }
  }

  @override
  void dispose() {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context, listen: false);
    accessibilityProvider.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Tracking'),
            actions: [
              IconButton(
                icon: Icon(
                  accessibilityProvider.isBlindModeEnabled
                      ? Icons.accessibility
                      : Icons.accessibility_new,
                ),
                onPressed: () {
                  accessibilityProvider.toggleBlindMode();
                  if (accessibilityProvider.isBlindModeEnabled) {
                    _readScreenContent();
                  }
                },
                tooltip: 'Toggle Blind Mode',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (accessibilityProvider.isBlindModeEnabled) {
                      accessibilityProvider.speak(
                        "Product Information: ${DummyData.currentProduct.name}, "
                        "ID: ${DummyData.currentProduct.id}, "
                        "Category: ${DummyData.currentProduct.category}"
                      );
                    }
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Name: ${DummyData.currentProduct.name}'),
                          Text('ID: ${DummyData.currentProduct.id}'),
                          Text('Category: ${DummyData.currentProduct.category}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Supply Chain Journey',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...journeySteps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        child: ListTile(
                          title: Text(step.title),
                          subtitle: Text('${step.description}\nLocation: ${step.location}'),
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                const Text(
                  'Carbon Emission Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  height: 300,
                  child: CarbonEmissionChart(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
