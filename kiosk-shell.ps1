# Kiosk shell для моноблоку.
# Цей скрипт стає ЗАМІНОЮ Windows shell (explorer.exe) на кіоск-обліковці —
# встановлюється через setup-kiosk-shell.ps1 (ключ Winlogon\Shell).
#
# ВАЖЛИВО: процес powershell.exe, що виконує цей файл, і Є "shell" сесії.
# Якщо він завершиться — Windows одразу розлогінить користувача. Тому головний
# цикл нижче ніколи не виходить сам по собі; Chrome перезапускається при будь-якому
# завершенні (крах, Alt+F4 через фізичну клавіатуру тощо).

$logFile = "C:\store\logs\kiosk-shell-log.txt"
New-Item -ItemType Directory -Force -Path (Split-Path $logFile) | Out-Null

function Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}

function Wait-ForFrontend {
    param([int]$TimeoutSec = 180)
    $elapsed = 0
    while ($elapsed -lt $TimeoutSec) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if ($response.StatusCode -eq 200) { return $true }
        } catch {
            # ще не готово — чекаємо (Docker/бекенд піднімаються)
        }
        Start-Sleep -Seconds 3
        $elapsed += 3
    }
    return $false
}

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chrome)) {
    $chrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}

Log "=== Kiosk shell started ==="

while ($true) {
    if (Wait-ForFrontend) {
        Log "Frontend ready."
    } else {
        Log "Timeout waiting for frontend — launching Chrome anyway, it will retry the page itself."
    }

    Log "Launching Chrome kiosk..."
    $proc = Start-Process $chrome -ArgumentList @(
        "--kiosk",
        "--no-first-run",
        "--disable-translate",
        "--disable-infobars",
        "--noerrdialogs",
        "--disable-pinch",
        "--overscroll-history-navigation=0",
        "http://localhost"
    ) -PassThru

    $proc.WaitForExit()
    Log "Chrome exited (code $($proc.ExitCode)). Restarting in 3s..."
    Start-Sleep -Seconds 3
}
