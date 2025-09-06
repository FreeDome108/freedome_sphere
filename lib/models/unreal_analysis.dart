class AnalysisResult {
  final String projectPath;
  final int totalFiles;
  final List<ProjectIssue> issues;
  final List<OptimizationSuggestion> suggestions;
  final DateTime analysisDate;
  final int performanceScore;

  AnalysisResult({
    required this.projectPath,
    required this.totalFiles,
    required this.issues,
    required this.suggestions,
    required this.analysisDate,
    required this.performanceScore,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      projectPath: json['projectPath'] ?? '',
      totalFiles: json['totalFiles'] ?? 0,
      issues: (json['issues'] as List<dynamic>?)
          ?.map((issue) => ProjectIssue.fromJson(issue))
          .toList() ?? [],
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((suggestion) => OptimizationSuggestion.fromJson(suggestion))
          .toList() ?? [],
      analysisDate: DateTime.parse(json['analysisDate'] ?? DateTime.now().toIso8601String()),
      performanceScore: json['performanceScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectPath': projectPath,
      'totalFiles': totalFiles,
      'issues': issues.map((issue) => issue.toJson()).toList(),
      'suggestions': suggestions.map((suggestion) => suggestion.toJson()).toList(),
      'analysisDate': analysisDate.toIso8601String(),
      'performanceScore': performanceScore,
    };
  }
}

class ProjectIssue {
  final IssueType type;
  final IssueSeverity severity;
  final String file;
  final int line;
  final String message;
  final String suggestion;

  ProjectIssue({
    required this.type,
    required this.severity,
    required this.file,
    required this.line,
    required this.message,
    required this.suggestion,
  });

  factory ProjectIssue.fromJson(Map<String, dynamic> json) {
    return ProjectIssue(
      type: IssueType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => IssueType.performance,
      ),
      severity: IssueSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
        orElse: () => IssueSeverity.info,
      ),
      file: json['file'] ?? '',
      line: json['line'] ?? 0,
      message: json['message'] ?? '',
      suggestion: json['suggestion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'file': file,
      'line': line,
      'message': message,
      'suggestion': suggestion,
    };
  }
}

class OptimizationSuggestion {
  final OptimizationType type;
  final String title;
  final String description;
  final Priority priority;
  final Impact estimatedImpact;

  OptimizationSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedImpact,
  });

  factory OptimizationSuggestion.fromJson(Map<String, dynamic> json) {
    return OptimizationSuggestion(
      type: OptimizationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => OptimizationType.performance,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: Priority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => Priority.medium,
      ),
      estimatedImpact: Impact.values.firstWhere(
        (e) => e.toString().split('.').last == json['estimatedImpact'],
        orElse: () => Impact.moderate,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'estimatedImpact': estimatedImpact.toString().split('.').last,
    };
  }
}

class OptimizationResult {
  final String originalCode;
  final String optimizedCode;
  final List<CodeChange> changes;
  final int performanceGain;
  final int memoryGain;

  OptimizationResult({
    required this.originalCode,
    required this.optimizedCode,
    required this.changes,
    required this.performanceGain,
    required this.memoryGain,
  });

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    return OptimizationResult(
      originalCode: json['originalCode'] ?? '',
      optimizedCode: json['optimizedCode'] ?? '',
      changes: (json['changes'] as List<dynamic>?)
          ?.map((change) => CodeChange.fromJson(change))
          .toList() ?? [],
      performanceGain: json['performanceGain'] ?? 0,
      memoryGain: json['memoryGain'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalCode': originalCode,
      'optimizedCode': optimizedCode,
      'changes': changes.map((change) => change.toJson()).toList(),
      'performanceGain': performanceGain,
      'memoryGain': memoryGain,
    };
  }
}

class CodeChange {
  final ChangeType type;
  final int line;
  final String original;
  final String optimized;
  final String description;

  CodeChange({
    required this.type,
    required this.line,
    required this.original,
    required this.optimized,
    required this.description,
  });

  factory CodeChange.fromJson(Map<String, dynamic> json) {
    return CodeChange(
      type: ChangeType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ChangeType.replacement,
      ),
      line: json['line'] ?? 0,
      original: json['original'] ?? '',
      optimized: json['optimized'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'line': line,
      'original': original,
      'optimized': optimized,
      'description': description,
    };
  }
}

enum IssueType {
  performance,
  memory,
  codeQuality,
  compatibility,
  error,
}

enum IssueSeverity {
  error,
  warning,
  info,
}

enum OptimizationType {
  performance,
  memory,
  codeQuality,
  structure,
}

enum Priority {
  critical,
  high,
  medium,
  low,
}

enum Impact {
  critical,
  significant,
  moderate,
  minor,
}

enum ChangeType {
  replacement,
  addition,
  removal,
  refactoring,
}
