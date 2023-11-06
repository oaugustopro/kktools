@echo off

@REM Inicio do MENU
:menu
cls
echo.
echo 1. Define Aliases
echo 2. Search Stored Credentials
echo 3. Funcao3
echo 4. Sair
echo.
set /p choice=Escolha uma opcao (1-4): 
echo %choice%
if "%choice%"=="1" (
    call :FunctionAlias
) else if "%choice%"=="2" (
    call :FunctionSearchStoredCredentials
) else if "%choice%"=="3" (
    call :Funcao3
) else if "%choice%"=="4" (
    goto :eof
) else (
    echo Opcao invalida. Tente novamente.
    pause
    goto menu
)
goto menu

@REM Define a função
:FunctionAlias
    echo "Definindo Aliases"
    DOSKEY l=dir /B $*
    DOSKEY ls=dir /B $*
    DOSKEY ll=dir /Q /P $*
    DOSKEY la=dir /P /A $*
    DOSKEY nss=npm start $T npm run serve
    pause
goto menu

@REM Define a função
:FunctionSearchStoredCredentials
    echo "* Procurando Credenciais"
    REM auxiliam na hora de procurar porarquivos que contenham senhas.
    echo "|-> Procurar arquivos com senhas"
    findstr /si password *.txt
    findstr /si password *.xml
    findstr /si password *.ini
    dir /b /s unattend.xml
    dir /b /s web.config
    dir /b /s sysprep.inf
    dir /b /s sysprep.xml
    dir /b /s *pass*
    dir /b /s vnc.ini
    cmdkey /list
    pause
goto menu

exit /b