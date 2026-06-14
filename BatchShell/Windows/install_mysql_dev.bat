@echo off
chcp 65001 >nul
title MySQL 绿色版一键安装(路径修复增强版)
setlocal enabledelayedexpansion

@REM whoami
@REM whoami /groups | findstr /i "administrators"
@REM fltmc >nul 2>&1 && echo [√] 真管理员权限 || echo [×] 还是标准权限
@REM pause
:: 检测管理员权限，没有就自动提权
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo 正在请求管理员权限...
    powershell Start-Process "%~f0" -Verb RunAs
    exit /b
)
echo 已获得管理员权限！

:: 提权后自动切回脚本所在目录（提权后默认会跳到 System32）
cd /d "%~dp0"


cls
echo ==============================================
echo    MySQL 绿色版一键安装增强脚本，安全性较低，仅适用于本地测试 / 内网非生产环境，绝对不能用于公网、生产环境
echo ==============================================
echo.

:: ===================== 默认参数定义 =====================
set "DEF_MYSQL_HOME=D:\mysql-8.0.46-winx64"
set "DEF_SERVICE_NAME=MySQL"
set "DEF_ROOT_PWD=123456"
set "DEF_PORT=3306"

:: -------------------- 1. 设置 MySQL 根目录 --------------------
echo 【1/5 设置MySQL根目录】
echo Default Path:%DEF_MYSQL_HOME%
set /p "INPUT_MYSQL_HOME=直接回车使用默认，或输入新路径："

:: 核心修复：自动去除输入内容首尾的双引号
if defined INPUT_MYSQL_HOME (
    set "INPUT_MYSQL_HOME=!INPUT_MYSQL_HOME:"=!"
    set "MYSQL_HOME=!INPUT_MYSQL_HOME!"
) else (
    set "MYSQL_HOME=%DEF_MYSQL_HOME%"
)

echo 已选定路径：!MYSQL_HOME!
echo.

:: 校验根目录是否存在
if not exist "!MYSQL_HOME!" (
    echo [FAIL]MySQL目录不存在，请检查路径是否正确！
    echo 当前路径：!MYSQL_HOME!
    pause >nul
    exit /b 1
)

set "MYSQL_BIN=!MYSQL_HOME!\bin"
set "INI_FILE=!MYSQL_HOME!\my.ini"

:: 校验bin目录是否存在（防止路径指错层级）
if not exist "!MYSQL_BIN!" (
    echo [FAIL]未找到 bin 目录，请确认路径是 MySQL 根目录！
    echo 当前bin路径：!MYSQL_BIN!
    pause >nul
    exit /b 1
)

cd /d "!MYSQL_BIN!"

:: 1. 检查系统PATH是否包含MySQL bin目录
echo [1/2] 检测系统PATH环境变量...
::echo 系统环境变量path: %PATH%
echo %PATH% | find /i "%MYSQL_BIN%" >nul
if !errorlevel! equ 0 (
    echo ✅ 已检测到MySQL路径：%MYSQL_BIN%
) else (
    echo ❌ 错误：PATH 中未包含 %MYSQL_BIN%
    echo 请将MySQL的bin目录添加到系统环境变量PATH中！
    pause >nul
    exit /b 1
)
echo.

:: 2. 检查命令是否可执行
echo [2/2] 检测命令可用性...
where mysql >nul 2>nul
if !errorlevel! equ 0 (
    echo ✅ mysql 命令调用正常
    echo MySQL 版本信息：
    mysql --version
) else (
    echo ❌ 错误：系统无法识别命令
    echo 环境变量配置异常，请重新检查！
    pause >nul
    exit /b 1
)

:: -------------------- 2. 端口设置 + 占用检测 --------------------
echo 【2/5 设置监听端口】
echo Default Port:%DEF_PORT%
set /p "INPUT_PORT=直接回车使用默认端口，或输入其他端口："
if not defined INPUT_PORT (
    set "PORT=%DEF_PORT%"
    echo 使用默认端口:!PORT!
) else (
    set "PORT=%INPUT_PORT%"
    echo 使用自定义端口:!PORT!
)

:: ---校验端口是否为合法数字---
:: 去掉首尾空格（兼容手动输入带空格的情况）
for /f "tokens=* delims= " %%A in ("!PORT!") do set "PORT=%%A"

:: 1. 非空检查
if "!PORT!"=="" (
    echo [FAIL] 端口号不能为空。
    goto :end
)

:: 2. 纯数字检查（用 set /a 转换，非数字会变 0 或报错，配合字符串比对）
::    先用 for /f 过滤非数字字符
set "DIGITS_ONLY=!PORT!"
for /f "delims=0123456789" %%C in ("!PORT!") do (
    set "DIGITS_ONLY="
)

if not defined DIGITS_ONLY (
    echo [FAIL] "!PORT!" 包含非数字字符，不是合法端口号。
    goto :end
)

:: 3. 数值范围检查：1 ~ 65535
set /a "NUM=!PORT!" 2>nul
if !NUM! LSS 1 (
    echo [FAIL] "!PORT!" 超出范围（最小值为 1）。
    goto :end
)
if !NUM! GTR 65535 (
    echo [FAIL] "!PORT!" 超出范围（最大值为 65535）。
    goto :end
)

