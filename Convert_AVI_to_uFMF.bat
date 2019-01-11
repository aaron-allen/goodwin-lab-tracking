@echo off
SETLOCAL enabledelayedexpansion
set today=%date:~-4%%date:~3,2%%date:~0,2%
set LOGFILE="C:\Users\GoodwinLab\UFMF\logfiles\%today%_AVI_to_uFMF.log" 
call :LOG > %LOGFILE%
exit /B


:LOG
date /T
time /T

:: Aaron M. Allen, updated 2019.01.07
:: Batch script to cut and convert raw videos to uFMF to be tracked. Also makes a lossless version of
:: the video for archival purposes.



:: This section tests to see if the previous weeks run is finished.
:: But it is not finished... may not be necessary since this script is not scheduled.
:WAIT
TIMEOUT 30 /NOBREAK
tasklist /FI "IMAGENAME eq ffmpeg.exe" 2>NUL | find /I /N "ffmpeg.exe">NUL
if "%ERRORLEVEL%"=="0" (goto WAIT)
tasklist /FI "IMAGENAME eq any2ufmf.exe" 2>NUL | find /I /N "any2ufmf.exe">NUL
if "%ERRORLEVEL%"=="0" (goto WAIT)
tasklist /FI "IMAGENAME eq xcopy.exe" 2>NUL | find /I /N "xcopy.exe">NUL
if "%ERRORLEVEL%"=="0" (goto WAIT)
tasklist /FI "IMAGENAME eq fc.exe" 2>NUL | find /I /N "fc.exe">NUL
if "%ERRORLEVEL%"=="0" (goto WAIT)


echo.
cd
cd /D "P:\TempRawVideos"
cd

:: Generate a list of directories that contain settings files for video conversion
for /f %%X in ('dir /s /b settings.txt') do echo %%~pX >> "C:\Users\GoodwinLab\UFMF\SettingsListFiles\%today%_SettingsList.txt"

:: Subsection videos from Synology based on the settings files,
:: convert them to ufmf, and copy ufmf to other Synology

if exist "%today%_SettingsList.txt" (
	echo.
	echo There are video to be processed
	echo.
	for /f "tokens=1,2,3 delims=\" %%A in ("C:\Users\GoodwinLab\UFMF\SettingsListFiles\%today%_SettingsList.txt") do (
		cd \%%A\%%B\%%C
		for /f "tokens=1,2,3 delims=," %%D in (settings.txt) do (
			::echo SUBSECTIONING VIDEO %%D FROM %%E SECONDS FOR %%F SECONDS
			echo SUBSECTIONING VIDEO %%D FROM %%E SECONDS FOR 3600 SECONDS
			::ffmpeg -hide_banner -i %%D -ss %%E.000 -t %%F.000 -c:v libx264 -preset ultrafast -crf 0 "D:\%%~nD_cut.avi"
			::ffmpeg -hide_banner -i %%D -ss %%E.000 -t %%F.000 -c:v rawvideo "D:\%%~nD_cut.avi"
			ffmpeg -hide_banner -i %%D -ss %%E.000 -t 3600.000 -c:v rawvideo "D:\%%~nD_cut.avi"
			echo CONVERTING VIDEO %%D TO UFMF
			any2ufmf "D:\%%~nD_cut.avi" "C:\Users\GoodwinLab\UFMF\videos\%%B-%%C-%%~nD.ufmf" C:\Users\GoodwinLab\UFMF\ufmfCompressionParams.txt
			xcopy /Y "C:\Users\GoodwinLab\UFMF\videos\%%B-%%C-%%~nD.ufmf" "Y:\%today%Converted\"
			fc /b "C:\Users\GoodwinLab\UFMF\videos\%%B-%%C-%%~nD.ufmf" "Y:\%today%Converted\%%B-%%C-%%~nD.ufmf" > nul
			echo THE ERROR LEVEL EQUALS    %errorlevel%
			if %errorlevel% EQU 0 (
				echo NOW DELTING FILES
				del "C:\Users\GoodwinLab\UFMF\videos\%%B-%%C-%%~nD.ufmf"
				del "D:\%%~nD_cut.avi"
			)
		)
	)


	cd
	cd /D "P:\TempRawVideos"
	cd

	:: Generate lossless compressions of video and send back to Synology
	for /f "tokens=1,2,3 delims=\" %%A in ("C:\Users\GoodwinLab\UFMF\SettingsListFiles\%today%_SettingsList.txt") do (
		cd \%%A\%%B\%%C
		for /f "tokens=1,2,3 delims=," %%D in (settings.txt) do (
			echo COMPRESSING LOSSLESS VIDEO %%D
			ffmpeg -hide_banner -i "%%D" -c:v libx264 -preset medium -crf 0 "D:\%%~nD_lossless.avi"
			xcopy /Y "D:\%%~nD_lossless.avi" "X:\lossless\%%B\%%C\"
			move /Y settings.txt "X:\lossless\%%B\%%C\"
			fc /b "D:\%%~nD_lossless.avi" "X:\lossless\%%B\%%C\%%~nD_lossless.avi" > nul
			echo THE ERROR LEVEL EQUALS    %errorlevel%
			if %errorlevel% EQU 0 (
				echo NOW DELETING FILES
				del "D:\%%~nD_lossless.avi"
			)
		)
	)


) else (
	echo.
	echo There are no videos to be processes
	echo.
)

echo All Done.
date /T
time /T
