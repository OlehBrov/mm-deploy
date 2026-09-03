# Повний відкат touch-lockdown налаштувань.
#
# ЗАПУСКАТИ: з адмінського акаунта, "Запустити від імені адміністратора" —
# скрипт одразу відкочує і HKCU (shell), і HKLM (edge-swipe policy),
# і вимикає Autologon. Оскільки акаунт сам є адміністратором, UAC-підвищення
# не підставляє чужі облікові дані (на відміну від setup-скриптів) — можна
# робити все одним скриптом.
#
# Що робить:
# 1. Повертає стандартний Windows shell (explorer.exe) замість kiosk-shell.ps1
# 2. Прибирає HKLM policy, що вимикала edge-swipe жести
# 3. Вимикає Autologon (через Autologon64.exe, якщо є, інакше вручну через реєстр)

#Requires -RunAsAdministrator

Write-Host "=== Відкат kiosk-lockdown ===" -ForegroundColor Cyan

# 1. Shell -> explorer.exe (HKCU, для поточного користувача)
Write-Host "Обліковий запис: $env:USERNAME"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value "explorer.exe"
Write-Host "[OK] Shell повернуто на explorer.exe"

# 2. Прибрати edge-swipe policy (HKLM)
$edgeUiPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI"
if (Test-Path $edgeUiPath) {
    Remove-ItemProperty -Path $edgeUiPath -Name "AllowEdgeSwipe" -ErrorAction SilentlyContinue
    Write-Host "[OK] Edge-swipe policy прибрано (жести знову працюють)"
} else {
    Write-Host "[--] Edge-swipe policy не знайдено (вже немає)"
}

# 3. Вимкнути Autologon
$autologonExe = Get-Command Autologon64.exe -ErrorAction SilentlyContinue
if (-not $autologonExe) {
    $candidatePaths = @(
        "C:\git\mm-deploy\Autologon64.exe",
        "$env:USERPROFILE\Downloads\Autologon64.exe",
        "C:\Tools\Autologon64.exe"
    )
    $found = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($found) { $autologonExe = $found }
}

if ($autologonExe) {
    & $autologonExe /disable /accepteula
    Write-Host "[OK] Autologon вимкнено через Autologon64.exe"
} else {
    # Fallback: вручну через реєстр
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "0"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -ErrorAction SilentlyContinue
    Write-Host "[OK] Autologon вимкнено вручну через реєстр (AutoAdminLogon=0)"
    Write-Host "    Autologon64.exe не знайдено — якщо потрібно остаточно прибрати збережений LSA-секрет пароля, запусти 'Autologon64.exe /disable' окремо, коли матимеш файл під рукою."
}

Write-Host ""
Write-Host "=== Готово. Перезавантаж машину — має завантажитись звичайний робочий стіл з екраном входу. ===" -ForegroundColor Green
