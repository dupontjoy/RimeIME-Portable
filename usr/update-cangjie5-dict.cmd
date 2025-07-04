:: 2025.05.27

@echo off
title �}�R����a�����ܸ�����
color 0a
pushd %~dp0

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:: �汾�ļ�
set "version_file=versions_cangjie5_dict.txt"

::=======================================
:: ������
::=======================================
:menu

call :test_fastest_ghmirror
call :check_version
if "%need_update%"=="1" (
    call :update_cangjie5_dict
    (echo|set /p="%latest_version%") > "%version_file%"
    echo �Ѹ��µ����°汾: %latest_version%
    call :deploy
) else (
    echo ��ǰ�������°汾: %latest_version%���������
)
call :end
goto :eof

::=======================================
:: �ӳ���
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\..\..\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:check_version
setlocal enabledelayedexpansion
echo.&echo �� ���ڼ��cangjie5_dict�汾...

:: GitHub API ��ַ
set "api_url=https://api.github.com/repos/Jackchows/Cangjie5/commits?path=Cangjie5.txt&page=1&per_page=1"

:: ��ȡ���°汾���r��
for /f %%i in ('powershell -Command "(Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json).commit.committer.date"') do (
    set "latest_version=%%i"
)
echo ���߰汾: %latest_version%

:: ��ȡ���ذ汾���r��
set "local_version="
if exist "%version_file%" (
    for /f "usebackq delims=" %%i in ("%version_file%") do (
        set "local_version=%%i"
    )
)
echo ���ذ汾: %local_version%

:: �Ƚϰ汾
if "%latest_version%"=="%local_version%" (
    set "need_update=0"
) else (
    set "need_update=1"
)
echo �汾�ȽϽ��: %need_update%

endlocal & set "need_update=%need_update%" & set "latest_version=%latest_version%"

goto :eof

:update_cangjie5_dict
setlocal enabledelayedexpansion
echo. [����] %GH_PROXY%/https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt
%Curl_Download% -O %GH_PROXY%/https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt

:: �����ı��滻ϵͳ ======================
:: ����ͷ�ļ�
(
    echo # encoding: utf-8
    echo ## �}�R����a��Ӌ����
    echo # https://github.com/Jackchows/Cangjie5
    echo # ʹ��ǰ�ձ���x��
    echo # https://github.com/Jackchows/Cangjie5/blob/master/README.md ��
    echo # https://github.com/Jackchows/Cangjie5/blob/master/change_summary.md
    echo #
    echo # ���P�Ŀ���}�R�����a��Ӌ��
    echo # https://github.com/Arthurmcarthur/Cangjie3-Plus
    echo ##
    echo ## һ�����򣬾C�Ͽ��]���l�����������ֳ��ú����ֿ������ڂ��y�h��ǰ�档
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

:: ����Ŀ���кţ�ʹ��PowerShell����UTF8���룩
for /f %%i in ('powershell -Command "Get-Content Cangjie5.txt -Encoding UTF8 | Select-String '^��' | ForEach-Object { $_.LineNumber }"') do (
    set /a "skip_lines=%%i-1"
)
if not defined skip_lines (
    echo ����δ�ҵ���'��'��ͷ����
    del Cangjie5.txt
    pause
    exit /b 1
)

:: �ϲ��ļ���ͳһʹ��UTF8���봦��
echo �������������ļ�...
powershell -Command "Get-Content header.tmp | Out-File cangjie5.dict.yaml -Encoding UTF8"
powershell -Command "Get-Content Cangjie5.txt -Encoding UTF8 | Select-Object -Skip %skip_lines% | Add-Content cangjie5.dict.yaml -Encoding UTF8"

:: ������ʱ�ļ�
del header.tmp
del Cangjie5.txt
echo ������ɣ��ļ��ѱ���Ϊcangjie5.dict.yaml
endlocal

goto :eof

:deploy
start "" "%cd%\..\weasel\WeaselDeployer.exe" /deploy
echo �����²���
goto :eof

:end
timeout /t 3 /nobreak
