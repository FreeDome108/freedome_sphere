#!/bin/bash

echo "🚀 Starting Freedome Sphere Editor..."

# Переход в директорию проекта
cd /Users/anton/proj/FreeDome/HKAPPLICATIONS/mbharata/freedome_sphere

# Проверка наличия Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js не найден. Установите Node.js 18+"
    exit 1
fi

# Проверка версии Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Требуется Node.js 18+. Текущая версия: $(node -v)"
    exit 1
fi

echo "✅ Node.js версия: $(node -v)"

# Проверка наличия package.json
if [ ! -f "package.json" ]; then
    echo "❌ package.json не найден. Убедитесь, что вы находитесь в правильной директории"
    exit 1
fi

# Установка зависимостей если нужно
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Ошибка установки зависимостей"
        exit 1
    fi
    echo "✅ Зависимости установлены"
else
    echo "✅ Зависимости уже установлены"
fi

# Проверка наличия основных файлов
if [ ! -f "src/main.js" ]; then
    echo "❌ src/main.js не найден"
    exit 1
fi

if [ ! -f "src/index.html" ]; then
    echo "❌ src/index.html не найден"
    exit 1
fi

echo "✅ Все файлы на месте"

# Запуск в режиме разработки
echo "🎨 Starting Freedome Sphere Editor..."
echo "📱 Профессиональный редактор для создания контента MBHARATA"
echo "🌐 Поддержка купольного отображения и anAntaSound"
echo "📚 Импорт комиксов Баранько"
echo "🎮 Интеграция с Unreal Engine и Blender"
echo ""
echo "Нажмите Ctrl+C для остановки"
echo ""

npm run dev
