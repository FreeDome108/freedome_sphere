import * as vscode from 'vscode';
import { UnrealProjectAnalyzer } from './analyzers/UnrealProjectAnalyzer';
import { CodeOptimizer } from './optimizers/CodeOptimizer';
import { BlueprintOptimizer } from './optimizers/BlueprintOptimizer';
import { ReportGenerator } from './reporters/ReportGenerator';
import { ErrorHandler } from './utils/ErrorHandler';

export function activate(context: vscode.ExtensionContext) {
    console.log('Unreal Blocks to Code Optimizer активирован!');

    const analyzer = new UnrealProjectAnalyzer();
    const codeOptimizer = new CodeOptimizer();
    const blueprintOptimizer = new BlueprintOptimizer();
    const reportGenerator = new ReportGenerator();
    const errorHandler = ErrorHandler.getInstance();

    // Команда анализа проекта
    const analyzeProjectCommand = vscode.commands.registerCommand('unreal-optimizer.analyzeProject', async () => {
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
        if (!workspaceFolder) {
            vscode.window.showErrorMessage('Откройте папку проекта для анализа');
            return;
        }

        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: "Анализ проекта Unreal Engine",
            cancellable: true
        }, async (progress, token) => {
            try {
                progress.report({ increment: 0, message: "Поиск файлов проекта..." });
                
                const analysisResult = await analyzer.analyzeProject(workspaceFolder.uri.fsPath, (value) => progress.report(value), token);
                
                progress.report({ increment: 50, message: "Генерация отчета..." });
                const report = await reportGenerator.generateAnalysisReport(analysisResult);
                
                progress.report({ increment: 100, message: "Анализ завершен!" });
                
                // Показать результаты в новом документе
                const doc = await vscode.workspace.openTextDocument({
                    content: report,
                    language: 'markdown'
                });
                await vscode.window.showTextDocument(doc);
                
                vscode.window.showInformationMessage(`Анализ завершен! Найдено ${analysisResult.issues.length} проблем для оптимизации.`);
                
            } catch (error) {
                errorHandler.handleError(error as Error, 'ProjectAnalyzer', { projectPath: workspaceFolder.uri.fsPath });
            }
        });
    });

    // Команда оптимизации кода
    const optimizeCodeCommand = vscode.commands.registerCommand('unreal-optimizer.optimizeCode', async () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('Откройте файл для оптимизации');
            return;
        }

        const document = editor.document;
        if (!document.fileName.match(/\.(cpp|h|cpppp)$/)) {
            vscode.window.showErrorMessage('Этот файл не является файлом C++ Unreal Engine');
            return;
        }

        try {
            const originalText = document.getText();
            const projectPath = workspaceFolder?.uri.fsPath;
            const optimizedText = await codeOptimizer.optimizeCode(originalText, document.fileName, projectPath);
            
            if (optimizedText !== originalText) {
                const edit = new vscode.WorkspaceEdit();
                edit.replace(document.uri, new vscode.Range(0, 0, document.lineCount, 0), optimizedText);
                await vscode.workspace.applyEdit(edit);
                vscode.window.showInformationMessage('Код оптимизирован!');
            } else {
                vscode.window.showInformationMessage('Код уже оптимизирован');
            }
        } catch (error) {
            errorHandler.handleError(error as Error, 'CodeOptimizer', { fileName: document.fileName });
        }
    });

    // Команда оптимизации Blueprints
    const optimizeBlueprintsCommand = vscode.commands.registerCommand('unreal-optimizer.optimizeBlueprints', async () => {
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
        if (!workspaceFolder) {
            vscode.window.showErrorMessage('Откройте папку проекта для оптимизации Blueprints');
            return;
        }

        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: "Оптимизация Blueprints",
            cancellable: true
        }, async (progress, token) => {
            try {
                progress.report({ increment: 0, message: "Поиск Blueprint файлов..." });
                
                const result = await blueprintOptimizer.optimizeBlueprints(workspaceFolder.uri.fsPath, (value) => progress.report(value), token);
                
                progress.report({ increment: 100, message: "Оптимизация завершена!" });
                
                vscode.window.showInformationMessage(`Оптимизировано ${result.optimizedFiles} Blueprint файлов`);
                
            } catch (error) {
                errorHandler.handleError(error as Error, 'BlueprintOptimizer', { projectPath: workspaceFolder.uri.fsPath });
            }
        });
    });

    // Команда генерации отчета
    const generateReportCommand = vscode.commands.registerCommand('unreal-optimizer.generateReport', async () => {
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
        if (!workspaceFolder) {
            vscode.window.showErrorMessage('Откройте папку проекта для генерации отчета');
            return;
        }

        try {
            const analysisResult = await analyzer.analyzeProject(workspaceFolder.uri.fsPath);
            const report = await reportGenerator.generateOptimizationReport(analysisResult);
            
            const doc = await vscode.workspace.openTextDocument({
                content: report,
                language: 'markdown'
            });
            await vscode.window.showTextDocument(doc);
            
        } catch (error) {
            errorHandler.handleError(error as Error, 'ReportGenerator', { projectPath: workspaceFolder.uri.fsPath });
        }
    });

    // Команда просмотра лога ошибок
    const viewErrorLogCommand = vscode.commands.registerCommand('unreal-optimizer.viewErrorLog', async () => {
        try {
            const errorReport = errorHandler.generateErrorReport();
            const doc = await vscode.workspace.openTextDocument({
                content: errorReport,
                language: 'markdown'
            });
            await vscode.window.showTextDocument(doc);
        } catch (error) {
            vscode.window.showErrorMessage(`Ошибка создания отчета об ошибках: ${error}`);
        }
    });

    // Регистрация команд
    context.subscriptions.push(analyzeProjectCommand);
    context.subscriptions.push(optimizeCodeCommand);
    context.subscriptions.push(optimizeBlueprintsCommand);
    context.subscriptions.push(generateReportCommand);
    context.subscriptions.push(viewErrorLogCommand);

    // Автоматическая оптимизация при сохранении (если включена)
    const config = vscode.workspace.getConfiguration('unrealOptimizer');
    if (config.get('enableAutoOptimization')) {
        const saveListener = vscode.workspace.onDidSaveTextDocument(async (document) => {
            if (document.fileName.match(/\.(cpp|h|cpppp)$/)) {
                try {
                    const originalText = document.getText();
                    const projectPath = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
                    const optimizedText = await codeOptimizer.optimizeCode(originalText, document.fileName, projectPath);
                    
                    if (optimizedText !== originalText) {
                        const edit = new vscode.WorkspaceEdit();
                        edit.replace(document.uri, new vscode.Range(0, 0, document.lineCount, 0), optimizedText);
                        await vscode.workspace.applyEdit(edit);
                    }
                } catch (error) {
                    errorHandler.handleError(error as Error, 'AutoOptimizer', { fileName: document.fileName });
                }
            }
        });
        context.subscriptions.push(saveListener);
    }
}

export function deactivate() {
    console.log('Unreal Blocks to Code Optimizer деактивирован');
}
