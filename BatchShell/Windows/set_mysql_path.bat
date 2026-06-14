cls
@echo off
chcp 65001 >nul

:START
set /p home=请输入MySQL安装路径：


:INSTALL
rem 如输入正确的 MySQL安装路径，开始设置环境变量
echo 输入的路径是:%home%
@setx /M MySQL_HOME "%home%"
@setx /M Path "%%MySQL_HOME%%\bin;%Path%"

:END
echo MySQL环境设置完毕
pause