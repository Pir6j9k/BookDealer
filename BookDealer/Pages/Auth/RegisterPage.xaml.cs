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
    /// Interaction logic for RegisterPage.xaml
    /// </summary>
    public partial class RegisterPage : Page
    {
        public RegisterPage()
        {
            InitializeComponent();
        }

        private void CreateAccB_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(NameTbx.Text) || string.IsNullOrEmpty(MailTbx.Text) || string.IsNullOrEmpty(LoginTbx.Text) || string.IsNullOrEmpty(PassB.Password) || string.IsNullOrEmpty(RepPassB.Password))
            {
                MessageBox.Show("Заполните все поля!");
                return;
            }

            if (Core.DB.Users.Any(x => x.Login == LoginTbx.Text))
            {
                MessageBox.Show("Данный логин занят!");
                return;
            }

            if (Core.DB.Users.Any(x => x.Email == MailTbx.Text))
            {
                MessageBox.Show("Данная почта занята!");
                return;
            }

            if (!MailTbx.Text.Contains("@"))
            {
                MessageBox.Show("Некорректная почта!");
                return;
            }

            string error = PasswordHelper.Validate(PassB.Password);
            if (error != null)
            {
                MessageBox.Show(error);
                return;
            }

            if (PassB.Password != RepPassB.Password)
            {
                MessageBox.Show("Пароли не совпадают!");
                return;
            }

            User user = new User
            {
                DisplayName = NameTbx.Text,
                Login = LoginTbx.Text,
                Email = MailTbx.Text,
                PasswordHash = PasswordHelper.Hash(PassB.Password),
                RoleID = 2,
                IsFrozen = false,
                CreatedAt = DateTime.Now
            };
            Core.DB.Users.Add(user);
            Core.DB.SaveChanges();
            MessageBox.Show("Пользователь успешно зарегистрирован!");
            LoginTbx.Clear();
            PassB.Clear();
            RepPassB.Clear();
            MailTbx.Clear();
            NameTbx.Clear();
        }
        private void ThemeChangeBtn_Click(object sender, RoutedEventArgs e)
        {
            ThemeManager.SwitchTheme();
        }
    }
}
