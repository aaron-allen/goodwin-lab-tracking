@echo off
setlocal EnableExtensions EnableDelayedExpansion

date /T
time /T

:: Aaron M. Allen, updated 2019.07.04
:: Batch script to transfer videos to Synology.
:: The raw video and settings.txt file to the '2P' Synology.

set today=%date:~-4%_%date:~3,2%_%date:~0,2%
set "WorDir=%cd%"
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
	echo.
	echo.
	echo.
	echo Copying raw video "%%A" to 2P Synology
	xcopy "%%A" "X:\TempRawVideos\%UserName%\%today%_Courtship\"
	echo THE ERROR LEVEL EQUALS    !errorlevel!

	if !errorlevel! EQU 0 (
		if exist "X:\TempRawVideos\%UserName%\%today%_Courtship\%%A" (
			echo Remote file exists
			set localsize="%%~zA"
			set remotesize="X:\TempRawVideos\%UserName%\%today%_Courtship\%%~zA"
				cd "X:\TempRawVideos\%UserName%\%today%_Courtship"
				set remotesize="%%~zA"
				cd %WorDir%
			echo Local file size is !localsize!
			echo Remote file size is !remotesize!

			if !localsize! EQU !remotesize! (
				echo Local and remote file sizes match
				echo NOW DELETING FILES
				del "%%A"
			) else (
				echo Local and remote file are different sizes
				echo Not deleting local file
			)
		) else (
			echo Remote file does NOT exist
			echo Not deleting local file
		)
	) else (
		echo error level is not zero
		echo Not deleting local file
	)
)

echo.
echo.
echo.

if exist "X:\TempRawVideos\%UserName%\%today%_Courtship\settings.txt" (
	echo. >> "P:\TempRawVideos\%UserName%\%today%_Courtship\settings.txt"
	type %SettingsFile% >> "X:\TempRawVideos\%UserName%\%today%_Courtship\settings.txt"
) else (
	type "%SettingsFile%" > "X:\TempRawVideos\%UserName%\%today%_Courtship\settings.txt"
)


del "D:\TransferLogFiles\lock.txt"

echo.
echo.
echo.

echo All Done.
date /T
time /T
