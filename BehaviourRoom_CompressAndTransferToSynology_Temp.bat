@echo off
date /T
time /T

:: Aaron M. Allen, updated 2019.03.06
:: Batch script to transfer videos to Synology.
:: The raw video and settings.txt file to the '2P' Synology.

set today=%date:~-4%_%date:~3,2%_%date:~0,2%
mkdir %today%_Courtship
set/P UserName=ENTER YOUR FIRST NAME: 
set/P SettingsFile=ENTER THE FULL NAME TO YOUR SETTINGS FILE: 

echo Your file transfers have been added to the queue.
echo Will exit when transfers are finished...

set LOGFILE="D:\TransferLogFiles\%today%_%UserName%_transfer.log" 
call :LOG > %LOGFILE%
exit /B


:LOG
date /T
time /T
echo User name: %UserName%
echo Settings file: %SettingsFile%


:WAIT
TIMEOUT 600 /NOBREAK
if exist "D:\TransferLogFiles\lock.txt" (goto WAIT)

type NUL > "D:\TransferLogFiles\lock.txt"

for %%A in ("*.avi") do (
	echo COPYING UNCOMPRESSED VIDEO "%%A" TO OTHER SYNOLOGY
	xcopy "%%A" "X:\TempRawVideos\%UserName%\%today%_Courtship\"
	echo THE ERROR LEVEL EQUALS    %errorlevel%
	if %errorlevel% EQU 0 (
		echo NOW DELTING FILES
		del "%%A"
	)
)
::xcopy "%SettingsFile%" "X:\TempRawVideos\%UserName%\%today%_Courtship\"
echo f | xcopy /f /y "%SettingsFile%" "X:\TempRawVideos\%UserName%\%today%_Courtship\settings.txt"

del "D:\TransferLogFiles\lock.txt"

echo All Done.
date /T
time /T
