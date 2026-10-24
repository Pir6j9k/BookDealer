using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace BookDealer
{
    public partial class Book
    {
        public string CoverFullPath
        {
            get
            {
                if (string.IsNullOrWhiteSpace(CoverPath))
                    return null;

                string full = Path.Combine(AppDomain.CurrentDomain.BaseDirectory,
                                           CoverPath.Replace('/', Path.DirectorySeparatorChar));
                return File.Exists(full) ? full : null;
            }
        }
    }

    public partial class Genre
    {
        public bool IsSelected { get; set; } = true;
    }
    public partial class User
    {
        public override string ToString()
        {
            return DisplayName;
        }
    }
}
