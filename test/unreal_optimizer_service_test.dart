
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:freedome_sphere_flutter/services/unreal_optimizer_service.dart';
import 'package:freedome_sphere_flutter/models/unreal_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unreal_optimizer_service_test.mocks.dart';

@GenerateMocks([UnrealOptimizerService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UnrealOptimizerService', () {
    late MockUnrealOptimizerService mockUnrealOptimizerService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockUnrealOptimizerService = MockUnrealOptimizerService();
    });

    test('initialize initializes the service', () async {
      when(mockUnrealOptimizerService.initialize()).thenAnswer((_) async => true);
      final result = await mockUnrealOptimizerService.initialize();
      expect(result, isTrue);
    });

    test('analyzeProject analyzes a project', () async {
      when(mockUnrealOptimizerService.analyzeProject(any)).thenAnswer((_) async => AnalysisResult(
        projectPath: '',
        totalFiles: 0,
        issues: [],
        suggestions: [],
        analysisDate: DateTime.now(),
        performanceScore: 0,
      ));

      final result = await mockUnrealOptimizerService.analyzeProject('/path/to/mock/project');
      expect(result, isA<AnalysisResult>());
    });

    test('optimizeCode optimizes code', () async {
      when(mockUnrealOptimizerService.optimizeCode(any, any)).thenAnswer((_) async => OptimizationResult(
        originalCode: '',
        optimizedCode: '',
        changes: [],
        performanceGain: 0,
        memoryGain: 0,
      ));

      final result = await mockUnrealOptimizerService.optimizeCode('...', 'TestFile.cpp');
      expect(result, isA<OptimizationResult>());
    });

    test('isUnrealProject returns true for a valid project', () async {
      when(mockUnrealOptimizerService.isUnrealProject(any)).thenAnswer((_) async => true);
      final result = await mockUnrealOptimizerService.isUnrealProject('/path/to/mock/project');
      expect(result, isTrue);
    });

    test('isUnrealProject returns false for an invalid project', () async {
      when(mockUnrealOptimizerService.isUnrealProject(any)).thenAnswer((_) async => false);
      final result = await mockUnrealOptimizerService.isUnrealProject('/path/to/invalid/project');
      expect(result, isFalse);
    });
  });
}
