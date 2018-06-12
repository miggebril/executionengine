using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuickFix;
using QuickFix.FixValues;
using MarketDataListener.Models;

using FixVersion = QuickFix.FixValues.ApplVerID;

namespace MarketDataListener.Services
{
    public class MarketPriceSource : IVenue
    {
        public FixSession FixSession {
            get
             { return sessionService; }
        }

        private FixSession sessionService;
        private string fixVersion;
        private FixMessageCracker fixParser;

        public MarketPriceSource(string version, FixSession connection)
        {
            fixVersion = version;
            sessionService = connection;
            InitializeMembers();
        }

        private void InitializeMembers()
        {
            fixParser = new FixMessageCracker();
            sessionService.OnMarketUpdate += new MarketSessionEventHandlers.MarketEventHandler(UpdateMessageRouter);
        }

        private void UpdateMessageRouter(Message update, MarketEventArgs e)
        {
            fixParser.Crack(update, e);
        }

        public void OnMessage(QuickFix.FIX44.MarketDataSnapshotFullRefresh marketRefresh, SessionID sessionId)
        {
            Console.WriteLine("Full snapshot refresh");
        }

        public void OnMessage(QuickFix.FIX44.MarketDataIncrementalRefresh marketRefresh, SessionID sessionId)
        {
            Console.WriteLine("Incremental refresh");
        }

        public void OnMessage(QuickFix.FIX44.SecurityDefinition secDef, SessionID sessionID)
        {
            Console.WriteLine("Sec Definition");
        }

        public void OnMessage(QuickFix.FIX44.Logout logoff, SessionID sessionID)
        {
            Console.WriteLine("Logout");
        }
        public void OnMessage(QuickFix.FIX44.Logon logon, SessionID sessionID)
        {
            Console.WriteLine("Logon");
        }
    }
}
