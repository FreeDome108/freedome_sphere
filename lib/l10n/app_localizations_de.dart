// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Freedome Sphere';

  @override
  String get newButton => 'Neu';

  @override
  String get open => 'Öffnen';

  @override
  String get save => 'Speichern';

  @override
  String get play => 'Abspielen';

  @override
  String get stop => 'Stoppen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get ready => 'Bereit';

  @override
  String get loadingProject => 'Projekt wird geladen...';

  @override
  String get projectLoaded => 'Projekt geladen';

  @override
  String get noProject => 'Kein Projekt';

  @override
  String errorLoadingProject(String error) {
    return 'Fehler beim Laden des Projekts: $error';
  }

  @override
  String get creatingNewProject => 'Neues Projekt wird erstellt...';

  @override
  String get newProjectCreated => 'Neues Projekt erstellt';

  @override
  String errorCreatingProject(String error) {
    return 'Fehler beim Erstellen des Projekts: $error';
  }

  @override
  String get openingProject => 'Projekt wird geöffnet...';

  @override
  String get savingProject => 'Projekt wird gespeichert...';

  @override
  String get projectSaved => 'Projekt gespeichert';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String errorSavingProject(String error) {
    return 'Fehler beim Speichern des Projekts: $error';
  }

  @override
  String get playingPreview => 'Vorschau wird abgespielt...';

  @override
  String get previewStopped => 'Vorschau gestoppt';

  @override
  String get viewReset => 'Ansicht zurückgesetzt';

  @override
  String get newProject => 'Neues Projekt';

  @override
  String get projectName => 'Projektname';

  @override
  String get enterProjectName => 'Projektname eingeben';

  @override
  String get pleaseEnterProjectName => 'Bitte geben Sie einen Projektnamen ein';

  @override
  String get descriptionOptional => 'Beschreibung (Optional)';

  @override
  String get enterProjectDescription => 'Projektbeschreibung eingeben';

  @override
  String get tagsOptional => 'Tags (Optional)';

  @override
  String get enterTagsSeparatedByCommas =>
      'Tags durch Kommas getrennt eingeben';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get project => 'Projekt';

  @override
  String get currentProject => 'Aktuelles Projekt';

  @override
  String created(String date) {
    return 'Erstellt: $date';
  }

  @override
  String modified(String date) {
    return 'Geändert: $date';
  }

  @override
  String get import => 'Importieren';

  @override
  String get importGeneral => 'Allgemeine Dateien';

  @override
  String get importBoranko => '.boranko importieren';

  @override
  String get importComics => '.comics importieren (veraltet)';

  @override
  String get comicsDeprecatedTitle => 'Veraltetes Format';

  @override
  String get comicsDeprecatedContent =>
      'Das .comics-Format ist veraltet und wird in einer zukünftigen Version entfernt. Bitte verwenden Sie das moderne .boranko-Format für alle neuen 2D-Projekte.';

  @override
  String get ok => 'OK';

  @override
  String get importingBorankoProject => 'Boranko-Projekt wird importiert...';

  @override
  String errorImportingBorankoProject(String error) {
    return 'Fehler beim Importieren des Boranko-Projekts: $error';
  }

  @override
  String get barankoComics => 'Baranko Comics';

  @override
  String get unrealEngine => 'Unreal Engine';

  @override
  String get blenderModel => 'Blender-Modell';

  @override
  String get audio => 'Audio';

  @override
  String get anantaSoundSetup => 'anAntaSound-Setup';

  @override
  String get threeDPositioning => '3D-Positionierung';

  @override
  String get loadDagaFile => '.daga-Datei laden';

  @override
  String get threeDContent => '3D-Inhalt';

  @override
  String get loadZelimFile => '.zelim-Datei laden';

  @override
  String get domeSettings => 'Kuppel-Einstellungen';

  @override
  String get domeConfiguration => 'Kuppel-Konfiguration';

  @override
  String radius(String radius) {
    return 'Radius: ${radius}m';
  }

  @override
  String get projectionType => 'Projektionstyp:';

  @override
  String get spherical => 'Sphärisch';

  @override
  String get fisheye => 'Fisheye';

  @override
  String get equirectangular => 'Equirectangular';

  @override
  String get export => 'Exportieren';

  @override
  String get mbharataClient => 'mbharata_client';

  @override
  String get domeProjection => 'Kuppel-Projektion';

  @override
  String get pleaseCreateOrOpenProject =>
      'Bitte erstellen oder öffnen Sie zuerst ein Projekt';

  @override
  String get importingBarankoComics => 'Baranko-Comics werden importiert...';

  @override
  String get importingUnrealEngineScene =>
      'Unreal Engine-Szene wird importiert...';

  @override
  String get importingBlenderModel => 'Blender-Modell wird importiert...';

  @override
  String get settingUpAnantaSound => 'anAntaSound wird eingerichtet...';

  @override
  String get opening3dAudioEditor => '3D-Audio-Editor wird geöffnet...';

  @override
  String get loadingDagaFile => '.daga-Datei wird geladen...';

  @override
  String get loadingZelimFile => '.zelim-Datei wird geladen...';

  @override
  String get exportingToMbharata => 'Export zu mbharata_client...';

  @override
  String get exportingDomeProjection => 'Kuppel-Projektion wird exportiert...';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get thai => 'ไทย';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get german => 'Deutsch';

  @override
  String get harkonnen => 'Харконнены';

  @override
  String get atreides => 'Атрейдесы';

  @override
  String get petrosyan => 'Петросян';

  @override
  String get homeScreenTitle => 'FreeDome Sphere';

  @override
  String get gifImporterTooltip => 'GIF-Importer';

  @override
  String get jpgImporterTooltip => 'JPG-Importer';

  @override
  String get videoImporterTooltip => 'Video-Importer';

  @override
  String get tutorialsTooltip => 'Tutorials';

  @override
  String get lyubomirLearningSystemTooltip => 'Lyubomir Lernsystem';

  @override
  String get anantaSoundTooltip => 'anAntaSound Quantenresonanzgerät';

  @override
  String get unrealOptimizerTooltip => 'Unreal Engine-Optimierer';

  @override
  String get borankoImportSuccess => 'Boranko-Projekt erfolgreich importiert';

  @override
  String get anantaSoundScreenTitle => 'anAntaSound Quantenresonanzgerät';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get initializingQuantumResonanceDevice =>
      'Quantenresonanzgerät wird initialisiert...';

  @override
  String get mp3Management => 'MP3-Verwaltung';

  @override
  String get loadMp3 => 'MP3 laden';

  @override
  String loadedFile(String fileName) {
    return 'Geladene Datei: $fileName';
  }

  @override
  String get participantManagement => 'Teilnehmerverwaltung';

  @override
  String get addParticipant => 'Teilnehmer hinzufügen';

  @override
  String get removeParticipant => 'Teilnehmer entfernen';

  @override
  String get activeParticipants => 'Aktive Teilnehmer:';

  @override
  String participant(int index) {
    return 'Teilnehmer $index';
  }

  @override
  String participantDetails(String weight, String r, String theta, String phi) {
    return 'Gewicht: $weight | Position: ($r, $theta, $phi)';
  }

  @override
  String get realTimeData => 'Echtzeitdaten';

  @override
  String get frequency => 'Frequenz';

  @override
  String get intensity => 'Intensität';

  @override
  String get participants => 'Teilnehmer';

  @override
  String get midi => 'MIDI';

  @override
  String get connected => 'Verbunden';

  @override
  String get disconnected => 'Getrennt';

  @override
  String get osc => 'OSC';

  @override
  String get consciousness => 'Bewusstsein';

  @override
  String get linked => 'Verknüpft';

  @override
  String get notLinked => 'Nicht verknüpft';

  @override
  String hzUnit(String value) {
    return '$value Hz';
  }

  @override
  String percentageUnit(String value) {
    return '$value%';
  }
}
