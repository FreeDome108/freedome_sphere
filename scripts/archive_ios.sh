#!/bin/bash

# 🍎 АВТОМАТИЧЕСКОЕ АРХИВИРОВАНИЕ FREEDOME SPHERE ДЛЯ iOS
# Полностью автоматический процесс создания архива и загрузки в App Store Connect

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Проверяем, что мы в правильной директории
if [ ! -f "pubspec.yaml" ]; then
    error "Запустите скрипт из корневой директории проекта FreeDome Sphere"
    exit 1
fi

# Получаем версию из pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)

log "🚀 Начинаем архивирование FreeDome Sphere v$VERSION_NAME (build $BUILD_NUMBER)"

# Проверяем зависимости
log "🔍 Проверка зависимостей..."

# Проверяем Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter не установлен. Установите Flutter для продолжения."
    exit 1
fi

# Проверяем Xcode
if ! command -v xcodebuild &> /dev/null; then
    error "Xcode не установлен. Установите Xcode для продолжения."
    exit 1
fi

# Проверяем xcrun altool
if ! command -v xcrun &> /dev/null; then
    error "Xcode Command Line Tools не установлены."
    exit 1
fi

success "✅ Все зависимости найдены"

# Очистка предыдущих сборок
log "🧹 Очистка предыдущих сборок..."
flutter clean
rm -rf ios/build
rm -rf build/ios

# Получение зависимостей
log "📦 Получение зависимостей Flutter..."
flutter pub get

# Обновление iOS зависимостей
log "🍎 Обновление iOS зависимостей..."
cd ios
pod install --repo-update
cd ..

# Проверка подписи
log "🔐 Проверка настроек подписи..."
DEVELOPMENT_TEAM=$(grep -o 'DEVELOPMENT_TEAM = [^;]*' ios/Runner.xcodeproj/project.pbxproj | head -1 | cut -d' ' -f3)
if [ -z "$DEVELOPMENT_TEAM" ]; then
    error "DEVELOPMENT_TEAM не найден в проекте. Проверьте настройки подписи."
    exit 1
fi

log "📋 Development Team: $DEVELOPMENT_TEAM"

# Создание архива
log "📦 Создание архива iOS приложения..."

# Создаем директорию для архива
ARCHIVE_DIR="build/ios/archive"
mkdir -p "$ARCHIVE_DIR"

# Путь к архиву
ARCHIVE_PATH="$ARCHIVE_DIR/FreeDomeSphere.xcarchive"

# Создаем архив
xcodebuild archive \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
    PRODUCT_BUNDLE_IDENTIFIER="net.nativemind.freedome.sphere" \
    MARKETING_VERSION="$VERSION_NAME" \
    CURRENT_PROJECT_VERSION="$BUILD_NUMBER"

if [ ! -d "$ARCHIVE_PATH" ]; then
    error "Не удалось создать архив"
    exit 1
fi

success "✅ Архив создан: $ARCHIVE_PATH"

# Экспорт IPA
log "📱 Экспорт IPA файла..."

EXPORT_DIR="build/ios/export"
mkdir -p "$EXPORT_DIR"

# Экспортируем IPA
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist ios/ExportOptions.plist \
    -allowProvisioningUpdates

IPA_PATH="$EXPORT_DIR/Runner.ipa"

if [ ! -f "$IPA_PATH" ]; then
    error "Не удалось экспортировать IPA файл"
    exit 1
fi

success "✅ IPA файл создан: $IPA_PATH"

# Проверка размера файла
IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
log "📊 Размер IPA файла: $IPA_SIZE"

# Загрузка в App Store Connect
log "☁️ Загрузка в App Store Connect..."

# Проверяем, что пользователь авторизован
if ! xcrun altool --list-providers -u "$(git config user.email)" &> /dev/null; then
    warning "Требуется авторизация в App Store Connect"
    log "Выполните: xcrun altool --store-password-in-keychain-item 'AC_PASSWORD' -u 'your-email@example.com' -p 'your-app-specific-password'"
    
    # Пытаемся загрузить с помощью сохраненных учетных данных
    if [ -n "$APPLE_ID" ] && [ -n "$APPLE_PASSWORD" ]; then
        log "Используем переменные окружения для авторизации..."
        xcrun altool --upload-app \
            -f "$IPA_PATH" \
            -u "$APPLE_ID" \
            -p "$APPLE_PASSWORD" \
            --type ios \
            --verbose
    else
        warning "Переменные окружения APPLE_ID и APPLE_PASSWORD не установлены"
        log "Для автоматической загрузки установите:"
        log "export APPLE_ID='your-email@example.com'"
        log "export APPLE_PASSWORD='your-app-specific-password'"
        log ""
        log "IPA файл готов для ручной загрузки: $IPA_PATH"
        log "Загрузите его через Xcode Organizer или Transporter"
    fi
else
    # Автоматическая загрузка
    xcrun altool --upload-app \
        -f "$IPA_PATH" \
        -u "$(git config user.email)" \
        --type ios \
        --verbose
fi

# Проверка статуса загрузки
if [ $? -eq 0 ]; then
    success "🎉 Приложение успешно загружено в App Store Connect!"
    log "📱 Проверьте статус в App Store Connect: https://appstoreconnect.apple.com"
    log "⏱️ Обработка может занять 10-30 минут"
else
    warning "⚠️ Возможны проблемы с загрузкой. Проверьте логи выше."
fi

# Создание отчета
REPORT_FILE="build/ios/archive_report.txt"
cat > "$REPORT_FILE" << EOF
FreeDome Sphere iOS Archive Report
==================================

Версия: $VERSION_NAME
Build: $BUILD_NUMBER
Дата: $(date)
Development Team: $DEVELOPMENT_TEAM

Файлы:
- Архив: $ARCHIVE_PATH
- IPA: $IPA_PATH
- Размер IPA: $IPA_SIZE

Статус: $([ $? -eq 0 ] && echo "Успешно загружено" || echo "Требует ручной загрузки")

Следующие шаги:
1. Проверьте статус в App Store Connect
2. Заполните метаданные приложения
3. Отправьте на ревью
4. Опубликуйте после одобрения

EOF

success "📋 Отчет создан: $REPORT_FILE"

log "🏁 Процесс архивирования завершен!"
log "📁 Все файлы сохранены в: build/ios/"

# Показываем итоговую информацию
echo ""
echo "🎯 ИТОГОВАЯ ИНФОРМАЦИЯ:"
echo "========================"
echo "📱 Приложение: FreeDome Sphere"
echo "📦 Версия: $VERSION_NAME"
echo "🔢 Build: $BUILD_NUMBER"
echo "📁 Архив: $ARCHIVE_PATH"
echo "📱 IPA: $IPA_PATH"
echo "📊 Размер: $IPA_SIZE"
echo "📋 Отчет: $REPORT_FILE"
echo ""
echo "🚀 Следующий шаг: Проверьте App Store Connect"
echo "🔗 https://appstoreconnect.apple.com"
