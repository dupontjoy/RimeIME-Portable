@Echo Off
Title С�Ǻ���ɫ��ж�ع���by��ˮţ

::�Զ��Թ���Ա�������bat�ļ�
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

Pushd %~dp0
If "%PROCESSOR_ARCHITECTURE%"=="AMD64" (Set a="WeaselSetup.exe"&Set b=%SystemRoot%\SysWOW64) Else (Set a="WeaselSetup.exe"&Set b=%SystemRoot%\system32)
Rd "%b%\test_permission_sununs" >nul 2>nul
Md "%b%\test_permission_sununs" 2>nul||(Echo ��ʹ���Ҽ�����Ա�������&&Pause >nul&&Exit)
Rd "%b%\test_permission_sununs" >nul 2>nul
"%~dp0weasel\WeaselServer.exe" /quit
taskkill /f /t /im WeaselServer.exe
"%~dp0weasel\%a%" /u
Del /f /q "%~dp0*.lnk" >nul 2>nul
mshta VBScript:Msgbox("ж�����",vbSystemModal,"")(close)
