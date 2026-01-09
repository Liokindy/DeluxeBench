SET "NAME=SFDItemTool"

SET "LOVE_PATH=F:\Program Files\LOVE\"
SET "FUSED_PATH=.\release\fused\"
SET "PACKAGE_PATH=.\release\package\"
SET "SOURCE_PATH=.\source\"

if exist %PACKAGE_PATH%%NAME%.zip del /F %PACKAGE_PATH%%NAME%.zip
if exist %PACKAGE_PATH%%NAME%.love del /F %PACKAGE_PATH%%NAME%.love
if exist %FUSED_PATH%%NAME%.exe del /F %FUSED_PATH%%NAME%.exe
if not exist %FUSED_PATH% mkdir %FUSED_PATH%
if not exist %PACKAGE_PATH% mkdir %PACKAGE_PATH%

powershell Compress-Archive -Path %SOURCE_PATH%* -DestinationPath %PACKAGE_PATH%%NAME%
ren %PACKAGE_PATH%%NAME%.zip %NAME%.love

copy "%LOVE_PATH%license.txt" %FUSED_PATH%
copy "%LOVE_PATH%love.dll" %FUSED_PATH%
copy "%LOVE_PATH%lua51.dll" %FUSED_PATH%
copy "%LOVE_PATH%mpg123.dll" %FUSED_PATH%
copy "%LOVE_PATH%msvcp120.dll" %FUSED_PATH%
copy "%LOVE_PATH%msvcr120.dll" %FUSED_PATH%
copy "%LOVE_PATH%OpenAL32.dll" %FUSED_PATH%
copy "%LOVE_PATH%SDL2.dll" %FUSED_PATH%
copy /b "%LOVE_PATH%lovec.exe"+%PACKAGE_PATH%%NAME%.love %FUSED_PATH%%NAME%.exe
