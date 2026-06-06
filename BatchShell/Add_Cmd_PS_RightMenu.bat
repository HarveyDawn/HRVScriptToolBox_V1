@echo off
chcp 65001 >nul

:: ============================================================
:: 脚本用途：
::   一键在 Windows 文件夹空白处及文件夹图标上，添加“在此处打开 CMD”
::   和“在此处打开 PowerShell”的右键菜单选项，提升日常操作效率。
::
:: 使用方法：
::   1. 将本文件保存为 .bat 格式（例如：AddCmdPs.bat）。
::   2. 直接双击运行该文件（脚本会自动请求管理员权限）。
::   3. 运行成功后，在任意文件夹空白处或文件夹上右键即可看到新选项。
:: ============================================================

:: --- 自动请求管理员权限 ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo 正在请求管理员权限...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:: --- 管理员权限获取结束 ---

echo 正在添加 CMD 和 PowerShell 到右键菜单...

:: 添加“在此处打开 CMD” (使用 HKLM\SOFTWARE\Classes 替代 HKCR 以避免路径报错)
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenCmdHere" /ve /d "在此处打开 CMD" /f
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenCmdHere" /v Icon /t REG_SZ /d "cmd.exe" /f
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenCmdHere\command" /ve /d "cmd.exe /s /k pushd \"%%V\"" /f

reg add "HKLM\SOFTWARE\Classes\Directory\shell\OpenCmdHere" /ve /d "在此处打开 CMD" /f
reg add "HKLM\SOFTWARE\Classes\Directory\shell\OpenCmdHere" /v Icon /t REG_SZ /d "cmd.exe" /f
reg add "HKLM\SOFTWARE\Classes\Directory\shell\OpenCmdHere\command" /ve /d "cmd.exe /s /k pushd \"%%V\"" /f

:: 添加“在此处打开 PowerShell”
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenPowerShellHere" /ve /d "在此处打开 PowerShell" /f
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenPowerShellHere" /v Icon /t REG_SZ /d "powershell.exe" /f
reg add "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenPowerShellHere\command" /ve /d "powershell.exe -noexit -command \"Set-Location -LiteralPath '%%V'\"" /f

reg add "HKLM\SOFTWARE\Classes\Directory\shell\OpenPowerShellHere" /ve /d "在此处打开 PowerShell" /f
reg add "HKLM\SOFTWARE\Classes\Directory\shell\OpenPowerShellHere" /v Icon /t REG_SZ /d "powershell.exe" /f
reg add "HKLM\SOFTWARE\Classes\Directory\shell\OpenPowerShellHere\command" /ve /d "powershell.exe -noexit -command \"Set-Location -LiteralPath '%%V'\"" /f

echo.
echo 添加成功！现在可以在文件夹空白处或文件夹上右键查看效果。
pause