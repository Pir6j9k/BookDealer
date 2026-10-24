using BookDealer.Pages.Auth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace BookDealer
{
    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            Core.MainWindow = this;
            Core.MainFrame = MainFrame;


            if (Core.CurrentUser?.Role?.RoleName == "Администратор")
                MainFrame.Navigate(new Pages.Admin.AdminPage());

            else
                MainFrame.Navigate(new Pages.Books.CatalogPage()); 
        }

        private void ThemeChangeBtn_Click(object sender, RoutedEventArgs e)
        {
            ThemeManager.SwitchTheme();
        }

        private void MainFrame_Navigated(object sender, NavigationEventArgs e)
        {
            if (e.Content is Page page && !string.IsNullOrWhiteSpace(page.Title)) 
            {
                LogoPanel.Visibility = Visibility.Collapsed;
                PageTitleText.Text = page.Title;
                PageTitleText.Visibility = Visibility.Visible;
            }
            else
            {
                LogoPanel.Visibility= Visibility.Visible;
                PageTitleText.Visibility= Visibility.Collapsed;
            }
            bool isCatalog = e.Content is Pages.Books.CatalogPage;
            SearchBorder.Visibility = isCatalog ? Visibility.Visible : Visibility.Collapsed;
            SearchTb.Text = "";
        }
        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            var timer = new System.Windows.Threading.DispatcherTimer();
            timer.Interval = new TimeSpan(0, 0, 1);
            timer.IsEnabled = true;
            timer.Tick += (o, t) => {
                DateTimeNow.Text = DateTime.Now.ToString();
            };
            timer.Start();
        }
        private void BackBtn_Click(object sender, RoutedEventArgs e)
        {
            if (MainFrame.CanGoBack) MainFrame.GoBack(); 
        }

        private void FavBtn_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Navigate(new Pages.Profile.FavoriteBooksPage());
        }

        private void CartBtn_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Navigate(new Pages.Profile.CartPage());
        }

        private void ProfileBtn_Click(object sender, RoutedEventArgs e)
        {
            if (Core.CurrentUser == null || Core.CurrentUser.Role?.RoleName == "Гость")
            {

                MainFrame.Navigate(new Pages.Auth.RegisterPage());
            }
            else 
                MainFrame.Navigate(new Pages.Profile.ProfilePage());
        }

        private void ExitBtn_Click(object sender, RoutedEventArgs e)
        {
            MessageBoxResult result = MessageBox.Show( "Выйти из профиля?", "Выход", MessageBoxButton.YesNo, MessageBoxImage.Question);

            if (result != MessageBoxResult.Yes)
                return;

            Core.CurrentUser = null;
            AuthWindow auth = new AuthWindow();
            Application.Current.MainWindow = auth;      
            auth.Show();                               

            Core.MainWindow.Close();
        }
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (MessageBox.Show("Закрыть приложение?", "Выход", MessageBoxButton.YesNo, MessageBoxImage.Question) != MessageBoxResult.Yes)
                e.Cancel = true;
        }

        private void SearchTb_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (MainFrame?.Content is Pages.Books.CatalogPage catalog)
                catalog.ApplySearch(SearchTb.Text);
        }
    }
}
