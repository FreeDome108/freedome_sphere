
import 'package:flutter/foundation.dart';
import '../models/lyubomir_understanding.dart';

class LyubomirUnderstandingService with ChangeNotifier {
  bool _isEnabled = false;
  LyubomirSettings _settings = LyubomirSettings(enabled: false, enabledTypes: []);
  List<LyubomirUnderstanding> _understandings = [];

  bool get isEnabled => _isEnabled;
  LyubomirSettings get settings => _settings;
  List<LyubomirUnderstanding> get understandings => _understandings;

  void updateSettings(LyubomirSettings newSettings) {
    _settings = newSettings;
    _isEnabled = newSettings.enabled;
    notifyListeners();
  }

  void analyzeContent(String id) {
    // Implement analysis logic here
  }
}
