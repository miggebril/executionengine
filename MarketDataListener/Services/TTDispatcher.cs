using System;
using TradingTechnologies.TTAPI;

namespace MarketDataListener.Services
{
    public class InstrumentSubscriptionDispatch : IDisposable
    {
        /// <summary>
        /// Declare the TTAPI objects
        /// </summary>
        private UniversalLoginTTAPI m_apiInstance = null;
        private WorkerDispatcher m_disp = null;
        private object m_lock = new object();
        private InstrumentLookupSubscription m_req = null;
        private TimeAndSalesSubscription m_tsSub = null;
        private bool m_disposed = false;


        /// <summary>
        /// Declare contract information objects
        /// </summary>
        private MarketKey m_marketKey;
        private ProductType m_productType;
        private string m_product;
        private string m_contract;


        /// <summary>
        /// Primary constructor
        /// </summary>
        public InstrumentSubscriptionDispatch(UniversalLoginTTAPI api, MarketKey mk, ProductType pt, string prod, string cont) 
        {
                m_apiInstance = api;
                m_marketKey = mk;
                m_productType = pt;
                m_product = prod;
                m_contract = cont;
        }

        /// <summary>
        /// Create and start the Dispatcher
        /// </summary>
        public void Start()
        {
            // Attach a WorkerDispatcher to the current thread
            m_disp = Dispatcher.AttachWorkerDispatcher();
            m_disp.BeginInvoke(new Action(Init));
            m_disp.Run();
        }

        /// <summary>
        /// Begin work on this thread
        /// </summary>
        public void Init()
        {
            // Perform an instrument lookup
            m_req = new InstrumentLookupSubscription(m_apiInstance.Session,
            Dispatcher.Current,
            new ProductKey(m_marketKey, m_productType, m_product), m_contract);
            //m_req.Update += newEventHandler<InstrumentLookupSubscriptionEventArgs>(req_Update);
            m_req.Start();
        }
        
        /// <summary>
        /// Clean up TTAPI objects
        /// </summary>
            public void Dispose()
            {
                lock (m_lock)
                {
                    if (!m_disposed)
                    {
                        // Detach callbacks and dispose of all subscriptions
                        if (m_req != null)
                        {
                            m_req.Dispose();
                            m_req = null;
                        }
                        if (m_tsSub != null)
                        {
                            m_tsSub.Dispose();
                        }
                        m_tsSub = null;
                    }
                    // Shutdown the Dispatcher
                    if (m_disp != null)
                    {
                        m_disp.BeginInvokeShutdown();
                        m_disp = null;
                    }
                    m_disposed = true;
                }
            }
    }
}
