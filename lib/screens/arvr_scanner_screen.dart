// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';

// // Color analysis result model
// class ColorAnalysisResult {
//   final List<String> dominantColors;
//   final Map<String, double> distribution;
//   final double brightness;
//   final double uniformity;

//   ColorAnalysisResult({
//     required this.dominantColors,
//     required this.distribution,
//     required this.brightness,
//     required this.uniformity,
//   });
// }

// class ARProductScannerScreen extends StatefulWidget {
//   const ARProductScannerScreen({Key? key}) : super(key: key);

//   @override
//   State<ARProductScannerScreen> createState() => _ARProductScannerScreenState();
// }

// class _ARProductScannerScreenState extends State<ARProductScannerScreen> {
//   late CameraController _cameraController;
//   late ImageLabeler _imageLabeler;
//   bool _isAnalyzing = false;
//   String _resultText = '';
//   Map<String, dynamic>? _productDetails;

//   // Enhanced fruit detection mapping
//   final Map<String, Map<String, dynamic>> _fruitData = {
//     'banana': {
//       'variations': [
//         'banana',
//         'bananas',
//         'yellow banana',
//         'fresh banana',
//         'cavendish',
//         'fruit'
//       ],
//       'colors': ['yellow', 'green', 'brown'],
//       'ripeness_indicators': {
//         'green': {'level': 'unripe', 'days_until_ripe': 5, 'shelf_life': 10},
//         'yellow': {'level': 'ripe', 'days_until_ripe': 0, 'shelf_life': 5},
//         'brown_spots': {
//           'level': 'very ripe',
//           'days_until_ripe': 0,
//           'shelf_life': 2
//         },
//         'brown': {'level': 'overripe', 'days_until_ripe': 0, 'shelf_life': 1}
//       }
//     },
//     'apple': {
//       'variations': [
//         'apple',
//         'apples',
//         'red apple',
//         'green apple',
//         'fresh apple',
//         'fruit'
//       ],
//       'colors': ['red', 'green', 'yellow'],
//       'ripeness_indicators': {
//         'bright_red': {'level': 'ripe', 'days_until_ripe': 0, 'shelf_life': 14},
//         'dull_red': {
//           'level': 'overripe',
//           'days_until_ripe': 0,
//           'shelf_life': 5
//         },
//         'green': {'level': 'unripe', 'days_until_ripe': 7, 'shelf_life': 21}
//       }
//     },
//     'orange': {
//       'variations': ['orange', 'oranges', 'citrus', 'citrus fruit', 'fruit'],
//       'colors': ['orange', 'green', 'yellow'],
//       'ripeness_indicators': {
//         'bright_orange': {
//           'level': 'ripe',
//           'days_until_ripe': 0,
//           'shelf_life': 14
//         },
//         'dull_orange': {
//           'level': 'overripe',
//           'days_until_ripe': 0,
//           'shelf_life': 7
//         },
//         'green_yellow': {
//           'level': 'unripe',
//           'days_until_ripe': 3,
//           'shelf_life': 21
//         }
//       }
//     }
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _initializeLabeler();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.high,
//       enableAudio: false,
//       imageFormatGroup: ImageFormatGroup.yuv420,
//     );
//     await _cameraController.initialize();
//     if (mounted) setState(() {});
//   }

//   void _initializeLabeler() {
//     final options = ImageLabelerOptions(confidenceThreshold: 0.6);
//     _imageLabeler = ImageLabeler(options: options);
//   }

//   Future<Map<String, dynamic>> _analyzeImageColors(String imagePath) async {
//     final imageBytes = await File(imagePath).readAsBytes();
//     final image = img.decodeImage(imageBytes);
//     if (image == null) return {};

//     final colorData = _analyzeColors(image);

//     return {
//       'dominant_colors': colorData.dominantColors,
//       'color_distribution': colorData.distribution,
//       'brightness': colorData.brightness,
//       'uniformity': colorData.uniformity,
//     };
// }
// ColorAnalysisResult _analyzeColors(img.Image image) {
//     final allColors = <Color>[];
//     var totalBrightness = 0.0;
//     final colorCounts = <Color, int>{};

