@echo off
chcp 65001 >nul
cls

:: ==============================================
:: 脚本名称：移除右键CMD和PowerShell菜单.bat
:: 功    能：一键清空由上方脚本添加的所有右键终端菜单
:: 使用方法：直接双击运行，自动获取管理员权限
:: ==============================================

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

echo Windows Registry Editor Version 5.00 >del.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCMD] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\OpenPS] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\AdminCMD] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\AdminPS] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\OpenCMD] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\OpenPS] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\AdminCMD] >>del.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\AdminPS] >>del.reg

reg import del.reg
del /f/q del.reg

echo.
echo ==============================================
echo ✅ 右键终端菜单已全部清除完毕
echo ==============================================
echo.
pause
exit