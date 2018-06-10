' *****************************************************************************
' *                                                                           *
' *                  Unpublished Work Copyright (c) 2007-2011                 *
' *                  Trading Technologies International, Inc.                 *
' *                       All Rights Reserved Worldwide                       *
' *                                                                           *
' *          * * *   S T R I C T L Y   P R O P R I E T A R Y   * * *          *
' *                                                                           *
' * WARNING:  This program (or document) is unpublished, proprietary property *
' * of Trading Technologies International, Inc. and  is  to be  maintained in *
' * strict confidence. Unauthorized reproduction,  distribution or disclosure *
' * of this program (or document),  or any program (or document) derived from *
' * it is  prohibited by  State and Federal law, and by local law  outside of *
' * the U.S.                                                                  *
' *                                                                           *
' *****************************************************************************

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''
''  This script makes a copy of the TT User Setup Access .mdb file,
''  updates the copy to wipe out sensitive info like passwords,
''  and then puts the sanitized copy into the tt\logfiles folder 
''  as "TTUS_sanitized.mdb".
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


option explicit

dim shell
set shell = CreateObject("WScript.Shell")

dim fs
set fs=CreateObject("Scripting.FileSystemObject")

dim windir
windir = shell.ExpandEnvironmentStrings("%WinDir%")

dim cscript32bit
cscript32bit = windir & "\syswow64\cscript.exe"

wscript.echo "args:" & wscript.arguments.length
if wscript.arguments.length = 0 then
	if fs.FileExists(cscript32bit) then
		wscript.echo "running using syswow64"
		dim other_process
		wscript.echo "cmd:" & cscript32bit & " " & wscript.scriptfullname
		set other_process = shell.exec(cscript32bit & " " & wscript.scriptfullname & " x")
		do while other_process.Status = 0
			wscript.echo "."
			WScript.Sleep(100)
		loop
		wscript.quit
	else
		wscript.echo "running normally"
	end if
end if

dim conn
set conn = createobject("ADODB.Connection")

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get config folder and logfile folders
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

dim config_folder
config_folder = shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Trading Technologies\installation\CONFIGFILEDIR")
wscript.echo "config_folder=" & config_folder

dim logfile_folder
logfile_folder = shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Trading Technologies\installation\LOGFILEDIR")
wscript.echo "logfile_folder=" & logfile_folder

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get db file name
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

dim db_file
db_file = get_database_file_name()


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' make a copy
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dim target_file
target_file = logfile_folder + "\\TTUS_sanitized.tmp"

fs.CopyFile db_file, target_file, true

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' connect to the copy
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dim connection_string
connection_string = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + target_file
conn.open(connection_string)


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' wipe out sensitive data
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

dim sql
sql = "update tt_user set"
sql = sql + " user_password = '',"
sql = sql + " user_display_name = CStr(user_id),"
sql = sql + " user_phone = '',"
sql = sql + " user_address = '',"
sql = sql + " user_smtp_login_password = '',"
sql = sql + " user_email = 'user@example.com'"
conn.execute sql

sql = "update tt_mgt set mgt_password = ''"
conn.execute sql

conn.close

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' rename copy to what TTSupport.bat will look for
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

dim final_target
final_target = logfile_folder + "\\TTUS_sanitized.mdb"

if fs.FileExists(final_target) then
	fs.DeleteFile final_target
end if

fs.MoveFile target_file, final_target

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function get_database_file_name
	
	dim ts
	set ts = fs.OpenTextFile(config_folder + "\\TTUserSetupServer.ini")
	
	dim line
	dim lines
	do until ts.AtEndOfStream
	    line = ts.ReadLine
	    if Left(line,19) = "AccessFileFullPath=" then
	    	lines = Split(line,"=")
	    	get_database_file_name = lines(1)
	    	exit function
	    end if
	loop

	get_database_file_name = ""
	
end function