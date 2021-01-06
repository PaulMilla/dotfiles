@echo off &setlocal enableDelayedExpansion

set ConEmuBaseDir=C:\Program Files\ConEmu\ConEmu

call :StartsWith "%cd%" "C:\git\substrate\src"
if %errorLevel%==0 (
    echo Initializing Substrate dir in new Admin Shell
    cmd.exe /k ""%ConEmuBaseDir%\CmdInit.cmd"&%USERPROFILE%\libs\initSubstrate.cmd&cd /d %cd%" -new_console:a
    echo This window can be safely closed...
    EXIT /B %ERRORLEVEL%
)

call :StartsWith "%cd%" "C:\git\griffin"
if %errorLevel%==0 (
    echo Initializing Griffin dir in new Admin Shell
    cmd.exe /k ""%ConEmuBaseDir%\CmdInit.cmd"&%USERPROFILE%\libs\initGriffin.cmd&cd /d %cd%" -new_console:a
    echo This window can be safely closed...
    EXIT /B %ERRORLEVEL%
)

cmd.exe /k pwsh.exe
EXIT /B %ERRORLEVEL%

:StartsWith text string -- Tests if a text starts with a given string
::                      -- [IN] text   - text to be searched
::                      -- [IN] string - string to be tested for
:$created 20080320 :$changed 20080320 :$categories StringOperation,Condition
:$source https://www.dostips.com
:$howto https://www.dostips.com/forum/viewtopic.php?t=3625
SETLOCAL
set "txt=%~1"
set "str=%~2"
if defined str call set "s=%str%%%txt:*%str%=%%"
if /i "%txt%" NEQ "%s%" set=2>NUL
EXIT /b