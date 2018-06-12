using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MarketDataListener.Models
{
    public static class Helpers
    {
        public static void LogException(Exception ex)
        {
            using (EventLog eventLog = new EventLog("Application"))
            {
                eventLog.Source = "MarketData Listener";
                eventLog.WriteEntry(ex.StackTrace, EventLogEntryType.Information, 101, 1);
            }
        }
    }
}
