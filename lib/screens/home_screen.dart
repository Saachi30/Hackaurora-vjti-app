import 'package:flutter/material.dart';
import 'package:hackaurora_vjti/screens/product_journey_screen.dart';
import 'package:hackaurora_vjti/screens/chatbot_screen.dart';
import 'package:hackaurora_vjti/screens/qr_scanner_screen.dart';
import 'package:hackaurora_vjti/screens/arvr_scanner_screen.dart';
import 'package:hackaurora_vjti/utils/dummy_data.dart';
import 'package:hackaurora_vjti/providers/accessibility_provider.dart';
import 'package:provider/provider.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  const DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.blue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  bool isAuthenticated() {
    // Replace with your actual authentication check
    return true;
  }

  void _handleNavigation(BuildContext context, String route, bool requiresAuth, {Widget? screen}) {
    if (requiresAuth && !isAuthenticated()) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final dashboardItems = [
      {
        'icon': Icons.search,
        'title': 'Search Products',
        'route': '/search-products',
        'requiresAuth': false,
        'iconColor': Colors.blue,
        'screen': null,
      },
      {
        'icon': Icons.qr_code_scanner,
        'title': 'Product Tracking',
        'route': '/qr-scanner',
        'requiresAuth': true,
        'iconColor': Colors.green,
        'screen': QRScannerScreen(),
      },
      {
        'icon': Icons.history,
        'title': 'Order History',
        'route': '/order-history',
        'requiresAuth': true,
        'iconColor': Colors.orange,
        'screen': null,
      },
      {
        'icon': Icons.leaderboard,
        'title': 'Leaderboard',
        'route': '/leaderboard',
        'requiresAuth': true,
        'iconColor': Colors.purple,
        'screen': null,
      },
      {
        'icon': Icons.notifications,
        'title': 'Notices',
        'route': '/notices',
        'requiresAuth': true,
        'iconColor': Colors.red,
        'screen': null,
      },
      {
        'icon': Icons.eco,
        'title': 'Environmental Impact',
        'route': '/environmental-impact',
        'requiresAuth': true,
        'iconColor': Colors.green,
        'screen': null,
      },
    ];
    return Consumer<AccessibilityProvider>(
    builder: (context, accessibilityProvider, child) {
    return Scaffold(
      appBar: AppBar(
            title: const Text('GreenTrack'),
            actions: [
              IconButton(
                icon: Icon(
                  accessibilityProvider.isBlindModeEnabled 
                    ? Icons.accessibility 
                    : Icons.accessibility_new,
                ),
                onPressed: () {
                  accessibilityProvider.toggleBlindMode();
                },
                tooltip: 'Toggle Blind Mode',
              ),
            ],
          ),
          body: GestureDetector(
            onLongPress: () {
              if (accessibilityProvider.isBlindModeEnabled) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              }
            },
        //   body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       Colors.green[50]!,
        //       Colors.blue[50]!,
        //     ],
        //   ),
        // ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ARProductScannerScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8, // Changed from 2.5 to 1.8 for taller cards
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return DashboardCard(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    iconColor: item['iconColor'] as Color,
                    onTap: () => _handleNavigation(
                      context,
                      item['route'] as String,
                      item['requiresAuth'] as bool,
                      screen: item['screen'] as Widget?,
                    ),
                  );
                
                },
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Impact',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Green Score',
                              '85/100',
                              Colors.green[50]!,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Verified Purchases',
                              '24',
                              Colors.blue[50]!,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Carbon Saved',
                              '142 kg',
                              Colors.purple[50]!,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  const FloatingChatButton()),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
    }
    );
    
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}