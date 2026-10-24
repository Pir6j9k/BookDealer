using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
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

namespace BookDealer.Pages.Auth
{
    /// <summary>
    /// Interaction logic for AuthPage.xaml
    /// </summary>
    public partial class AuthPage : Page
    {
        int failedAttempts = 0;
        public AuthPage()
        {
            InitializeComponent();
        }
        public static string GetHash(String pass)
        {
            using (var hash = SHA256.Create())
            {
                return string.Concat(hash.ComputeHash(Encoding.UTF8.GetBytes(pass)).Select(x => x.ToString("X2")));
            }
        }

        private void OpenMainWindow()
        {
            MainWindow mainWindow = new MainWindow();
            Core.MainWindow = mainWindow;
            Core.MainFrame = mainWindow.MainFrame;

            mainWindow.Show();

            Window authWindow = Window.GetWindow(this);
            authWindow?.Close();
        }

        private void GuestB_Click(object sender, RoutedEventArgs e)
        {
            Core.CurrentUser = null;
            OpenMainWindow();
        }
        private void LoginB_Click(object sender, RoutedEventArgs e)
        {
            try
            {

                if (string.IsNullOrEmpty(LoginTbx.Text) || string.IsNullOrEmpty(PassPb.Password))
                {
                    MessageBox.Show("Заполните все поля!");
                    return;
                }
                string hashedPass = GetHash(PassPb.Password);
                User user = Core.DB.Users.FirstOrDefault(x => x.Login == LoginTbx.Text && x.PasswordHash == hashedPass);
                if (user == null)
                {
                    MessageBox.Show("Пользователь не найден!");
                    failedAttempts++;
                    if (failedAttempts >= 3)
                    {
                        if (CapSt.Visibility != Visibility.Visible)
                        {
                            CaptchaSwitch();
                            
                        }
                        CaptchaChange();
                        LoginTbx.Clear();
                        PassPb.Clear();
                    }
                    return;
                }
                Core.CurrentUser = user;

                MessageBox.Show($"Добро пожаловать, {user.DisplayName}");
                OpenMainWindow();
            }
            catch { }
        }

        public void CaptchaSwitch()
        {
            bool showCaptcha = CapSt.Visibility != Visibility.Visible;


            CapSt.Visibility = showCaptcha
                ? Visibility.Visible
                : Visibility.Collapsed;

            logst.Visibility = showCaptcha
                ? Visibility.Collapsed
                : Visibility.Visible;

            GuestB.Visibility = showCaptcha
                ? Visibility.Collapsed
                : Visibility.Visible;

            LoginB.Visibility = showCaptcha
                ? Visibility.Collapsed
                : Visibility.Visible;

            RegSp.Visibility = showCaptcha
                ? Visibility.Collapsed
                : Visibility.Visible;

            if (showCaptcha)
            {
                CaptchaChange();
            }
            else
            {
                captchaInput.Clear();
            }
        }

        public void CaptchaChange()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            Random r = new Random();
            string pwd = "";

            for (int i = 0; i < 6; i++)
            {
                pwd += chars[r.Next(chars.Length )];
            }
            captcha.Text = pwd;
        }

        private void submitCaptcha_Click(object sender, RoutedEventArgs e)
        {
            if (captchaInput.Text.Trim() != captcha.Text)
            {
                MessageBox.Show("Неверно введена капча", "Ошибка");
                CaptchaChange();
                captchaInput.Clear();
                return;
            }

            MessageBox.Show("Капча введена успешно, можете продолжить авторизацию", "Успех");
            failedAttempts = 0;
            CaptchaSwitch();
        }

       
        private void ThemeChangeBtn_Click(object sender, RoutedEventArgs e)
        {
            ThemeManager.SwitchTheme();
        }
    }
}
