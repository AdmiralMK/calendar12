# Скрипт для автоматического создания релиза на GitHub
param(
    [string]$Version = "1.0.0",
    [string]$Title = "",
    [string]$Notes = ""
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Создание релиза Calendar12 v$Version" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Проверка наличия gh
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] GitHub CLI (gh) не установлен!" -ForegroundColor Red
    Write-Host "Установите: winget install --id GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# Проверка авторизации
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Не выполнен вход в GitHub CLI!" -ForegroundColor Red
    Write-Host "Выполните: gh auth login" -ForegroundColor Yellow
    exit 1
}

# Проверяем наличие APK
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "[!] APK не найден. Собираем..." -ForegroundColor Yellow
    flutter build apk --release
}

# Копируем APK с красивым именем
$apkName = "Calendar12-v$Version.apk"
Copy-Item $apkPath -Destination $apkName -Force
Write-Host "[OK] APK скопирован: $apkName" -ForegroundColor Green

# Заголовок релиза
if ([string]::IsNullOrWhiteSpace($Title)) {
    $Title = "Calendar12 v$Version"
}

# Описание релиза
if ([string]::IsNullOrWhiteSpace($Notes)) {
    $Notes = @"
## Что нового в версии $Version

### Основные возможности
- Отображение 12 месяцев на одном экране (сетка 3x4)
- Три темы оформления: светлая, темная, системная
- Навигация по годам от 1900 до 2070
- Подсветка текущего дня
- Сохранение настроек между запусками
- Компактный селектор года с прокруткой
- Адаптивный дизайн под разные экраны

### Технические детали
- Flutter 3.27+
- Material Design 3
- База данных: SharedPreferences
- Архитектура: x86_64 (эмуляторы) и ARM (реальные устройства)

### Установка
Скачайте APK-файл и установите на ваше Android-устройство.
"@
}

# Сохраняем описание во временный файл (для корректной обработки многострочности)
$notesFile = [System.IO.Path]::GetTempFileName()
$Notes | Out-File -FilePath $notesFile -Encoding UTF8

Write-Host ""
Write-Host "Создание релиза..." -ForegroundColor White

# Создаём релиз
gh release create "v$Version" $apkName --title $Title --notes-file $notesFile

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " Релиз успешно создан!" -ForegroundColor Green
    Write-Host " https://github.com/AdmiralMK/calendar12/releases/tag/v$Version" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Не удалось создать релиз" -ForegroundColor Red
}

# Очистка
Remove-Item $notesFile -Force -ErrorAction SilentlyContinue