import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AccessibilityProvider with ChangeNotifier {
  bool _isBlindModeEnabled = false;
  final FlutterTts flutterTts = FlutterTts();

  bool get isBlindModeEnabled => _isBlindModeEnabled;

  void toggleBlindMode() {
    _isBlindModeEnabled = !_isBlindModeEnabled;
    if (_isBlindModeEnabled) {
      speak("Blind mode enabled. Double tap and hold anywhere on the screen to open scanner.");
    } else {
      speak("Blind mode disabled");
    }
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (_isBlindModeEnabled) {
      await flutterTts.speak(text);
    }
  }
  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }
}