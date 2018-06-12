using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MarketDataListener.Models
{
    public enum MarketConnectionStatus
    {
        Connecting = 0,
        Connected = 1,
        Disconnecting = 2,
        Disconnected = 3
    }
}
