@echo off
chcp 65001 >nul
cls

:: ==============================================
:: 脚本名称：添加右键CMD和PowerShell菜单.bat
:: 作    者：豆包
:: 功    能：一键将 普通CMD、普通PowerShell、管理员CMD、管理员PowerShell
::          添加到鼠标右键菜单（空白处+文件夹图标均生效）
:: 适用系统：Windows 10 / Windows 11
:: 使用方法：直接双击运行，脚本会自动请求管理员权限
:: 注    意：Win11 需右键 -> 显示更多选项 查看菜单
:: ==============================================

:: 自动获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

:: 生成注册表文件（UTF-8 无乱码）
echo Windows Registry Editor Version 5.00 >tmp.reg
echo.>>tmp.reg

::普通CMD 空白目录右键
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCMD] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCMD] >>tmp.reg
echo @="在此处打开 CMD" >>tmp.reg
echo "Icon"="cmd.exe" >>tmp.reg
echo "ShowBasedOnVelocityId"=dword:00639bc8 >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCMD\command] >>tmp.reg
echo @="cmd.exe /s /k pushd ""%%V""" >>tmp.reg
echo.>>tmp.reg

::普通PowerShell
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\OpenPS] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\OpenPS] >>tmp.reg
echo @="在此处打开 PowerShell" >>tmp.reg
echo "Icon"="powershell.exe" >>tmp.reg
echo "ShowBasedOnVelocityId"=dword:00639bc8 >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\OpenPS\command] >>tmp.reg
echo @="powershell.exe -NoExit -Command Set-Location -LiteralPath ""%%V""" >>tmp.reg
echo.>>tmp.reg

::管理员CMD
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\AdminCMD] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\AdminCMD] >>tmp.reg
echo @="在此打开CMD(管理员)" >>tmp.reg
echo "Icon"="cmd.exe" >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\AdminCMD\command] >>tmp.reg
echo @="powershell -windowstyle hidden -Command Start-Process cmd -ArgumentList '/s,/k,pushd,%%V' -Verb RunAs" >>tmp.reg
echo.>>tmp.reg

::管理员PowerShell
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\AdminPS] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\AdminPS] >>tmp.reg
echo @="在此打开PowerShell(管理员)" >>tmp.reg
echo "Icon"="powershell.exe" >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\AdminPS\command] >>tmp.reg
echo @="powershell -windowstyle hidden -Command Start-Process powershell -ArgumentList '-NoExit,Set-Location,'""""%%V"""" -Verb RunAs" >>tmp.reg
echo.>>tmp.reg

::文件夹图标右键
echo [-HKEY_CLASSES_ROOT\Directory\shell\OpenCMD] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\OpenCMD] >>tmp.reg
echo @="在此处打开 CMD" >>tmp.reg
echo "Icon"="cmd.exe" >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\OpenCMD\command] >>tmp.reg
echo @="cmd.exe /s /k pushd ""%%V""" >>tmp.reg
echo.>>tmp.reg

echo [-HKEY_CLASSES_ROOT\Directory\shell\OpenPS] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\OpenPS] >>tmp.reg
echo @="在此处打开 PowerShell" >>tmp.reg
echo "Icon"="powershell.exe" >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\OpenPS\command] >>tmp.reg
echo @="powershell.exe -NoExit -Command Set-Location -LiteralPath ""%%V""" >>tmp.reg
echo.>>tmp.reg

echo [-HKEY_CLASSES_ROOT\Directory\shell\AdminCMD] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\AdminCMD] >>tmp.reg
echo @="在此打开CMD(管理员)" >>tmp.reg
echo "Icon"="cmd.exe" >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\AdminCMD\command] >>tmp.reg
echo @="powershell -windowstyle hidden -Command Start-Process cmd -ArgumentList '/s,/k,pushd,%%V' -Verb RunAs" >>tmp.reg
echo.>>tmp.reg

echo [-HKEY_CLASSES_ROOT\Directory\shell\AdminPS] >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\AdminPS] >>tmp.reg
echo @="在此打开PowerShell(管理员)" >>tmp.reg
echo "Icon"="powershell.exe" >>tmp.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\AdminPS\command] >>tmp.reg
echo @="powershell -windowstyle hidden -Command Start-Process powershell -ArgumentList '-NoExit,Set-Location,'""""%%V"""" -Verb RunAs" >>tmp.reg

:: 导入注册表并清理临时文件
reg import tmp.reg
del /f/q tmp.reg

echo.
echo ==============================================
echo ✅ 全部添加完成：普通CMD/PS + 管理员CMD/PS
echo ℹ️ Win11右键 → 点击【显示更多选项】查看菜单
echo ==============================================
echo.
pause
exit