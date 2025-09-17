import * as fs from 'fs-extra';
import * as path from 'path';
import * as vscode from 'vscode';

export interface BackupOptions {
    enabled: boolean;
    maxBackups: number;
    backupDirectory: string;
    includeTimestamp: boolean;
    compressBackups: boolean;
}

export interface BackupInfo {
    originalPath: string;
    backupPath: string;
    timestamp: Date;
    size: number;
    compressed: boolean;
}

export class BackupManager {
    private readonly defaultOptions: BackupOptions = {
        enabled: true,
        maxBackups: 5,
        backupDirectory: '.backups',
        includeTimestamp: true,
        compressBackups: false
    };

    private options: BackupOptions;

    constructor(options?: Partial<BackupOptions>) {
        this.options = { ...this.defaultOptions, ...options };
    }

    async createBackup(filePath: string, projectPath: string): Promise<BackupInfo | null> {
        if (!this.options.enabled) {
            return null;
        }

        try {
            // Проверяем, существует ли файл
            if (!await fs.pathExists(filePath)) {
                throw new Error(`Файл не существует: ${filePath}`);
            }

            // Создаем директорию для резервных копий
            const backupDir = path.join(projectPath, this.options.backupDirectory);
            await fs.ensureDir(backupDir);

            // Генерируем имя резервной копии
            const backupName = this.generateBackupName(filePath);
            const backupPath = path.join(backupDir, backupName);

            // Создаем резервную копию
            await fs.copy(filePath, backupPath);

            // Получаем информацию о файле
            const stats = await fs.stat(backupPath);
            const backupInfo: BackupInfo = {
                originalPath: filePath,
                backupPath: backupPath,
                timestamp: new Date(),
                size: stats.size,
                compressed: false
            };

            // Очищаем старые резервные копии
            await this.cleanupOldBackups(backupDir, filePath);

            return backupInfo;

        } catch (error) {
            vscode.window.showErrorMessage(`Ошибка создания резервной копии: ${error}`);
            return null;
        }
    }

    async restoreBackup(backupInfo: BackupInfo): Promise<boolean> {
        try {
            // Проверяем, существует ли резервная копия
            if (!await fs.pathExists(backupInfo.backupPath)) {
                throw new Error(`Резервная копия не найдена: ${backupInfo.backupPath}`);
            }

            // Восстанавливаем файл
            await fs.copy(backupInfo.backupPath, backupInfo.originalPath);

            return true;

        } catch (error) {
            vscode.window.showErrorMessage(`Ошибка восстановления резервной копии: ${error}`);
            return false;
        }
    }

