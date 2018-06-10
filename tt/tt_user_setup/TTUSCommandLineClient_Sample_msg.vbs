'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Demos using TTUSCommandLineClient.exe to run a sql or a report that's built into TT User Setup Server.
' This gets the report as a .csv file which can be opened in Excel.
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
option explicit

dim username
dim password
dim msg

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
' EDIT HERE.  Change the username, password, and choose which message to send to the TT User Setup Server
' Username must have Super Administrator permissions (e.g., TTSYSTEM)
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
username = "TTSYSTEM"
password = "12345678"
msg = "get_report_most_recent_x_trader_version_restricted"


dim shell
set shell = CreateObject("WScript.Shell")

dim fso
set fso=CreateObject("Scripting.FileSystemObject")

' get a temp file path where we will write both the config file and the file that we fetched from the server
dim logfile_folder
logfile_folder = shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Trading Technologies\installation\LOGFILEDIR") & "\"

dim config_file
config_file = logfile_folder & "TTUSCommandLineClient.ini"
wscript.echo "writing config to " & config_file
dim tso
set tso = fso.CreateTextFile(config_file)

' write out the lines to the config file
tso.writeline "RequestType=msg" ' msg
tso.writeline "Payload=" & msg
tso.writeline "OutputDir=" & logfile_folder
tso.writeline "OutputFile=" & msg & ".csv"

tso.close

' run TTUSCommandLineClient.exe
shell.run "c:\tt-dev\742\xproducts\tt_user_setup\main\dev\debug\TTUSCommandLineClient.exe " & username & " " & password & " " & config_file, 10, false

' done
wscript.echo "done"
wscript.quit

