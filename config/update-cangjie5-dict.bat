:: 2025.03.02

@echo off
setlocal enabledelayedexpansion
title 倉頡五代碼表智能更新器
color 0a
pushd %~dp0

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:test_fastest_proxy
:: 定义测试链接
set "test_url=https://github.com/Jackchows/Cangjie5/raw/master/README.md"

:: 定义镜像站点列表
set "proxies=gh-proxy.com ghfast.top ghproxy.net github.moeyy.xyz"

:: 初始化变量
set "fastest_proxy="
set "fastest_time=9999.999"

:: 循环测试每个镜像站点
for %%p in (%proxies%) do (
    echo 测试镜像站点: %%p
    for /f "tokens=*" %%t in ('curl --max-time 20 -o NUL -s -w "%%{time_total}" "https://%%p/%test_url%" 2^>^&1 ^|^| echo 9999') do (
        set "current_time=%%t"
        echo  耗时: !current_time! 秒
        call :compare_time %%p !current_time!
    )
)

:: 输出结果
echo ------------------------
echo 最快的镜像站点是: %fastest_proxy%
set "GH_PROXY=https://%fastest_proxy%"
echo GH_PROXY=%GH_PROXY%
goto :menu

:compare_time
if "%~2"=="" exit /b
setlocal
set "time=%~2"
:: 移除可能的逗号（某些区域设置使用逗号作小数点）
set "time=!time:,=.!"
:: 浮点数比较需要特殊处理
set /a int_time=!time:.=! 
set /a int_fastest=!fastest_time:.=!
if !int_time! lss !int_fastest! (
    endlocal
    set "fastest_time=%~2"
    set "fastest_proxy=%~1"
) else (
    endlocal
)
exit /b

:menu
call :updating
call :deploy
goto :eof

:updating
:: scripts
echo. downloading Cangjie5.txt
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

:deploy
start "" "%cd%\..\weasel\WeaselDeployer.exe" /deploy