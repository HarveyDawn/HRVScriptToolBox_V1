@echo off
chcp 65001 >nul

:: ============================================================
:: 脚本用途：
::   一键移除 Windows 文件夹空白处及文件夹图标上的“在此处打开 CMD”
::   和“在此处打开 PowerShell”的右键菜单选项，清理右键菜单。
::
:: 使用方法：
::   1. 将本文件保存为 .bat 格式（例如：RemoveCmdPs.bat）。
::   2. 直接双击运行该文件（脚本会自动请求管理员权限）。
::   3. 运行成功后，右键菜单中的相关选项将被彻底移除。
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

echo 正在清理右键菜单中的 CMD 和 PowerShell 选项...

:: 移除“在此处打开 CMD”
reg delete "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenCmdHere" /f
reg delete "HKLM\SOFTWARE\Classes\Directory\shell\OpenCmdHere" /f

:: 移除“在此处打开 PowerShell”
reg delete "HKLM\SOFTWARE\Classes\Directory\Background\shell\OpenPowerShellHere" /f
reg delete "HKLM\SOFTWARE\Classes\Directory\shell\OpenPowerShellHere" /f

echo.
echo 清理完成！右键菜单已恢复干净。
pause