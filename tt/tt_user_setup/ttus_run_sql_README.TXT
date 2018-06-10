See also TTUSCommandLineClient_README.TXT.  What's the difference?
1) ttus_run_sql.vbs runs on the server, where the TTUS MS Access database (.mdb) file is.  It does not use the network.
2) TTUSCommandLineClient.exe runs on the client, requires authentication, and communicates with the TT User Setup Server over the network via TTM.

ttus_run_sql.vbs Usage:

cscript ttus_run_sql.vbs [SQL SCRIPT FILE] [options...]

If you are running this on 64-bit Windows, use cscript in syswow64 folder:
C:\Windows\syswow64\cscript ttus_run_sql.vbs sql.txt

Options:
db=other.mdb       By default, runs against db configured
                   in tt\config\TTUserSetupServer.ini.
                   Use this to run against a different db.
				
file=output.txt    By default, outputs to console. Use this to write to file.

Examples:
cscript ttus_run_sql.vbs sql.txt
cscript ttus_run_sql.vbs sql.txt db=other_db.mdb file=output.txt


