:: 2025.05.27

@echo off
title 倉頡五代碼表智能更新器
color 0a
pushd %~dp0

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:: 版本文件
set "version_file=versions_cangjie5_dict.txt"

::=======================================
:: 主流程
::=======================================
:menu

call :test_fastest_ghmirror
call :check_version
if "%need_update%"=="1" (
    call :update_cangjie5_dict
    (echo|set /p="%latest_version%") > "%version_file%"
    echo 已更新到最新版本: %latest_version%
    call :deploy
) else (
    echo 当前已是最新版本: %latest_version%，无需更新
)
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\..\..\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:check_version
setlocal enabledelayedexpansion
echo.&echo █ 正在检查cangjie5_dict版本...

:: GitHub API 地址
set "api_url=https://api.github.com/repos/Jackchows/Cangjie5/commits?path=Cangjie5.txt&page=1&per_page=1"

:: 获取最新版本更新時间
for /f %%i in ('powershell -Command "(Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json).commit.committer.date"') do (
    set "latest_version=%%i"
)
echo 在线版本: %latest_version%

:: 读取本地版本更新時间
set "local_version="
if exist "%version_file%" (
    for /f "usebackq delims=" %%i in ("%version_file%") do (
        set "local_version=%%i"
    )
)
echo 本地版本: %local_version%

:: 比较版本
if "%latest_version%"=="%local_version%" (
    set "need_update=0"
) else (
    set "need_update=1"
)
echo 版本比较结果: %need_update%

endlocal & set "need_update=%need_update%" & set "latest_version=%latest_version%"

goto :eof

:update_cangjie5_dict
setlocal enabledelayedexpansion
echo. [下载] %GH_PROXY%/https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt
%Curl_Download% -O %GH_PROXY%/https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt

:: 智能文本替换系统 ======================
:: 生成头文件
(
    echo # encoding: utf-8
    echo ## 倉頡五代補完計劃：
    echo # https://github.com/Jackchows/Cangjie5
    echo # 使用前務必閱讀：
    echo # https://github.com/Jackchows/Cangjie5/blob/master/README.md 及
    echo # https://github.com/Jackchows/Cangjie5/blob/master/change_summary.md
    echo #
    echo # 相關項目：倉頡三代補完計畫
    echo # https://github.com/Arthurmcarthur/Cangjie3-Plus
    echo ##
    echo ## 一般排序，綜合考慮字頻及繁簡，部分常用簡化字可能排在傳統漢字前面。
    echo ---
    echo name: "cangjie5"
    echo version: "%latest_version%"
    echo sort: original
    echo use_preset_vocabulary: false
    echo columns:
    echo   - text
    echo   - code
    echo   - stem
    echo encoder:
    echo   exclude_patterns:
    echo     - '^x.*$'
    echo     - '^z.*$'
    echo   rules:
    echo     - length_equal: 2
    echo       formula: "AaAzBaBbBz"
    echo     - length_equal: 3
    echo       formula: "AaAzBaBzCz"
    echo     - length_in_range: [4, 10]
    echo       formula: "AaBzCaYzZz"
    echo   tail_anchor: "'"
    echo ...
) > header.tmp

:: 查找目标行号（使用PowerShell处理UTF8编码）
for /f %%i in ('powershell -Command "Get-Content Cangjie5.txt -Encoding UTF8 | Select-String '^日' | ForEach-Object { $_.LineNumber }"') do (
    set /a "skip_lines=%%i-1"
)
if not defined skip_lines (
    echo 错误：未找到以'日'开头的行
    del Cangjie5.txt
    pause
    exit /b 1
)

:: 合并文件（统一使用UTF8编码处理）
echo 正在生成最终文件...
powershell -Command "Get-Content header.tmp | Out-File cangjie5.dict.yaml -Encoding UTF8"
powershell -Command "Get-Content Cangjie5.txt -Encoding UTF8 | Select-Object -Skip %skip_lines% | Add-Content cangjie5.dict.yaml -Encoding UTF8"

:: 清理临时文件
del header.tmp
del Cangjie5.txt
echo 处理完成，文件已保存为cangjie5.dict.yaml
endlocal

goto :eof

:deploy
start "" "%cd%\..\weasel\WeaselDeployer.exe" /deploy
echo 已重新布署
goto :eof

:end
timeout /t 3 /nobreak
