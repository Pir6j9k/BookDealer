using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;

namespace BookDealer
{
    public static class Core
    {
        public static BookShopEntities DB { get; set; } = new BookShopEntities();
        public static User CurrentUser {  get; set; }
        public static Frame MainFrame { get; set; }
        public static MainWindow MainWindow { get; set; }
    }
}
