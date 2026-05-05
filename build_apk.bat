@echo off
title Flutter APK Builder

echo ============================
echo  FLUTTER APK AUTO BUILDER
echo ============================

echo Checking Flutter...
flutter --version
if %errorlevel% neq 0 (
    echo Flutter not found! Install Flutter first.
    pause
    exit /b
)

echo.
echo Cleaning project...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Accepting Android licenses...
flutter doctor --android-licenses

echo.
echo Building APK (RELEASE)...
flutter build apk --release

echo.
echo ============================
echo BUILD DONE
echo APK LOCATION:
echo build\app\outputs\flutter-apk\app-release.apk
echo ============================

pause