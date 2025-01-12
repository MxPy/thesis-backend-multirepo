@echo off
setlocal EnableDelayedExpansion

:: Save current directory
set "CURRENT_DIR=%CD%"

:: Initialize counters
set UPDATED_COUNT=0
set MISSING_COUNT=0

:: Define repositories and their branches
set "REPOS[1]=thesis-prototype-server"
set "BRANCHES[1]=main"
set "REPOS[2]=thesis-prototype-apigateway"
set "BRANCHES[2]=main"
set "REPOS[3]=thesis-prototype-admin-apigateway"
set "BRANCHES[3]=master"
set "REPOS[4]=thesis-mock-server"
set "BRANCHES[4]=master"
set "REPOS[5]=thesis-backend"
set "BRANCHES[5]=main"
set "REPOS[6]=thesis-forum-monorepo"
set "BRANCHES[6]=master"
set "REPOS[7]=thesis-backend\thesis-sensors-py-service"
set "BRANCHES[7]=main"
set "REPOS[8]=thesis-backend\thesis-timescale-service"
set "BRANCHES[8]=main"
set "REPOS[9]=thesis-backend\thesis-health-wrapper"
set "BRANCHES[9]=main"
set "REPOS[10]=thesis-backend\thesis-health-data-provider"
set "BRANCHES[10]=main"

:: Loop through repositories
for /L %%i in (1,1,10) do (
    if exist "!CURRENT_DIR!\!REPOS[%%i]!" (
        echo Updating repository: !REPOS[%%i]!
        cd "!CURRENT_DIR!\!REPOS[%%i]!"
        
        echo Switching to branch: !BRANCHES[%%i]!
        git fetch origin
        git checkout !BRANCHES[%%i]!
        git reset --hard origin\!BRANCHES[%%i]!
        git pull origin !BRANCHES[%%i]!
        
        echo Update completed: !REPOS[%%i]!
        echo ------------------------
        set /a UPDATED_COUNT+=1
    ) else (
        echo Warning: Directory does not exist: !REPOS[%%i]!
        set /a MISSING_COUNT+=1
    )
)

:: Return to original directory
cd "%CURRENT_DIR%"

:: Display statistics
echo.
echo Update process completed!
echo Statistics:
echo    Repositories updated: %UPDATED_COUNT%
echo    Missing directories: %MISSING_COUNT%
set /a TOTAL=%UPDATED_COUNT%+%MISSING_COUNT%
echo    Total checked: %TOTAL%

endlocal