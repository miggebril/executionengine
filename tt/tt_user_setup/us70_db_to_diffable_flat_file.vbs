option explicit

wscript.echo "started"

' open a file with the SQL DDL commands

dim s

if not WScript.Arguments.Count = 2 then
	s =  "usage:" & vbcrlf 
	s = s & "xa75_run_sql.vbs [CONNECTION STRING FILE] [SQL SCRIPT FILE]" & vbcrlf 
	s = s & "Example of running and piping output to text file:" & vbcrlf 
	s = s & "cscript xa75_run_sql.vbs conn.txt xa75.sql //NoLogo > output.txt"
	wscript.echo s
	wscript.quit
end if


dim fs
dim ts
set fs=CreateObject("Scripting.FileSystemObject")

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get connection string
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if not fs.FileExists(wscript.arguments(0)) then
	wscript.echo "connection string file not found"
	
end if

if not fs.FileExists(wscript.arguments(1)) then
	wscript.echo "sql script file not found"
	wscript.quit(2)
end if


set ts = fs.OpenTextFile(wscript.arguments(0))

dim connection_string

dim sConnectionString
if not ts.AtEndOfStream then
	sConnectionString = ts.ReadLine	
end if

if sConnectionString = "" then
	wscript.echo "connection string file line 1 is blank or missing"
	wscript.quit(3)
end if


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get sql script, make a copy without comments
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


'' strip out comments
dim tsoriginal
dim tscopy
set tsoriginal = fs.OpenTextFile(wscript.arguments(1))
set tscopy = fs.CreateTextFile("tempcopy.sql")
dim sLine
Do Until tsoriginal.AtEndOfStream
    sLine = tsoriginal.ReadLine
    if Len(sLine) > 1 then
	    if Left(sLine,2) <> "--" then
	    	tscopy.WriteLine(sLine)	
	    end if
	else
    	tscopy.WriteLine(sLine)	
	end if 
Loop

dim sScript
set ts = fs.OpenTextFile("tempcopy.sql")

if not ts.AtEndOfStream then
	sScript = ts.ReadAll
end if

if sScript = "" then
	wscript.echo "sql script file is empty"
	wscript.quit(4)
end if

'wscript.echo sScript


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' open the db
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


dim conn
set conn = createobject("ADODB.Connection")

conn.open(sConnectionString)


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' run each "batch", delimited by "GO" in the script.
'' Access let's you run only one SQL statement at a time.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


' use "go" as a delimiter in the batches, mimicing SQL Server
dim delim
delim = "go" & vbcrlf

dim batches
batches = Split(sScript,delim)

dim i
dim rs
dim cnt
cnt = 0
for i = lbound(batches) to ubound(batches)
	
	cnt = cnt + 1
	execute i, batches(i)

next

wscript.echo "done with " & cnt & " batches of sql"

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
if InStr(fld.Name,"last_updated_datetime" ) = 0 and InStr(fld.Name,"created_datetime" ) = 0 then
						if sRow <> "" then
							sRow = sRow & vbtab
						end if
						sRow = sRow & fld.Name
end if						
					next
					wscript.echo sRow	

				end if

				sRow = ""
				for each fld in rs.fields
if InStr(fld.Name,"last_updated_datetime" ) = 0 and InStr(fld.Name,"created_datetime" ) = 0 then
					if sRow <> "" then
						sRow = sRow & vbtab
					end if
					sRow = sRow & fld
end if					
				next
				wscript.echo sRow
				rs.movenext
			wend
		end if
	end if


end function


conn.close

