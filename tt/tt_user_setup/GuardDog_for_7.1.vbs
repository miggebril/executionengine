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

dim fs
set fs=CreateObject("Scripting.FileSystemObject")

dim shell
set shell = CreateObject("WScript.Shell")

dim conn
set conn = createobject("ADODB.Connection")

dim accounts_dict
set accounts_dict = CreateObject("Scripting.Dictionary")

dim rs
dim sql
dim output_file_full_path
dim output_file
dim dt

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
'' connect to the db
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
dim connection_string
connection_string = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + db_file
conn.open(connection_string)

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' create a lookup dictionary of accounts for the traders file
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

sql = "select trdr_member + trdr_group + trdr_trader, acct_name"
sql = sql & " from tt_trader "
sql = sql & " inner join tt_account on tt_account.acct_trader_id = tt_trader.trdr_id"
sql = sql & " where trdr_publish_to_guardian = 1"
sql = sql & " order by trdr_member + trdr_group + trdr_trader, acct_name"

set rs = conn.execute(sql)

dim temp

do while not rs.eof
	dim mgt_key
	dim acct
	mgt_key = rs(0)
	acct = rs(1)
	if accounts_dict.Exists(mgt_key) then
		temp = accounts_dict.Item(mgt_key)			
		accounts_dict.Item(mgt_key) = temp & "," & acct
	else
		accounts_dict.Add mgt_key, acct
	end if
	rs.movenext
loop


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' create the traders file
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if has_command_line_arg("nodate") then
	output_file_full_path = logfile_folder & "\" & "TraderInfo.txt"
else
	output_file_full_path = logfile_folder & "\" & get_filename_date & "TraderInfo.txt"
end if

set output_file = fs.CreateTextFile(output_file_full_path)

output_file.WriteLine "Trader ID|Account|Alias|Credit|Currency|Allow Trading|Ignore P&L|Risk On/Off|Last Modified|Who Modified|IP Address"

sql = "select * from tt_trader LEFT JOIN tt_user ON tt_trader.trdr_last_updated_user_id = tt_user.user_id order by 1"

set rs = conn.execute(sql)

do while not rs.eof
	mgt_key = rs("trdr_member") & rs("trdr_group") & rs("trdr_trader")
	if accounts_dict.Exists(mgt_key) then

		output_file.Write mgt_key
		output_file.Write "|"

		output_file.Write accounts_dict.Item(mgt_key)
		output_file.Write "|"

		output_file.Write rs("trdr_description")
		output_file.Write "|"

		output_file.Write rs("trdr_credit")
		output_file.Write "|"

		output_file.Write rs("trdr_currency")
		output_file.Write "|"

		if rs("trdr_allow_trading") = 1 then
			output_file.Write "Yes"
		else
			output_file.Write "No"
		end if
		output_file.Write "|"

		if rs("trdr_ignore_pl") = 1 then
			output_file.Write "Yes"
		else
			output_file.Write "No"
		end if
		output_file.Write "|"

		if rs("trdr_risk_on") = 1 then
			output_file.Write "On"
		else
			output_file.Write "Off"
		end if
		output_file.Write "|"

		output_file.Write my_format_date(rs("trdr_last_updated_datetime"))		
		output_file.Write "|"
		
		if IsNull(rs("user_login")) then
			output_file.Write ""
		else
			output_file.Write rs("user_login")
		end if
		
		output_file.Write "|"
		
		output_file.Write "127.0.0.1"
		output_file.Write VbCrLf
		
	end if
	rs.movenext
loop

output_file.close

wscript.echo output_file_full_path & " created"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' create the product limit file
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if has_command_line_arg("nodate") then
	output_file_full_path = logfile_folder & "\" & "ProductInfo.txt"
else
	output_file_full_path = logfile_folder & "\" & get_filename_date & "ProductInfo.txt"
end if

set output_file = fs.CreateTextFile(output_file_full_path)

output_file.WriteLine "Trader ID|Exchange|Product|Type|Additional Margin(%)|Maximum Order Qty.|Maximum Position|Allow Trade Out|Last Modified|Who Modified|IP Address"

