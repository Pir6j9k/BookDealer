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
using System.Windows.Shapes;

namespace BookDealer.Pages.Admin
{
    /// <summary>
    /// Interaction logic for AddUserWindow.xaml
    /// </summary>
    public partial class AddUserWindow : Window
    {
        public AddUserWindow()
        {
            InitializeComponent();
            RoleCb.ItemsSource = Core.DB.Roles.ToList();
            RoleCb.SelectedIndex = 0;
        }

        public string GetHash(String pass)
        {
            using (var hash = SHA256.Create())
            {
                return string.Concat(hash.ComputeHash(Encoding.UTF8.GetBytes(pass)).Select(x => x.ToString("X2")));
            }
        }
        private void SaveBtn_Click(object sender, RoutedEventArgs e)
        {
            string login = LoginTb.Text.Trim();
            string password = PasswordPb.Password;
            string name = DisplayNameTb.Text.Trim();
            string email = EmailTb.Text.Trim();
            Role role = RoleCb.SelectedItem as Role;

            if (login == "" || password == "" || name == "" || email == "" || role == null)
            {
                MessageBox.Show("Заполните все поля!");
                return;
            }

            if (!email.Contains("@"))
            {
                MessageBox.Show("Некорректная почта!");
                return;
            }

            if (Core.DB.Users.Any(u => u.Login == login))
            {
                MessageBox.Show("Пользователь с таким логином уже существует!");
                return;
            }

            try
            {
                if (password.Length >= 8)
                {
                    bool en = true;
                    bool number = false;

                    for (int i = 0; i < password.Length; i++)
                    {
                        if (password[i] >= '0' && password[i] <= '9')
                            number = true;
                        else if (!((password[i] >= 'A' && password[i] <= 'Z') || (password[i] >= 'a' && password[i] <= 'z'))) en = false;
                    }
                    if (!en)
                    {
                        MessageBox.Show("Используйте только английскую раскладку!");
                        return;
                    }
                    if (!number)
                    {
                        MessageBox.Show("Добавьте хотя бы одну цифру!");
                        return;
                    }
                    User user = new User
                    {
                        Login = login,
                        PasswordHash = GetHash(password),
                        DisplayName = name,
                        Email = email,
                        RoleID = role.RoleID,
                        IsFrozen = false,
                        CreatedAt = DateTime.Now
                    };
                    Core.DB.Users.Add(user);
                    Core.DB.SaveChanges();
                    DialogResult = true;

                }
                else
                    MessageBox.Show("Пароль должен быть минимум 8 симвалов!");
            }
            catch (Exception ex)
            {
                Exception inner = ex;
                while (inner.InnerException != null)
                    inner = inner.InnerException;
                MessageBox.Show("Ошибка добавления: " + inner.Message);
            }
        }

        private void CancelBtn_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
        }
        private void ThemeChangeBtn_Click(object sender, RoutedEventArgs e)
        {
            ThemeManager.SwitchTheme();
        }

    }
}
