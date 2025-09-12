// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Сфера Атрейдесов';

  @override
  String get newButton => 'Создать';

  @override
  String get open => 'Открыть с честью';

  @override
  String get save => 'Сохранить благородно';

  @override
  String get play => 'Воспроизвести';

  @override
  String get stop => 'Остановить';

  @override
  String get reset => 'Обновить';

  @override
  String get ready => 'Готов служить';

  @override
  String get loadingProject => 'Загружаю проект с достоинством...';

  @override
  String get projectLoaded => 'Проект загружен честно';

  @override
  String get noProject => 'Нет проекта';

  @override
  String errorLoadingProject(String error) {
    return 'Благородная ошибка загрузки: $error';
  }

  @override
  String get creatingNewProject => 'Создаю новый благородный проект...';

  @override
  String get newProjectCreated => 'Благородный проект создан';

  @override
  String errorCreatingProject(String error) {
    return 'Ошибка создания проекта: $error';
  }

  @override
  String get openingProject => 'Открываю проект с честью...';

  @override
  String get savingProject => 'Сохраняю проект благородно...';

  @override
  String get projectSaved => 'Проект сохранен с честью';

  @override
  String get saveFailed => 'Сохранение не удалось';

  @override
  String errorSavingProject(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get playingPreview => 'Воспроизвожу предварительный просмотр...';

  @override
  String get previewStopped => 'Просмотр остановлен';

  @override
  String get viewReset => 'Вид обновлен';

  @override
  String get newProject => 'Новый Благородный Проект';

  @override
  String get projectName => 'Имя проекта';

  @override
  String get enterProjectName => 'Введите благородное имя проекта';

  @override
  String get pleaseEnterProjectName => 'Пожалуйста, укажите имя проекта';

  @override
  String get descriptionOptional => 'Описание (по желанию)';

  @override
  String get enterProjectDescription => 'Опишите благородный проект';

  @override
  String get tagsOptional => 'Метки (по желанию)';

  @override
  String get enterTagsSeparatedByCommas => 'Метки через запятую';

  @override
  String get cancel => 'Отменить';

  @override
  String get create => 'Создать благородно';

  @override
  String get project => 'Проект';

  @override
  String get currentProject => 'Текущий проект';

  @override
  String created(String date) {
    return 'Создан: $date';
  }

  @override
  String modified(String date) {
    return 'Изменен: $date';
  }

  @override
  String get import => 'Импортировать';

  @override
  String get importGeneral => 'General Files';

  @override
  String get importBoranko => 'Импортировать .boranko';

  @override
  String get importComics => 'Импортировать .comics (устарело)';

  @override
  String get comicsDeprecatedTitle => 'Устаревший формат';

  @override
  String get comicsDeprecatedContent =>
      'Формат .comics устарел как старые традиции. Используйте современный .boranko для новых благородных проектов.';

  @override
  String get ok => 'Понятно';

  @override
  String get importingBorankoProject => 'Импортирую Boranko-проект...';

  @override
  String errorImportingBorankoProject(String error) {
    return 'Ошибка импорта Boranko: $error';
  }

  @override
  String get barankoComics => 'Комиксы Баранко';

  @override
  String get unrealEngine => 'Двигатель Реальности';

  @override
  String get blenderModel => 'Модель Блендера';

  @override
  String get audio => 'Благородный звук';

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
      'Пожалуйста, создайте или откройте проект сначала';

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
  String get language => 'Язык дома';

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
  String get homeScreenTitle => 'Сфера Атрейдесов';

  @override
  String get gifImporterTooltip => 'GIF Importer';

  @override
  String get jpgImporterTooltip => 'JPG Importer';

  @override
  String get videoImporterTooltip => 'Video Importer';

  @override
  String get tutorialsTooltip => 'Tutorials';

  @override
  String get lyubomirLearningSystemTooltip => 'نظام التعلم النبيل ليوبومير';

  @override
  String get anantaSoundTooltip => 'anAntaSound Quantum Resonance Device';

  @override
  String get unrealOptimizerTooltip => 'Unreal Engine Optimizer';

  @override
  String get borankoImportSuccess => 'Boranko project imported successfully';

  @override
  String get anantaSoundScreenTitle => 'Благородное устройство anAntaSound';

  @override
  String get active => 'Активен';

  @override
  String get inactive => 'Неактивен';

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
  String get connected => 'Подключен';

  @override
  String get disconnected => 'Отключен';

  @override
  String get osc => 'OSC';

  @override
  String get consciousness => 'Сознание';

  @override
  String get linked => 'Связан';

  @override
  String get notLinked => 'Не связан';

  @override
  String hzUnit(String value) {
    return '$value Hz';
  }

  @override
  String percentageUnit(String value) {
    return '$value%';
  }
}