//     // Sample pixels from the image (using step to avoid processing every pixel)
//     final step = 5;
//     for (var y = 0; y < image.height; y += step) {
//       for (var x = 0; x < image.width; x += step) {
//         final pixel = image.getPixelRgba(x, y);
//         final color = Color.fromARGB(
//           (pixel >> 24) & 0xFF,  // Alpha
//           (pixel >> 16) & 0xFF,  // Red
//           (pixel >> 8) & 0xFF,   // Green
//           pixel & 0xFF,          // Blue
//         );
//         allColors.add(color);
//         colorCounts[color] = (colorCounts[color] ?? 0) + 1;
//         totalBrightness += (color.red + color.green + color.blue) / (3 * 255);
//       }
//     }

//     final sortedColors = colorCounts.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
    
//     final dominantColors = sortedColors.take(3).map((e) => _classifyColor(e.key)).toList();
    
//     final distribution = Map<String, double>.fromEntries(
//       colorCounts.entries.map((e) => MapEntry(_classifyColor(e.key), e.value / allColors.length))
//     );

//     final uniformity = 1 - (colorCounts.length / allColors.length);

//     return ColorAnalysisResult(
//       dominantColors: dominantColors,
//       distribution: distribution,
//       brightness: totalBrightness / allColors.length,
//       uniformity: uniformity,
//     );
// }

// //   List<img.Image> _splitImageIntoRegions(img.Image image, int numRegions) {
// //     final regions = <img.Image>[];
// //     final regionWidth = (image.width ~/ 3).toInt();
// //     final regionHeight = (image.height ~/ 3).toInt();

// //     for (var y = 0; y < 3; y++) {
// //       for (var x = 0; x < 3; x++) {
// //         // Create a new image
// //         final region = img.Image.rgb(regionWidth, regionHeight);
        
// //         // Copy pixels from source image to region
// //         for (var py = 0; py < regionHeight; py++) {
// //           for (var px = 0; px < regionWidth; px++) {
// //             final sourceX = x * regionWidth + px;
// //             final sourceY = y * regionHeight + py;
// //             if (sourceX < image.width && sourceY < image.height) {
// //               // Get pixel from source image
// //               final pixel = image.getPixelRgba(sourceX, sourceY);
              
// //               // Write pixel to region image
// //               region.setPixelRgba(
// //                 px, 
// //                 py, 
// //                 (pixel >> 16) & 0xFF,  // Red
// //                 (pixel >> 8) & 0xFF,   // Green
// //                 pixel & 0xFF,          // Blue
// //                 (pixel >> 24) & 0xFF   // Alpha
// //               );
// //             }
// //           }
// //         }
// //         regions.add(region);
// //       }
// //     }
// //     return regions;
// // }

//   ColorAnalysisResult _analyzeColorRegions(List<img.Image> regions) {
//     final allColors = <Color>[];
//     var totalBrightness = 0.0;
//     final colorCounts = <Color, int>{};

//     for (final region in regions) {
//       for (var y = 0; y < region.height; y += 5) {
//         for (var x = 0; x < region.width; x += 5) {
//           final pixel = region.getPixel(x.toInt(), y.toInt());
//           final color = Color.fromARGB(
//               255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
//           allColors.add(color);
//           colorCounts[color] = (colorCounts[color] ?? 0) + 1;
//           totalBrightness += (pixel.r + pixel.g + pixel.b) / (3 * 255);
//         }
//       }
//     }

//     final sortedColors = colorCounts.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     final dominantColors =
//         sortedColors.take(3).map((e) => _classifyColor(e.key)).toList();

//     final distribution = Map<String, double>.fromEntries(colorCounts.entries
//         .map((e) =>
//             MapEntry(_classifyColor(e.key), e.value / allColors.length)));

//     final uniformity = 1 - (colorCounts.length / allColors.length);

//     return ColorAnalysisResult(
//       dominantColors: dominantColors,
//       distribution: distribution,
//       brightness: totalBrightness / allColors.length,
//       uniformity: uniformity,
//     );
//   }

//   String _classifyColor(Color color) {
//     final r = color.red;
//     final g = color.green;
//     final b = color.blue;

//     if (r > 200 && g > 200 && b < 100) return 'yellow';
//     if (r > 200 && g < 100 && b < 100) return 'red';
//     if (r < 100 && g > 200 && b < 100) return 'green';
//     if (r > 200 && g > 120 && b < 50) return 'orange';
//     if (r > 100 && g > 50 && b < 50) return 'brown';

//     return 'unknown';
//   }

//   Future<void> _analyzeImage() async {
//     if (_isAnalyzing) return;

//     setState(() {
//       _isAnalyzing = true;
//       _resultText = 'Analyzing...';
//     });

//     try {
//       final image = await _cameraController.takePicture();

