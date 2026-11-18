@echo off
title AutoVerse.ai - Deploy to Cloudflare
echo.
echo ===== AutoVerse.ai deploy =====
echo Site address: press Enter to use https://autoverse-ai.pages.dev
echo (type https://autoverse.ai ONLY after you own that domain and connected it)
echo.
set /p SITE_URL=Site address: 
if "%SITE_URL%"=="" set SITE_URL=https://autoverse-ai.pages.dev
call npm install || goto :fail
call npm run build || goto :fail
call npx wrangler login || goto :fail
call npx wrangler pages deploy dist --project-name autoverse-ai || goto :fail
echo.
echo DONE. Open the .pages.dev address printed above.
pause
exit /b 0
:fail
echo.
echo Something failed. Copy the error text above and send it to Claude.
pause
exit /b 1
