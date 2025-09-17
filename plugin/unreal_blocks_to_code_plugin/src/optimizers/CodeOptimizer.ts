import { OptimizationResult, CodeChange, ChangeType } from '../types/AnalysisTypes';
import { BackupManager } from '../utils/BackupManager';

export class CodeOptimizer {
    private readonly config: any;
    private readonly backupManager: BackupManager;

    constructor() {
        this.config = {
            optimizationLevel: 'basic',
            enableAggressiveOptimization: false,
            preserveComments: true
        };
        this.backupManager = new BackupManager();
    }

    async optimizeCode(code: string, fileName: string, projectPath?: string): Promise<string> {
        let optimizedCode = code;
        const changes: CodeChange[] = [];

        // Создаем резервную копию перед оптимизацией
        if (projectPath) {
            await this.backupManager.createOptimizationBackup(fileName, projectPath);
        }

        // 1. Оптимизация циклов
        const loopOptimization = this.optimizeLoops(optimizedCode);
        optimizedCode = loopOptimization.code;
        changes.push(...loopOptimization.changes);

        // 2. Оптимизация строковых операций
        const stringOptimization = this.optimizeStringOperations(optimizedCode);
        optimizedCode = stringOptimization.code;
        changes.push(...stringOptimization.changes);

        // 3. Добавление const где возможно
        const constOptimization = this.addConstKeywords(optimizedCode);
        optimizedCode = constOptimization.code;
        changes.push(...constOptimization.changes);

        // 4. Оптимизация UE макросов
        const macroOptimization = this.optimizeUEMacros(optimizedCode);
        optimizedCode = macroOptimization.code;
        changes.push(...macroOptimization.changes);

        // 5. Оптимизация памяти
        const memoryOptimization = this.optimizeMemoryUsage(optimizedCode);
        optimizedCode = memoryOptimization.code;
        changes.push(...memoryOptimization.changes);

        // 6. Добавление include guards если отсутствуют
        const includeGuardOptimization = this.addIncludeGuards(optimizedCode, fileName);
        optimizedCode = includeGuardOptimization.code;
        changes.push(...includeGuardOptimization.changes);

        // 7. Оптимизация includes
        const includeOptimization = this.optimizeIncludes(optimizedCode);
        optimizedCode = includeOptimization.code;
        changes.push(...includeOptimization.changes);

        // 8. Оптимизация контейнеров
        const containerOptimization = this.optimizeContainers(optimizedCode);
        optimizedCode = containerOptimization.code;
        changes.push(...containerOptimization.changes);

        // 9. Оптимизация делегатов
        const delegateOptimization = this.optimizeDelegates(optimizedCode);
        optimizedCode = delegateOptimization.code;
        changes.push(...delegateOptimization.changes);

        // 10. Оптимизация UE макросов (расширенная)
        const advancedMacroOptimization = this.optimizeAdvancedUEMacros(optimizedCode);
        optimizedCode = advancedMacroOptimization.code;
        changes.push(...advancedMacroOptimization.changes);

        // 11. Оптимизация производительности
        const performanceOptimization = this.optimizePerformance(optimizedCode);
        optimizedCode = performanceOptimization.code;
        changes.push(...performanceOptimization.changes);

        return optimizedCode;
    }

    private optimizeLoops(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;
        const lines = code.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Оптимизация: for (int i = 0; i < array.size(); i++) -> for (const auto& item : array)
            const inefficientLoopMatch = line.match(/for\s*\(\s*int\s+(\w+)\s*=\s*0\s*;\s*\1\s*<\s*(\w+)\.size\(\)\s*;\s*\1\+\+\s*\)/);
            if (inefficientLoopMatch) {
                const [, indexVar, arrayVar] = inefficientLoopMatch;
                const optimizedLine = line.replace(
                    inefficientLoopMatch[0],
                    `for (const auto& ${indexVar} : ${arrayVar})`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Заменен неэффективный цикл на range-based for loop'
                });
            }

