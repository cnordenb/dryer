@echo off
rem Run the duplication finder from cmd.exe or PowerShell, creating a local
rem virtualenv on first use. ./dryer does the same from a POSIX shell.
setlocal
set "VENV=%~dp0.venv"
set "DRYER=%VENV%\Scripts\dryer.exe"

rem The console script is the last thing pip writes, so its presence means the
rem install finished. A venv left behind by a failed install is completed here.
if exist "%DRYER%" goto run
if not exist "%VENV%\Scripts\python.exe" call :make_venv || exit /b 1
"%VENV%\Scripts\python.exe" -m pip install --disable-pip-version-check -e "%~dp0." || exit /b 1
if not exist "%DRYER%" exit /b 1

:run
"%DRYER%" %*
exit /b %ERRORLEVEL%

rem py -3 is the launcher python.org installs. python can be the Microsoft
rem Store stub, which fails the version check.
:make_venv
for %%P in ("py -3" python python3) do (
  %%~P -c "import sys; sys.exit(sys.version_info < (3, 11))" >nul 2>&1 && (
    %%~P -m venv "%VENV%"
    exit /b
  )
)
echo dryer: Python 3.11 or newer is required 1>&2
exit /b 1