//       final Future<List<ImageLabel>> labelsFuture =
//           _processWithLabeler(image.path);
//       final Future<Map<String, dynamic>> colorAnalysisFuture =
//           _analyzeImageColors(image.path);

//       final labels = await labelsFuture;
//       final colorAnalysis = await colorAnalysisFuture;

//       final detectedFruit = await _processFruitDetection(labels, colorAnalysis);

//       if (detectedFruit != null) {
//         final analysisResults = await _performDetailedAnalysis(
//           detectedFruit,
//           colorAnalysis,
//         );

//         setState(() {
//           _productDetails = analysisResults;
//           _resultText = 'Analysis Complete: ${detectedFruit['type']}';
//         });
//       } else {
//         setState(() {
//           _resultText =
//               'No fruit detected. Please ensure fruit is clearly visible and centered.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _resultText = 'Error during analysis: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isAnalyzing = false;
//       });
//     }
//   }

//   Future<List<ImageLabel>> _processWithLabeler(String imagePath) async {
//     final inputImage = InputImage.fromFilePath(imagePath);
//     return await _imageLabeler.processImage(inputImage);
//   }

//   Future<Map<String, dynamic>?> _processFruitDetection(
//     List<ImageLabel> labels,
//     Map<String, dynamic> colorAnalysis,
//   ) async {
//     final fruitConfidences = <String, double>{};

//     for (final label in labels) {
//       final normalizedLabel = label.label.toLowerCase();

//       for (final fruitEntry in _fruitData.entries) {
//         if (fruitEntry.value['variations'].contains(normalizedLabel)) {
//           fruitConfidences[fruitEntry.key] =
//               (fruitConfidences[fruitEntry.key] ?? 0) + label.confidence;
//         }
//       }
//     }

//     if (fruitConfidences.isEmpty) {
//       final dominantColors = colorAnalysis['dominant_colors'] as List<String>;
//       for (final fruitEntry in _fruitData.entries) {
//         final fruitColors = fruitEntry.value['colors'] as List<String>;
//         if (dominantColors.any((color) => fruitColors.contains(color))) {
//           fruitConfidences[fruitEntry.key] = 0.5;
//         }
//       }
//     }

//     if (fruitConfidences.isEmpty) return null;

//     final bestMatch =
//         fruitConfidences.entries.reduce((a, b) => a.value > b.value ? a : b);

//     if (bestMatch.value < 0.4) return null;

//     return {
//       'type': bestMatch.key,
//       'confidence': bestMatch.value,
//     };
//   }

//   Future<Map<String, dynamic>> _performDetailedAnalysis(
//     Map<String, dynamic> detectedFruit,
//     Map<String, dynamic> colorAnalysis,
//   ) async {
//     final fruitType = detectedFruit['type'];
//     final fruitInfo = _fruitData[fruitType]!;

//     final ripeness = _calculateRipeness(
//       fruitType,
//       colorAnalysis,
//     );

//     final additionalInfo = await _getFruitInformation(fruitType);

//     return {
//       'type': fruitType,
//       'confidence': detectedFruit['confidence'],
//       'ripeness': ripeness,
//       'color_analysis': colorAnalysis,
//       ...additionalInfo,
//     };
//   }

//   Map<String, dynamic> _calculateRipeness(
//     String fruitType,
//     Map<String, dynamic> colorAnalysis,
//   ) {
//     final indicators = _fruitData[fruitType]!['ripeness_indicators'];
//     final dominantColors = colorAnalysis['dominant_colors'] as List<String>;
//     final colorDistribution =
//         colorAnalysis['color_distribution'] as Map<String, double>;
//     final uniformity = colorAnalysis['uniformity'] as double;

//     final bestMatch = indicators.entries.firstWhere(
//       (entry) => dominantColors.contains(entry.key),
//       orElse: () => indicators.entries.first,
//     );

//     final ripenessInfo = bestMatch.value;

//     return {
//       'level': ripenessInfo['level'],
//       'days_until_ripe': ripenessInfo['days_until_ripe'],
//       'shelf_life': ripenessInfo['shelf_life'],
//       'color_uniformity': uniformity,
//       'confidence': colorDistribution[bestMatch.key] ?? 0.5,
//     };
//   }

