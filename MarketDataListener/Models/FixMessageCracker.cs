using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuickFix;

namespace MarketDataListener.Models
{
    public class FixMessageCracker : MessageCracker
    {

        public FixMessageCracker()
        {
            Console.WriteLine("FixMessageCracker() execcuted");
        }

        public void Crack(Message sender, MarketEventArgs e)
        {
            Console.WriteLine(e.Session.ToString() + " Acceptor message: " + sender.ToString());

            base.Crack(sender, e.Session);
        }
    }
}
