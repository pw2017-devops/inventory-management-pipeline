@echo off

rem                          Copyright 2017  Pegasystems Inc.                           
rem                                 All rights reserved.                                 
rem This software has been provided pursuant to a License Agreement containing restrictions
rem on its use. The software contains valuable trade secrets and proprietary information of
rem Pegasystems Inc and is protected by federal copyright law.It may not be copied, modified,
rem translated or distributed in any form or medium, disclosed to third parties or used in 
rem any manner not provided for in  said License Agreement except with  written
rem authorization from Pegasystems Inc.


rem Go through a barrage of tests to verify that JAVA_HOME is set.
set scriptpath=%~dp0
if not "%JAVA_HOME%" == "" goto JavaHomeTest
echo The JAVA_HOME environment variable must be defined.
goto Error
:JavaHomeTest
if not exist "%JAVA_HOME%\bin\java.exe" goto JavaHomeBad
goto JavaHomeOk
:JavaHomeBad
echo The JAVA_HOME environment variable must point to a 
echo valid installation of the JDK.
goto Error

rem At this point, JAVA_HOME is set, shorthand our EXEs.
:JavaHomeOk
set JAVA_BIN="%JAVA_HOME%\bin\java.exe"
set JAR_BIN="%JAVA_HOME%\bin\jar.exe"
set ANT_HOME=%~dp0\..
rem reset the props in case of multiple runs!
set "ANT_PROPS="

set "PEGA_TOOL=%~1"
shift

if "%PEGA_TOOL%"=="" goto :argHelp
if "%PEGA_TOOL%"=="help" goto :argHelp
if "%PEGA_TOOL%"=="--help" goto :argHelp
if "%PEGA_TOOL%"=="export" goto :pegaToolOK
if "%PEGA_TOOL%"=="import" goto :pegaToolOK
if "%PEGA_TOOL%"=="expose" goto :pegaToolOK
if "%PEGA_TOOL%"=="hotfix" goto :pegaToolOK
if "%PEGA_TOOL%"=="getStatus" goto :pegaToolOK
if "%PEGA_TOOL%"=="manageTrackedData" goto :pegaToolOK
if "%PEGA_TOOL%"=="rollback" goto :pegaToolOK
if "%PEGA_TOOL%"=="manageRestorePoints" goto :pegaToolOK
if "%PEGA_TOOL%"=="updateAccessGroup" goto :pegaToolOK

rem If the tool is not in the list above, print an error
echo Unknown tool: "%PEGA_TOOL%"
goto :argHelp

rem If the tool is one of the old import methods, inform the user
rem that they should use 'import'
:importMessage
echo ** The mode "%PEGA_TOOL%" has been replaced by the mode "import". 
echo ** Continuing using "import" mode...
set "PEGA_TOOL=import"
goto :pegaToolOK

:pegaToolOK

:ArgLoop
if "%~1" == "" goto ArgLoopEnd
  rem Special case for --help, we want script to really exit.
  if "%~1" == "--help" goto ArgHelp
  if "%~1" == "help" goto ArgHelp
  rem Branch to a label for this command, using the value on
  rem the other side of the equals as an argument.
  call :%~1 %2 2>NUL
  rem All of our branches set ERRORLEVEL 0, so if it is != 0
  rem we must have had an illegal argument. Tell the user.
  if %ERRORLEVEL% neq 0 goto ArgError
  rem Shift out both our --arg and our =value.
  shift
  shift
goto ArgLoop
:ArgLoopEnd

rem **************************** Script Starts Here ****************************
FOR /F "delims=;" %%D IN ('wmic os get LocalDateTime ^| findstr \.') DO @SET LCL_INS_DT=%%D
if "%LCL_INS_DT%" == "" goto UseRandom
  set TIMESTAMP=%LCL_INS_DT:~0,8%_%LCL_INS_DT:~8,6%
  goto TimeStampSet
:UseRandom
  set TIMESTAMP=%RANDOM%
:TimeStampSet
set LOGFILE=%scriptpath%\logs\CLI-prpcserviceutils-%TIMESTAMP%.log 
set CODEFILE=%scriptpath%\logs\%TIMESTAMP%.code.txt
mkdir %scriptpath%\logs 2> NUL
rem Invoke our ant script, passing in the arguments as collected
set ANT_PROPS=%ANT_PROPS% "-Dprpc.service.util.action=%PEGA_TOOL%"
set ANT_PROPS=%ANT_PROPS% "-Dlogfile.timestamp=%TIMESTAMP%"

echo Invoke our ant script, passing in the arguments as collected

rem call "%ANT_HOME%\bin\ant.bat" %ANT_PROPS% -f prpcserviceutilsWrapper.xml "performOperation" 2>&1| ..\lib\tee.exe %LOGFILE%
set ANT_SCRIPT=%scriptpath%\prpcserviceutilsWrapper.xml
set ANT_TARGET="performOperation"
call %scriptpath%..\invokeAnt.bat 2>&1  | %scriptpath%..\lib\Tee.exe %LOGFILE%

rem read in the exit code that ant returned

if exist %CODEFILE% (
    set /p code=<%CODEFILE%
    del %CODEFILE%
) else (
    set code=1
)

rem **************************** Script  Ends  Here ****************************

exit /b %code%
goto End

:--connPropFile
set "ANT_PROPS=%ANT_PROPS% -Dprpcserviceutils.connection.filepath=%1"
exit /b 0
:--propFile
set "ANT_PROPS=%ANT_PROPS% -Dprpc.service.utils.custom.property.filepath=%1"
exit /b 0
:--poolSize
set "ANT_PROPS=%ANT_PROPS% -Dprpcserviceutils.pool.size=%1"
exit /b 0
:--requestTimeOut
set "ANT_PROPS=%ANT_PROPS% -Dprpcserviceutils.request.timeout=%1"
exit /b 0
:--jobIdFile
set "ANT_PROPS=%ANT_PROPS% -Doperation.specific.file.path=%1"
exit /b 0
:--operationName
set "ANT_PROPS=%ANT_PROPS% -Dgetstatus.operationName=%1"
exit /b 0
:--artifactsDir
set "ANT_PROPS=%ANT_PROPS% -Dservice.responseartifacts.dir=%1"
exit /b 0
:ArgError
echo Illegal argument "%~1"
:ArgHelp
echo usage:
echo prpcserviceutils.bat ( expose ^| export ^| hotfix ^| getStatus ^| import ^| manageTrackedData ^| rollback ^| manageRestorePoints ^| updateAccessGroup ^| help ) [options...]
echo.
echo Options:
echo   --connPropFile	Path to connection.properties to operate on multiple instances.
echo   --propFile       Location of prpcServiceUtils.properties file. Defaults to .\prpcServiceUtils.properties
echo   --poolSize		Thread pool size
echo   --requestTimeOut	Request TimeOut
echo   --jobIdFile		Path to the JobIds file generated by EXPORT/IMPORT/EXPOSE/HOTFIX operation
echo   --operationName	Operation name to be queried for getStatus. import, export, expose, and rollback are the valid operation names
echo   --artifactsDir	Specify directory where all the service response artifacts like attachments, service operation logs are stored. 

echo All "--" options are optional and will override options in the properties file
exit /b 1

:Error
echo Exiting with Error
exit /b 1

:End
echo Exiting with NO Error
exit /b 0
