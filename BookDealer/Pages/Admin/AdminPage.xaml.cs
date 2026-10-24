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
using System.Windows.Forms.DataVisualization.Charting;
using Word = Microsoft.Office.Interop.Word;
using Excel = Microsoft.Office.Interop.Excel;
using System.Data.Entity;
namespace BookDealer.Pages.Admin
{
    /// <summary>
    /// Interaction logic for AdminPage.xaml
    /// </summary>
    public partial class AdminPage : Page
    {
        private readonly Chart _paymentsChart = new Chart();

        public AdminPage()
        {
            InitializeComponent();
            PaymentsReport.SetupChart(_paymentsChart);
            PaymentsChartHost.Child = _paymentsChart;
            LoadData();
        }
        private User editedUser = null;

        private void LoadData()
        {
            LoadBooks();
            LoadPurchase();
            LoadUsers();
            LoadPaymentsUsers();

            RoleColumn.ItemsSource = Core.DB.Roles.ToList();
        }
        private void LoadPaymentsUsers()
        {
            PaymentsUserComboBox.ItemsSource = Core.DB.Users.AsNoTracking().OrderBy(u => u.DisplayName).ToList();
            if (PaymentsUserComboBox.Items.Count > 0)
                PaymentsUserComboBox.SelectedIndex = 0;
            RefreshPaymentsChart();
        }

        private void LoadUsers()
        {
            string u = UserSearchTb.Text.Trim();
            if (u == "")
            {
                UserGd.ItemsSource = Core.DB.Users.Include("Role").ToList();
            }
            else
                UserGd.ItemsSource = Core.DB.Users.Include("Role").Where(r => r.Login.Contains(u) || r.DisplayName.Contains(u) || r.Email.Contains(u)).ToList();
        }
        private void LoadBooks()
        {
            string b = BookSearchTb.Text.Trim();
            if (b == "")
                BooksDg.ItemsSource = Core.DB.Books.ToList();
            else
                BooksDg.ItemsSource = Core.DB.Books.Where(c => c.Title.Contains(b) || c.Author.Contains(b)).ToList();
        }
        private void LoadPurchase()
        {
            string p = PurchaseSearchTb.Text.Trim();
            if (p == "")
                PurchaseDg.ItemsSource = Core.DB.Purchases.Include("User").ToList();
            else
                PurchaseDg.ItemsSource = Core.DB.Purchases.Include("User").Where(o => o.User.DisplayName.Contains(p) || o.PaymentStatus.Contains(p)).ToList();


        }
        private void UserSearchTb_TextChanged(object sender, TextChangedEventArgs e)
        {
            LoadUsers();
        }


        private void UserGd_BeginningEdit(object sender, DataGridBeginningEditEventArgs e)
        {
            if (e.Row.Item != editedUser) 
                e.Cancel = true;
        }

        private void ChangeUserBtn_Click(object sender, RoutedEventArgs e)
        {
            if (editedUser == null)
            {
                User user = UserGd.SelectedItem as User;
                if (user == null)
                {
                    MessageBox.Show("Выберите пользователя!");
                    return;
                }
                editedUser = user;
                UserGd.IsReadOnly = false;
                ChangeUserBtn.Content = "💾 Сохранить";
                AddUserBtn.IsEnabled = false;
                DeleteUserBtn.IsEnabled = false;
                ChangePasswordBtn.IsEnabled = false;
                UserSearchTb.IsEnabled = false;
                return;
            }

            UserGd.CommitEdit(DataGridEditingUnit.Row, true);
            if (string.IsNullOrWhiteSpace(editedUser.Login) ||
                string.IsNullOrWhiteSpace(editedUser.DisplayName) ||
                editedUser.Role == null)
            {
                MessageBox.Show("Логин, имя и роль не могут быть пустыми!");
                return;
            }
            try
            {
                Core.DB.SaveChanges();
                MessageBox.Show("Изменения сохранены!");
                editedUser = null;
                UserGd.IsReadOnly = true;
                ChangeUserBtn.Content = "🖊 Изменить";
                AddUserBtn.IsEnabled = true;
                DeleteUserBtn.IsEnabled = true;
                ChangePasswordBtn.IsEnabled = true;
                UserSearchTb.IsEnabled = true;

                LoadData();
            }
            catch (Exception ex)
            {
                Exception inner = ex;
                while (inner.InnerException != null)
                    inner = inner.InnerException;
                MessageBox.Show("Ошибка сохранения: " + inner.Message);
            }
        }

        private void ChangePasswordBtn_Click(object sender, RoutedEventArgs e)
        {
            User user = UserGd.SelectedItem as User;
            if (user == null)
            {
                MessageBox.Show("Выберите пользователя!");
                return;
            }

            ChangePasswordWindow win = new ChangePasswordWindow(user);
            win.Owner = Window.GetWindow(this);
            if (win.ShowDialog() == true)
            {
                MessageBox.Show("Пароль изменён!");
                LoadUsers();
            }
        }
        private void AddUserBtn_Click(object sender, RoutedEventArgs e)
        {
            AddUserWindow win = new AddUserWindow();
            win.Owner = Window.GetWindow(this);
            if (win.ShowDialog() == true)
                LoadData();
        }

