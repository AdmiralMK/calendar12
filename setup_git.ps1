# ============================================================
# Скрипт настройки Git и первой выгрузки проекта в GitHub
# Проект: Calendar12 (Календарь12)
# Профиль GitHub: https://github.com/AdmiralMK
# ============================================================

# Цветной вывод для удобства
function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# ------------------------------------------------------------
# ШАГ 0: Проверка окружения
# ------------------------------------------------------------
Write-Step "ШАГ 0: Проверка окружения"

# Проверяем, что мы в корне проекта
$projectRoot = Get-Location
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "Скрипт нужно запускать в корне Flutter-проекта (где находится pubspec.yaml)"
    Write-Error "Текущая папка: $projectRoot"
    exit 1
}
Write-Success "Находимся в корне проекта: $projectRoot"

# Проверяем наличие Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git не установлен! Скачайте с https://git-scm.com/downloads"
    exit 1
}
Write-Success "Git установлен: $(git --version)"

# Проверяем наличие GitHub CLI (опционально)
$hasGhCli = Get-Command gh -ErrorAction SilentlyContinue
if ($hasGhCli) {
    Write-Success "GitHub CLI установлен: $(gh --version | Select-Object -First 1)"
} else {
    Write-Warning "GitHub CLI не установлен. Будем использовать обычный git."
    Write-Warning "Рекомендуется установить: https://cli.github.com/"
}

# ------------------------------------------------------------
# ШАГ 1: Проверка .gitignore
# ------------------------------------------------------------
Write-Step "ШАГ 1: Проверка .gitignore"

if (-not (Test-Path ".gitignore")) {
    Write-Error "Файл .gitignore не найден! Создайте его перед запуском скрипта."
    exit 1
}
Write-Success "Файл .gitignore найден"

# ------------------------------------------------------------
# ШАГ 2: Настройка Git пользователя
# ------------------------------------------------------------
Write-Step "ШАГ 2: Настройка Git пользователя"

# Проверяем текущую конфигурацию
$currentName = git config --global user.name
$currentEmail = git config --global user.email

Write-Host "Текущие настройки Git:" -ForegroundColor White
Write-Host "  Имя:    $currentName" -ForegroundColor White
Write-Host "  Email:  $currentEmail" -ForegroundColor White

# Предлагаем настроить для проекта локально
Write-Host ""
$configureLocal = Read-Host "Настроить имя и email для этого проекта локально? (y/n)"

if ($configureLocal -eq 'y' -or $configureLocal -eq 'Y') {
    $userName = Read-Host "Введите ваше имя для Git (по умолчанию: Konstantin Markov)"
    if ([string]::IsNullOrWhiteSpace($userName)) {
        $userName = "Konstantin Markov"
    }
    
    $userEmail = Read-Host "Введите ваш email для Git (по умолчанию: kbmarkov@gmail.com)"
    if ([string]::IsNullOrWhiteSpace($userEmail)) {
        $userEmail = "kbmarkov@gmail.com"
    }
    
    git config --local user.name "$userName"
    git config --local user.email "$userEmail"
    
    Write-Success "Настройки сохранены локально для проекта"
    Write-Host "  Имя:   $(git config --local user.name)" -ForegroundColor Green
    Write-Host "  Email: $(git config --local user.email)" -ForegroundColor Green
}

# ------------------------------------------------------------
# ШАГ 3: Инициализация Git репозитория
# ------------------------------------------------------------
Write-Step "ШАГ 3: Инициализация Git репозитория"

if (Test-Path ".git") {
    Write-Warning "Git репозиторий уже инициализирован"
    $reinit = Read-Host "Переинициализировать? (y/n)"
    if ($reinit -eq 'y' -or $reinit -eq 'Y') {
        Remove-Item -Path ".git" -Recurse -Force
        git init
        Write-Success "Git репозиторий переинициализирован"
    }
} else {
    git init
    Write-Success "Git репозиторий инициализирован"
}

# Устанавливаем основную ветку как main
git branch -M main
Write-Success "Основная ветка установлена как 'main'"

# ------------------------------------------------------------
# ШАГ 4: Создание удаленного репозитория на GitHub
# ------------------------------------------------------------
Write-Step "ШАГ 4: Создание удаленного репозитория"

$repoName = "calendar12"
$repoUrl = "https://github.com/AdmiralMK/$repoName.git"

