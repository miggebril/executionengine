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

option explicit

dim bad 
bad = false

dim shell
set shell = CreateObject("WScript.Shell")

dim fs
set fs=CreateObject("Scripting.FileSystemObject")

if  Instr(1, wscript.fullname, "wscript.exe", 1) > 0 then
	bad = true
end if

if WScript.Arguments.Count >= 1 then
	' good
else 
	bad = true
end if

if bad then
	dim windir
	windir = shell.ExpandEnvironmentStrings("%WinDir%")
	dim s
	s = "Usage:" & vbcrlf
	s = s & "cscript ttus_run_sql.vbs [SQL SCRIPT FILE] [options...]" & vbcrlf & vbcrlf
	s = s &  "If you are running this on 64-bit Windows, use cscript in syswow64 folder:" & vbcrlf
	s = s &  windir & "\syswow64\cscript ttus_run_sql.vbs sql.txt"  & vbcrlf  & vbcrlf
	s = s & "Options:" & vbcrlf
	s = s & "db=other.mdb    By default, runs against db configured" & vbcrlf
	s = s & "                in tt\config\TTUserSetupServer.ini." & vbcrlf
	s = s & "                Use this to run against a different db." & vbcrlf
    s = s & "file=output.txt By default, outputs to console. Use this to write to file." & vbcrlf				
'    s = s & "provider=ace    By default, uses Microsoft.Jet.OLEDB.4.0 provider." & vbcrlf				
'	s = s & "                Use this to use Microsoft.ACE.OLEDB.12.0 provider." & vbcrlf
	s = s & "Examples:" & vbcrlf
	s = s &  "cscript ttus_run_sql.vbs sql.txt" & vbcrlf
	s = s &  "cscript ttus_run_sql.vbs sql.txt db=other_db.mdb file=output.txt" & vbcrlf
	wscript.echo s
	wscript.quit
end if

dim db
db = ""

dim output_file_name
output_file_name = ""

dim output_file

dim provider
provider = "Microsoft.Jet.OLEDB.4.0"

if wscript.arguments.count > 1 then
	for i = 1 to wscript.arguments.count - 1
		dim arg
		arg = wscript.arguments(i)

		if left(arg,2) = "db" then
			db = mid(arg,4)
		elseif left(arg,4) = "file" then
			output_file_name = mid(arg,6)
			set output_file = fs.CreateTextFile(output_file_name, true)
		elseif left(arg,8) = "provider" then
			if mid(arg, 10) = "ace" then
				provider = "Microsoft.ACE.OLEDB.12.0"
			elseif mid(arg, 10) = "jes" then
				provider = "Microsoft.Jet.OLEDB.4.0"
			end if
		end if
	next
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get sql script
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


if not fs.FileExists(wscript.arguments(0)) then
	wscript.echo "sql script file " & wscript.arguments(0) & " not found"
	wscript.quit(2)
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get db file name from tt\config\TTUserSetupServer.ini
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if db = "" then
	db = get_database_file_name_from_config
end if


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Connect to the db
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dim connection_string
connection_string = "Provider=" & provider & ";Data Source=" + db

dim conn
set conn = createobject("ADODB.Connection")
conn.open(connection_string)

dim i
dim rs
dim cnt
cnt = 0
dim sql 
sql = ""
dim sLine

' use "go" as a delimiter in the batches, mimicing SQL Server
dim delim
delim = "go" & vbcrlf

dim ts
set ts = fs.OpenTextFile(wscript.arguments(0))

Do Until ts.AtEndOfStream
    sLine = ts.ReadLine
    if Len(sLine) > 0 then
	    if Left(sLine,2) <> "--" then
	    	if sLine = "go" then
	    		cnt = cnt + 1
	    		if cnt mod 1000 = 0 then
	    			wscript.echo cnt
	    		end if
	    		execute cnt, sql
	    		sql = ""
	    	else
	    		sql = sql + vbcrlf + sLine
	    	end if
	    end if
	end if 
Loop

if sql <> "" then
	cnt = cnt + 1
	execute i, sql
end if


wscript.echo "us70_run_sql.vbs completed " & cnt & " batches of sql"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' run each "batch", delimited by "go" in the script.
'' Access let's you run only one SQL statement at a time.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
conn.close

function execute (i, sql)
	on error resume next
	set rs = conn.execute(sql)

	dim bad
	bad = false
	dim err
	for each err in conn.errors
		bad = true
		wscript.echo "********************"
		wscript.echo "$BATCH:" & i
		wscript.echo "$ERROR::" & err.Description 
		wscript.echo "$SQL FOLLOWS:"
		wscript.echo sql
		wscript.echo "********************"
	next
	
	if bad then
		exit function
	end if

	dim fld
	dim sRow
	dim bFirst
	bFirst = true

	if not rs is nothing then
		if rs.state = 1 then ' open
			while not rs.eof
				sRow = ""

				if bFirst then
					bFirst = false

					for each fld in rs.fields
						if sRow <> "" then
							sRow = sRow & "," 
						end if
						sRow = sRow & """" & Replace(fld.Name, """", """""") & """"
					next
					if output_file <> "" then
						if i > 1 then
							output_file.write vbcrlf
						end if
						output_file.write(sRow)
					else
						wscript.echo sRow	
					end if

				end if

				sRow = ""
				for each fld in rs.fields
					if sRow <> "" then
						sRow = sRow & ","
					end if
					sRow = sRow & """" & Replace(fld, """", """""") & """"
				next

				if output_file <> "" then
					output_file.write vbcrlf
					output_file.write(sRow)
				else
					wscript.echo sRow	
				end if

				rs.movenext
			wend
		end if
	end if

end function

function get_database_file_name_from_config

		dim config_folder
		config_folder = shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Trading Technologies\installation\CONFIGFILEDIR")
		
		dim ts
		set ts = fs.OpenTextFile(config_folder + "\\TTUserSetupServer.ini")
		
		dim line
		dim lines
		do until ts.AtEndOfStream
			line = ts.ReadLine
			if Left(line,19) = "AccessFileFullPath=" then
				lines = Split(line,"=")
				get_database_file_name_from_config = lines(1)
				exit function
			end if
		loop

		get_database_file_name_from_config = ""

end function


