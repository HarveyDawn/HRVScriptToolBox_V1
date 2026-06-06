@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
mode con: cols=120 lines=30
color 0A
title Claude Code CLI 全自动安装

echo.
echo ======================================================
echo          🚀 Claude Code CLI 全自动安装脚本
echo                支持 Windows 10/11  已修复PATH
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

:: 安装 VC++ 运行库
echo 📦 正在安装必备运行库 VC++ Redist...
curl -L -s "https://aka.ms/vs/17/release/vc_redist.x64.exe" -o "%temp%\vc_redist.x64.exe"
start /wait "" "%temp%\vc_redist.x64.exe" /quiet /norestart
del "%temp%\vc_redist.x64.exe" >nul 2>&1
echo ✅ 运行库安装完成

echo.
echo ======================================================
echo 🚀 开始安装 Claude Code CLI
echo ======================================================
echo.

:: 官方安装
powershell -Command "irm https://claude.ai/install.ps1 | iex"
if %errorlevel% equ 0 (
    echo ✅ 官方安装成功
) else (
    echo ⚠️  官方脚本失败，使用 winget 安装...
    winget install Anthropic.ClaudeCode --accept-source-agreements --accept-package-agreements -h
)

echo.
echo ======================================================
echo 🔧 【终极修复】自动写入系统PATH，解决命令找不到
echo ======================================================
echo.

:: 核心修复：把 Claude 路径永久写入系统环境变量
set "CLAUDE_PATH=%LocalAppData%\claude-cli"
set "USER_PATH=%UserProfile%\AppData\Local\Microsoft\WinGet\Packages\Anthropic.ClaudeCode*"

:: 强制写入用户环境变量
powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';%CLAUDE_PATH%', 'User')"
powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';%USER_PATH%', 'User')"

:: 立即刷新当前终端环境
for /f "delims=" %%a in ('powershell -c "[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')"') do set "PATH=%%a"

echo ✅ 系统环境变量已永久修复
echo.

echo ======================================================
echo ✅ 最终验证
echo ======================================================
echo.

claude --version >nul 2>&1
if %errorlevel% equ 0 (
    echo 🎉 安装成功！当前版本：
    claude --version
    echo.
    echo ======================================================
    echo ✅ 使用方法：
    echo    任意终端输入：claude --version
    ======================================================
) else (
    echo ❌ 未实时生效，请【关闭所有终端】重新打开即可使用！
    echo 测试命令：claude --version
)

echo.
echo 按任意键退出...
pause >nul
exit /b