:: 4. 前导零检查（"007" 虽能转换为 7，但不算标准端口写法）
set "STRIPPED=!NUM!"
if not "!PORT!"=="!STRIPPED!" (
    echo [WARN] "!PORT!" 含有前导零，标准写法应为 !NUM!，但数值本身合法。
    goto :end
)

echo [PASS] "!PORT!" 是合法端口号。

echo 正在检测端口 !PORT! 是否被占用...
netstat -ano | findstr ":!PORT! " >nul
if !errorlevel! equ 0 (
    echo [FAIL]端口 !PORT! 已被占用，请更换端口后重试！
    pause >nul
    exit /b 1
)
echo 端口 !PORT! 空闲，检测通过
echo.

:: -------------------- 3. 自动校验/生成 my.ini 配置文件 --------------------
echo 【3/5 配置文件校验与生成】
if exist "!INI_FILE!" (
    echo 已检测到现有 my.ini，跳过自动生成
) else (
    echo 未找到 my.ini，自动生成标准配置文件...
    (
        echo [mysqld]
        echo basedir=!MYSQL_HOME!
        echo datadir=!MYSQL_HOME!\data
        echo port=!PORT!
        echo character-set-server=utf8mb4
        echo default-storage-engine=INNODB
        echo max_connections=500
        echo.
        echo [mysql]
        echo default-character-set=utf8mb4
    ) > "!INI_FILE!"
    echo my.ini 生成完成：!INI_FILE!
)
echo 配置文件校验通过
echo.

:: -------------------- 4. 设置服务名 --------------------
echo 【4/5 设置Windows服务名】
echo Default Service Name: %DEF_SERVICE_NAME%
set /p "INPUT_SERVICE=直接回车使用默认，或输入新服务名："
if not defined INPUT_SERVICE (
    set "SERVICE_NAME=%DEF_SERVICE_NAME%"
    echo 使用默认服务名:!SERVICE_NAME!
) else (
    set "SERVICE_NAME=%INPUT_SERVICE%"
    echo 使用自定义服务名:!SERVICE_NAME!
)


echo 已选定服务名：!SERVICE_NAME!
echo.

:: -------------------- 5. 设置 root 密码 --------------------
echo 【5/5 设置root账户密码】
echo Default Root Password: %DEF_ROOT_PWD%
set /p "INPUT_PWD=直接回车使用默认密码，或输入新密码："
if not defined INPUT_PWD (
    set "ROOT_PWD=%DEF_ROOT_PWD%"
) else (
    set "ROOT_PWD=%INPUT_PWD%"
)
echo 已设置root密码：!ROOT_PWD!
echo.

echo ==============================================
echo 开始执行安装流程，请稍候...
echo ==============================================
echo.

:: ===================== 清理旧环境 =====================
echo 1. 停止并清理旧 !SERVICE_NAME! 服务...
:: 先停止服务，忽略不存在/未运行的错误
net stop "!SERVICE_NAME!" >nul 2>&1
:: sc命令强制删除服务，兼容性更强
sc delete "!SERVICE_NAME!" >nul 2>&1
:: mysqld原生方式兜底清理
mysqld --remove "!SERVICE_NAME!" >nul 2>&1
:: 等待2秒，确保系统释放服务注册表资源
timeout /t 2 /nobreak >nul

echo 2. 删除旧 data 目录，避免初始化冲突...
if exist "!MYSQL_HOME!\data" (
    rmdir /s /q "!MYSQL_HOME!\data"
)
echo.

:: ===================== 初始化 MySQL =====================
echo 3. 初始化 MySQL 数据库...
mysqld --initialize-insecure
if !errorlevel! neq 0 (
    echo [FAIL]MySQL初始化失败！请检查目录权限。
    pause >nul
    exit /b 1
)
echo 初始化完成
echo.

:: ===================== 安装并启动服务 =====================
echo 4. 安装 Windows 服务：!SERVICE_NAME!
mysqld --install "!SERVICE_NAME!"
if !errorlevel! neq 0 (
    echo [FAIL]服务安装失败！
    pause >nul
    exit /b 1
)
echo 服务安装完成
echo.

echo 5. 启动 !SERVICE_NAME! 服务...
net start "!SERVICE_NAME!"
if !errorlevel! neq 0 (
    echo [FAIL]服务启动失败！检查配置与权限。
    pause >nul
    exit /b 1
)
echo 服务启动成功
echo.

:: ===================== 修改 root 密码 =====================
echo 6. 更新 root 账户密码...
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '!ROOT_PWD!';"
if !errorlevel! neq 0 (
    echo 【警告】密码设置异常，请手动登录修改密码。
)
echo.

:: ===================== 安装完成信息 =====================
echo ==============================================
echo          MySQL 安装配置全部完成
echo ==============================================
echo MySQL 路径：!MYSQL_HOME!
echo 配置文件：!INI_FILE!
echo 服务名称：!SERVICE_NAME!
echo 监听端口：!PORT!
echo root 密码：!ROOT_PWD!
echo 登录命令：mysql -u root -p
echo ==============================================
pause >nul
endlocal