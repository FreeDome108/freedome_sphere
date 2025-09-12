// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Сфера Харконненов';

  @override
  String get newButton => 'Захватить';

  @override
  String get open => 'Вскрыть';

  @override
  String get save => 'Сохранить в хранилище';

  @override
  String get play => 'Активировать';

  @override
  String get stop => 'Прекратить';

  @override
  String get reset => 'Уничтожить';

  @override
  String get ready => 'К бою готов';

  @override
  String get loadingProject => 'Загружаю проект в бункер...';

  @override
  String get projectLoaded => 'Проект захвачен';

  @override
  String get noProject => 'Нет добычи';

  @override
  String errorLoadingProject(String error) {
    return 'Ошибка захвата проекта: $error';
  }

  @override
  String get creatingNewProject => 'Создаю новую крепость...';

  @override
  String get newProjectCreated => 'Крепость построена';

  @override
  String errorCreatingProject(String error) {
    return 'Ошибка строительства крепости: $error';
  }

  @override
  String get openingProject => 'Вскрываю проект...';

  @override
  String get savingProject => 'Сохраняю в тайники...';

  @override
  String get projectSaved => 'Спрятано в тайнике';

  @override
  String get saveFailed => 'Тайник взломан';

  @override
  String errorSavingProject(String error) {
    return 'Ошибка сокрытия: $error';
  }

  @override
  String get playingPreview => 'Демонстрирую мощь...';

  @override
  String get previewStopped => 'Демонстрация завершена';

  @override
  String get viewReset => 'Обзор обнулен';

  @override
  String get newProject => 'Новая Крепость';

  @override
  String get projectName => 'Название крепости';

  @override
  String get enterProjectName => 'Введите название крепости';

  @override
  String get pleaseEnterProjectName => 'Укажите название крепости';

  @override
  String get descriptionOptional => 'Описание (по желанию)';

  @override
  String get enterProjectDescription => 'Опишите крепость';

  @override
  String get tagsOptional => 'Метки (по желанию)';

  @override
  String get enterTagsSeparatedByCommas => 'Метки через запятую';

  @override
  String get cancel => 'Отступить';

  @override
  String get create => 'Построить';

  @override
  String get project => 'Крепость';

  @override
  String get currentProject => 'Текущая крепость';

  @override
  String created(String date) {
    return 'Построена: $date';
  }

  @override
  String modified(String date) {
    return 'Укреплена: $date';
  }

  @override
  String get import => 'Захватить';

  @override
  String get importGeneral => 'General Files';

  @override
  String get importBoranko => 'Захватить .boranko';

  @override
  String get importComics => 'Захватить .comics (устарело)';

  @override
  String get comicsDeprecatedTitle => 'Древний формат';

  @override
  String get comicsDeprecatedContent =>
      'Формат .comics устарел как технологии Атрейдесов. Используйте современный .boranko для новых завоеваний.';

  @override
  String get ok => 'Понял';

  @override
  String get importingBorankoProject => 'Захватываю Boranko-проект...';

  @override
  String errorImportingBorankoProject(String error) {
    return 'Ошибка захвата Boranko: $error';
  }

  @override
  String get barankoComics => 'Комиксы Баранко';

  @override
  String get unrealEngine => 'Двигатель Разрушения';

  @override
  String get blenderModel => 'Модель Блендера';

  @override
  String get audio => 'Звуковое оружие';

  @override
  String get anantaSoundSetup => 'Настройка anAntaSound';

  @override
  String get threeDPositioning => '3D-позиционирование';

  @override
  String get loadDagaFile => 'Загрузить .daga файл';

  @override
  String get threeDContent => '3D-контент';

  @override
  String get loadZelimFile => 'Загрузить .zelim файл';

  @override
  String get domeSettings => 'Настройки купола';

  @override
  String get domeConfiguration => 'Конфигурация купола';

  @override
  String radius(String radius) {
    return 'Радиус: $radiusм';
  }

  @override
  String get projectionType => 'Тип проекции:';

  @override
  String get spherical => 'Сферическая';

  @override
  String get fisheye => 'Рыбий глаз';

  @override
  String get equirectangular => 'Равнопрямоугольная';

  @override
  String get export => 'Экспортировать';

  @override
  String get mbharataClient => 'mbharata_client';

  @override
  String get domeProjection => 'Проекция купола';

  @override
  String get pleaseCreateOrOpenProject =>
      'Сначала постройте или захватите крепость';

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
  String get language => 'Язык империи';

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
  String get homeScreenTitle => 'Сфера Харконненов';

  @override
  String get gifImporterTooltip => 'GIF Importer';

  @override
  String get jpgImporterTooltip => 'JPG Importer';

  @override
  String get videoImporterTooltip => 'Video Importer';

  @override
  String get tutorialsTooltip => 'Tutorials';

  @override
  String get lyubomirLearningSystemTooltip => 'Система обучения Любомира';

  @override
  String get anantaSoundTooltip => 'anAntaSound Quantum Resonance Device';

  @override
  String get unrealOptimizerTooltip => 'Unreal Engine Optimizer';

  @override
  String get borankoImportSuccess => 'Boranko project imported successfully';

  @override
  String get anantaSoundScreenTitle => 'Звуковое оружие anAntaSound';

  @override
  String get active => 'Активно';

  @override
  String get inactive => 'Неактивно';

  @override
  String get initializingQuantumResonanceDevice =>
      'Initializing Quantum Resonance Device...';

  @override
  String get mp3Management => 'MP3 Management';

  @override
  String get loadMp3 => 'Load MP3';

  @override
  String loadedFile(String fileName) {
    return 'Loaded file: $fileName';
  }

  @override
  String get participantManagement => 'Participant Management';

  @override
  String get addParticipant => 'Add Participant';

  @override
  String get removeParticipant => 'Remove Participant';

  @override
  String get activeParticipants => 'Active Participants:';

  @override
  String participant(int index) {
    return 'Participant $index';
  }

  @override
  String participantDetails(String weight, String r, String theta, String phi) {
    return 'Weight: $weight | Position: ($r, $theta, $phi)';
  }

  @override
  String get realTimeData => 'Real-time Data';

  @override
  String get frequency => 'Частота';

  @override
  String get intensity => 'Интенсивность';

  @override
  String get participants => 'Участники';

  @override
  String get midi => 'MIDI';

  @override
  String get connected => 'Подключено';

  @override
  String get disconnected => 'Отключено';

  @override
  String get osc => 'OSC';

  @override
  String get consciousness => 'Сознание';

  @override
  String get linked => 'Связано';

  @override
  String get notLinked => 'Не связано';

  @override
  String hzUnit(String value) {
    return '$value Hz';
  }

  @override
  String percentageUnit(String value) {
    return '$value%';
  }
}