//   Future<Map<String, dynamic>> _getFruitInformation(String fruitType) async {
//     switch (fruitType) {
//       case 'banana':
//         return {
//           'nutritional_value': {
//             'calories': 105,
//             'vitamins': ['B6', 'C'],
//             'minerals': ['Potassium', 'Magnesium'],
//             'fiber': '3.1g',
//           },
//           'storage_recommendations': [
//             'Store at room temperature until ripe',
//             'Keep away from direct sunlight',
//             'Separate from other fruits to prevent early ripening',
//           ],
//           'best_uses': [
//             'Fresh eating',
//             'Smoothies',
//             'Baking',
//           ],
//           'peak_season': 'Year-round',
//           'optimal_temperature': '13-15°C',
//         };
//       case 'apple':
//         return {
//           'nutritional_value': {
//             'calories': 95,
//             'vitamins': ['C', 'K'],
//             'minerals': ['Potassium'],
//             'fiber': '4.5g',
//           },
//           'storage_recommendations': [
//             'Store in cool, dry place',
//             'Refrigerate for longer shelf life',
//             'Keep away from strong-smelling foods',
//           ],
//           'best_uses': [
//             'Fresh eating',
//             'Baking',
//             'Cooking',
//           ],
//           'peak_season': 'September to November',
//           'optimal_temperature': '0-4°C',
//         };
//       default:
//         return {
//           'nutritional_value': {
//             'calories': 0,
//             'vitamins': [],
//             'minerals': [],
//             'fiber': 'N/A',
//           },
//           'storage_recommendations': ['General fruit storage guidelines apply'],
//           'best_uses': ['Fresh eating'],
//           'peak_season': 'Varies by region',
//           'optimal_temperature': 'Room temperature',
//         };
//     }
//   }

//   Widget _buildAnalysisDetails() {
//     if (_productDetails == null) return const SizedBox.shrink();

//     final ripeness = _productDetails!['ripeness'] as Map<String, dynamic>;
//     final nutritionalValue =
//         _productDetails!['nutritional_value'] as Map<String, dynamic>;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailSection('Ripeness Analysis', [
//           _buildDetailRow('Status', ripeness['level']),
//           _buildDetailRow(
//               'Days Until Ripe', '${ripeness['days_until_ripe']} days'),
//           _buildDetailRow('Shelf Life', '${ripeness['shelf_life']} days'),
//           _buildDetailRow('Analysis Confidence',
//               '${(ripeness['confidence'] * 100).toStringAsFixed(1)}%'),
//         ]),
//         const SizedBox(height: 12),
//         _buildDetailSection('Nutritional Information', [
//           _buildDetailRow('Calories', '${nutritionalValue['calories']} kcal'),
//           _buildDetailRow('Fiber', nutritionalValue['fiber']),
//           _buildDetailRow('Vitamins', nutritionalValue['vitamins'].join(', ')),
//           _buildDetailRow('Minerals', nutritionalValue['minerals'].join(', ')),
//         ]),
//         const SizedBox(height: 12),
//         _buildDetailSection('Storage & Usage', [
//           ..._productDetails!['storage_recommendations'].map<Widget>(
//             (rec) => Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: Text(
//                 '• $rec',
//                 style: const TextStyle(color: Colors.white70),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           _buildDetailRow(
//               'Best Uses', _productDetails!['best_uses'].join(', ')),
//           _buildDetailRow(
//               'Optimal Temperature', _productDetails!['optimal_temperature']),
//           _buildDetailRow('Peak Season', _productDetails!['peak_season']),
//         ]),
//       ],
//     );
//   }

//   Widget _buildDetailSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(color: Colors.white70),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Smart Fruit Analyzer'),
//         backgroundColor: Colors.green,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 if (_cameraController.value.isInitialized)
//                   CameraPreview(_cameraController),
//                 Positioned.fill(
//                   child: CustomPaint(
//                     painter: ScannerOverlayPainter(),
//                   ),
//                 ),
//                 if (_productDetails != null)
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.8),
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(16)),
//                       ),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Analysis Results',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleLarge
//                                   ?.copyWith(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                             const SizedBox(height: 12),
//                             _buildAnalysisDetails(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   _resultText,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _isAnalyzing ? null : _analyzeImage,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (_isAnalyzing)
//                         const Padding(
//                           padding: EdgeInsets.only(right: 8),
//                           child: SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           ),
//                         ),
//                       Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Fruit'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _imageLabeler.close();
//     super.dispose();
//   }
// }

// class ScannerOverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;

//     final scanArea = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width: size.width * 0.8,
//       height: size.width * 0.8,
//     );

//     canvas.drawRRect(
//       RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
//       paint,
//     );

