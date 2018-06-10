See also ttus_run_sql_README.TXT.  What's the difference?
1) ttus_run_sql.vbs runs on the server, where the TTUS MS Access database (.mdb) file is.  It does not use the network.
2) TTUSCommandLineClient.exe runs on the client, requires authentication, and communicates with the TT User Setup Server over the network via TTM.


TTUSCommandLineClient.exe Usage:

TTUSCommandLineClient.exe username password c:\full\path\to\a_config_file.ini

Username must have Super Administrator permissions (e.g., TTSYSTEM)

Config file contains name=value pairs as follows, specifying the type of request and the payload.

Notice that the example payloads change depending on type:

To run sql or a command that's built into the TTUS server:
RequestType=msg
Payload=get_markets

Or to run your own SQL
RequestType=sql
Payload=select * from tt_market

Or to fetch a file from the server's logfiles folder:
RequestType=file
Payload=TT_2011-12-31.log


Other config settings:

OutputDir=c:\dir_WITH_trailing_slash\
defaults to your tt\logfiles\ folder

OutputFile=your_output.txt
