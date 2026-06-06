@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
mode con: cols=120 lines=30
color 0A
title Claude Code CLI 全自动安装工具

echo.
echo ======================================================
echo          🚀 Claude Code CLI 全自动安装脚本
echo                支持 Windows 10/11
echo ======================================================
echo.

:: 检查管理员权限
fltmc >nul 2>&1 || (
    echo ⚠️  请【右键此脚本】选择【以管理员身份运行】！
    echo.
    pause >nul
    exit /b 1
)

echo ✅ 正在检查系统依赖...
echo.

:: 安装依赖：Microsoft Visual C++ 运行库（必须）
echo 📦 正在安装必备运行库 VC++ Redist...
curl -L -s "https://aka.ms/vs/17/release/vc_redist.x64.exe" -o "%temp%\vc_redist.x64.exe"
start /wait "" "%temp%\vc_redist.x64.exe" /quiet /norestart
del "%temp%\vc_redist.x64.exe" >nul 2>&1
echo ✅ 运行库安装完成

echo.
echo ======================================================
echo 🚀 开始安装 Claude Code CLI（官方原版）
echo ======================================================
echo.

:: 方案1：官方PowerShell安装
powershell -Command "irm https://claude.ai/install.ps1 | iex"
if %errorlevel% equ 0 (
    echo ✅ 官方安装成功
) else (
    echo.
    echo ⚠️  官方脚本失败，切换 winget 安装...
    winget install Anthropic.ClaudeCode --accept-source-agreements --accept-package-agreements -h
)

echo.
echo ======================================================
echo 🔧 自动修复 PATH 环境变量（解决找不到claude命令）
echo ======================================================
echo.

:: 强制刷新系统环境变量
for /f "delims=" %%a in ('powershell -c "[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')"') do set "PATH=%%a"

:: 自动添加常用安装目录到PATH
set "CLAUD_PATH1=%LocalAppData%\claude-cli"
set "CLAUD_PATH2=%UserProfile%\AppData\Local\Microsoft\WinGet\Packages\Anthropic.ClaudeCode*"
set "PATH=%CLAUD_PATH1%;%CLAUD_PATH2%;%PATH%"

echo ✅ 环境变量已自动修复
echo.

echo ======================================================
echo ✅ 验证安装结果
echo ======================================================
echo.

:: 验证命令
claude --version >nul 2>&1
if %errorlevel% equ 0 (
    echo 🎉 安装成功！当前版本：
    claude --version
    echo.
    echo ======================================================
    echo ✅ 使用方法：
    echo    打开终端 → 输入：claude "你的需求"
    echo    示例：claude "写一个Python登录界面"
    echo ======================================================
) else (
    echo ❌ 命令仍未生效，请【重启电脑】后再试！
    echo 重启后直接输入：claude --version 验证
)

echo.
echo 按任意键退出...
pause >nul
exit /b