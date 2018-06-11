@ECHO OFF

IF "%~1"=="" (
  GOTO HandleInvalidArgsInput
)

SET BUILD_DIR=v%~1
SET CONFIG_DIR=config
SET CONFIG_EXT=json
SET SRC_DIR=src

SET BACKEND_NAME=backend
SET BACKEND_CONFIG=%SRC_DIR%\%BACKEND_NAME%\config.%CONFIG_EXT%
SET BACKEND_WINDOW_NAME=%BACKEND_NAME% %BUILD_DIR%

SET FRONTEND_NAME=frontend
SET FRONTEND_CONFIG=%SRC_DIR%\%FRONTEND_NAME%\config.%CONFIG_EXT%
SET FRONTEND_WINDOW_NAME=%FRONTEND_NAME% %BUILD_DIR%

CALL :ClearFolderForBuild

CALL :BuildAll
IF %ERRORLEVEL% NEQ 0 GOTO HandleBuildError

CALL :CopyConfigFiles

IF %ERRORLEVEL% NEQ 0 GOTO HandleCopyConfigError

CALL :CreateScriptForRun
CALL :CreateScriptForStop

ECHO Build sucsessfully completed!
EXIT /B 0


:ClearFolderForBuild
  IF EXIST %BUILD_DIR% RD /s /q "%BUILD_DIR%"
  EXIT /B 0

:BuildAll
  CALL :BuildComponent %BACKEND_NAME%
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1

  CALL :BuildComponent %FRONTEND_NAME%
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1

  EXIT /B 0

:BuildComponent
  dotnet publish %SRC_DIR%\%~1 -c Release -o ..\..\%BUILD_DIR%\%~1
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1
  EXIT /B 0

:CopyConfigFiles
  MD "%BUILD_DIR%\%CONFIG_DIR%"
  COPY "%BACKEND_CONFIG%" "%BUILD_DIR%\%CONFIG_DIR%\%BACKEND_NAME%.%CONFIG_EXT%"
  COPY "%FRONTEND_CONFIG%" "%BUILD_DIR%\%CONFIG_DIR%\%FRONTEND_NAME%.%CONFIG_EXT%"
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1
  EXIT /B 0

:CreateScriptForRun
  SET RESULT_FILE=%BUILD_DIR%\run.cmd
  SET A=%%%%A
  SET B=%%%%B

  @ECHO @ECHO OFF > %RESULT_FILE%
  @ECHO copy "%CONFIG_DIR%\%BACKEND_NAME%.%CONFIG_EXT%" "%BACKEND_NAME%\config.%CONFIG_EXT%" >> %RESULT_FILE%
  @ECHO copy "%CONFIG_DIR%\%FRONTEND_NAME%.%CONFIG_EXT%" "%FRONTEND_NAME%\config.%CONFIG_EXT%" >> %RESULT_FILE%
  @ECHO start "%BACKEND_WINDOW_NAME%" dotnet %BACKEND_NAME%\%BACKEND_NAME%.dll >> %RESULT_FILE%
  @ECHO start "%FRONTEND_WINDOW_NAME%" dotnet %FRONTEND_NAME%\%FRONTEND_NAME%.dll >> %RESULT_FILE%
  EXIT /B 0

:CreateScriptForStop
  (
    @ECHO @ECHO OFF
    @ECHO taskkill /IM dotnet.exe
  ) > %BUILD_DIR%\stop.cmd
  EXIT /B 0

:HandleInvalidArgsInput
  ECHO Invalid build version. Usage: build.cmd version
  EXIT /B 1

:HandleBuildError
  ECHO Error during build project...
  CALL :Clear
  EXIT /B 2

:HandleCopyConfigError
  ECHO Error during copy config files...
  CALL :Clear
  EXIT /B 3
