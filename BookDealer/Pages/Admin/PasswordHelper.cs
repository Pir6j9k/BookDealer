using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace BookDealer
{
    public static class PasswordHelper
    {
        public static string Hash(string pass)
        {
            using (var hash = SHA256.Create())
            {
                return string.Concat(hash.ComputeHash(Encoding.UTF8.GetBytes(pass)).Select(x => x.ToString("X2")));
            }
        }

        public static string Validate(string pass)
        {
            if (pass.Length < 8)
                return "Пароль должен быть минимум 8 символов!";

            bool number = false;
            foreach (char c in pass)
            {
                if (c >= '0' && c <= '9')
                    number = true;
                else if (!((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')))
                    return "Используйте только английскую раскладку!";
            }

            if (!number)
                return "Добавьте хотя бы одну цифру!";

            return null;
        }
    }
}