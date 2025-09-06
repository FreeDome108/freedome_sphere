// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Freedome Sphere';

  @override
  String get newButton => 'Новый';

  @override
  String get open => 'Открыть';

  @override
  String get save => 'Сохранить';

  @override
  String get play => 'Воспроизвести';

  @override
  String get stop => 'Остановить';

  @override
  String get reset => 'Сбросить';

  @override
  String get ready => 'Готов';

  @override
  String get loadingProject => 'Загрузка проекта...';

  @override
  String get projectLoaded => 'Проект загружен';

  @override
  String get noProject => 'Нет проекта';

  @override
  String errorLoadingProject(String error) {
    return 'Ошибка загрузки проекта: $error';
  }

  @override
  String get creatingNewProject => 'Создание нового проекта...';

  @override
  String get newProjectCreated => 'Новый проект создан';

  @override
  String errorCreatingProject(String error) {
    return 'Ошибка создания проекта: $error';
  }

  @override
  String get openingProject => 'Открытие проекта...';

  @override
  String get savingProject => 'Сохранение проекта...';

  @override
  String get projectSaved => 'Проект сохранен';

  @override
  String get saveFailed => 'Ошибка сохранения';

  @override
  String errorSavingProject(String error) {
    return 'Ошибка сохранения проекта: $error';
  }

  @override
  String get playingPreview => 'Воспроизведение превью...';

  @override
  String get previewStopped => 'Превью остановлено';

  @override
  String get viewReset => 'Вид сброшен';

  @override
  String get newProject => 'Новый проект';

  @override
  String get projectName => 'Название проекта';

  @override
  String get enterProjectName => 'Введите название проекта';

  @override
  String get pleaseEnterProjectName => 'Пожалуйста, введите название проекта';

  @override
  String get descriptionOptional => 'Описание (необязательно)';

  @override
  String get enterProjectDescription => 'Введите описание проекта';

  @override
  String get tagsOptional => 'Теги (необязательно)';

  @override
  String get enterTagsSeparatedByCommas => 'Введите теги через запятую';

  @override
  String get cancel => 'Отмена';

  @override
  String get create => 'Создать';

  @override
  String get project => 'Проект';

  @override
  String get currentProject => 'Текущий проект';

  @override
  String created(String date) {
    return 'Создано';
  }

  @override
  String modified(String date) {
    return 'Изменен: $date';
  }

  @override
  String get import => 'Импорт';

  @override
  String get barankoComics => 'Комиксы Baranko';

  @override
  String get unrealEngine => 'Unreal Engine';

  @override
  String get blenderModel => 'Модель Blender';

  @override
  String get audio => 'Аудио';

  @override
  String get anantaSoundSetup => 'Настройка anAntaSound';

  @override
  String get threeDPositioning => '3D позиционирование';

  @override
  String get loadDagaFile => 'Загрузить .daga файл';

  @override
  String get threeDContent => '3D контент';

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
  String get equirectangular => 'Равнопромежуточная';

  @override
  String get export => 'Экспорт';

  @override
  String get mbharataClient => 'mbharata_client';

  @override
  String get domeProjection => 'Проекция купола';

  @override
  String get pleaseCreateOrOpenProject =>
      'Пожалуйста, создайте или откройте проект';

  @override
  String get importingBarankoComics => 'Импорт комиксов Baranko...';

  @override
  String get importingUnrealEngineScene => 'Импорт сцены Unreal Engine...';

  @override
  String get importingBlenderModel => 'Импорт модели Blender...';

  @override
  String get settingUpAnantaSound => 'Настройка anAntaSound...';

  @override
  String get opening3dAudioEditor => 'Открытие 3D аудио редактора...';

  @override
  String get loadingDagaFile => 'Загрузка .daga файла...';

  @override
  String get loadingZelimFile => 'Загрузка .zelim файла...';

  @override
  String get exportingToMbharata => 'Экспорт в mbharata_client...';

  @override
  String get exportingDomeProjection => 'Экспорт проекции купола...';

  @override
  String get language => 'Язык';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get thai => 'ไทย';

  @override
  String get hindi => 'हिन्दी';
}
