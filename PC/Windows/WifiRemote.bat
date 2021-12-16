:: Check for Python Installation
python --version 3 >NUL
if errorlevel 1 goto errorNoPython

:: Reaching here means Python is installed.
:: Execute stuff...
pip3 install pynput

:: Once done, exit the batch file -- skips executing the errorNoPython section
start "" "pythonw" "../controller.py" "%1"
call focus "Wifi Remote Controller"
goto:eof

:errorNoPython
echo.
echo Error^: Python not installed
pause