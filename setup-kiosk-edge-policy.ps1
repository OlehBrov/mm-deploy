# Крок 2 з 2 налаштування kiosk-блокування.
#
# ЗАПУСКАТИ: з адмінського акаунта, "Запустити від імені адміністратора".
# Це машинний (HKLM) параметр — не прив'язаний до конкретного користувача,
# достатньо виконати один раз, під будь-яким адміном.
#
# Що робить: вимикає системні edge-swipe жести (свайпи від країв екрана —
# Action Center / Task View) для ВСІХ користувачів машини.

#Requires -RunAsAdministrator

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" -Name "AllowEdgeSwipe" -Value 0 -Type DWord
Write-Host "[OK] Edge-swipe жести вимкнено системно (HKLM policy) для всіх користувачів."

Write-Host ""
Write-Host "Готово. Перезавантаж машину, щоб обидва кроки набули чинності."
