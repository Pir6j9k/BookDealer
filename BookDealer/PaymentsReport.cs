using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Forms.DataVisualization.Charting;
using Excel = Microsoft.Office.Interop.Excel;
using Word = Microsoft.Office.Interop.Word;

namespace BookDealer
{
    public static class PaymentsReport
    {
        public static void SetupChart(Chart chart)
        {
            chart.ChartAreas.Add(new ChartArea("Main"));
            chart.Legends.Add(new Legend("Legend"));
            chart.BackColor = System.Drawing.Color.Transparent;

            chart.Palette = ChartColorPalette.None;
            chart.PaletteCustomColors = new[]
            {
                System.Drawing.Color.FromArgb(185, 47, 32),
                System.Drawing.Color.FromArgb(188, 179, 179),
                System.Drawing.Color.FromArgb(220, 97, 84)
            };
        }

        public static void DrawChart(Chart chart, User user, string chartType)
        {
            chart.Series.Clear();
            chart.Titles.Clear();

            if (user == null || string.IsNullOrEmpty(chartType))
                return;

            List<PaymentRow> payments;
            try
            {
                payments = GetPayments(user.UserID);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось загрузить платежи: " + ex.GetBaseException().Message);
                return;
            }

            if (payments.Count == 0)
            {
                chart.Titles.Add("У пользователя «" + user.DisplayName + "» нет оплаченных платежей");
                return;
            }

            var series = new Series("Платежи")
            {
                ChartType = (SeriesChartType)Enum.Parse(typeof(SeriesChartType), chartType),
                ChartArea = "Main",
                Legend = "Legend",
                IsValueShownAsLabel = true,
                LabelFormat = "N0"
            };

            foreach (var p in payments)
                series.Points.AddXY(p.BookTitle, p.Amount);

            chart.Series.Add(series);
            chart.ChartAreas["Main"].AxisX.Interval = 1;
            chart.ChartAreas["Main"].AxisY.Title = "Сумма, ₽";
            chart.Titles.Add("Платежи пользователя «" + user.DisplayName + "»");
        }

        public static List<PaymentRow> GetPayments(int userId)
        {
            return Core.DB.Purchases.AsNoTracking()
                .Where(p => p.UserID == userId && p.PaymentStatus == "Оплачено")
                .OrderBy(p => p.PurchasedAt)
                .Select(p => new PaymentRow
                {
                    PurchasedAt = p.PurchasedAt,
                    BookTitle = p.Book.Title,
                    PaymentMethod = p.PaymentMethod,
                    Amount = p.Price
                })
                .ToList();
        }

        private static List<UserPayments> GetAllUserPayments()
        {
            var result = new List<UserPayments>();
            foreach (var u in Core.DB.Users.AsNoTracking().OrderBy(u => u.DisplayName).ToList())
            {
                var rows = GetPayments(u.UserID);
                if (rows.Count > 0)
                    result.Add(new UserPayments { UserName = u.DisplayName, Login = u.Login, Rows = rows });
            }
            return result;
        }

        public static void ExportToExcel()
        {
            List<UserPayments> all;
            try
            {
                all = GetAllUserPayments();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось загрузить платежи: " + ex.GetBaseException().Message);
                return;
            }

            if (all.Count == 0)
            {
                MessageBox.Show("Нет платежей для экспорта.");
                return;
            }

            var app = new Excel.Application();
            try
            {
                Excel.Workbook wb = app.Workbooks.Add();

                for (int i = 0; i < all.Count; i++)
                {
                    Excel.Worksheet ws = i == 0
                        ? (Excel.Worksheet)wb.Worksheets[1]
                        : (Excel.Worksheet)wb.Worksheets.Add(After: wb.Worksheets[wb.Worksheets.Count]);
                    ws.Name = SheetName(all[i].Login);

                    ws.Cells[1, 1] = "Дата";
                    ws.Cells[1, 2] = "Книга";
                    ws.Cells[1, 3] = "Способ оплаты";
                    ws.Cells[1, 4] = "Сумма, ₽";
                    ws.Range["A1", "D1"].Font.Bold = true;

                    int row = 2;
                    foreach (var p in all[i].Rows)
                    {
                        ws.Cells[row, 1] = p.PurchasedAt.ToString("dd.MM.yyyy HH:mm");
                        ws.Cells[row, 2] = p.BookTitle;
                        ws.Cells[row, 3] = p.PaymentMethod;
                        ws.Cells[row, 4] = p.Amount;
                        row++;
                    }

                    ws.Cells[row, 3] = "Итого:";
                    ws.Cells[row, 4] = "=SUM(D2:D" + (row - 1) + ")";
                    ws.Range["C" + row, "D" + row].Font.Bold = true;
                    ws.Columns.AutoFit();
                }

                app.Visible = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось выгрузить в Excel: " + ex.Message);
                app.Quit();
            }
        }