if ($hasGhCli) {
    # Используем GitHub CLI для создания репозитория
    Write-Host "Используем GitHub CLI для создания репозитория..." -ForegroundColor White
    
    # Проверяем авторизацию
    try {
        gh auth status 2>&1 | Out-Null
        Write-Success "GitHub CLI авторизован"
    } catch {
        Write-Warning "GitHub CLI не авторизован. Выполните авторизацию:"
        gh auth login
    }
    
    # Проверяем, существует ли репозиторий
    $repoExists = gh repo view "AdmiralMK/$repoName" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Warning "Репозиторий уже существует: $repoUrl"
        $useExisting = Read-Host "Использовать существующий репозиторий? (y/n)"
        if ($useExisting -ne 'y' -and $useExisting -ne 'Y') {
            Write-Error "Прервано пользователем"
            exit 1
        }
    } else {
        # Создаем новый репозиторий
        $isPrivate = Read-Host "Создать приватный репозиторий? (y/n, по умолчанию y)"
        $visibility = if ($isPrivate -eq 'n' -or $isPrivate -eq 'N') { "public" } else { "private" }
        
        gh repo create "AdmiralMK/$repoName" --$visibility --description "Календарь12 - Flutter приложение для отображения 12 месяцев на одном экране"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Репозиторий создан: $repoUrl"
        } else {
            Write-Error "Не удалось создать репозиторий"
            exit 1
        }
    }
} else {
    # Без GitHub CLI - нужно создать репозиторий вручную
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host " ВАЖНО: Создайте репозиторий вручную на GitHub!" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Откройте в браузере: https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: $repoName" -ForegroundColor White
    Write-Host "3. Description: Календарь12 - Flutter приложение" -ForegroundColor White
    Write-Host "4. Выберите Public или Private" -ForegroundColor White
    Write-Host "5. НЕ ставьте галочки 'Add README', '.gitignore', 'license'" -ForegroundColor Yellow
    Write-Host "   (они уже есть в проекте)" -ForegroundColor Yellow
    Write-Host "6. Нажмите 'Create repository'" -ForegroundColor White
    Write-Host ""
    
    $ready = Read-Host "После создания репозитория нажмите Enter для продолжения..."
}

# ------------------------------------------------------------
# ШАГ 5: Подключение удаленного репозитория
# ------------------------------------------------------------
Write-Step "ШАГ 5: Подключение удаленного репозитория"

# Удаляем существующий remote, если есть
$existingRemote = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0) {
    git remote remove origin
    Write-Warning "Удален старый remote: $existingRemote"
}

git remote add origin $repoUrl
Write-Success "Добавлен remote origin: $repoUrl"

# ------------------------------------------------------------
# ШАГ 6: Первый коммит
# ------------------------------------------------------------
Write-Step "ШАГ 6: Первый коммит"

# Добавляем все файлы
git add .
Write-Success "Все файлы добавлены в индекс"

# Показываем, что будет закоммичено
$filesCount = (git diff --cached --numstat | Measure-Object).Count
Write-Host "Будет закоммичено файлов: $filesCount" -ForegroundColor White

# Создаем коммит
$commitMessage = Read-Host "Введите сообщение для первого коммита (Enter для стандартного)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Initial commit: Calendar12 v1.0.0`n`n- Flutter приложение для отображения 12 месяцев`n- База данных Isar`n- Поддержка тем (светлая/темная/системная)`n- Выбор года от 1900 до 2070"
}

git commit -m "$commitMessage"
Write-Success "Первый коммит создан"

# ------------------------------------------------------------
# ШАГ 7: Выгрузка в GitHub
# ------------------------------------------------------------
Write-Step "ШАГ 7: Выгрузка в GitHub"

Write-Host "Выполняется git push..." -ForegroundColor White
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Success "Код успешно выгружен в GitHub!"
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " ГОТОВО! Репозиторий доступен по адресу:" -ForegroundColor Green
    Write-Host " $repoUrl" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Error "Ошибка при выгрузке. Возможные причины:"
    Write-Host "  1. Репозиторий не создан на GitHub" -ForegroundColor Yellow
    Write-Host "  2. Не настроена авторизация" -ForegroundColor Yellow
    Write-Host "  3. Неправильный URL репозитория" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Попробуйте выполнить вручную:" -ForegroundColor White
    Write-Host "  git push -u origin main" -ForegroundColor Cyan
}

# ------------------------------------------------------------
# ШАГ 8: Информация о дальнейшей работе
# ------------------------------------------------------------
Write-Step "Инструкция для дальнейшей работы"

Write-Host ""
Write-Host "Для сохранения новых изменений используйте:" -ForegroundColor White
Write-Host ""
Write-Host "  # 1. Посмотреть изменения" -ForegroundColor Cyan
Write-Host "  git status" -ForegroundColor White
Write-Host ""
Write-Host "  # 2. Добавить измененные файлы" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor White
Write-Host ""
Write-Host "  # 3. Создать коммит" -ForegroundColor Cyan
Write-Host "  git commit -m 'Описание изменений'" -ForegroundColor White
Write-Host ""
Write-Host "  # 4. Выгрузить в GitHub" -ForegroundColor Cyan
Write-Host "  git push" -ForegroundColor White
Write-Host ""
Write-Host "Для создания новой версии (тега):" -ForegroundColor White
Write-Host "  git tag v1.0.1" -ForegroundColor Cyan
Write-Host "  git push --tags" -ForegroundColor Cyan
Write-Host ""