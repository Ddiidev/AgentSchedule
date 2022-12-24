@echo off
TITLE Compiling with GCC
SET PATH=C:\PROGRA~2\EUPORT~1\GCC\bin;%PATH%
SET PATH=C:\PROGRA~2\EUPORT~1\bin;%PATH%

:: main.compile.bat "your_file.ex"
euc.exe -gcc -cflags "-DEWINDOWS -flto -fdata-sections -ffunction-sections -fomit-frame-pointer -c -w -Wall -Wl,--gc-sections -Wl,--strip-all -fsigned-char -s -Os -IC:\Euphoria -ffast-math" -con -rc-file main.rc -lib C:\PROGRA~2\EUPORT~1\bin\eu.a "%~1"
PAUSE