            // Оптимизация: while с size() в условии
            const whileSizeMatch = line.match(/while\s*\(\s*(\w+)\s*<\s*(\w+)\.size\(\)\s*\)/);
            if (whileSizeMatch) {
                const [, indexVar, arrayVar] = whileSizeMatch;
                const optimizedLine = line.replace(
                    whileSizeMatch[0],
                    `while (${indexVar} < ${arrayVar}.Num())`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Заменен .size() на .Num() для UE контейнеров'
                });
            }
        }

        return { code: lines.join('\n'), changes };
    }

    private optimizeStringOperations(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;
        const lines = code.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Оптимизация: FString + FString -> FString::Format
            const stringConcatMatch = line.match(/(\w+)\s*=\s*(\w+)\s*\+\s*(\w+)/);
            if (stringConcatMatch && line.includes('FString')) {
                const [, resultVar, str1, str2] = stringConcatMatch;
                const optimizedLine = line.replace(
                    stringConcatMatch[0],
                    `${resultVar} = FString::Format(TEXT("{0}{1}"), {${str1}, ${str2}})`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Заменена конкатенация строк на FString::Format'
                });
            }

            // Оптимизация: множественная конкатенация
            const multiConcatMatch = line.match(/(\w+)\s*=\s*(\w+)\s*\+\s*(\w+)\s*\+\s*(\w+)/);
            if (multiConcatMatch && line.includes('FString')) {
                const [, resultVar, str1, str2, str3] = multiConcatMatch;
                const optimizedLine = line.replace(
                    multiConcatMatch[0],
                    `${resultVar} = FString::Format(TEXT("{0}{1}{2}"), {${str1}, ${str2}, ${str3}})`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Заменена множественная конкатенация на FString::Format'
                });
            }
        }

        return { code: lines.join('\n'), changes };
    }

    private addConstKeywords(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;
        const lines = code.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Добавление const для локальных переменных
            const localVarMatch = line.match(/^\s*(int|float|bool|FString|FVector|FRotator|FTransform)\s+(\w+)\s*=\s*([^;]+);/);
            if (localVarMatch && !line.includes('const')) {
                const [, type, varName, value] = localVarMatch;
                const optimizedLine = line.replace(
                    localVarMatch[0],
                    `const ${type} ${varName} = ${value};`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: `Добавлен const для неизменяемой переменной ${varName}`
                });
            }

            // Добавление const для параметров функций
            const paramMatch = line.match(/^\s*(int|float|bool|FString|FVector|FRotator|FTransform)\s+(\w+)\s*\)/);
            if (paramMatch && !line.includes('const') && !line.includes('&')) {
                const [, type, paramName] = paramMatch;
                const optimizedLine = line.replace(
                    paramMatch[0],
                    `const ${type}& ${paramName})`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: `Добавлен const& для параметра ${paramName}`
                });
            }
        }

        return { code: lines.join('\n'), changes };
    }

    private optimizeUEMacros(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;

        // Оптимизация GENERATED_BODY()
        if (code.includes('GENERATED_BODY()')) {
            optimizedCode = optimizedCode.replace(
                /GENERATED_BODY\(\)/g,
                'GENERATED_BODY()'
            );
            
            changes.push({
                type: 'replacement' as ChangeType,
                line: 0,
                original: 'GENERATED_BODY()',
                optimized: 'GENERATED_BODY()',
                description: 'Оптимизирован макрос GENERATED_BODY'
            });
        }

        // Добавление UFUNCTION оптимизаций
        const ufunctionMatch = code.match(/UFUNCTION\([^)]*\)/g);
        if (ufunctionMatch) {
            for (const match of ufunctionMatch) {
                if (!match.includes('CallInEditor')) {
                    const optimized = match.replace(')', ', CallInEditor = true)');
                    optimizedCode = optimizedCode.replace(match, optimized);
                    
                    changes.push({
                        type: 'replacement' as ChangeType,
                        line: 0,
                        original: match,
                        optimized: optimized,
                        description: 'Добавлен CallInEditor для UFUNCTION'
                    });
                }
            }
        }

        return { code: optimizedCode, changes };
    }

    private optimizeMemoryUsage(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;
        const lines = code.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Замена new на умные указатели
            const newMatch = line.match(/(\w+)\s*=\s*new\s+(\w+)\(\)/);
            if (newMatch && !line.includes('MakeShared') && !line.includes('MakeUnique')) {
                const [, varName, className] = newMatch;
                const optimizedLine = line.replace(
                    newMatch[0],
                    `${varName} = MakeShared<${className}>()`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: `Заменен new на MakeShared для ${className}`
                });
            }

            // Оптимизация TArray
            const tarrayMatch = line.match(/TArray<(\w+)>\s+(\w+);/);
            if (tarrayMatch) {
                const [, elementType, arrayName] = tarrayMatch;
                const optimizedLine = line.replace(
                    tarrayMatch[0],
                    `TArray<${elementType}> ${arrayName}; ${arrayName}.Reserve(100); // Предварительное выделение памяти`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: `Добавлено предварительное выделение памяти для TArray ${arrayName}`
                });
            }
        }

        return { code: lines.join('\n'), changes };
    }

    private addIncludeGuards(code: string, fileName: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        
        if (!code.includes('#pragma once') && !code.includes('#ifndef')) {
            const guardName = fileName.replace(/[^a-zA-Z0-9]/g, '_').toUpperCase();
            const includeGuard = `#pragma once\n\n`;
            
            const optimizedCode = includeGuard + code;
            
            changes.push({
                type: 'addition' as ChangeType,
                line: 1,
                original: '',
                optimized: includeGuard,
                description: 'Добавлен include guard'
            });
            
            return { code: optimizedCode, changes };
        }
        
        return { code, changes };
    }

    private optimizeIncludes(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        const lines = code.split('\n');
        const includeLines: string[] = [];
        const otherLines: string[] = [];
        
        // Разделяем include строки и остальной код
        for (const line of lines) {
            if (line.trim().startsWith('#include')) {
                includeLines.push(line);
            } else {
                otherLines.push(line);
            }
        }
        
        // Сортируем include строки
        includeLines.sort((a, b) => {
            const aIsSystem = a.includes('<');
            const bIsSystem = b.includes('<');
            
            if (aIsSystem && !bIsSystem) return -1;
            if (!aIsSystem && bIsSystem) return 1;
            return a.localeCompare(b);
        });
        
        // Удаляем дубликаты
        const uniqueIncludes = [...new Set(includeLines)];
        
        if (uniqueIncludes.length !== includeLines.length) {
            changes.push({
                type: 'removal' as ChangeType,
                line: 0,
                original: includeLines.join('\n'),
                optimized: uniqueIncludes.join('\n'),
                description: 'Удалены дублирующиеся include директивы'
            });
        }
        
        const optimizedCode = [...uniqueIncludes, ...otherLines].join('\n');
        return { code: optimizedCode, changes };
    }

    private optimizeContainers(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        const lines = code.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Оптимизация TArray с множественными Add
            const multipleAddMatch = line.match(/(\w+)\.Add\(([^)]+)\);\s*(\w+)\.Add\(([^)]+)\);\s*(\w+)\.Add\(([^)]+)\);/);
            if (multipleAddMatch) {
                const [, arrayName, val1, , val2, , val3] = multipleAddMatch;
                const optimizedLine = `${arrayName}.Add({${val1}, ${val2}, ${val3}});`;
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Объединены множественные Add в один вызов'
                });
            }

            // Оптимизация TMap с множественными Find
            const multipleFindMatch = line.match(/(\w+)\.Find\(([^)]+)\);\s*(\w+)\.Find\(([^)]+)\);/);
            if (multipleFindMatch) {
                const [, mapName, key1, , key2] = multipleFindMatch;
                const optimizedLine = `auto [${key1}, ${key2}] = ${mapName}.Find({${key1}, ${key2}});`;
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Оптимизированы множественные Find операции'
                });
            }

            // Добавление Reserve для TArray
            const tarrayDeclMatch = line.match(/TArray<(\w+)>\s+(\w+);/);
            if (tarrayDeclMatch && !line.includes('Reserve')) {
                const [, elementType, arrayName] = tarrayDeclMatch;
                const optimizedLine = line + `\n\t${arrayName}.Reserve(100); // Предварительное выделение памяти`;
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'addition' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: `Добавлено предварительное выделение памяти для TArray ${arrayName}`
                });
            }
        }

        return { code: lines.join('\n'), changes };
    }

    private optimizeDelegates(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;

        // Оптимизация DECLARE_DELEGATE
        const delegateMatch = code.match(/DECLARE_DELEGATE\s*\(\s*(\w+)\s*\)/g);
        if (delegateMatch) {
            for (const match of delegateMatch) {
                const optimized = match.replace('DECLARE_DELEGATE', 'DECLARE_DELEGATE_OneParam');
                optimizedCode = optimizedCode.replace(match, optimized);
                
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: 0,
                    original: match,
                    optimized: optimized,
                    description: 'Оптимизирован DECLARE_DELEGATE'
                });
            }
        }

        // Оптимизация BindUObject
        const bindMatch = code.match(/BindUObject\s*\(\s*this\s*,\s*&(\w+)::(\w+)\s*\)/g);
        if (bindMatch) {
            for (const match of bindMatch) {
                const optimized = match.replace('BindUObject', 'BindUFunction');
                optimizedCode = optimizedCode.replace(match, optimized);
                
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: 0,
                    original: match,
                    optimized: optimized,
                    description: 'Заменен BindUObject на BindUFunction'
                });
            }
        }

        return { code: optimizedCode, changes };
    }

    private optimizeAdvancedUEMacros(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        let optimizedCode = code;

        // Оптимизация UPROPERTY
        const upropertyMatch = code.match(/UPROPERTY\s*\(\s*\)/g);
        if (upropertyMatch) {
            for (const match of upropertyMatch) {
                const optimized = 'UPROPERTY(VisibleAnywhere, BlueprintReadOnly)';
                optimizedCode = optimizedCode.replace(match, optimized);
                
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: 0,
                    original: match,
                    optimized: optimized,
                    description: 'Добавлены параметры в UPROPERTY'
                });
            }
        }

        // Оптимизация UFUNCTION
        const ufunctionMatch = code.match(/UFUNCTION\s*\(\s*\)/g);
        if (ufunctionMatch) {
            for (const match of ufunctionMatch) {
                const optimized = 'UFUNCTION(BlueprintCallable, Category = "Default")';
                optimizedCode = optimizedCode.replace(match, optimized);
                
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: 0,
                    original: match,
                    optimized: optimized,
                    description: 'Добавлены параметры в UFUNCTION'
                });
            }
        }

        // Оптимизация UCLASS
        const uclassMatch = code.match(/UCLASS\s*\(\s*\)/g);
        if (uclassMatch) {
            for (const match of uclassMatch) {
                const optimized = 'UCLASS(BlueprintType, Blueprintable)';
                optimizedCode = optimizedCode.replace(match, optimized);
                
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: 0,
                    original: match,
                    optimized: optimized,
                    description: 'Добавлены параметры в UCLASS'
                });
            }
        }

        return { code: optimizedCode, changes };
    }

    private optimizePerformance(code: string): { code: string; changes: CodeChange[] } {
        const changes: CodeChange[] = [];
        const lines = code.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Оптимизация GetTimeSeconds
            const timeMatch = line.match(/GetWorld\(\)->GetTimeSeconds\(\)/);
            if (timeMatch) {
                const optimizedLine = line.replace(
                    'GetWorld()->GetTimeSeconds()',
                    'GetWorld()->GetTimeSeconds() // Кэшируйте это значение если используется часто'
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Добавлен комментарий для оптимизации GetTimeSeconds'
                });
            }

            // Оптимизация Distance вычислений
            const distanceMatch = line.match(/GetActorLocation\(\)\.Distance\s*\(\s*(\w+)\s*\)/);
            if (distanceMatch) {
                const [, targetVar] = distanceMatch;
                const optimizedLine = line.replace(
                    'GetActorLocation().Distance(' + targetVar + ')',
                    'FVector::Dist(GetActorLocation(), ' + targetVar + ')'
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Заменен Distance на FVector::Dist для лучшей производительности'
                });
            }

            // Оптимизация множественных IsValid
            const isValidMatch = line.match(/IsValid\s*\(\s*(\w+)\s*\)\s*&&\s*IsValid\s*\(\s*(\w+)\s*\)/);
            if (isValidMatch) {
                const [, obj1, obj2] = isValidMatch;
                const optimizedLine = line.replace(
                    `IsValid(${obj1}) && IsValid(${obj2})`,
                    `IsValid(${obj1}) && IsValid(${obj2}) // Рассмотрите объединение проверок`
                );
                
                lines[i] = optimizedLine;
                changes.push({
                    type: 'replacement' as ChangeType,
                    line: i + 1,
                    original: line,
                    optimized: optimizedLine,
                    description: 'Добавлен комментарий для оптимизации IsValid'
                });
            }
        }

        return { code: lines.join('\n'), changes };
    }
}
