' *****************************************************************************
' *                                                                           *
' *                  Unpublished Work Copyright (c) 2007-2011                *
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


' Corey Trager, TT, May 2007

option explicit

if not WScript.Arguments.Count > 2 then
	dim s
	s =  "usage:" & vbcrlf 
	s = s & "cscript export_user_data.vbs [output folder] [billingServerId] [connection string file]" & vbcrlf 
	wscript.echo s
	wscript.quit(1)
end if

dim shell
set shell = CreateObject("WScript.Shell")

dim fs
set fs=CreateObject("Scripting.FileSystemObject")

dim output_folder
output_folder = wscript.arguments(0)

dim billingServerId
billingServerId = wscript.arguments(1)

dim connFile
connFile = wscript.arguments(2)

dim today
today = now

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' get connection string
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if not fs.FileExists(connFile) then
	wscript.echo "connection string file " & connfile & " not found"
	wscript.quit(2)
end if

dim tsconn
set tsconn = fs.OpenTextFile(connFile)

dim connection_string

dim sConnectionString
if not tsconn.AtEndOfStream then
	sConnectionString = tsconn.ReadLine	
	tsconn.close()	
end if

if sConnectionString = "" then
	wscript.echo "connection string file line 1 is blank or missing"
	wscript.quit(3)
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Check if the output_folder actually exists.
' If not, use c:\ as the output folder
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if not fs.FolderExists(output_folder) then
		wscript.echo "ERROR: output folder " & output_folder & " not found "
		wscript.echo "Using c:\ as the output folder instead"
		output_folder = "c:"
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' open the output file
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dim output_filename
output_filename = get_output_filename
dim full_path
full_path = output_folder & "\" & output_filename
full_path = replace(full_path, "\\","\") ' just in case the folder already ended with a slash
dim output_file
set output_file = fs.CreateTextFile(full_path)


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Start the XML output
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' for readability...
dim tab1, tab2, tab3, tab4, tab5
tab1 = vbTab
tab2 = vbTab & vbTab
tab3 = vbTab & vbTab & vbTab
tab4 = vbTab & vbTab & vbTab & vbTab
tab5 = vbTab & vbTab & vbTab & vbTab & vbTab

output_file.WriteLine "<?xml version=""1.0"" encoding=""UTF-8""?>"
output_file.WriteLine "<UserData versionId=""1.0.0.0"""
output_file.WriteLine "fileCreationDateStamp=""" & get_date_for_xml & """"
output_file.WriteLine "billingServerId=""" & billingServerId & """"
output_file.WriteLine "xsi:noNamespaceSchemaLocation=""UserData.xsd"""
output_file.WriteLine "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">"
output_file.WriteLine tab1 & "<Users>"

dim bError
bError = false

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Connect
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

dim conn
set conn = createobject("adodb.connection")
connect_to_db

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Run sql
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


dim rs
if not bError then

	dim sql
	
	sql =       " SELECT DISTINCT tt_user.user_id, tt_user.user_login as [user_name], "
	sql = sql & " tt_user.user_display_name as [display_name], "
	sql = sql & " iif(tt_country.country_code = '<NONE>','', trim(tt_country.country_code)) as [country_abbrev], tt_user.user_postal_code as [zip_code], "
	sql = sql & " tt_user.user_def1 as [user_defined_1], tt_user.user_def2 as [user_defined_2], tt_user.user_def3 as [user_defined_3], "
	sql = sql & " tt_market.market_name as [market],  "
	sql = sql & " tt_gmgt.gm_member as [member],  "
	sql = sql & " tt_gmgt.gm_group as [group],  "
	sql = sql & " tt_gmgt.gm_trader as [trader] "
	sql = sql & " FROM tt_market INNER JOIN ((tt_us_state "
	sql = sql & " INNER JOIN (tt_country  "
	sql = sql & " INNER JOIN tt_user  "
	sql = sql & " ON tt_country.country_id = tt_user.user_country_id) "
	sql = sql & " ON tt_us_state.state_id = tt_user.user_state_id) "
	sql = sql & " INNER JOIN ((tt_gateway   "
	sql = sql & " INNER JOIN tt_gmgt  "
	sql = sql & " ON tt_gateway.gateway_id = tt_gmgt.gm_gateway_id) "
	sql = sql & " INNER JOIN tt_user_gmgt "
	sql = sql & " ON tt_gmgt.gm_id = tt_user_gmgt.uxg_gmgt_id) "
	sql = sql & " ON tt_user.user_id = tt_user_gmgt.uxg_user_id) "
	sql = sql & " ON tt_market.market_id = tt_gateway.gateway_market_id "
	sql = sql & " WHERE uxg_available_to_user = 1 or (uxg_available_to_fix_adapter_user = 1 and user_fix_adapter_role = 1) "
	sql = sql & " ORDER BY tt_user.user_login "
	
'	wscript.echo(sql)
	execute_sql(sql)

end if



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Loop through rows
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

dim prev_user
prev_user = -9999
dim user_cnt
user_cnt = 0

if not bError then
	if not rs is nothing then
		do while not rs.eof
			
			user_cnt = user_cnt + 1
			if rs("user_id") <> prev_user then

				' finish the previous user
				if user_cnt > 1 then
					output_file.WriteLine tab3 & "</MGTs>"
					output_file.WriteLine tab2 & "</User>"
				end if

				' output a newly encountered user
				
				output_file.WriteLine tab2 & "<User id=""" & rs("user_id") & """>"  
					
				output_file.WriteLine tab3 & "<login>" & format_safe_xml_string(rs("user_name")) & "</login>"
				output_file.WriteLine tab3 & "<tt_sku>2</tt_sku>"
				output_file.WriteLine tab3 & "<userName>" & format_safe_xml_string(rs("display_name")) & "</userName>"
				output_file.WriteLine tab3 & "<postalCode>" & format_safe_xml_string(rs("zip_code")) & "</postalCode>"
				output_file.WriteLine tab3 & "<countryCode>" & format_safe_xml_string(rs("country_abbrev")) & "</countryCode>"
				output_file.WriteLine tab4 & "<userDefinedFields>"
				output_file.WriteLine tab5 & "<userDefinedField fieldName=""User Defined 1"">" & format_safe_xml_string(rs("user_defined_1")) & "</userDefinedField>"
				output_file.WriteLine tab5 & "<userDefinedField fieldName=""User Defined 2"">" & format_safe_xml_string(rs("user_defined_2")) & "</userDefinedField>"
				output_file.WriteLine tab5 & "<userDefinedField fieldName=""User Defined 3"">" & format_safe_xml_string(rs("user_defined_3")) & "</userDefinedField>"
				output_file.WriteLine tab4 & "</userDefinedFields>"
				output_file.WriteLine tab3 & "<MGTs>"
				
			end if

			if rs("market") <> "" then
				
				output_file.WriteLine tab4 & "<MGT" & _
					" market=""" & escape_property(rs("market")) & """" & _
					" member=""" & escape_property(rs("member")) & """" & _
					" group=""" & escape_property(rs("group")) & """" & _
					" trader=""" & escape_property(rs("trader")) & """" & _
					"/>"
			end if
			prev_user = rs("user_id")
			rs.movenext
		loop
	end if
end if



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Finish the XML
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' finish the previous user
if user_cnt > 0 then
	output_file.WriteLine tab3 & "</MGTs>"
	output_file.WriteLine tab2 & "</User>"
end if

output_file.WriteLine tab1 & "</Users>"
output_file.WriteLine "</UserData>"

wscript.echo "done"



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' connect to db
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
sub connect_to_db

	on error resume next

	conn.open sConnectionString

	if conn.state <> 1 then 'adStateOpen 
		dim err
		for each err in conn.errors
			bError = false
			wscript.echo "ERROR - Unable to connect to db: " & err.Description
		next
	end if
	
	on error goto 0

end sub



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' execute stored proc
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
sub execute_sql(sql)

	on error resume next

	dim cmd
	set cmd = createobject("adodb.command")
	set cmd.ActiveConnection = conn
	cmd.CommandType = 1 'adCmdText
	cmd.CommandText = sql

	set rs = cmd.Execute()

	if err.number <> 0 then
		bError = true
		wscript.echo "ERROR - Unable to execute sql: " & err.Description
	end if
	
	on error goto 0

end sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function format_safe_xml_string(s)

	format_safe_xml_string = "<![CDATA[" & s & "]]>"

end function

function escape_property(s)

	escape_property = Replace(s, "&", "&amp;")

end function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function pad_left(s)
	if len(s) = 1 then
		s = "0" & s
	end if
	pad_left = s
end function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function get_date_for_xml

	dim s
	s = datepart("yyyy",today)
	s = s & "-"
	s = s & pad_left(datepart("m",today))
	s = s & "-"
	s = s & pad_left(datepart("d",today))
	s = s & "T"
	s = s & pad_left(datepart("h",today))
	s = s & ":"
	s = s & pad_left(datepart("n",today))
	s = s & ":"
	s = s & pad_left(datepart("s",today))

	get_date_for_xml = s


end function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function get_output_filename
	
	dim s
	s = datepart("yyyy",today)
	s = s & pad_left(datepart("m",today))
	s = s & pad_left(datepart("d",today))
	s = s & "_"
	s = s & pad_left(datepart("h",today))
	s = s & pad_left(datepart("n",today))
	s = s & pad_left(datepart("s",today))

	get_output_filename = "export_user_data_usersetup_" & s & ".xml"
end function
