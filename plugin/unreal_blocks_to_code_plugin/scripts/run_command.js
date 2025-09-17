#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');
const { UnrealProjectAnalyzer } = require('../out/analyzers/UnrealProjectAnalyzer');
const { CodeOptimizer } = require('../out/optimizers/CodeOptimizer');
const { BlueprintOptimizer } = require('../out/optimizers/BlueprintOptimizer');
const { ReportGenerator } = require('../out/reporters/ReportGenerator');

/**
 * Скрипт для запуска команд плагина из Flutter приложения
 */

async function main() {
    const args = process.argv.slice(2);
    
    if (args.length < 1) {
        console.error('Usage: node run_command.js <command> <params_json>');
        process.exit(1);
    }
    
    const command = args[0];
    const paramsJson = args[1] || '{}';
    
    try {
        const params = JSON.parse(paramsJson);
        
        switch (command) {
            case 'analyze':
                await runAnalyze(params);
                break;
            case 'optimize':
                await runOptimize(params);
                break;
            case 'optimizeBlueprints':
                await runOptimizeBlueprints(params);
                break;
            case 'generateReport':
                await runGenerateReport(params);
                break;
            default:
                throw new Error(`Unknown command: ${command}`);
        }
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

/**
 * Запуск анализа проекта
 */
async function runAnalyze(params) {
    const { projectPath, configFile } = params;
    
    if (!projectPath) {
        throw new Error('projectPath is required');
    }
    
    const config = await loadConfig(configFile);
    const analyzer = new UnrealProjectAnalyzer();
    
    const result = await analyzer.analyzeProject(projectPath, (progress) => {
        // Прогресс можно логировать, но не выводить в stdout
        console.error(`Progress: ${progress.message}`);
    });
    
    console.log(JSON.stringify(result));
}

/**
 * Запуск оптимизации кода
 */
async function runOptimize(params) {
    const { filePath, content, configFile } = params;
    
    if (!filePath || !content) {
        throw new Error('filePath and content are required');
    }
    
    const config = await loadConfig(configFile);
    const optimizer = new CodeOptimizer();
    
    const result = await optimizer.optimizeCode(content, filePath, path.dirname(filePath));
    
    console.log(JSON.stringify(result));
}

/**
 * Запуск оптимизации Blueprints
 */
async function runOptimizeBlueprints(params) {
    const { projectPath, configFile } = params;
    
    if (!projectPath) {
        throw new Error('projectPath is required');
    }
    
    const config = await loadConfig(configFile);
    const optimizer = new BlueprintOptimizer();
    
    const result = await optimizer.optimizeBlueprints(projectPath, (progress) => {
        console.error(`Progress: ${progress.message}`);
    });
    
    console.log(JSON.stringify(result));
}

/**
 * Запуск генерации отчета
 */
async function runGenerateReport(params) {
    const { projectPath, configFile } = params;
    
    if (!projectPath) {
        throw new Error('projectPath is required');
    }
    
    const config = await loadConfig(configFile);
    const analyzer = new UnrealProjectAnalyzer();
    const reportGenerator = new ReportGenerator();
    
    const analysisResult = await analyzer.analyzeProject(projectPath);
    const report = await reportGenerator.generateOptimizationReport(analysisResult);
    
    console.log(report);
}

/**
 * Загрузка конфигурации
 */
async function loadConfig(configFile) {
    if (!configFile || !await fs.pathExists(configFile)) {
        return {
            enableAutoOptimization: false,
            optimizationLevel: 'basic',
            includeBlueprints: true,
            backupBeforeOptimization: true
        };
    }
    
    try {
        const configContent = await fs.readFile(configFile, 'utf8');
        return JSON.parse(configContent);
    } catch (error) {
        console.error('Error loading config:', error.message);
        return {
            enableAutoOptimization: false,
            optimizationLevel: 'basic',
            includeBlueprints: true,
            backupBeforeOptimization: true
        };
    }
}

// Запуск скрипта
if (require.main === module) {
    main().catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}

module.exports = { main };
