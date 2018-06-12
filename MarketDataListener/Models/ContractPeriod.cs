using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MarketDataListener.Models
{
    public class ContractPeriod
    {
        public int MonthYear { get; set; }
        public ContractPeriod NextMonthYear { get; set; }

        public ContractPeriod(int month, int year, ContractPeriod nextContract = default(ContractPeriod))
        {
            MonthYear = (year * 12) + month;
            NextMonthYear = nextContract;
        }
        public ContractPeriod(DateTime date, ContractPeriod nextContract = default(ContractPeriod))
        {
            MonthYear = (date.Year * 12) + date.Month;
            NextMonthYear = nextContract;
        }
    }
}
