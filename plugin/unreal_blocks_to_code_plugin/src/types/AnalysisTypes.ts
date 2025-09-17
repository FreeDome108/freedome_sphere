export interface AnalysisResult {
    projectPath: string;
    totalFiles: number;
    issues: ProjectIssue[];
    suggestions: OptimizationSuggestion[];
    analysisDate: Date;
    performanceScore: number;
}

export interface ProjectIssue {
    type: IssueType;
    severity: IssueSeverity;
    file: string;
    line: number;
    message: string;
    suggestion: string;
}

export interface OptimizationSuggestion {
    type: OptimizationType;
    title: string;
    description: string;
    priority: Priority;
    estimatedImpact: Impact;
}

export type IssueType = 
    | 'performance'
    | 'memory'
    | 'code-quality'
    | 'compatibility'
    | 'error';

export type IssueSeverity = 
    | 'error'
    | 'warning'
    | 'info';

export type OptimizationType = 
    | 'performance'
    | 'memory'
    | 'code-quality'
    | 'structure';

export type Priority = 
    | 'critical'
    | 'high'
    | 'medium'
    | 'low';

export type Impact = 
    | 'critical'
    | 'significant'
    | 'moderate'
    | 'minor';

export interface OptimizationResult {
    originalCode: string;
    optimizedCode: string;
    changes: CodeChange[];
    performanceGain: number;
    memoryGain: number;
}

export interface CodeChange {
    type: ChangeType;
    line: number;
    original: string;
    optimized: string;
    description: string;
}

export type ChangeType = 
    | 'replacement'
    | 'addition'
    | 'removal'
    | 'refactoring';

export interface BlueprintOptimizationResult {
    optimizedFiles: number;
    totalFiles: number;
    issues: ProjectIssue[];
    suggestions: OptimizationSuggestion[];
}

export interface ConfigurationSettings {
    enableAutoOptimization: boolean;
    optimizationLevel: 'basic' | 'advanced' | 'aggressive';
    includeBlueprints: boolean;
    backupBeforeOptimization: boolean;
    maxFileSize: number;
    excludePatterns: string[];
}

export interface FileAnalysisResult {
    filePath: string;
    fileType: 'cpp' | 'header' | 'blueprint' | 'config';
    issues: ProjectIssue[];
    optimizationSuggestions: OptimizationSuggestion[];
    fileSize: number;
    lastModified: Date;
}

export interface ProjectStructure {
    projectName: string;
    projectPath: string;
    engineVersion: string;
    modules: string[];
    plugins: string[];
    cppFiles: string[];
    blueprintFiles: string[];
    configFiles: string[];
}

export interface OptimizationMetrics {
    totalOptimizations: number;
    performanceImprovements: number;
    memoryOptimizations: number;
    codeQualityImprovements: number;
    estimatedPerformanceGain: number;
    estimatedMemoryGain: number;
}
