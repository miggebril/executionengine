@echo off
REM
REM  Batch File: start_ttchron.bat
REM
REM  Description:
REM     Starts the TT Gateway services for all installed gateways
REM
REM  Copyright:
REM     Copyright (c) Trading Technologies International 2000
REM     All rights reserved worldwide
REM
REM  Change History:
REM     13-Apr-2000	sschwarz	Created
REM     26-Jan-2001	jfink		Revised to use TTChron v1.16 commands.

Echo Starting TT Gateway Services
REM sc stop "ttchron"
sc start "ttchron"
