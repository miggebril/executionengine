using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuickFix;
using QuickFix.Fields;

namespace MarketDataListener.Models
{
    public class MarketSessionEventHandlers 
    {
        public delegate void MarketEventHandler(Message sender, MarketEventArgs e);
        //public delegate void ConnectionStatusUpdate(object sender, ConnectionUpdateEventArgs e);
        //public delegate void OrderBookUpdate(object sender, OrderUpdateEventArgs e);
        //public delegate void SecurityDefinitionResponse(object sender, SecurityDefinitionReceivedEventArgs e);
    }

    public class MarketEventArgs : EventArgs
    {
        public MarketEventArgs()
        {
        }

        public SessionID Session { get; set; }
    }
    public class OrderUpdateEventArgs : MarketEventArgs
    {
        public MDReqID MarketRequestId { get; set; }
        public object OrderBook { get; set; }
    }

    public class SecurityDefinitionReceivedEventArgs : MarketEventArgs
    {
        public SecurityID SecurityRequestId { get; set; }
        public QuickFix.FIX44.SecurityDefinition Instrument { get; set; }
    }

    public class ConnectionUpdateEventArgs : MarketEventArgs
    {
        public int MarketId { get; set; }
        public MarketConnectionStatus ConnectionStatus { get; set; }
    }
}