'with max long short
'output_file.WriteLine "Trader ID|Exchange|Product|Type|Additional Margin(%)|Maximum Order Qty.|Maximum Position|Max Long/Short|Allow Trade Out|Last Modified|Who Modified|IP Address"

sql = "SELECT tt_product_limit.*, tt_user.user_login, tt_gateway.gateway_name, tt_product_type.product_description, trdr_member as mgt_member, trdr_group as mgt_group, trdr_trader as mgt_trader"
sql = sql & " FROM tt_trader "
sql = sql & " INNER JOIN (tt_product_type "
sql = sql & " INNER JOIN (tt_gateway "
sql = sql & " INNER JOIN (tt_product_limit "
sql = sql & " LEFT JOIN tt_user "
sql = sql & " ON tt_product_limit.plim_last_updated_user_id = tt_user.user_id) "
sql = sql & " ON tt_gateway.gateway_id = tt_product_limit.plim_gateway_id) "
sql = sql & " ON tt_product_type.product_id = tt_product_limit.plim_product_type) "
sql = sql & " ON tt_trader.trdr_id = tt_product_limit.plim_trader_id "
sql = sql & " ORDER BY trdr_member, trdr_group, trdr_trader, gateway_name, plim_product, product_description "

set rs = conn.execute(sql)

do while not rs.eof
	output_file.Write rs("mgt_member") & rs("mgt_group") & rs("mgt_trader")
	output_file.Write "|"

	output_file.Write rs("gateway_name")
	output_file.Write "|"

	output_file.Write rs("plim_product")
	output_file.Write "|"

	output_file.Write rs("product_description")
	output_file.Write "|"

	output_file.Write CDbl(rs("plim_additional_margin_pct"))/1000
	output_file.Write "|"

	output_file.Write rs("plim_max_order_qty")
	output_file.Write "|"

	output_file.Write rs("plim_max_position")
	output_file.Write "|"

' with max long short
' output_file.Write rs("plim_max_long_short")
' output_file.Write "|"
	
	if rs("plim_allow_tradeout") = 1 then
		output_file.Write "Yes"
	else
		output_file.Write "No"
	end if	
	output_file.Write "|"
	
	output_file.Write my_format_date(rs("plim_last_updated_datetime"))
	output_file.Write "|"

	if IsNull(rs("user_login")) then
		output_file.Write ""
	else
		output_file.Write rs("user_login")
	end if

	output_file.Write "|"

	output_file.Write "127.0.0.1"
	output_file.Write VbCrLf
		
	rs.movenext
loop

output_file.close
conn.close

wscript.echo output_file_full_path & " created"

wscript.echo "GuardDog.vbs done"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function pad_left(s)
	if len(s) = 1 then
		s = "0" & s
	end if
	pad_left = s
end function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function my_format_date(dt)
	dim month
	dim day
	dim year
	dim hour
	dim min
	dim sec
	
	month = pad_left(DatePart("m", dt))
	day = pad_left(DatePart("d", dt))
	year = DatePart("yyyy", dt)
	hour = pad_left(DatePart("h", dt))
	min = pad_left(DatePart("n", dt))
	sec = pad_left(DatePart("s", dt))

		
	my_format_date = month & "/" & day & "/" & year & " " & hour & ":" & min & ":" & sec

end function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function get_database_file_name
	
	dim ts
'	set ts = fs.OpenTextFile(config_folder + "\\TTUserSetupServer_710_DEBUG.ini")
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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function has_command_line_arg(arg)
	dim i

	for i = 1 to wscript.arguments.Count 
		if wscript.arguments(i-1) = arg then
			has_command_line_arg = true
			exit function
		end if
	next

	has_command_line_arg = false
end function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function get_filename_date
	
	dim today
	today = now
	dim s
	s = datepart("yyyy", today)
	s = s & "_"
	s = s & pad_left(datepart("m",today))
	s = s & "_"
	s = s & pad_left(datepart("d",today))
	s = s & "_"

	get_filename_date = s
	
end function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
function pad_left(s)

	if len(s) = 1 then
		s = "0" & s
	end if
	pad_left = s
	
end function
