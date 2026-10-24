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
    /// Interaction logic for AddOrEditBookWindow.xaml
    /// </summary>
    public partial class AddOrEditBookWindow : Window
    {
        private Book editedBook;

        public AddOrEditBookWindow(Book book = null)
        {
            InitializeComponent();
            editedBook = book;

            var genres = Core.DB.Genres.ToList();
            GenresLb.ItemsSource = genres;

            if (editedBook == null)
            {
                Title = "Добавить книгу";
                return;
            }

            Title = "Изменить книгу";
            TitleTb.Text = editedBook.Title;
            AuthorTb.Text = editedBook.Author;
            PriceTb.Text = editedBook.Price.ToString();

            foreach (Genre g in genres)
                if (editedBook.Genres.Any(x => x.GenreID == g.GenreID))
                    GenresLb.SelectedItems.Add(g);
        }

        private void SaveBtn_Click(object sender, RoutedEventArgs e)
        {
            string title = TitleTb.Text.Trim();
            string author = AuthorTb.Text.Trim();

            if (title == "" || author == "")
            {
                MessageBox.Show("Заполните название и автора!");
                return;
            }

            decimal price;
            if (!decimal.TryParse(PriceTb.Text.Trim(), out price) || price <= 0)
            {
                MessageBox.Show("Введите корректную цену!");
                return;
            }

            if (GenresLb.SelectedItems.Count == 0)
            {
                MessageBox.Show("Выберите хотя бы один жанр!");
                return;
            }

            try
            {
                Book book = editedBook ?? new Book();

                book.Title = title;
                book.Author = author;
                book.Price = price;
                book.IsFree = false;

                book.Genres.Clear();
                foreach (Genre g in GenresLb.SelectedItems)
                    book.Genres.Add(g);

                if (editedBook == null)
                {

                    book.CreatedAt = DateTime.Now;
                    Core.DB.Books.Add(book);
                }

                Core.DB.SaveChanges();
                DialogResult = true;
            }
            catch (Exception ex)
            {
                Exception inner = ex;
                while (inner.InnerException != null)
                    inner = inner.InnerException;
                MessageBox.Show("Ошибка сохранения: " + inner.Message);
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