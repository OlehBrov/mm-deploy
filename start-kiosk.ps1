# Чекаємо поки frontend контейнер стане доступним
Write-Host "Waiting for frontend to start..."

$timeout = 120  # максимум 2 хвилини
$elapsed = 0

while ($elapsed -lt $timeout) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "Frontend is ready. Launching Chrome kiosk..."
            break
        }
    } catch {
        # ще не готово — чекаємо
    }
    Start-Sleep -Seconds 3
    $elapsed += 3
}

if ($elapsed -ge $timeout) {
    Write-Host "Timeout: frontend did not start in $timeout seconds."
    exit 1
}

# Запуск Chrome в kiosk режимі
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chrome)) {
    $chrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}

Start-Process $chrome -ArgumentList "--kiosk", "--no-first-run", "--disable-translate", "--disable-infobars", "http://localhost"
