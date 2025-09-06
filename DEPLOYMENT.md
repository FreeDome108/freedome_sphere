# Инструкции по развертыванию

## Настройка секретов GitHub

Для автоматической публикации в App Store и Google Play необходимо настроить следующие секреты в GitHub:

### Google Play Store

1. Создайте Service Account в Google Cloud Console
2. Скачайте JSON ключ
3. Добавьте секрет `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` с содержимым JSON файла

### Apple App Store

1. Создайте API ключ в App Store Connect
2. Добавьте следующие секреты:
   - `APPLE_ISSUER_ID` - ID издателя
   - `APPLE_API_KEY_ID` - ID API ключа
   - `APPLE_API_PRIVATE_KEY` - Приватный ключ (в формате .p8)

## Настройка iOS

1. Обновите `ios/ExportOptions.plist`:
   - Замените `YOUR_TEAM_ID` на ваш Team ID
   - Замените `YOUR_PROVISIONING_PROFILE` на имя профиля

2. Настройте подписание кода в Xcode

## Настройка Android

1. Создайте keystore для подписания релизных сборок
2. Настройте `android/app/build.gradle.kts` для использования релизного keystore

## Запуск релиза

### Автоматический релиз (рекомендуется)

1. Создайте тег: `git tag v2.0.0`
2. Запушьте тег: `git push origin v2.0.0`
3. GitHub Actions автоматически запустит процесс публикации

### Ручной запуск

1. Перейдите в Actions в GitHub
2. Выберите workflow "Release to App Stores"
3. Нажмите "Run workflow"
4. Введите версию (например, 2.0.0)

## Проверка статуса

- Проверьте логи в GitHub Actions
- Проверьте статус в Google Play Console
- Проверьте статус в App Store Connect
