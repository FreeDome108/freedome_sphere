#!/bin/bash

# Скрипт для создания релиза
# Использование: ./scripts/release.sh [version]

set -e

# Получаем версию из аргумента или из pubspec.yaml
if [ -n "$1" ]; then
    VERSION=$1
else
    VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
fi

echo "🚀 Создание релиза версии $VERSION"

# Проверяем, что мы в правильной ветке
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Внимание: вы не в main/master ветке. Текущая ветка: $CURRENT_BRANCH"
    read -p "Продолжить? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Проверяем, что нет незакоммиченных изменений
if ! git diff-index --quiet HEAD --; then
    echo "❌ Есть незакоммиченные изменения. Сначала закоммитьте их."
    exit 1
fi

# Проверяем, что тесты проходят
echo "🧪 Запуск тестов..."
flutter test

# Создаем тег
TAG="v$VERSION"
echo "🏷️  Создание тега $TAG"
git tag -a "$TAG" -m "Release $VERSION"

# Пушим тег
echo "📤 Отправка тега в репозиторий..."
git push origin "$TAG"

echo "✅ Релиз $VERSION создан и отправлен!"
echo "🔍 Проверьте статус в GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions"
