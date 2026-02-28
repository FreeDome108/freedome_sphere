import '../models/comics_project.dart';
import '../models/boranko_project.dart';

/// Сервис для создания маппинга между слоями и звуками
///
/// BORANKO V1.1: Определяет какие звуки привязаны к каким слоям
/// на основе анализа временных интервалов анимаций
class BorankoLayerSoundMapper {
  /// Создать маппинг звуков к слоям
  ///
  /// Анализирует временные интервалы анимаций слоев и звуков
  /// и определяет связи между ними
  Map<String, List<String>> mapSoundsToLayers(
    List<ComicsLayer> layers,
    List<ComicsSound> sounds,
  ) {
    final mapping = <String, List<String>>{};

    print('🔗 BORANKO V1.1: Создание маппинга слоев и звуков...');

    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final layerId = 'layer_$i';
      mapping[layerId] = [];

      // Получаем временные интервалы анимаций слоя
      final layerTimeRanges = _getLayerTimeRanges(layer);

      for (int j = 0; j < sounds.length; j++) {
        final sound = sounds[j];
        final soundId = 'sound_$j';

        // Получаем временные интервалы звука
        final soundTimeRanges = _getSoundTimeRanges(sound);

        // Проверяем, пересекаются ли временные интервалы
        if (_hasTimeOverlap(layerTimeRanges, soundTimeRanges)) {
          mapping[layerId]!.add(soundId);
          print('   🔗 $layerId <-> $soundId (${sound.file})');
        }
      }
    }

    return mapping;
  }

  /// Создать список BorankoSound с привязкой к слоям
  List<BorankoSound> createBorankoSounds(
    List<ComicsSound> comicsSounds,
    Map<String, List<String>> mapping,
    String soundsDir,
  ) {
    final borankoSounds = <BorankoSound>[];

    for (int i = 0; i < comicsSounds.length; i++) {
      final comicsSound = comicsSounds[i];
      final soundId = 'sound_$i';

      // Находим все слои, к которым привязан этот звук
      final linkedLayers = <String>[];
      mapping.forEach((layerId, soundIds) {
        if (soundIds.contains(soundId)) {
          linkedLayers.add(layerId);
        }
      });

      // Если звук привязан только к одному слою, используем layerId
      // Если к нескольким или ни к одному - оставляем null (глобальный)
      final layerId = linkedLayers.length == 1 ? linkedLayers.first : null;

      final borankoSound = BorankoSound(
        id: soundId,
        soundPath: 'sounds/${comicsSound.file}',
        startTime:
            comicsSound.startTime / 1000.0, // конвертируем из ms в секунды
        volume: 1.0,
        layerId: layerId, // V1.1: привязка к слою
      );

      borankoSounds.add(borankoSound);

      if (layerId != null) {
        print('   🔊 Звук $soundId привязан к слою $layerId');
      } else {
        print('   🔊 Звук $soundId глобальный (${linkedLayers.length} слоев)');
      }
    }

    return borankoSounds;
  }

  /// Получить временные интервалы для слоя
  List<TimeRange> _getLayerTimeRanges(ComicsLayer layer) {
    final ranges = <TimeRange>[];

    for (final anim in layer.animations) {
      if (anim.isTranslate || anim.isScale || anim.isRotate) {
        final start = anim.startTime ?? 0;
        final end = anim.endTime ?? start;
        ranges.add(TimeRange(start, end));
      }
    }

    return ranges.isEmpty ? [TimeRange(0, 999999)] : ranges;
  }

  /// Получить временные интервалы для звука
  List<TimeRange> _getSoundTimeRanges(ComicsSound sound) {
    final ranges = <TimeRange>[];

    for (final anim in sound.animations) {
      if (anim.isSound) {
        final start = anim.startTime ?? 0;
        final end = anim.endTime ?? (start + 5000); // по умолчанию 5 сек
        ranges.add(TimeRange(start, end));
      }
    }

    return ranges.isEmpty
        ? [TimeRange(sound.startTime, sound.startTime + 5000)]
        : ranges;
  }

  /// Проверить, пересекаются ли временные интервалы
  bool _hasTimeOverlap(List<TimeRange> ranges1, List<TimeRange> ranges2) {
    for (final r1 in ranges1) {
      for (final r2 in ranges2) {
        if (_rangesOverlap(r1, r2)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Проверить, пересекаются ли два временных интервала
  bool _rangesOverlap(TimeRange r1, TimeRange r2) {
    return r1.start <= r2.end && r2.start <= r1.end;
  }

  /// Создать страницы Boranko с привязкой звуков
  List<BorankoPage> createBorankoPages(
    List<ComicsLayer> layers,
    List<BorankoSound> sounds,
    Map<String, List<String>> mapping,
    String layersDir,
  ) {
    final pages = <BorankoPage>[];

    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final layerId = 'layer_$i';

      // Получаем звуки для этого слоя
      final layerSounds = sounds
          .where((sound) => sound.layerId == layerId)
          .toList();

      // Получаем имя файла изображения
      final imageFile = layer.mainImageFile;
      if (imageFile == null) continue;

      // Создаем страницу
      final page = BorankoPage(
        id: 'page_$i',
        pageNumber: i + 1,
        imagePath: 'layers/$imageFile',
        fileName: imageFile,
        originalPath: 'layers/$imageFile',
        zDepth: 100.0,
        domeOptimized: false,
        quantumCompatible: false,
        sounds: layerSounds,
      );

      pages.add(page);
    }

    return pages;
  }

  /// Анализ и вывод статистики маппинга
  void printMappingStats(
    Map<String, List<String>> mapping,
    List<ComicsSound> sounds,
  ) {
    print('\n📊 Статистика маппинга:');

    int layersWithSounds = 0;
    int totalConnections = 0;

    mapping.forEach((layerId, soundIds) {
      if (soundIds.isNotEmpty) {
        layersWithSounds++;
        totalConnections += soundIds.length;
      }
    });

    final globalSounds = sounds.length - totalConnections;

    print('   📁 Слоев со звуками: $layersWithSounds');
    print('   🔗 Всего связей: $totalConnections');
    print('   🌍 Глобальных звуков: $globalSounds');
  }
}

/// Временной интервал
class TimeRange {
  final int start;
  final int end;

  TimeRange(this.start, this.end);

  @override
  String toString() => '[$start-$end]';
}

