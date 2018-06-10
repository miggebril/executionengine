'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Demos using TTUSCommandLineClient.exe to run your own SQL.
' This gets the results of the SQL as a .csv file which can be opened in Excel.
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
option explicit

dim username
dim password
dim sql

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
' EDIT HERE.  Change the username, password, and the SQL you want to run
' Username must have Super Administrator permissions (e.g., TTSYSTEM)
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
username = "TTSYSTEM"
password = "12345678"

' Some sample sql which lists active users that have logged in within the past 30 days
sql = "SELECT user_login, user_display_name, user_most_recent_login_datetime "
sql = sql & " FROM tt_user"
sql = sql & " WHERE user_status = 1"
sql = sql & " AND user_most_recent_login_datetime > DateAdd('d', -30, now)"
sql = sql & " ORDER BY user_login"
wscript.echo "sql:"
wscript.echo sql

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
tso.writeline "RequestType=sql" ' sql
tso.writeline "Payload=" & sql
tso.writeline "OutputDir=" & logfile_folder
tso.writeline "OutputFile=TTUSCommandLineClient_results.csv" 

tso.close

' run TTUSCommandLineClient.exe - wait for a return code
shell.run "c:\tt-dev\742\xproducts\tt_user_setup\main\dev\debug\TTUSCommandLineClient.exe " & username & " " & password & " " & config_file, 10, false

' done
wscript.echo "done" 
wscript.quit
