
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedome_sphere_flutter/services/project_service.dart';
import 'package:freedome_sphere_flutter/models/project.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProjectService', () {
    late ProjectService projectService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      projectService = ProjectService();
    });

    test('createNewProject creates a new project', () async {
      final projectName = 'Test Project';
      final project = await projectService.createNewProject(name: projectName);

      expect(project.name, projectName);
      expect(project.description, '');
      expect(project.tags, []);
    });

    test('loadProject loads a project', () async {
      final project = FreedomeProject(
        id: '1',
        name: 'Test Project',
        created: DateTime.now(),
        modified: DateTime.now(),
        dome: DomeSettings(resolution: Resolution(width: 4096, height: 2048)),
        settings: ProjectSettings(),
      );
      final projects = [project];
      final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('freedome_projects', projectsJson);

      final loadedProject = await projectService.loadProject('1');

      expect(loadedProject, isNotNull);
      expect(loadedProject!.id, '1');
    });

    test('saveProject saves a project', () async {
      final project = FreedomeProject(
        id: '1',
        name: 'Test Project',
        created: DateTime.now(),
        modified: DateTime.now(),
        dome: DomeSettings(resolution: Resolution(width: 4096, height: 2048)),
        settings: ProjectSettings(),
      );

      final result = await projectService.saveProject(project);

      expect(result, isTrue);
    });

    test('getAllProjects returns all projects', () async {
      final project1 = FreedomeProject(
        id: '1',
        name: 'Test Project 1',
        created: DateTime.now(),
        modified: DateTime.now(),
        dome: DomeSettings(resolution: Resolution(width: 4096, height: 2048)),
        settings: ProjectSettings(),
      );
      final project2 = FreedomeProject(
        id: '2',
        name: 'Test Project 2',
        created: DateTime.now(),
        modified: DateTime.now(),
        dome: DomeSettings(resolution: Resolution(width: 4096, height: 2048)),
        settings: ProjectSettings(),
      );
      final projects = [project1, project2];
      final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('freedome_projects', projectsJson);

      final allProjects = await projectService.getAllProjects();

      expect(allProjects.length, 2);
    });

    test('deleteProject deletes a project', () async {
      final project = FreedomeProject(
        id: '1',
        name: 'Test Project',
        created: DateTime.now(),
        modified: DateTime.now(),
        dome: DomeSettings(resolution: Resolution(width: 4096, height: 2048)),
        settings: ProjectSettings(),
      );
      final projects = [project];
      final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('freedome_projects', projectsJson);

      final result = await projectService.deleteProject('1');

      expect(result, isTrue);
    });

    test('setCurrentProject sets the current project', () async {
      await projectService.setCurrentProject('1');

      final prefs = await SharedPreferences.getInstance();
      final currentProjectId = prefs.getString('current_project');

      expect(currentProjectId, '1');
    });

    test('getCurrentProject gets the current project', () async {
      final project = FreedomeProject(
        id: '1',
        name: 'Test Project',
        created: DateTime.now(),
        modified: DateTime.now(),
        dome: DomeSettings(resolution: Resolution(width: 4096, height: 2048)),
        settings: ProjectSettings(),
      );
      final projects = [project];
      final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_project', '1');
      await prefs.setString('freedome_projects', projectsJson);

      final currentProject = await projectService.getCurrentProject();

      expect(currentProject, isNotNull);
      expect(currentProject!.id, '1');
    });
  });
}
