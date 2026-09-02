# Крок 1 з 2 налаштування kiosk-блокування.
#
# ЗАПУСКАТИ: під тим Windows-акаунтом, що буде "кіоском" (на цій машині — існуючий
# адмінський акаунт, окремий низькопривілейований kiosk-акаунт не використовується,
# бо Docker Desktop зберігає образи/дані per-user в %LOCALAPPDATA% і довелось би
# дублювати збірку під другим акаунтом). Звичайний PowerShell, без підвищення прав —
# HKCU не потребує адмін-прав для запису, і зайве підвищення (якби акаунт був
# НЕ адміністратором) підставило б чужі облікові дані через UAC.
#
# Що робить: підміняє Windows shell (замість explorer.exe) на kiosk-shell.ps1 —
# тільки для ПОТОЧНОГО користувача (HKCU).

$deployPath = "C:\git\mm-deploy"
$shellScript = Join-Path $deployPath "kiosk-shell.ps1"

if (-not (Test-Path $shellScript)) {
    Write-Error "Не знайдено $shellScript. Перевір шлях до репозиторію mm-deploy на цій машині (мав би бути C:\git\mm-deploy)."
    exit 1
}

$shellCommand = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$shellScript`""

Write-Host "Обліковий запис, для якого підміняється shell: $env:USERNAME"
Write-Host "Якщо це НЕ кіоск-акаунт — зупинись (Ctrl+C) і перезапусти під потрібним користувачем."

New-Item -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value $shellCommand
Write-Host "[OK] Shell для '$env:USERNAME' замінено на kiosk-shell.ps1"

Write-Host ""
Write-Host "Далі: з адмінського акаунта запустити setup-kiosk-edge-policy.ps1 (крок 2 з 2)."
Write-Host "Перезавантаження робити тільки після обох кроків."
