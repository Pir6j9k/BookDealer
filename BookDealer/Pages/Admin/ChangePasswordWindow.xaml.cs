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
using System.Windows.Shapes;

namespace BookDealer.Pages.Admin
{
    /// <summary>
    /// Interaction logic for ChangePasswordWindow.xaml
    /// </summary>
    public partial class ChangePasswordWindow : Window
    {
        private readonly User _user;

        public ChangePasswordWindow(User user)
        {
            InitializeComponent();
            _user = user;
            UserNameTb.Text = user.DisplayName;
        }

        private void SaveBtn_Click(object sender, RoutedEventArgs e)
        {
            string pass = NewPasswordPb.Password;

            string error = PasswordHelper.Validate(pass);
            if (error != null)
            {
                MessageBox.Show(error);
                return;
            }
            if (pass != ConfirmPasswordPb.Password)
            {
                MessageBox.Show("Пароли не совпадают!");
                return;
            }

            try
            {
                _user.PasswordHash = PasswordHelper.Hash(pass);
                Core.DB.SaveChanges();
                DialogResult = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка сохранения: " + ex.GetBaseException().Message);
            }
        }
        private void ThemeChangeBtn_Click(object sender, RoutedEventArgs e)
        {
            ThemeManager.SwitchTheme();
        }
    }
}
