
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/lyubomir_understanding.dart';

class LyubomirUnderstandingService with ChangeNotifier {
  bool _isEnabled = false;
  LyubomirSettings _settings = LyubomirSettings(
    enabled: false,
    enabledTypes: UnderstandingType.values,
    autoAnalyze: false,
    sensitivity: 0.5,
  );
  List<LyubomirUnderstanding> _understandings = [];

  bool get isEnabled => _isEnabled;
  LyubomirSettings get settings => _settings;
  List<LyubomirUnderstanding> get understandings => _understandings;

  Future<void> initialize() async {
    // Simulate loading settings from storage
    await Future.delayed(const Duration(seconds: 1));
    _isEnabled = _settings.enabled;
    _understandings = [
      LyubomirUnderstanding(
        id: '1',
        name: 'Пример визуального понимания',
        description: 'Анализ изображения кота',
        type: UnderstandingType.visual,
        status: UnderstandingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastAnalyzed: DateTime.now(),
        results: [
          UnderstandingResult(
            confidence: 0.95,
            type: UnderstandingType.visual,
            timestamp: DateTime.now(),
            tags: ['кот', 'животное', 'милый'],
            data: {'box': [10, 20, 100, 120], 'class': 'cat'},
          )
        ],
      )
    ];
    notifyListeners();
  }

  Future<void> updateSettings(LyubomirSettings newSettings) async {
    _settings = newSettings;
    _isEnabled = newSettings.enabled;
    notifyListeners();
    // Simulate saving settings
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void createUnderstanding({
    required String name,
    required String description,
    required UnderstandingType type,
  }) {
    final newUnderstanding = LyubomirUnderstanding(
      id: Random().nextInt(10000).toString(),
      name: name,
      description: description,
      type: type,
      status: UnderstandingStatus.idle,
      createdAt: DateTime.now(),
    );
    _understandings.add(newUnderstanding);
    notifyListeners();
  }

  void deleteUnderstanding(String id) {
    _understandings.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  void analyzeContent(String id) {
    final understandingIndex = _understandings.indexWhere((u) => u.id == id);
    if (understandingIndex != -1) {
      final understanding = _understandings[understandingIndex];
      _understandings[understandingIndex] = LyubomirUnderstanding(
          id: understanding.id,
          name: understanding.name,
          description: understanding.description,
          type: understanding.type,
          createdAt: understanding.createdAt,
          status: UnderstandingStatus.analyzing,
          lastAnalyzed: understanding.lastAnalyzed,
          results: understanding.results);
      notifyListeners();

      Future.delayed(const Duration(seconds: 2), () {
        final results = [
          UnderstandingResult(
            confidence: Random().nextDouble() * 0.5 + 0.5,
            type: understanding.type,
            timestamp: DateTime.now(),
            tags: ['tag1', 'tag2', 'tag3'],
            data: {'random_data': Random().nextInt(100)},
          )
        ];
        final updatedUnderstanding = LyubomirUnderstanding(
            id: understanding.id,
            name: understanding.name,
            description: understanding.description,
            type: understanding.type,
            createdAt: understanding.createdAt,
            status: UnderstandingStatus.completed,
            lastAnalyzed: DateTime.now(),
            results: results);
        _understandings[understandingIndex] = updatedUnderstanding;
        notifyListeners();
      });
    }
  }

  Future<void> resetToDefaults() async {
    _settings = LyubomirSettings(
      enabled: false,
      enabledTypes: UnderstandingType.values,
      autoAnalyze: false,
      sensitivity: 0.5,
    );
    _isEnabled = _settings.enabled;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> clearAllData() async {
    _understandings.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
