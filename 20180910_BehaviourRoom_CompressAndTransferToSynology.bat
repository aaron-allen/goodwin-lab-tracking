@echo off
date /T
time /T

set today=%date:~-4%_%date:~3,2%_%date:~0,2%
mkdir %today%_Courtship
set/P UserName=ENTER YOUR FIRST NAME: 
set/P SettingsFile=ENTER THE FULL NAME TO YOUR SETTINGS FILE: 
echo This is your name: %UserName%
echo This is your settings file: %SettingsFile%


for %%A in ("*.avi") do (
	echo COMPRESSING VIDEO "%%A"
	ffmpeg -i "%%A" -c:v libx264 -preset fast -crf 25 "%today%_Courtship\%%~nA_compressed.avi"
	echo COPYING COMPRESSED VIDEO "%%A" TO SYNOLOGY
	xcopy "%today%_Courtship\%%~nA_compressed.avi" "Z:\%UserName%\%today%_Courtship\"

	echo COPYING UNCOMPRESSED VIDEO "%%A" TO OTHER SYNOLOGY
	xcopy "%%A" "X:\raw\%UserName%\%today%_Courtship\"
	fc /b "%%A" "X:\raw\%UserName%\%today%_Courtship\%%A" > nul
	echo THE ERROR LEVEL EQUALS    %errorlevel%
	if %errorlevel% EQU 0 (
		echo NOW DELTING FILES
		del "%%A"
	)
)
::xcopy "%SettingsFile%" "X:\raw\%UserName%\%today%_Courtship\"
echo f | xcopy /f /y "%SettingsFile%" "X:\raw\%UserName%\%today%_Courtship\settings.txt"




echo All Done.
date /T
time /T

PAUSE





