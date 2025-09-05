// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Freedome Sphere';

  @override
  String get new => 'New';

  @override
  String get open => 'Open';

  @override
  String get save => 'Save';

  @override
  String get play => 'Play';

  @override
  String get stop => 'Stop';

  @override
  String get reset => 'Reset';

  @override
  String get ready => 'Ready';

  @override
  String get loadingProject => 'Loading project...';

  @override
  String get projectLoaded => 'Project loaded';

  @override
  String get noProject => 'No project';

  @override
  String errorLoadingProject(String error) {
    return 'Error loading project: $error';
  }

  @override
  String get creatingNewProject => 'Creating new project...';

  @override
  String get newProjectCreated => 'New project created';

  @override
  String errorCreatingProject(String error) {
    return 'Error creating project: $error';
  }

  @override
  String get openingProject => 'Opening project...';

  @override
  String get savingProject => 'Saving project...';

  @override
  String get projectSaved => 'Project saved';

  @override
  String get saveFailed => 'Save failed';

  @override
  String errorSavingProject(String error) {
    return 'Error saving project: $error';
  }

  @override
  String get playingPreview => 'Playing preview...';

  @override
  String get previewStopped => 'Preview stopped';

  @override
  String get viewReset => 'View reset';

  @override
  String get newProject => 'New Project';

  @override
  String get projectName => 'Project Name';

  @override
  String get enterProjectName => 'Enter project name';

  @override
  String get pleaseEnterProjectName => 'Please enter a project name';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get enterProjectDescription => 'Enter project description';

  @override
  String get tagsOptional => 'Tags (Optional)';

  @override
  String get enterTagsSeparatedByCommas => 'Enter tags separated by commas';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get project => 'Project';

  @override
  String get currentProject => 'Current Project';

  @override
  String created(String date) {
    return 'Created: $date';
  }

  @override
  String modified(String date) {
    return 'Modified: $date';
  }

  @override
  String get import => 'Import';

  @override
  String get barankoComics => 'Baranko Comics';

  @override
  String get unrealEngine => 'Unreal Engine';

  @override
  String get blenderModel => 'Blender Model';

  @override
  String get audio => 'Audio';

  @override
  String get anantaSoundSetup => 'anAntaSound Setup';

  @override
  String get threeDPositioning => '3D Positioning';

  @override
  String get loadDagaFile => 'Load .daga File';

  @override
  String get threeDContent => '3D Content';

  @override
  String get loadZelimFile => 'Load .zelim File';

  @override
  String get domeSettings => 'Dome Settings';

  @override
  String get domeConfiguration => 'Dome Configuration';

  @override
  String radius(String radius) {
    return 'Radius: ${radius}m';
  }

  @override
  String get projectionType => 'Projection Type:';

  @override
  String get spherical => 'Spherical';

  @override
  String get fisheye => 'Fisheye';

  @override
  String get equirectangular => 'Equirectangular';

  @override
  String get export => 'Export';

  @override
  String get mbharataClient => 'mbharata_client';

  @override
  String get domeProjection => 'Dome Projection';

  @override
  String get pleaseCreateOrOpenProject => 'Please create or open a project first';

  @override
  String get importingBarankoComics => 'Importing Baranko comics...';

  @override
  String get importingUnrealEngineScene => 'Importing Unreal Engine scene...';

  @override
  String get importingBlenderModel => 'Importing Blender model...';

  @override
  String get settingUpAnantaSound => 'Setting up anAntaSound...';

  @override
  String get opening3dAudioEditor => 'Opening 3D Audio editor...';

  @override
  String get loadingDagaFile => 'Loading .daga file...';

  @override
  String get loadingZelimFile => 'Loading .zelim file...';

  @override
  String get exportingToMbharata => 'Exporting to mbharata_client...';

  @override
  String get exportingDomeProjection => 'Exporting dome projection...';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get thai => 'ไทย';

  @override
  String get hindi => 'हिन्दी';
}
