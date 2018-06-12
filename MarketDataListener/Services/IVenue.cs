using QuickFix;

namespace MarketDataListener.Services
{
    public interface IVenue
    {
        void OnMessage(QuickFix.FIX44.Logon logon, SessionID sessionID);
        void OnMessage(QuickFix.FIX44.Logout logoff, SessionID sessionID);
    }

    public struct MarketSession
    {
        public int MarketSessionID { get; set; }
        public bool Connected { get; set; }
        public SessionCredentials Credentials { get; set; }
    }

    public struct SessionCredentials
    {
        public string User { get; set; }
        public byte[] PrivateKey { get; set; }
    }
}
