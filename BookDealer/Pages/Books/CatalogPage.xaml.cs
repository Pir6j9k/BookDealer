using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
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

namespace BookDealer.Pages.Books
{
    /// <summary>
    /// Interaction logic for CatalogPage.xaml
    /// </summary>
    public partial class CatalogPage : Page
    {
        private List<Genre> _genres = new List<Genre>();

        public CatalogPage()
        {
            InitializeComponent();
            LoadGenres();
            LoadBooks();
        }

        private void LoadGenres()
        {
            try
            {
                _genres = Core.DB.Genres.AsNoTracking().OrderBy(g => g.GenreName).ToList();
                GenresList.ItemsSource = _genres;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось загрузить жанры: " + ex.GetBaseException().Message);
            }
        }

        private void LoadBooks()
        {
            var selectedIds = _genres.Where(g => g.IsSelected).Select(g => g.GenreID).ToList();


            try
            {
                IQueryable<Book> query = Core.DB.Books.AsNoTracking();

                if (TryParsePrice(PriceFromTextBox.Text, out decimal priceFrom))
                    query = query.Where(b => b.Price >= priceFrom);

                if (TryParsePrice(PriceToTextBox.Text, out decimal priceTo))
                    query = query.Where(b => b.Price <= priceTo);
                if (!string.IsNullOrEmpty(_searchText))
                    query = query.Where(b => b.Title.Contains(_searchText));
                if (selectedIds.Count > 0)
                    query = query.Where(b => b.Genres.Any(g => selectedIds.Contains(g.GenreID)));

                switch (SortComboBox.SelectedIndex)
                {
                    case 1:
                        query = query.OrderBy(b => b.Price).ThenBy(b => b.Title);
                        break;
                    case 2:
                        query = query.OrderByDescending(b => b.Price).ThenBy(b => b.Title);
                        break;
                    default:
                        query = query
                            .OrderByDescending(b => b.Purchases.Count(p => p.PaymentStatus == "Оплачено"))
                            .ThenBy(b => b.Title);
                        break;
                }

                ShowBooks(query.ToList());
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось загрузить книги: " + ex.GetBaseException().Message);
            }
        }

        private void ShowBooks(List<Book> books)
        {
            BookLb.ItemsSource = books;
        }

        private void ResetFilterBtn_Click(object sender, RoutedEventArgs e)
        {
            PriceFromTextBox.Text = "";
            PriceToTextBox.Text = "";
            foreach (var genre in _genres)
                genre.IsSelected = false;
            GenresList.ItemsSource = null;
            GenresList.ItemsSource = _genres;
            SortComboBox.SelectedItem = null;
            LoadBooks();
        }

        private void SearchButton_Click(object sender, RoutedEventArgs e)
        {
            LoadBooks();
        }

        private void SearchTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                LoadBooks();
        }

        private void GenreCheckBox_Click(object sender, RoutedEventArgs e)
        {
            var cb = (CheckBox)sender;
            var genre = (Genre)cb.Tag;
            genre.IsSelected = cb.IsChecked == true;
            LoadBooks();
        }

        private void SortComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!IsLoaded)
                return;
            LoadBooks();
        }

        private void AddToCart_Click(object sender, RoutedEventArgs e)
        {
            var book = (sender as Button)?.Tag as Book;
            if (book == null || !RequireLogin())
                return;

            int userId = Core.CurrentUser.UserID;
            CartItem item = null;

            try
            {
                if (Core.DB.Purchases.Any(p => p.UserID == userId && p.BookID == book.BookID
                                               && p.PaymentStatus == "Оплачено"))
                {
                    MessageBox.Show("Эта книга уже куплена — найдите её в личном кабинете.");
                    return;
                }

                if (Core.DB.CartItems.Any(c => c.UserID == userId && c.BookID == book.BookID))
                {
                    MessageBox.Show("Эта книга уже в корзине.");
                    return;
                }

                item = new CartItem { UserID = userId, BookID = book.BookID, AddedAt = DateTime.Now };
                Core.DB.CartItems.Add(item);
                Core.DB.SaveChanges();

                MessageBox.Show("«" + book.Title + "» добавлена в корзину.");
            }
            catch (Exception ex)
            {
                if (item != null)
                    Core.DB.CartItems.Remove(item); 
                MessageBox.Show("Не удалось добавить в корзину: " + ex.GetBaseException().Message);
            }
        }

        private void Wishlist_Click(object sender, RoutedEventArgs e)
        {
            var book = (sender as Button)?.Tag as Book;
            if (book == null || !RequireLogin())
                return;

            int userId = Core.CurrentUser.UserID;
            ReadingList item = null;

            try
            {
                if (Core.DB.ReadingLists.Any(r => r.UserID == userId && r.BookID == book.BookID))
                {
                    MessageBox.Show("Эта книга уже есть в вашем списке.");
                    return;
                }

                item = new ReadingList
                {
                    UserID = userId,
                    BookID = book.BookID,
                    Status = "В планах",
                    AddedAt = DateTime.Now
                };
                Core.DB.ReadingLists.Add(item);
                Core.DB.SaveChanges();

                MessageBox.Show("«" + book.Title + "» добавлена в список желаний.");
            }
            catch (Exception ex)
            {
                if (item != null)
                    Core.DB.ReadingLists.Remove(item);
                MessageBox.Show("Не удалось добавить в список: " + ex.GetBaseException().Message);
            }
        }

        private static bool RequireLogin()
        {
            if (Core.CurrentUser != null)
                return true;

            MessageBox.Show("Чтобы выполнить это действие, войдите в аккаунт.");
            return false;
        }

        private static bool TryParsePrice(string text, out decimal value)
        {
            return decimal.TryParse(text.Trim().Replace('.', ','), NumberStyles.Number, CultureInfo.GetCultureInfo("ru-RU"), out value);
        }

        private void BookLb_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var book = BookLb.SelectedItem as Book;
            if(book == null) return;
            BookLb.SelectedItem = null;
            NavigationService.Navigate(new Pages.Books.BookCardPage());
        }

        private string _searchText = "";

        public void ApplySearch(string text)
        {
            text = text?.Trim() ?? "";
            if (text == _searchText) return;  

            _searchText = text;
            LoadBooks();
        }
    }
}
