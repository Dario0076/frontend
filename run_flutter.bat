@echo off
echo Iniciando Flutter con configuracion CORS para desarrollo...
cd /d "c:\Users\USER\Downloads\InventarioWorkSpace\frontend"
flutter run -d chrome --dart-define=CORS_ENABLED=true
pause