        private static string SheetName(string name)
        {
            foreach (char c in new[] { ':', '\\', '/', '?', '*', '[', ']' })
                name = name.Replace(c, '_');
            return name.Length > 31 ? name.Substring(0, 31) : name;
        }

        public static void ExportToWord(Chart chart)
        {
            List<UserPayments> all;
            try
            {
                all = GetAllUserPayments();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось загрузить платежи: " + ex.GetBaseException().Message);
                return;
            }

            if (all.Count == 0)
            {
                MessageBox.Show("Нет платежей для экспорта.");
                return;
            }

            var app = new Word.Application();
            try
            {
                Word.Document doc = app.Documents.Add();
                AddParagraph(doc, "Платежи пользователей", 18, true);

                if (chart.Series.Count > 0)
                {
                    string png = Path.Combine(Path.GetTempPath(), "bookdealer_chart.png");
                    chart.SaveImage(png, ChartImageFormat.Png);
                    doc.InlineShapes.AddPicture(png, false, true, doc.Paragraphs[doc.Paragraphs.Count].Range);
                    AddParagraph(doc, "", 11, false);
                }

                foreach (var up in all)
                {
                    AddParagraph(doc, up.UserName + " (" + up.Login + ")", 14, true);

                    int count = up.Rows.Count;
                    Word.Range range = doc.Paragraphs[doc.Paragraphs.Count].Range;
                    Word.Table table = doc.Tables.Add(range, count + 2, 4);
                    table.Borders.Enable = 1;

                    table.Cell(1, 1).Range.Text = "Дата";
                    table.Cell(1, 2).Range.Text = "Книга";
                    table.Cell(1, 3).Range.Text = "Способ оплаты";
                    table.Cell(1, 4).Range.Text = "Сумма, ₽";
                    table.Rows[1].Range.Font.Bold = 1;

                    for (int i = 0; i < count; i++)
                    {
                        var p = up.Rows[i];
                        table.Cell(i + 2, 1).Range.Text = p.PurchasedAt.ToString("dd.MM.yyyy HH:mm");
                        table.Cell(i + 2, 2).Range.Text = p.BookTitle;
                        table.Cell(i + 2, 3).Range.Text = p.PaymentMethod;
                        table.Cell(i + 2, 4).Range.Text = p.Amount.ToString("N2");
                    }

                    table.Cell(count + 2, 3).Range.Text = "Итого:";
                    table.Cell(count + 2, 4).Range.Text = up.Rows.Sum(r => r.Amount).ToString("N2");
                    table.Rows[count + 2].Range.Font.Bold = 1;

                    AddParagraph(doc, "", 11, false);
                }

                app.Visible = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Не удалось выгрузить в Word: " + ex.Message);
                app.Quit();
            }
        }

        private static void AddParagraph(Word.Document doc, string text, int fontSize, bool bold)
        {
            Word.Paragraph para = doc.Paragraphs.Add();
            para.Range.Text = text;
            para.Range.Font.Size = fontSize;
            para.Range.Font.Bold = bold ? 1 : 0;
            para.Range.InsertParagraphAfter();
        }
    }

    public class PaymentRow
    {
        public DateTime PurchasedAt { get; set; }
        public string BookTitle { get; set; }
        public string PaymentMethod { get; set; }
        public decimal Amount { get; set; }
    }

    public class UserPayments
    {
        public string UserName { get; set; }
        public string Login { get; set; }
        public List<PaymentRow> Rows { get; set; }
    }
}