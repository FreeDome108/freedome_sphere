import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

/// Сервис для работы с проектами
class ProjectService {
  static const String _projectsKey = 'freedome_projects';
  static const String _currentProjectKey = 'current_project';
  
  /// Создать новый проект
  Future<FreedomeProject> createNewProject({
    required String name,
    String description = '',
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final project = FreedomeProject(
      id: _generateId(),
      name: name,
      description: description,
      tags: tags,
      created: now,
      modified: now,
      dome: DomeSettings(
        resolution: Resolution(width: 4096, height: 2048),
      ),
      settings: ProjectSettings(),
    );
    
    await _saveProject(project);
    return project;
  }
  
  /// Загрузить проект
  Future<FreedomeProject?> loadProject(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString(_projectsKey);
      
      if (projectsJson != null) {
        final projects = jsonDecode(projectsJson) as List;
        final projectData = projects.firstWhere(
          (p) => p['id'] == projectId,
          orElse: () => null,
        );
        
        if (projectData != null) {
          return FreedomeProject.fromJson(projectData);
        }
      }
    } catch (e) {
      print('Ошибка загрузки проекта: $e');
    }
    
    return null;
  }
  
  /// Сохранить проект
  Future<bool> saveProject(FreedomeProject project) async {
    try {
      final updatedProject = project.copyWith(modified: DateTime.now());
      await _saveProject(updatedProject);
      return true;
    } catch (e) {
      print('Ошибка сохранения проекта: $e');
      return false;
    }
  }
  
  /// Получить список всех проектов
  Future<List<FreedomeProject>> getAllProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString(_projectsKey);
      
      if (projectsJson != null) {
        final projects = jsonDecode(projectsJson) as List;
        return projects.map((p) => FreedomeProject.fromJson(p)).toList();
      }
    } catch (e) {
      print('Ошибка получения списка проектов: $e');
    }
    
    return [];
  }
  
  /// Удалить проект
  Future<bool> deleteProject(String projectId) async {
    try {
      final projects = await getAllProjects();
      projects.removeWhere((p) => p.id == projectId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_projectsKey, jsonEncode(projects.map((p) => p.toJson()).toList()));
      
      return true;
    } catch (e) {
      print('Ошибка удаления проекта: $e');
      return false;
    }
  }
  
  /// Установить текущий проект
  Future<void> setCurrentProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentProjectKey, projectId);
  }
  
  /// Получить текущий проект
  Future<FreedomeProject?> getCurrentProject() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectId = prefs.getString(_currentProjectKey);
      
      if (projectId != null) {
        return await loadProject(projectId);
      }
    } catch (e) {
      print('Ошибка получения текущего проекта: $e');
    }
    
    return null;
  }
  
  /// Экспортировать проект в файл
  Future<String?> exportProject(FreedomeProject project, String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = jsonEncode(project.toJson());
      await file.writeAsString(jsonString);
      return filePath;
    } catch (e) {
      print('Ошибка экспорта проекта: $e');
      return null;
    }
  }
  
  /// Импортировать проект из файла
  Future<FreedomeProject?> importProject(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final projectData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Генерируем новый ID для импортированного проекта
      projectData['id'] = _generateId();
      projectData['modified'] = DateTime.now().toIso8601String();
      
      final project = FreedomeProject.fromJson(projectData);
      await _saveProject(project);
      
      return project;
    } catch (e) {
      print('Ошибка импорта проекта: $e');
      return null;
    }
  }
  
  /// Получить путь к директории документов
  Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  /// Получить путь к директории проектов
  Future<String> getProjectsDirectory() async {
    final documentsDir = await getDocumentsDirectory();
    final projectsDir = Directory('$documentsDir/FreedomeSphere/Projects');
    
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    
    return projectsDir.path;
  }
  
  /// Сохранить проект в SharedPreferences
  Future<void> _saveProject(FreedomeProject project) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await getAllProjects();
    
    // Удаляем старую версию проекта если она существует
    projects.removeWhere((p) => p.id == project.id);
    
    // Добавляем обновленную версию
    projects.add(project);
    
    // Сортируем по дате изменения (новые сверху)
    projects.sort((a, b) => b.modified.compareTo(a.modified));
    
    await prefs.setString(_projectsKey, jsonEncode(projects.map((p) => p.toJson()).toList()));
  }
  
  /// Генерировать уникальный ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
