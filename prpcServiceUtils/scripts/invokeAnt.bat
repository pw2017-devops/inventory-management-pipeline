@echo off
rem script to invoke ant

call "%ANT_HOME%\bin\ant.bat" %ANT_PROPS% -f %ANT_SCRIPT% %ANT_TARGET% -noclasspath

echo %errorlevel% > %CODEFILE%
if not (%errorlevel%)==(0) goto Error

goto End

rem Set error codes and exit
:Error
echo Exiting with Error
exit /b %errorlevel%

:End
echo Exiting with NO Error
exit /b 0
