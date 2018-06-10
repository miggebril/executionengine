'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Demos using TTUSCommandLineClient.exe to fetch a file from the server's logfiles folder.
' This fetches a copy of yesterdays TT User Setup audit trail file,  "UserSetupDbUpdates".
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

option explicit

dim username
dim password
dim extension

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
' EDIT HERE.  Change the username, password, and choose whether you want the plain text log format or the pretty html format
' Username must have Super Administrator permissions (e.g., TTSYSTEM)
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
username = "TTSYSTEM"
password = "12345678"
extension = "log"  '  or use "html" to grab the prettier file


dim shell
set shell = CreateObject("WScript.Shell")

dim fso
set fso=CreateObject("Scripting.FileSystemObject")

' format the filename of yesterday's TTUS audit trail file
dim yesterday
yesterday = DateAdd("d", -1, now)

dim audit_trail_filename
audit_trail_filename = "UserSetupDbUpdates_" & format_date_as_YYYY_MM_DD(yesterday) & "." & extension

wscript.echo "fetching file " & audit_trail_filename

' get a temp file path where we will write both the config file and the file that we fetched from the server
dim logfile_folder
logfile_folder = shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Trading Technologies\installation\LOGFILEDIR") & "\"

dim config_file
config_file = logfile_folder & "TTUSCommandLineClient.ini"
wscript.echo "writing config to " & config_file
dim tso
set tso = fso.CreateTextFile(config_file)

' write out the lines to the config file
tso.writeline "RequestType=file" ' file
tso.writeline "Payload=" & audit_trail_filename
tso.writeline "OutputDir=" & logfile_folder
tso.writeline "OutputFile=" & audit_Trail_filename & ".copy." & extension

tso.close

' run TTUSCommandLineClient.exe
shell.run "c:\tt-dev\742\xproducts\tt_user_setup\main\dev\debug\TTUSCommandLineClient.exe " & username & " " & password & " " & config_file, 10, false

' done
wscript.echo "done"
wscript.quit


' format the date as YYYY-MM-DD
Function format_date_as_YYYY_MM_DD(d)

	dim s
	s = DatePart("yyyy", d)
	s = s & "-"
	s = s & pad_left(DatePart("m",d))
	s = s & "-"
	s = s & pad_left(DatePart("d",d))

	format_date_as_YYYY_MM_DD = s
	
End Function

Function pad_left(s)

	if len(s) = 1 then
		s = "0" & s
	end if
	pad_left = s
	
End Function
