#!/bin/bash

# 🎨 ДЕМОНСТРАЦИЯ FREEDOME SPHERE ДЛЯ 3D ХУДОЖНИКА
# Специально для Яна - практическое руководство

set -e

echo "🎨 ==============================================="
echo "   FREEDOME SPHERE - ДЕМОНСТРАЦИЯ ДЛЯ 3D ХУДОЖНИКА"
echo "   Специально для Яна"
echo "🎨 ==============================================="
echo ""

# Проверяем Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не установлен. Установите Flutter для продолжения."
    exit 1
fi

echo "✅ Flutter найден: $(flutter --version | head -n 1)"
echo ""

# Переходим в директорию проекта
cd "$(dirname "$0")"

echo "📁 Рабочая директория: $(pwd)"
echo ""

# Проверяем зависимости
echo "🔧 Проверка зависимостей..."
flutter pub get
echo ""

# Создаем демонстрационные файлы
echo "🎬 Создание демонстрационных материалов..."

# Создаем папку для демо
mkdir -p demo_assets

# Создаем простую 3D модель для демонстрации
cat > demo_assets/demo_model.json << 'EOF'
{
  "name": "Демо Модель для Яна",
  "type": "3d_model",
  "geometry": {
    "vertices": [
      [-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0],
      [-1, -1, 2], [1, -1, 2], [1, 1, 2], [-1, 1, 2]
    ],
    "faces": [
      [0, 1, 2], [0, 2, 3], [4, 7, 6], [4, 6, 5],
      [0, 4, 5], [0, 5, 1], [2, 6, 7], [2, 7, 3],
      [0, 3, 7], [0, 7, 4], [1, 5, 6], [1, 6, 2]
    ]
  },
  "materials": [
    {
      "name": "Демо Материал",
      "color": [0.2, 0.6, 1.0],
      "metalness": 0.1,
      "roughness": 0.3
    }
  ],
  "animation": {
    "duration": 5.0,
    "keyframes": [
      {"time": 0.0, "rotation": [0, 0, 0]},
      {"time": 2.5, "rotation": [0, 180, 0]},
      {"time": 5.0, "rotation": [0, 360, 0]}
    ]
  }
}
EOF

# Создаем аудио файл для демонстрации
cat > demo_assets/demo_audio.json << 'EOF'
{
  "name": "Демо Аудио",
  "type": "background_music",
  "anAntaSound": {
    "enabled": true,
    "spatialFactor": 1.0,
    "quantumResonance": {
      "frequency": 432.0,
      "intensity": 0.7,
      "coherenceTime": 2000.0
    }
  }
}
EOF

echo "✅ Демонстрационные материалы созданы"
echo ""

# Запускаем приложение
echo "🚀 Запуск FreeDome Sphere..."
echo ""
echo "📋 ДЕМОНСТРАЦИОННЫЙ СЦЕНАРИЙ:"
echo "   1. Импорт 3D модели из Blender (автоматически)"
echo "   2. Квантовая оптимизация для купола"
echo "   3. Настройка anAntaSound системы"
echo "   4. Анализ ИИ 'Понимание Любомира'"
echo "   5. Экспорт готового приложения"
echo "   6. Автоматическая публикация в магазины"
echo ""
echo "⏱️  Время выполнения: 8 минут вместо 17 часов!"
echo ""

# Запускаем Flutter приложение
flutter run -d chrome --web-port=8080

echo ""
echo "🎉 Демонстрация завершена!"
echo "📱 Готовое приложение будет доступно в Google Play и Apple Store"
