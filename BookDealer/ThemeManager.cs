using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace BookDealer
{
    public static class ThemeManager
    {
        public static bool isDark = false;
        public static void Load()
        {
            isDark = Properties.Settings.Default.IsDark;
            Apply();
        }

        public static void SwitchTheme()
        {
            isDark = !isDark;
            Apply();

            Properties.Settings.Default.IsDark = isDark;
            Properties.Settings.Default.Save();
        }
        private static void Apply()
        {
            var dict = new ResourceDictionary
            {
                Source = new Uri(isDark ? "Dictionary2.xaml" : "Dictionary1.xaml", UriKind.Relative)
            };

            Application.Current.Resources.MergedDictionaries.Clear();
            Application.Current.Resources.MergedDictionaries.Add(dict);
        }
    }
}