    async listBackups(projectPath: string, originalPath?: string): Promise<BackupInfo[]> {
        try {
            const backupDir = path.join(projectPath, this.options.backupDirectory);
            
            if (!await fs.pathExists(backupDir)) {
                return [];
            }

            const files = await fs.readdir(backupDir);
            const backups: BackupInfo[] = [];

            for (const file of files) {
                const backupPath = path.join(backupDir, file);
                const stats = await fs.stat(backupPath);

                if (stats.isFile()) {
                    const backupInfo = this.parseBackupName(file, backupPath);
                    
                    if (backupInfo && (!originalPath || backupInfo.originalPath === originalPath)) {
                        backups.push(backupInfo);
                    }
                }
            }

            // Сортируем по времени создания (новые сначала)
            return backups.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());

        } catch (error) {
            vscode.window.showErrorMessage(`Ошибка получения списка резервных копий: ${error}`);
            return [];
        }
    }

    async deleteBackup(backupInfo: BackupInfo): Promise<boolean> {
        try {
            if (await fs.pathExists(backupInfo.backupPath)) {
                await fs.remove(backupInfo.backupPath);
                return true;
            }
            return false;
        } catch (error) {
            vscode.window.showErrorMessage(`Ошибка удаления резервной копии: ${error}`);
            return false;
        }
    }

    async cleanupOldBackups(backupDir: string, originalPath: string): Promise<void> {
        try {
            const backups = await this.listBackups(path.dirname(backupDir), originalPath);
            
            if (backups.length > this.options.maxBackups) {
                const backupsToDelete = backups.slice(this.options.maxBackups);
                
                for (const backup of backupsToDelete) {
                    await this.deleteBackup(backup);
                }
            }
        } catch (error) {
            console.error('Ошибка очистки старых резервных копий:', error);
        }
    }

    private generateBackupName(filePath: string): string {
        const fileName = path.basename(filePath);
        const fileExt = path.extname(fileName);
        const baseName = path.basename(fileName, fileExt);
        
        let backupName: string;
        
        if (this.options.includeTimestamp) {
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            backupName = `${baseName}_backup_${timestamp}${fileExt}`;
        } else {
            backupName = `${baseName}_backup${fileExt}`;
        }

        return backupName;
    }

    private parseBackupName(fileName: string, backupPath: string): BackupInfo | null {
        try {
            // Парсим имя файла для извлечения информации
            const match = fileName.match(/^(.+)_backup_(.+)(\.[^.]+)$/);
            
            if (match) {
                const [, baseName, timestamp, extension] = match;
                const originalName = baseName + extension;
                
                return {
                    originalPath: originalName, // Это будет относительный путь
                    backupPath: backupPath,
                    timestamp: new Date(timestamp.replace(/-/g, ':')),
                    size: 0, // Будет заполнено при чтении файла
                    compressed: false
                };
            }
            
            return null;
        } catch (error) {
            return null;
        }
    }

    // Метод для создания резервной копии перед оптимизацией
    async createOptimizationBackup(filePath: string, projectPath: string): Promise<BackupInfo | null> {
        const config = vscode.workspace.getConfiguration('unrealOptimizer');
        const backupEnabled = config.get('backupBeforeOptimization', true);
        
        if (!backupEnabled) {
            return null;
        }

        return await this.createBackup(filePath, projectPath);
    }

    // Метод для восстановления из последней резервной копии
    async restoreFromLatestBackup(projectPath: string, originalPath: string): Promise<boolean> {
        const backups = await this.listBackups(projectPath, originalPath);
        
        if (backups.length === 0) {
            vscode.window.showWarningMessage('Резервные копии не найдены');
            return false;
        }

        const latestBackup = backups[0];
        return await this.restoreBackup(latestBackup);
    }

    // Метод для показа диалога выбора резервной копии
    async showBackupSelectionDialog(projectPath: string, originalPath: string): Promise<BackupInfo | null> {
        const backups = await this.listBackups(projectPath, originalPath);
        
        if (backups.length === 0) {
            vscode.window.showInformationMessage('Резервные копии не найдены');
            return null;
        }

        const items = backups.map(backup => ({
            label: `Резервная копия от ${backup.timestamp.toLocaleString()}`,
            description: `Размер: ${(backup.size / 1024).toFixed(2)} KB`,
            backup: backup
        }));

        const selected = await vscode.window.showQuickPick(items, {
            placeHolder: 'Выберите резервную копию для восстановления'
        });

        return selected ? selected.backup : null;
    }

    // Метод для настройки параметров резервного копирования
    updateOptions(newOptions: Partial<BackupOptions>): void {
        this.options = { ...this.options, ...newOptions };
    }

    // Метод для получения текущих настроек
    getOptions(): BackupOptions {
        return { ...this.options };
    }

    // Метод для проверки доступности резервного копирования
    async isBackupAvailable(projectPath: string): Promise<boolean> {
        try {
            const backupDir = path.join(projectPath, this.options.backupDirectory);
            await fs.ensureDir(backupDir);
            return true;
        } catch (error) {
            return false;
        }
    }

    // Метод для получения статистики резервных копий
    async getBackupStatistics(projectPath: string): Promise<{
        totalBackups: number;
        totalSize: number;
        oldestBackup: Date | null;
        newestBackup: Date | null;
    }> {
        const backups = await this.listBackups(projectPath);
        
        if (backups.length === 0) {
            return {
                totalBackups: 0,
                totalSize: 0,
                oldestBackup: null,
                newestBackup: null
            };
        }

        const totalSize = backups.reduce((sum, backup) => sum + backup.size, 0);
        const timestamps = backups.map(backup => backup.timestamp);
        
        return {
            totalBackups: backups.length,
            totalSize: totalSize,
            oldestBackup: new Date(Math.min(...timestamps.map(t => t.getTime()))),
            newestBackup: new Date(Math.max(...timestamps.map(t => t.getTime())))
        };
    }
}


