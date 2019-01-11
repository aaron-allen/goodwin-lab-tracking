@echo off
SETLOCAL enabledelayedexpansion
date /T
time /T

cd /D "P:\TempRawVideos"
dir  /s /b *.avi > OrphanVideos.txt
for /f "tokens=*" %%A in (OrphanVideos.txt) do (
	echo.
	echo.
	echo The full path and file is:   "%%A"
	echo The path is:                 "%%~pA"
	echo The file name is:            "%%~nA"
	echo Making lossless compression of "%%A"
	ffmpeg -hide_banner -i "%%A" -c:v libx264 -preset medium -crf 0 "D:\%%~nA_lossless.avi"
	echo Moving "%%~nA" spare Synology
	xcopy /S /Y "D:\%%~nA_lossless.avi" "P:\OrphanVideos%%~pA"
	fc /b "D:\%%~nA_lossless.avi" "P:\OrphanVideos%%~pA%%~nA_lossless.avi" > nul
	echo THE ERROR LEVEL EQUALS    %errorlevel%
	if %errorlevel% EQU 0 (
		echo NOW DELETING FILES
		del "D:\%%~nA_lossless.avi"
		del "%%A"
	)
)

echo All Done.
date /T
time /T

PAUSE
