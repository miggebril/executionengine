::****************************************************************************
:: The TTSupport.bat is launched by GuardianMFC to collect logfiles
::
:: Usage 1:
:: TTSupport.bat zipfilename LogfileDir DatfileDir ConfigDir AuditfileDir GuardConfigDir XTConfigDir XRConfigDir TTBIN [-m MISS] [-d DayRestriction]
::
:: Arguments:
::     zipfilename      : the name of the zip file
::     LogfileDir       : the absolute path of the logfiles directory
::     DatfileDir       : the absolute path of the datfiles directory
::     ConfigDir        : the absolute path of the config direcotry
::     AuditfileDir     : the absolute path of the auditfiles directory
::     GuardianConfigDir: the absolute path of the guardian\config directory
::     XTConfigDir      : the absolute path of X_Trader config directory
::     XRConfigDir      : the absolute path of X_Risk config directory
::     TTBIN            : the absolute path of tt\bin directory
:: Options:
::     -m MISS          : collect MISS Gate ini and log files. MISS is the absolute path of MISS Gateway
::     -d DayRestriction: the number of days within which files are collected 
:: 
::
:: Usage 2:
:: TTSupport.bat -s zipfilename ttDir [-m MISS] [-d DayRestriction]
::
:: This version simplifies the command arguments when running TTSupport.bat manually from the command window
:: It assumes that all paths are under tt folder and use the default path.
:: Arguments:
::     zipfilename      : the name of the zip file
::     ttDir            : the absolute path of tt directory
:: Options:
::     -m MISS          : collect MISS Gate ini and log files. MISS is the absolute path of MISS Gateway
::     -d DayRestriction: the number of days within which files are collected
::
:: *****************************************************************************

IF "%~1" == "" GOTO error
IF "%~1" == "-s" GOTO simple

:: get arguments
SET ZipFileName=%~1
SHIFT
SET LogfileDir=%~1
SHIFT
SET DatfileDir=%~1
SHIFT
SET ConfigDir=%~1
SHIFT
SET AuditfileDir=%~1
SHIFT
SET GuardConfigDir=%~1
SHIFT
SET XTConfigDir=%~1
SHIFT
SET XRConfigDir=%~1
SHIFT
SET TTBIN=%~1
SHIFT
GOTO options

:: this is a simple version
:simple
SHIFT
IF "%~1" == "" GOTO error
SET ZipFileName=%~1
SHIFT
IF "%~1" == "" GOTO error
SET LogfileDir=%~1\logfiles
SET DatfileDir=%~1\datfiles
SET ConfigDir=%~1\config
SET AuditfileDir=%~1\auditfiles
SET GuardConfigDir=%~1\guardian\config
SET XTConfigDir=%~1\datfiles
SET XRConfigDir=%~1\X_RISK\XRConfig
SET TTBIN=%~1\bin
SHIFT

:: handle options
:options
IF "%~1" == "" (
	GOTO run
)

SET opt=%~1
SHIFT
IF "%opt%" == "-m" (
	:: set miss path
	SET MISS=%~1
) ELSE (
	IF "%opt%" == "-d" (
		:: day restriction
		call :getdate %~1
	)
)

:: have more option?
SHIFT
IF "%~1" == "" (
	GOTO run
)

SET opt=%~1
SHIFT
IF "%opt%" == "-m" (
	SET MISS=%~1
) ELSE (
	IF "%opt%" == "-d" (
		call :getdate %~1
	)
)


:run
:: export registry values
reggiecpp /e "%logfileDir%\tt_local_machine_reg.txt" "HKEY_LOCAL_MACHINE\Software\Trading Technologies"
reggiecpp /e "%logfileDir%\tt_local_machine_tz_reg.txt" "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
reggiecpp /e "%logfileDir%\tt_local_machine_ccs_reg.txt" "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment"
reggiecpp /e "%logfileDir%\tt_local_machine_tcpip_reg.txt" "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip"

:: create reggie log
reggiecpp

:: export network settings
netstat -nab > "%logfileDir%\netstat1.txt"
netstat -rse > "%logfileDir%\netstat2.txt"
ipconfig /all > "%logfileDir%\ipconfig.txt"
netsh int ip sh joins > "%logfileDir%\netsh.txt"
netsh interface ip show global > "%logfileDir%\netsh1.txt"
::Query OS Version
For /f "tokens=2 delims=[]" %%V in ('ver') Do (set version=%%V) 
For /f "tokens=2 delims=. " %%V in ('echo %version%') Do (set OS=%%V) 
if "%OS%" GEQ "6" Netsh interface tcp show global > "%logfileDir%\netsh2.txt"

:: export system information
systeminfo > "%logfileDir%\systeminfo.txt"

:: export path
path > "%logfileDir%\path.txt"

:: collecting log files and minidumps under tt\logfiles directory
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\*.txt"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\*.log"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\*.mdmp"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\*.bak"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\*.csv"
rem sim
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\sim\*.txt"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\sim\*.log"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\sim\*.mdmp"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\sim\*.bak"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\sim\*.csv"
IF EXIST "%LogfileDir%\install" zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\install\*.txt"

:: export user setup database
cscript "%TTBIN%\ttus_create_sanitized_database_copy.vbs"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\*.mdb"
zip -1 %DateRestriction% "%ZipFileName%" "%LogfileDir%\sim\*.mdb"

:: collecting files under tt\datfiles
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*_RISK_AUDIT_*.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*-01.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*-02.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*risk_audit.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.rsk"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\TTTraders_*.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.tbl"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*PositionByMGT.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*fillseqstore.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*mdb.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.TTSettlm*"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.TTOpenPrc*"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\ProductTableData\*.*"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\Saved Orders\*.*"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.sob"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.sob.bak"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*Send*.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*Rec*.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%DatfileDir%\*.chf"

