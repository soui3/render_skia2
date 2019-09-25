cd /d %~dp0
@ECHO off
SETLOCAL enabledelayedexpansion
cls
COLOR 1f

ECHO.
ECHO.
ECHO   ##############################################################
ECHO   #               欢迎使用 SOUI 工程配置向导                   #
ECHO   #                                启程软件 2017.04.01         #
ECHO   ##############################################################
ECHO.
ECHO.

SET cfg=
SET specs=
SET target=x86
SET targetx86andx64=0
SET selected=
SET mt=1
SET unicode=1
SET wchar=1
SET supportxp=0
SET vsvarbat=

	  for /f "skip=2 delims=: tokens=1,*" %%i in ('%windir%\system32\reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /v "ProgramFilesDir (x86)"') do ( 
	    set str=%%i
		set var=%%j
		set "var=!var:"=!"
		if not "!var:~-1!"=="=" set strCMD=!str:~-1!:!var!
	 )
	 SET strCMD=%strCMD%\Microsoft Visual Studio\Installer\vswhere.exe
	
	 if exist "%strCMD%" (
	 for /f "delims=" %%i in ('"%strCMD%" -nologo -version [16.0^,17.0] -prerelease -property installationPath -format value') do (
	    set vs2019path=%%i
		)
	 )
	 
rem 选择编译版本
SET /p selected=1.选择编译版本[1=x86;2=x64;3=x86+x64]:
if %selected%==1 (
	SET target=x86
) else if %selected%==2 (
	SET target=x64
	SET cfg=!cfg! x64
) else if %selected%==3 (
	SET target=x86
	SET targetx86andx64=1
) else (
	goto error
)


rem 选择开发环境
SET /p selected=2.选择开发环境[1=2017;2=2019]:

if %selected%==1 (
	SET specs=win32-msvc2017
	for /f "skip=2 delims=: tokens=1,*" %%i in ('%windir%\system32\reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" /v "15.0" /reg:32') do ( 
	    set str=%%i
		set var=%%j
		set "var=!var:"=!"
		if not "!var:~-1!"=="=" set value=!str:~-1!:!var!
	 )
	 SET value=!value!\VC\Auxiliary\Build\vcvarsall.bat
	 ECHO Vs2017 path is:!value! 
		SET vsvarbat="!value!"
		call !vsvarbat! %target%
		rem call "!value!" %target%
		goto toolsetxp
) else if %selected%==2 (		 
	  SET specs=win32-msvc2017
	  SET vs2019path=!vs2019path!\VC\Auxiliary\Build\vcvarsall.bat
	  ECHO Vs2019 path is:!vs2019path! 
		SET vsvarbat="!vs2019path!"
		call !vsvarbat! %target%
		rem call "!value!" %target%
		goto toolsetxp
)else (
	goto error
)

:toolsetxp
rem 选择字符集
SET /p selected=3.选择字符集[1=UNICODE;2=MBCS]:

if %selected%==1 (
	rem do nothing
	set unicode=1
) else if %selected%==2 (
	SET unicode=0
	SET cfg=!cfg! MBCS
) else (
	goto error
)

rem 选择WCHAR支持
SET /p selected=4.将WCHAR作为内建类型[1=是;2=否]:
if %selected%==1 (
	rem do nothing
	SET wchar=1
) else if %selected%==2 (
	SET cfg=!cfg! DISABLE_WCHAR
	SET wchar=0
) else (
	goto error
)

rem CRT
SET /p selected=5.选择CRT链接模式[1=静态链接(MT);2=动态链接(MD)]:
if %selected%==1 (
	SET mt=1
	SET cfg=!cfg! USING_MT
) else if %selected%==2 (
	SET mt=0
	rem do nothing
) else (
	goto error
)

rem 为release版本生成调试信息
SET /p selected=6.是否为release版本生成调试信息[1=生成;2=不生成]:
if %selected%==1 (
	SET cfg=!cfg! CAN_DEBUG
) else if %selected%==2 (
	rem do nothing
) else (
	goto error
)
cd /d %~dp0

%SOUI3PATH%\tools\qmake2017 -tp vc -r -spec %SOUI3PATH%\tools\mkspecs\%specs% "CONFIG += %cfg%"
	if %targetx86andx64%==1 (
		call !vsvarbat! x64
		SET cfg=!cfg! x64
		cd /d %~dp0
		%SOUI3PATH%\tools\qmake2017 -tp vc -r -spec %SOUI3PATH%\tools\mkspecs\%specs% "CONFIG += !cfg!"
	)
	if %supportxp%==1 (
		%SOUI3PATH%\tools\ConvertPlatformToXp -f souiprosubdir.xml
		)
		


goto final

:error
	ECHO 选择错误，请重新选择	
:final

rem pause