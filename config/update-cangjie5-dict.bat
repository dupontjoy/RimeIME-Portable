::2023.11.03

@echo off

title Ò»¼üÏÂÔØcangjieÂë±í
color 0a

pushd %~dp0

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs

:: start updating
call :updating
call :end
goto :eof

:updating
:: scripts
echo. downloading cangjie5
::%Download% -o "%cd%\cangjie5.dict.yaml" https://github.com/Jackchows/Cangjie5/raw/master/scripts/cangjie5.dict.yaml
%Download% -o "%cd%\cangjie5.txt" https://github.com/Jackchows/Cangjie5/raw/master/Cangjie5.txt


:end
timeout /t 3 /nobreak
