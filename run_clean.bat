@echo off
REM Clean Flutter Web Runner - Filters out debug service errors
REM Usage: run_clean.bat

echo 🚀 Starting Flutter app with filtered debug output...
echo 📝 Filtering out 'DebugService: Error serving requests' messages  
echo 🌐 App will be available at: http://localhost:3001
echo.

flutter run -d chrome --web-port=3001 --dart-define-from-file=.env --debug 2^>^&1 ^| findstr /v "DebugService: Error serving requests"