        private void DeleteUserBtn_Click(object sender, RoutedEventArgs e)
        {
            User user = UserGd.SelectedItem as User;
            if (user == null) return;
            if (user.UserID == Core.CurrentUser.UserID)
            {
                MessageBox.Show("Нельзя удалить самого себя!");
                return;
            }
            MessageBoxResult result = MessageBox.Show($"Удалить пользователя {user.DisplayName}?", "Удаление", MessageBoxButton.YesNo, MessageBoxImage.Warning);

            if (result != MessageBoxResult.Yes)
                return;

            try
            {
                int id = user.UserID;
                var reviewsId = Core.DB.Reviews.Where(r => r.UserID == id).Select(r => r.ReviewID).ToList();
                Core.DB.CartItems.RemoveRange(Core.DB.CartItems.Where(x => x.UserID == id));
                Core.DB.ReadingLists.RemoveRange(Core.DB.ReadingLists.Where(x => x.UserID == id));
                Core.DB.Purchases.RemoveRange(Core.DB.Purchases.Where(x => x.UserID == id));
                Core.DB.Reviews.RemoveRange(Core.DB.Reviews.Where(x => x.UserID == id));
                Core.DB.Complaints.RemoveRange(Core.DB.Complaints.Where(x => x.UserID == id));
                Core.DB.Complaints.RemoveRange(Core.DB.Complaints.Where(x => reviewsId.Contains(x.ReviewID.Value)));

                Core.DB.Users.Remove(user);
                Core.DB.SaveChanges();
                MessageBox.Show("Пользователь удалён!");
                LoadData();
            }
            catch (Exception ex)
            {
                Exception inner = ex;
                while (inner.InnerException != null)
                    inner = inner.InnerException;

                MessageBox.Show("Ошибка удаления: " + inner.Message);
            }
        }

        private void BookSearchTb_TextChanged(object sender, TextChangedEventArgs e)
        {
            LoadBooks();
        }
        private void AddBookBtn_Click(object sender, RoutedEventArgs e)
        {
            AddOrEditBookWindow win = new AddOrEditBookWindow();
            win.Owner = Window.GetWindow(this);
            if (win.ShowDialog() == true)
                LoadData();
        }

        private void ChangeBookBtn_Click(object sender, RoutedEventArgs e)
        {
            Book book = BooksDg.SelectedItem as Book;
            if (book == null)
            {
                MessageBox.Show("Выберите книгу!");
                return;
            }

            AddOrEditBookWindow win = new AddOrEditBookWindow(book);
            win.Owner = Window.GetWindow(this);
            if (win.ShowDialog() == true)
                LoadData();
            else
                Core.DB.Entry(book).Reload();
        }

        private void DeleteBookBtn_Click(object sender, RoutedEventArgs e)
        {
            Book book = BooksDg.SelectedItem as Book;
            if (book == null)
            {
                MessageBox.Show("Выберите книгу!");
                return;
            }

            MessageBoxResult result = MessageBox.Show($"Удалить книгу {book.Title}?", "Удаление", MessageBoxButton.YesNo, MessageBoxImage.Warning);

            if (result != MessageBoxResult.Yes) return;

            try
            {
                int id = book.BookID;
                var reviewId = Core.DB.Reviews.Where(r => r.BookID == id).Select(r => r.ReviewID).ToList();

                Core.DB.Complaints.RemoveRange(Core.DB.Complaints.Where(c => reviewId.Contains(c.ReviewID.Value)));
                Core.DB.Reviews.RemoveRange(Core.DB.Reviews.Where(r => r.BookID == id));
                Core.DB.CartItems.RemoveRange(Core.DB.CartItems.Where(r => r.BookID == id));
                Core.DB.ReadingLists.RemoveRange(Core.DB.ReadingLists.Where(r => r.BookID == id));
                Core.DB.Purchases.RemoveRange(Core.DB.Purchases.Where(r => r.BookID == id));

                book.Genres.Clear();
                Core.DB.Books.Remove(book);
                Core.DB.SaveChanges();
                MessageBox.Show("Книга удалена!");
                LoadData();
            }
            catch (Exception ex)
            {
                Exception inner = ex;
                while (inner.InnerException != null)
                    inner = inner.InnerException;
                MessageBox.Show("Ошибка удаления: " + inner.Message);
            }
        }

        private void PurchaseSearchTb_TextChanged(object sender, TextChangedEventArgs e)
        {
            LoadPurchase();
        }

        private void InitPaymentsTab()
        {
            PaymentsReport.SetupChart(_paymentsChart);
            PaymentsChartHost.Child = _paymentsChart;

            try
            {
                PaymentsUserComboBox.ItemsSource = Core.DB.Users.AsNoTracking().OrderBy(u => u.DisplayName).ToList();
                if (PaymentsUserComboBox.Items.Count > 0)
                    PaymentsUserComboBox.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось загрузить пользователей: " + ex.GetBaseException().Message);
            }

            RefreshPaymentsChart();
        }

        private void RefreshPaymentsChart()
        {
            var typeItem = PaymentsChartTypeComboBox.SelectedItem as ComboBoxItem;
            PaymentsReport.DrawChart(_paymentsChart, PaymentsUserComboBox.SelectedItem as User, typeItem?.Tag as string);
        }

        private void PaymentsUserComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!IsLoaded)
                return;
            RefreshPaymentsChart();
        }

        private void PaymentsChartTypeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!IsLoaded)
                return;
            RefreshPaymentsChart();
        }

        private void PaymentsExportExcel_Click(object sender, RoutedEventArgs e)
        {
            PaymentsReport.ExportToExcel();
        }

        private void PaymentsExportWord_Click(object sender, RoutedEventArgs e)
        {
            PaymentsReport.ExportToWord(_paymentsChart);
        }
    }
}
