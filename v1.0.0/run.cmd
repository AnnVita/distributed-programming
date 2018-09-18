@ECHO OFF 
copy "config\backend.json" "backend\config.json" 
copy "config\frontend.json" "frontend\config.json" 
start "backend v1.0.0" dotnet backend\backend.dll 
start "frontend v1.0.0" dotnet frontend\frontend.dll 
