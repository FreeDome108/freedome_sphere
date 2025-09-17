import 'lib/services/blender_service.dart';

void main() async {
  print('🔍 Тестирование BlenderService...');
  final service = BlenderService();
  final metadata = service.createHovercarMetadata();
  print('✅ BlenderService создан');
  print('📋 Метаданные hovercar:');
  print('   - Название: ${metadata['name']}');
  print('   - Категория: ${metadata['category']}');
  print('   - Теги: ${metadata['tags'].join(', ')}');
  print('   - Полигоны: ${metadata['polygons']}');
  print('   - Текстуры: ${metadata['textures']}');
  print('   - Материалы: ${metadata['materials']}');
  print('   - Квантовая совместимость: ${metadata['quantumCompatible']}');
  print('');
  print('🎯 Валидация файла...');
  final isValid = await service.validateBlendFile('samples/import/blend/free-cyberpunk-hovercar/source/cdp-test-7.blend');
  print('✅ Файл валиден: $isValid');
}

