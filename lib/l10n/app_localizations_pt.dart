// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Петросян Сфера';

  @override
  String get newButton => 'Новый анекдот';

  @override
  String get open => 'Открыть с юмором';

  @override
  String get save => 'Сохранить шутку';

  @override
  String get play => 'Рассказать';

  @override
  String get stop => 'Хватит шутить';

  @override
  String get reset => 'Забыть анекдот';

  @override
  String get ready => 'Готов шутить';

  @override
  String get loadingProject => 'Загружаю проект... Как долго! Это не анекдот!';

  @override
  String get projectLoaded => 'Проект загружен! А вы думали это шутка?';

  @override
  String get noProject => 'Нет проекта - вот это анекдот!';

  @override
  String errorLoadingProject(String error) {
    return 'Ошибка загрузки: $error. Это не смешно!';
  }

  @override
  String get creatingNewProject =>
      'Создаю новый проект... Надеюсь, он будет смешнее предыдущего!';

  @override
  String get newProjectCreated => 'Новый проект создан! Ха-ха-ха!';

  @override
  String errorCreatingProject(String error) {
    return 'Ошибка создания проекта: $error. Вот это поворот!';
  }

  @override
  String get openingProject => 'Открываю проект... Как коробку с сюрпризом!';

  @override
  String get savingProject => 'Сохраняю проект... Как хорошую шутку в памяти!';

  @override
  String get projectSaved =>
      'Проект сохранен! Теперь он бессмертен как мои анекдоты!';

  @override
  String get saveFailed => 'Сохранение не удалось! Как неудачная шутка...';

  @override
  String errorSavingProject(String error) {
    return 'Ошибка сохранения: $error. Это не смешно!';
  }

  @override
  String get playingPreview => 'Показываю превью... Как фокус!';

  @override
  String get previewStopped => 'Превью остановлено! Занавес!';

  @override
  String get viewReset => 'Вид сброшен! Как память после хорошей шутки!';

  @override
  String get newProject => 'Новый Смешной Проект';

  @override
  String get projectName => 'Название проекта (желательно смешное)';

  @override
  String get enterProjectName => 'Введите название проекта (с юмором!)';

  @override
  String get pleaseEnterProjectName =>
      'Пожалуйста, введите название! Без названия - не анекдот!';

  @override
  String get descriptionOptional => 'Описание (с шутками)';

  @override
  String get enterProjectDescription => 'Опишите проект с юмором';

  @override
  String get tagsOptional => 'Теги (смешные)';

  @override
  String get enterTagsSeparatedByCommas =>
      'Теги через запятую (как паузы в анекдоте)';

  @override
  String get cancel => 'Отменить (как плохую шутку)';

  @override
  String get create => 'Создать с юмором';

  @override
  String get project => 'Проект-анекдот';

  @override
  String get currentProject => 'Текущий проект (надеюсь, смешной)';

  @override
  String created(String date) {
    return 'Создан: $date (хорошая дата для шутки)';
  }

  @override
  String modified(String date) {
    return 'Изменен: $date (стал еще смешнее)';
  }

  @override
  String get import => 'Импорт (как хорошую шутку)';

  @override
  String get importBoranko => 'Импортировать .boranko (с юмором)';

  @override
  String get importComics => 'Импортировать .comics (старые как мои анекдоты)';

  @override
  String get comicsDeprecatedTitle => 'Устаревший формат (как мои шутки)';

  @override
  String get comicsDeprecatedContent =>
      'Формат .comics устарел как анекдоты про компьютеры. Используйте .boranko - он свежее!';

  @override
  String get ok => 'Понял шутку';

  @override
  String get importingBorankoProject =>
      'Импортирую Boranko... Как хорошую шутку!';

  @override
  String errorImportingBorankoProject(String error) {
    return 'Ошибка импорта Boranko: $error. Это не смешно!';
  }

  @override
  String get barankoComics => 'Комиксы Баранко (смешные)';

  @override
  String get unrealEngine => 'Нереальный Двигатель (как мои гонорары)';

  @override
  String get blenderModel => 'Модель Блендера (перемешаю с юмором)';

  @override
  String get audio => 'Звук (смеха)';

  @override
  String get anantaSoundSetup => 'Настройка anAntaSound (для смеха)';

  @override
  String get threeDPositioning => '3D-позиционирование (как в анекдоте)';

  @override
  String get loadDagaFile => 'Загрузить .daga файл (с юмором)';

  @override
  String get threeDContent => '3D-контент (объемные шутки)';

  @override
  String get loadZelimFile => 'Загрузить .zelim файл (зеленый юмор)';

  @override
  String get domeSettings => 'Настройки купола (цирка)';

  @override
  String get domeConfiguration => 'Конфигурация купола (для выступлений)';

  @override
  String radius(String radius) {
    return 'Радиус: $radiusм (размер зала для шуток)';
  }

  @override
  String get projectionType => 'Тип проекции (как подача шутки):';

  @override
  String get spherical => 'Сферическая (объемная шутка)';

  @override
  String get fisheye => 'Рыбий глаз (как у зрителей)';

  @override
  String get equirectangular => 'Равнопрямоугольная (как хорошая шутка)';

  @override
  String get export => 'Экспорт (шуток)';

  @override
  String get mbharataClient => 'mbharata_client (клиент для смеха)';

  @override
  String get domeProjection => 'Проекция купола (цирка)';

  @override
  String get pleaseCreateOrOpenProject =>
      'Сначала создайте проект! Без проекта - не анекдот!';

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
  String get language => 'Язык юмора';

  @override
  String get english => 'English (серьезный)';

  @override
  String get russian => 'Русский (классический)';

  @override
  String get thai => 'ไทย (экзотический)';

  @override
  String get hindi => 'हिन्दी (болливудский)';

  @override
  String get german => 'Deutsch (без юмора)';

  @override
  String get harkonnen => 'Харконнены (злые шутки)';

  @override
  String get atreides => 'Атрейдесы (благородные шутки)';

  @override
  String get petrosyan => 'Петросян (самые смешные)';

  @override
  String get homeScreenTitle => 'Петросян Сфера (Центр Юмора)';

  @override
  String get gifImporterTooltip => 'GIF Importer';

  @override
  String get jpgImporterTooltip => 'JPG Importer';

  @override
  String get videoImporterTooltip => 'Video Importer';

  @override
  String get tutorialsTooltip => 'Tutorials';

  @override
  String get lyubomirUnderstandingTooltip => 'Lyubomir\'s Understanding';

  @override
  String get anantaSoundTooltip => 'anAntaSound Quantum Resonance Device';

  @override
  String get unrealOptimizerTooltip => 'Unreal Engine Optimizer';

  @override
  String get borankoImportSuccess => 'Boranko project imported successfully';

  @override
  String get anantaSoundScreenTitle => 'anAntaSound Устройство Смеха';

  @override
  String get active => 'Активно (как мой юмор)';

  @override
  String get inactive => 'Неактивно (как зрители без чувства юмора)';

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
  String get frequency => 'Частота (шуток в минуту)';

  @override
  String get intensity => 'Интенсивность (смеха)';

  @override
  String get participants => 'Участники (зрители)';

  @override
  String get midi => 'MIDI';

  @override
  String get connected => 'Подключен (к юмору)';

  @override
  String get disconnected => 'Отключен (от юмора)';

  @override
  String get osc => 'OSC';

  @override
  String get consciousness => 'Сознание (чувство юмора)';

  @override
  String get linked => 'Связан (с юмором)';

  @override
  String get notLinked => 'Не связан (без чувства юмора)';

  @override
  String hzUnit(String value) {
    return '$value Hz';
  }

  @override
  String percentageUnit(String value) {
    return '$value%';
  }
}
