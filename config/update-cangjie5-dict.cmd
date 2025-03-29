:: 2025.03.02

@echo off
title 倉頡五代碼表智能更新器
color 0a
pushd %~dp0

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:test_fastest_ghmirror
CALL "%cd%\..\..\..\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"

::=======================================
:: 主流程
::=======================================
:menu
call :updating
call :deploy
call :end
goto :eof

:updating
setlocal
echo. [下载] %GH_PROXY%/https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt
%Curl_Download% -O %GH_PROXY%/https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt

:: 获取最后修改日期 ======================
:: 使用PowerShell获取时间戳
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod 'https://api.github.com/repos/Jackchows/Cangjie5/commits?path=Cangjie5.txt&page=1&per_page=1').commit.committer.date"') do (
    set "uploadDate=%%i"
)
echo 最新提交日期: %uploadDate%
set "last_modified_date=%uploadDate%"

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
    echo version: "%last_modified_date%"
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
goto :eof

:end
timeout /t 3 /nobreak