:: collecting product table files
zip -1 %DateRestriction% "%ZipFileName%" "%GuardConfigDir%\*.dat"
zip -1 %DateRestriction% "%ZipFileName%" "%GuardConfigDir%\sim\*.dat"

:: collecting config files
IF "%ConfigDir%" == "" GOTO auditfiles
zip -1 %DateRestriction% "%ZipFileName%" "%ConfigDir%\*.*"
zip -1 %DateRestriction% "%ZipFileName%" "%ConfigDir%\sim\*.*"

:auditfiles
:: collecting audit files
IF "%AuditfileDir%" == "" GOTO sysenv
zip -1 %DateRestriction% "%ZipFileName%" "%AuditfileDir%\*.*"

:sysenv
:: %ALLUSERSPROFILE% is a default system environment variable
zip -1 %DateRestriction% "%ZipFileName%" "%ALLUSERSPROFILE%\documents\drwatson\drwtsn32.log"
zip -1 %DateRestriction% "%ZipFileName%" "%ALLUSERSPROFILE%\Application Data\Microsoft\Dr Watson\drwtsn32.log"
zip -1 %DateRestriction% "%ZipFileName%" "%ALLUSERSPROFILE%\Application Data\Trading Technologies\*.log"
zip -1 %DateRestriction% "%ZipFileName%" "%ALLUSERSPROFILE%\Application Data\Trading Technologies\*\*.log"

:: collecting host info
:: %SYSTEMROOT% is a default system environment variable
zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\System32\drivers\etc\Hosts"

:: collecting v4.0.30319 .NET Framework dlls
:: this needs to be just a temporary solution, otherwise the path will change anytime the MS Framework is updated
IF EXIST "%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\SOS.dll" zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\SOS.dll"
IF EXIST "%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\mscordacwks.dll" zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\mscordacwks.dll"
IF EXIST "%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\clr.dll" zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\clr.dll"
IF EXIST "%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\SOS.dll" zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\SOS.dll"
IF EXIST "%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\mscordacwks.dll" zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\mscordacwks.dll"
IF EXIST "%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\clr.dll" zip -1 %DateRestriction% "%ZipFileName%" "%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\clr.dll"

:: collecting X_Trader config files
IF "%XTConfigDir%" == "" GOTO xrconfig
zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfig\*"
zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfigOld\*"
if exist "%XTConfigDir%\TTConfig_JA" zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfig_Ja\*"
if exist "%XTConfigDir%\TTConfigOld_JA" zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfigOld_Ja\*"
if exist "%XTConfigDir%\TTConfig_MB" zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfig_MB\*"
if exist "%XTConfigDir%\TTConfig_JA_MB" zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfig_JA_MB\*"
if exist "%XTConfigDir%\TTConfigOld_MB" zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfigOld_MB\*"
if exist "%XTConfigDir%\TTConfigOld_JA_MB" zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTConfigOld_JA_MB\*"
zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\Export\*"
zip -1 -r %DateRestriction% "%ZipFileName%" "%XTConfigDir%\TTSprdTbls\*"

:: collecting X_Risk config files
:xrconfig
IF "%XRConfigDir%" == "" GOTO miss
zip -1 -r %DateRestriction% "%ZipFileName%" "%XRConfigDir%\*"

:: collecting MISS GW ini and log files
:miss
IF "%MISS%" == "" GOTO :end
cd /d "%MISS%\opt"
zip -1 -R %DateRestriction% "%ZipFileName%" "*.ini"
zip -1 -R %DateRestriction% "%ZipFileName%" "*elb*.log"

:end
:: zip ttsupport.out
zip -1 "%ZipFileName%" "%LogfileDir%\ttsupport.out"
zip -1 "%ZipFileName%" "%LogfileDir%\sim\ttsupport.out"

GOTO :EOF

:error
EXIT /B 1


:getdate
:: Get the date of # of days before today
@ECHO OFF
IF %1 LEQ 0 GOTO :EOF

FOR /F "TOKENS=1* DELIMS= " %%A IN ('DATE/T') DO SET CDATE=%%B
FOR /F "TOKENS=1-3 DELIMS=/" %%A IN ('echo %CDATE%') DO (
	SET /A mm=%%A 
	SET /A dd=%%B 
	SET /A yyyy=%%C
)

ECHO Today: %mm%%dd%%yyyy%

:: convert date to Julian date
SET /A mon = ( %mm% - 14 ) / 12
SET /A year  = %yyyy% + 4800
SET /A jdate  = 1461 * ( %year% + %mon% ) / 4 + 367 * ( %mm% - 2 -12 * %mon% ) / 12 - ( 3 * ( ( %year% + %mon% + 100 ) / 100 ) ) / 4 + %dd% - 32075

SET /A jpast = jdate - %1 + 1

:: convert Julian date to date
SET /A P = %jpast% + 68569
SET /A Q = 4 * %P% / 146097
SET /A R = %P% - ( 146097 * %Q% +3 ) / 4
SET /A S = 4000 * ( %R% + 1 ) / 1461001
SET /A T = %R% - 1461 * %S% / 4 + 31
SET /A U = 80 * %T% / 2447
SET /A V = %U% / 11

SET /A year = 100 * ( %Q% - 49 ) + %S% + %V%
SET /A month = %U% + 2 - 12 * %V%
SET /A day = %T% - 2447 * %U% / 80

:: Add leading zeroes
IF %month% LSS 10 SET month=0%month%
IF %day%   LSS 10 SET day=0%day%

:: Return value
@ECHO ON
SET DateRestriction=-t %month%%day%%year%

GOTO :EOF
