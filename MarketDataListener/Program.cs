using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuickFix;
using QuickFix.Transport;
using MarketDataListener.Services;

namespace MarketDataListener
{
    static class Program
    {
        static void Main(string[] args)
        {
            string configPath = "marketdatalistener.cfg";
            if (args.Length > 1)
            {
                Console.WriteLine("MULTIPLE CONFIGS ENTERED. ERROR.");
                for (int index = 0; index < args.Length; index++)
                {
                    Console.WriteLine(args[index]);
                    configPath = args[index];
                    SessionSettings sessionSettings = new SessionSettings(configPath);

                    //string host = sessionSettings.Get().GetString(SessionSettings.SENDERCOMPID);
                    string host = "CLIENT1";
                    string target = "EXECUTOR";

                    FixSession fixClientApplication = new FixSession(QuickFix.FixValues.ApplVerID.FIX44, host, target);
                    MarketPriceSource venue = new MarketPriceSource(QuickFix.FixValues.ApplVerID.FIX44, fixClientApplication);

                    IMessageStoreFactory storeFactory = new FileStoreFactory(sessionSettings);
                    ILogFactory logFactory = new FileLogFactory(sessionSettings);

                    SocketInitiator acceptor = new SocketInitiator(
                        fixClientApplication,
                        storeFactory,
                        sessionSettings,
                        logFactory);

                    acceptor.Start();
                    fixClientApplication.Run();
                } 
            }
            else
            {
                try
                {
                    SessionSettings sessionSettings = new SessionSettings(configPath);
                    string host = "CLIENT1";
                    string target = "EXECUTOR";
                    FixSession fixClientApplication = new FixSession(QuickFix.FixValues.ApplVerID.FIX44, host, target);
                    MarketPriceSource venue = new MarketPriceSource(QuickFix.FixValues.ApplVerID.FIX44, fixClientApplication);

                    IMessageStoreFactory storeFactory = new FileStoreFactory(sessionSettings);
                    ILogFactory logFactory = new FileLogFactory(sessionSettings);

                    SocketInitiator acceptor = new SocketInitiator(
                        fixClientApplication,
                        storeFactory,
                        sessionSettings,
                        logFactory);

                    acceptor.Start();
                    fixClientApplication.Run();
                }
                catch (Exception ex)
                {
                    Models.Helpers.LogException(ex);
                }
            }
        }
    }
}