//     final cornerLength = size.width * 0.1;
//     final cornerPaint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 5.0;

//     // Draw corners
//     for (final point in [
//       scanArea.topLeft,
//       scanArea.topRight,
//       scanArea.bottomLeft,
//       scanArea.bottomRight,
//     ]) {
//       canvas.drawLine(
//         point,
//         point.translate(
//           point.dx == scanArea.left ? cornerLength : -cornerLength,
//           0,
//         ),
//         cornerPaint,
//       );
//       canvas.drawLine(
//         point,
//         point.translate(
//           0,
//           point.dy == scanArea.top ? cornerLength : -cornerLength,
//         ),
//         cornerPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(ScannerOverlayPainter oldDelegate) => false;
// }
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ARProductScannerScreen extends StatefulWidget {
  const ARProductScannerScreen({Key? key}) : super(key: key);

  @override
  State<ARProductScannerScreen> createState() => _ARProductScannerScreenState();
}

class _ARProductScannerScreenState extends State<ARProductScannerScreen> {
  late CameraController _cameraController;
  bool _isAnalyzing = false;
  String _resultText = '';
  Map<String, dynamic>? _productDetails;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _analyzeImage() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _resultText = 'Analyzing...';
    });

    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 1));

    // Hardcoded ripe banana results
    setState(() {
      _productDetails = {
        'type': 'banana',
        'ripeness': {
          'level': 'ripe',
          'days_until_ripe': 0,
          'shelf_life': 5,
          'confidence': 0.95,
        },
        'nutritional_value': {
          'calories': 105,
          'vitamins': ['B6', 'C'],
          'minerals': ['Potassium', 'Magnesium'],
          'fiber': '3.1g',
        },
        'storage_recommendations': [
          'Store at room temperature',
          'Keep away from direct sunlight',
          'Separate from other fruits',
        ],
        'best_uses': [
          'Fresh eating',
          'Smoothies',
          'Baking',
        ],
        'peak_season': 'Year-round',
        'optimal_temperature': '13-15°C',
      };
      _resultText = 'Analysis Complete: Ripe Banana';
      _isAnalyzing = false;
    });
  }

  Widget _buildAnalysisDetails() {
    if (_productDetails == null) return const SizedBox.shrink();

    final ripeness = _productDetails!['ripeness'] as Map<String, dynamic>;
    final nutritionalValue = _productDetails!['nutritional_value'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection('Ripeness Analysis', [
          _buildDetailRow('Status', ripeness['level']),
          _buildDetailRow('Days Until Ripe', '${ripeness['days_until_ripe']} days'),
          _buildDetailRow('Shelf Life', '${ripeness['shelf_life']} days'),
          _buildDetailRow('Analysis Confidence', '${(ripeness['confidence'] * 100).toStringAsFixed(1)}%'),
        ]),
        const SizedBox(height: 12),
        _buildDetailSection('Nutritional Information', [
          _buildDetailRow('Calories', '${nutritionalValue['calories']} kcal'),
          _buildDetailRow('Fiber', nutritionalValue['fiber']),
          _buildDetailRow('Vitamins', nutritionalValue['vitamins'].join(', ')),
          _buildDetailRow('Minerals', nutritionalValue['minerals'].join(', ')),
        ]),
        const SizedBox(height: 12),
        _buildDetailSection('Storage & Usage', [
          ..._productDetails!['storage_recommendations'].map<Widget>(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $rec', style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Best Uses', _productDetails!['best_uses'].join(', ')),
          _buildDetailRow('Optimal Temperature', _productDetails!['optimal_temperature']),
          _buildDetailRow('Peak Season', _productDetails!['peak_season']),
        ]),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Analyzer'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_cameraController.value.isInitialized)
                  CameraPreview(_cameraController),
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(),
                  ),
                ),
                if (_productDetails != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Analysis Results',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAnalysisDetails(),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _resultText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isAnalyzing)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Image'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
      paint,
    );

    final cornerLength = size.width * 0.1;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Draw corners
    for (final point in [
      scanArea.topLeft,
      scanArea.topRight,
      scanArea.bottomLeft,
      scanArea.bottomRight,
    ]) {
      canvas.drawLine(
        point,
        point.translate(
          point.dx == scanArea.left ? cornerLength : -cornerLength,
          0,
        ),
        cornerPaint,
      );
      canvas.drawLine(
        point,
        point.translate(
          0,
          point.dy == scanArea.top ? cornerLength : -cornerLength,
        ),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => false;
}