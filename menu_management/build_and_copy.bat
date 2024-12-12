@echo off
REM Define variables
set "DESKTOP=%USERPROFILE%\Desktop"
set "TARGET_FOLDER=Menu Management"
set "TARGET_PATH=%DESKTOP%\%TARGET_FOLDER%"
set "BUILD_PATH=build\windows\x64\runner\Release"

REM Step 1: Build the Flutter app
echo Building the app...
flutter build windows
if %ERRORLEVEL% NEQ 0 (
    echo Build failed. Exiting script.
    exit /b %ERRORLEVEL%
)

echo Build completed successfully.

REM Step 2: Create or clear the target folder on the desktop
if exist "%TARGET_PATH%" (
    echo Target folder already exists. Clearing its contents.
    rmdir /s /q "%TARGET_PATH%"
)
mkdir "%TARGET_PATH%"

REM Step 3: Copy the contents of the build directory to the target folder
echo Copying build contents to the target folder...
xcopy "%BUILD_PATH%\*" "%TARGET_PATH%" /s /e /y

echo App copied to "%TARGET_PATH%" successfully.
