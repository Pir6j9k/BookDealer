USE [master]
GO
/****** Object:  Database [BookShop]    Script Date: 2026-10-24 10:18:32 PM ******/
CREATE DATABASE [BookShop]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BookShop', FILENAME = N'E:\Program Files\MSSQL17.MSSQLSERVER\MSSQL\DATA\BookShop.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BookShop_log', FILENAME = N'E:\Program Files\MSSQL17.MSSQLSERVER\MSSQL\DATA\BookShop_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [BookShop] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BookShop].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BookShop] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BookShop] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BookShop] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BookShop] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BookShop] SET ARITHABORT OFF 
GO
ALTER DATABASE [BookShop] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BookShop] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BookShop] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BookShop] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BookShop] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BookShop] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BookShop] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BookShop] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BookShop] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BookShop] SET  ENABLE_BROKER 
GO
ALTER DATABASE [BookShop] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BookShop] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BookShop] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BookShop] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BookShop] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BookShop] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BookShop] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BookShop] SET RECOVERY FULL 
GO
ALTER DATABASE [BookShop] SET  MULTI_USER 
GO
ALTER DATABASE [BookShop] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BookShop] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BookShop] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BookShop] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BookShop] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BookShop] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [BookShop] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'BookShop', N'ON'
GO
ALTER DATABASE [BookShop] SET QUERY_STORE = ON
GO
ALTER DATABASE [BookShop] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [BookShop]
GO
/****** Object:  Table [dbo].[Books]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[BookID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Author] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CoverPath] [nvarchar](500) NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED 
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reviews]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reviews](
	[ReviewID] [int] IDENTITY(1,1) NOT NULL,
	[BookID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ReviewText] [nvarchar](max) NULL,
	[Rating] [int] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Reviews] PRIMARY KEY CLUSTERED 
(
	[ReviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_PopularBooks]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_PopularBooks] AS
SELECT b.BookID,
b.Title,
b.Author,
ROUND(AVG(CAST(r.Rating AS FLOAT)), 2) AS AvgRating,
COUNT(r.ReviewID) AS ReviewCount
FROM Books b
LEFT JOIN Reviews r ON b.BookID = r.BookID
GROUP BY b.BookID, b.Title, b.Author
HAVING AVG(CAST(r.Rating AS FLOAT)) >= 7 OR COUNT(r.ReviewID) = 0;
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Login] [nvarchar](50) NOT NULL,
	[PasswordHash] [nvarchar](256) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[RoleID] [int] NOT NULL,
	[IsFrozen] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_FrozenContent]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_FrozenContent] AS
SELECT 'Книга' AS [Тип], b.BookID AS [ID], b.Title AS [Название],
b.Author AS [Автор/Пользователь]
FROM Books b
WHERE b.IsFrozen = 1
UNION ALL
SELECT 'Пользователь', u.UserID, u.DisplayName, u.Email
FROM Users u
WHERE u.IsFrozen = 1;
GO
/****** Object:  Table [dbo].[Complaints]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Complaints](
	[ComplaintID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[BookID] [int] NULL,
	[ReviewID] [int] NULL,
	[Reason] [nvarchar](max) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Complaints] PRIMARY KEY CLUSTERED 
(
	[ComplaintID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Complaints]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Complaints] AS
SELECT c.ComplaintID,
u.Login AS [Жалобщик],
CASE WHEN c.BookID IS NOT NULL THEN N'Книга' ELSE N'Отзыв' END AS [Тип],
COALESCE(b.Title, CAST(c.ReviewID AS NVARCHAR(10))) AS [Объект],
c.Reason,
c.CreatedAt
FROM Complaints c
JOIN Users u ON c.UserID = u.UserID
LEFT JOIN Books b ON c.BookID = b.BookID;
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReadingLists]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReadingLists](
	[ReadingListID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[BookID] [int] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[AddedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_ReadingLists] PRIMARY KEY CLUSTERED 
(
	[ReadingListID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_UserStats]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_UserStats] AS
SELECT u.UserID, u.Login, u.DisplayName,
r.RoleName,
(SELECT COUNT(*) FROM Reviews rv WHERE rv.UserID = u.UserID) AS ReviewsCount,
(SELECT COUNT(*) FROM ReadingLists rl WHERE rl.UserID = u.UserID) AS BooksInList
FROM Users u
JOIN Roles r ON u.RoleID = r.RoleID;
GO
/****** Object:  Table [dbo].[Purchases]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Purchases](
	[PurchaseID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[BookID] [int] NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[PaymentMethod] [nvarchar](50) NOT NULL,
	[PaymentStatus] [nvarchar](20) NOT NULL,
	[TransactionID] [nvarchar](100) NULL,
	[PurchasedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Purchases] PRIMARY KEY CLUSTERED 
(
	[PurchaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_BookSales]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_BookSales] AS
SELECT b.BookID,
b.Title,
b.Author,
COUNT(p.PurchaseID) AS SalesCount,
SUM(p.Price) AS Revenue
FROM Books b
LEFT JOIN Purchases p ON b.BookID = p.BookID AND p.PaymentStatus = N'Оплачено'
GROUP BY b.BookID, b.Title, b.Author;
GO
/****** Object:  View [dbo].[vw_UserLibrary]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_UserLibrary] AS
SELECT p.UserID,
u.DisplayName,
b.BookID,
b.Title,
p.PurchasedAt
FROM Purchases p
JOIN Users u ON p.UserID = u.UserID
JOIN Books b ON p.BookID = b.BookID
WHERE p.PaymentStatus = N'Оплачено';
GO
/****** Object:  Table [dbo].[BookGenres]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookGenres](
	[BookID] [int] NOT NULL,
	[GenreID] [int] NOT NULL,
 CONSTRAINT [PK_BookGenres] PRIMARY KEY CLUSTERED 
(
	[BookID] ASC,
	[GenreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CartItems]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CartItems](
	[CartItemID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[BookID] [int] NOT NULL,
	[AddedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_CartItems] PRIMARY KEY CLUSTERED 
(
	[CartItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Genres]    Script Date: 2026-10-24 10:18:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Genres](
	[GenreID] [int] IDENTITY(1,1) NOT NULL,
	[GenreName] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_Genres] PRIMARY KEY CLUSTERED 
(
	[GenreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (1, 1)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (1, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (2, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (2, 7)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (4, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (5, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (7, 3)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (7, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (8, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (9, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (10, 2)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (10, 5)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (10, 10)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (12, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (12, 8)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (13, 7)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (13, 8)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (17, 1)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (17, 4)
INSERT [dbo].[BookGenres] ([BookID], [GenreID]) VALUES (17, 7)
GO
SET IDENTITY_INSERT [dbo].[Books] ON 

INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (1, N'Книжный вор', N'Маркус Зусак', N'Экипаж грузового корабля получает сигнал бедствия с красной планеты и понимает, что ответ на него может стоить всем жизни.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\MarkusZusak-TheBookThief.jpg', CAST(500.00 AS Decimal(10, 2)), CAST(N'2026-02-01T10:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (2, N'Лисья Нора', N'Нора Сакавич', N'Новгородская земля, XII век. Молодой дружинник ищет пропавший обоз и раскрывает заговор.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\NoraSacavic-TheFoxholeCourt.jpg', CAST(1000.00 AS Decimal(10, 2)), CAST(N'2026-02-20T12:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (4, N'Джейн Эйр', N'Шарлотта Бронте', N'Первая книга цикла о девочке, которая слышит деревья и оказывается наследницей древнего ордена лесных стражей.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\SharloteBronte-JaneAir.jpg', CAST(250.00 AS Decimal(10, 2)), CAST(N'2026-02-05T11:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (5, N'Вино из одуванчиков', N'Рэй Бредбери', N'Уютное фэнтези о мастере книжных переплётов, к которому приходит дракон с необычным заказом.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\RayBradbury-DandelionWine.jpg', CAST(429.00 AS Decimal(10, 2)), CAST(N'2026-04-01T09:30:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (7, N'Смерть на Ниле', N'Агата Кристи', N'Следователь уголовного розыска расследует серию загадочных происшествий на ночных мостах Петербурга.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\AgataKristi-DeathOnNil.jpg', CAST(379.00 AS Decimal(10, 2)), CAST(N'2026-03-01T13:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (8, N'Ночь в Лиссабоне', N'Эрих Мария Ремарк', N'Букинист приглашает частного детектива найти утерянную рукопись, за которой охотятся коллекционеры.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\ErichMariaRemark-TheNightInLisabon.jpg', CAST(329.00 AS Decimal(10, 2)), CAST(N'2026-06-15T16:20:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (9, N'Аэропорт', N'Артур Хейли', N'Понятное введение в алгоритмы и структуры данных с примерами из повседневной жизни.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\ArthurHailey-Airport.jpg', CAST(400.00 AS Decimal(10, 2)), CAST(N'2026-03-20T10:45:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (10, N'Цирцея', N'Мадлен Миллер', N'Практическое руководство по построению полезных привычек и отказу от вредных.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\MadlenMiller-Circe.jpg', CAST(459.00 AS Decimal(10, 2)), CAST(N'2026-05-25T18:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (12, N'Дом на краю ночи', N'Кэтрин Бэннер', N'Мистический триллер о семье, переехавшей в старый дом, где по ночам слышны шаги.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\KatrineBenner-TheHouseAtTheEdgeOfNight.jpg', CAST(700.00 AS Decimal(10, 2)), CAST(N'2026-03-01T21:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (13, N'Маленькая жизнь', N'Ханья Янагихара', N'Секретная система быстрого обогащения, о которой молчат банки.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\HanyaYanagihara-ALittleLife.jpg', CAST(1999.00 AS Decimal(10, 2)), CAST(N'2026-03-05T12:00:00.000' AS DateTime))
INSERT [dbo].[Books] ([BookID], [Title], [Author], [Description], [CoverPath], [Price], [CreatedAt]) VALUES (17, N'Маленькия принц', N'Антуан де Сент-Экзюпери', N'Экипаж грузового корабля получает сигнал бедствия с красной планеты и понимает, что ответ на него может стоить всем жизни.', N'C:\Users\hasul\source\repos\BookDealer\BookDealer\Resourses\Images\AntuanDeSentExupery-ALittlePrince.jpg', CAST(500.00 AS Decimal(10, 2)), CAST(N'2026-02-01T10:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Books] OFF
GO
SET IDENTITY_INSERT [dbo].[CartItems] ON 

INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (1, 3, 5, CAST(N'2026-10-10T19:20:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (2, 3, 7, CAST(N'2026-10-12T20:05:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (5, 5, 1, CAST(N'2026-09-28T09:15:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (6, 5, 9, CAST(N'2026-10-15T18:30:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (7, 6, 5, CAST(N'2026-10-01T22:00:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (8, 6, 9, CAST(N'2026-10-16T08:45:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (9, 7, 1, CAST(N'2026-10-08T13:25:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (10, 7, 9, CAST(N'2026-10-17T19:50:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (11, 8, 5, CAST(N'2026-09-30T16:10:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (12, 8, 7, CAST(N'2026-10-13T20:35:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (13, 9, 5, CAST(N'2026-10-11T17:00:00.000' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (16, 22, 4, CAST(N'2026-10-24T20:01:24.343' AS DateTime))
INSERT [dbo].[CartItems] ([CartItemID], [UserID], [BookID], [AddedAt]) VALUES (17, 22, 13, CAST(N'2026-10-24T20:01:33.360' AS DateTime))
SET IDENTITY_INSERT [dbo].[CartItems] OFF
GO
SET IDENTITY_INSERT [dbo].[Complaints] ON 

INSERT [dbo].[Complaints] ([ComplaintID], [UserID], [BookID], [ReviewID], [Reason], [CreatedAt]) VALUES (2, 6, 13, NULL, N'Название вводит в заблуждение: внутри только реклама платного курса.', CAST(N'2026-03-25T14:30:00.000' AS DateTime))
INSERT [dbo].[Complaints] ([ComplaintID], [UserID], [BookID], [ReviewID], [Reason], [CreatedAt]) VALUES (4, 7, 13, NULL, N'Текст книги скопирован с чужого сайта, признаки плагиата.', CAST(N'2026-03-28T19:45:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Complaints] OFF
GO
SET IDENTITY_INSERT [dbo].[Genres] ON 

INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (1, N'Фантастика', N'Произведения о будущем, космосе, технологиях и альтернативных мирах')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (2, N'Фэнтези', N'Вымышленные миры, магия, мифические существа и эпические сражения')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (3, N'Детектив', N'Расследования преступлений, загадки и поиск виновного')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (4, N'Роман', N'Прозаические произведения о судьбах героев и отношениях между людьми')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (5, N'Исторический роман', N'Сюжеты, действие которых разворачивается в реальных исторических эпохах')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (6, N'Научно-популярная', N'Доступное изложение научных знаний и современных технологий')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (7, N'Приключения', N'Путешествия, испытания и опасные ситуации')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (8, N'Ужасы', N'Мистика, страх и напряжённая атмосфера')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (9, N'Поэзия', N'Стихотворные произведения и поэтические сборники')
INSERT [dbo].[Genres] ([GenreID], [GenreName], [Description]) VALUES (10, N'Саморазвитие', N'Книги о привычках, продуктивности, карьере и личностном росте')
SET IDENTITY_INSERT [dbo].[Genres] OFF
GO
SET IDENTITY_INSERT [dbo].[Purchases] ON 

INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (1, 3, 1, CAST(349.00 AS Decimal(10, 2)), N'Банковская карта', N'Оплачено', N'TXN-20260302-0001', CAST(N'2026-03-02T18:20:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (2, 3, 4, CAST(399.00 AS Decimal(10, 2)), N'СБП', N'Оплачено', N'TXN-20260303-0002', CAST(N'2026-03-03T12:05:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (3, 3, 9, CAST(549.00 AS Decimal(10, 2)), N'Банковская карта', N'Оплачено', N'TXN-20260401-0003', CAST(N'2026-04-01T20:40:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (6, 5, 4, CAST(399.00 AS Decimal(10, 2)), N'SberPay', N'Оплачено', N'TXN-20260310-0006', CAST(N'2026-03-10T14:00:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (7, 5, 5, CAST(429.00 AS Decimal(10, 2)), N'SberPay', N'Оплачено', N'TXN-20260410-0007', CAST(N'2026-04-10T19:25:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (8, 5, 10, CAST(459.00 AS Decimal(10, 2)), N'СБП', N'Оплачено', N'TXN-20260601-0008', CAST(N'2026-06-01T08:50:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (9, 6, 2, CAST(299.00 AS Decimal(10, 2)), N'Банковская карта', N'Оплачено', N'TXN-20260308-0009', CAST(N'2026-03-08T22:15:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (10, 6, 7, CAST(379.00 AS Decimal(10, 2)), N'Банковская карта', N'Оплачено', N'TXN-20260320-0010', CAST(N'2026-03-20T17:45:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (11, 6, 8, CAST(329.00 AS Decimal(10, 2)), N'СБП', N'Оплачено', N'TXN-20260620-0011', CAST(N'2026-06-20T11:10:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (12, 7, 5, CAST(429.00 AS Decimal(10, 2)), N'ЮMoney', N'Оплачено', N'TXN-20260415-0012', CAST(N'2026-04-15T15:35:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (13, 7, 10, CAST(459.00 AS Decimal(10, 2)), N'Банковская карта', N'Ожидает оплаты', NULL, CAST(N'2026-09-22T10:00:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (14, 8, 9, CAST(549.00 AS Decimal(10, 2)), N'SberPay', N'Оплачено', N'TXN-20260405-0014', CAST(N'2026-04-05T13:20:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (15, 8, 1, CAST(349.00 AS Decimal(10, 2)), N'Банковская карта', N'Возврат', N'TXN-20260402-0015', CAST(N'2026-04-02T16:00:00.000' AS DateTime))
INSERT [dbo].[Purchases] ([PurchaseID], [UserID], [BookID], [Price], [PaymentMethod], [PaymentStatus], [TransactionID], [PurchasedAt]) VALUES (16, 9, 4, CAST(399.00 AS Decimal(10, 2)), N'СБП', N'Оплачено', N'TXN-20260420-0016', CAST(N'2026-04-20T20:30:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Purchases] OFF
GO
SET IDENTITY_INSERT [dbo].[ReadingLists] ON 

INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (1, 3, 1, N'Прочитано', CAST(N'2026-03-02T18:30:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (2, 3, 4, N'Прочитано', CAST(N'2026-03-03T12:10:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (3, 3, 9, N'Читаю', CAST(N'2026-04-01T20:45:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (5, 3, 5, N'В планах', CAST(N'2026-05-02T10:00:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (9, 5, 4, N'Прочитано', CAST(N'2026-03-10T14:05:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (10, 5, 5, N'Читаю', CAST(N'2026-04-10T19:30:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (11, 5, 10, N'Заброшено', CAST(N'2026-06-01T08:55:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (13, 6, 2, N'Прочитано', CAST(N'2026-03-08T22:20:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (14, 6, 7, N'Прочитано', CAST(N'2026-03-20T17:50:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (15, 6, 8, N'Читаю', CAST(N'2026-06-20T11:15:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (16, 7, 5, N'Читаю', CAST(N'2026-04-15T15:40:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (18, 7, 10, N'В планах', CAST(N'2026-09-22T10:05:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (19, 8, 9, N'Читаю', CAST(N'2026-04-05T13:25:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (21, 9, 4, N'Прочитано', CAST(N'2026-04-20T20:35:00.000' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (27, 22, 4, N'В планах', CAST(N'2026-10-24T20:01:19.217' AS DateTime))
INSERT [dbo].[ReadingLists] ([ReadingListID], [UserID], [BookID], [Status], [AddedAt]) VALUES (28, 22, 9, N'В планах', CAST(N'2026-10-24T20:01:29.800' AS DateTime))
SET IDENTITY_INSERT [dbo].[ReadingLists] OFF
GO
SET IDENTITY_INSERT [dbo].[Reviews] ON 

INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (1, 1, 3, N'Отличная космическая история, читается на одном дыхании. Концовка неожиданная.', 9, CAST(N'2026-03-10T21:00:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (3, 4, 3, N'Лучшее фэнтези, что я читала за последний год. Жду продолжения!', 10, CAST(N'2026-03-12T22:10:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (4, 4, 5, N'Тёплый и добрый мир, очень живые персонажи.', 9, CAST(N'2026-03-18T20:00:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (5, 4, 9, N'Понравилось, но хотелось бы больше приключений и меньше описаний.', 7, CAST(N'2026-04-28T18:40:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (6, 5, 5, N'Необычная идея и приятный юмор.', 8, CAST(N'2026-04-25T21:30:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (7, 5, 7, N'Очень уютная книга, идеально для вечера с чаем.', 9, CAST(N'2026-04-30T22:00:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (9, 7, 6, N'Средне: интрига есть, но развязка слабоватая.', 6, CAST(N'2026-03-28T20:20:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (10, 8, 6, N'Отличная загадка и интересные герои-коллекционеры.', 8, CAST(N'2026-07-01T17:00:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (11, 9, 3, N'Наконец-то алгоритмы объяснены простым языком. Рекомендую всем начинающим.', 10, CAST(N'2026-04-10T19:00:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (12, 9, 8, N'Много полезных примеров, пригодилось для учёбы.', 9, CAST(N'2026-04-12T20:45:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (13, 10, 5, N'Ничего нового, много воды.', 5, CAST(N'2026-06-10T09:30:00.000' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewID], [BookID], [UserID], [ReviewText], [Rating], [CreatedAt]) VALUES (14, 2, 6, N'Интересная эпоха и убедительные детали быта.', 8, CAST(N'2026-03-15T22:50:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Reviews] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([RoleID], [RoleName]) VALUES (1, N'Администратор')
INSERT [dbo].[Roles] ([RoleID], [RoleName]) VALUES (3, N'Гость')
INSERT [dbo].[Roles] ([RoleID], [RoleName]) VALUES (2, N'Покупатель')
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (1, N'admin', N'3EB3FE66B31E3B4D10FA70B5CAD49C7112294AF6AE4E476A1C405155D45AA121', N'admin@bookshop.ru', N'Администратор', 1, 0, CAST(N'2026-01-10T09:00:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (2, N'admin_olga', N'3EB3FE66B31E3B4D10FA70B5CAD49C7112294AF6AE4E476A1C405155D45AA121', N'olga.admin@bookshop.ru', N'Ольга Ермакова', 1, 0, CAST(N'2026-01-10T09:05:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (3, N'anna_k', N'CBB2068F41AB9F2BF1D2C5D0DDB02C6B0B7AAFA28EED52BC1C48D7873C3934DD', N'anna.volkova@mail.ru', N'Анна Волкова', 2, 0, CAST(N'2026-02-14T10:05:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (5, N'elena_s', N'93B4ED13622FA264C0AE58F131765CB85D0F9905E82024AE74A755895B575701', N'elena.smirnova@yandex.ru', N'Елена Смирнова', 2, 0, CAST(N'2026-03-01T08:55:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (6, N'maxim_p', N'CBB2068F41AB9F2BF1D2C5D0DDB02C6B0B7AAFA28EED52BC1C48D7873C3934DD', N'maxim.popov@mail.ru', N'Максим Попов', 2, 0, CAST(N'2026-03-05T21:15:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (7, N'olga', N'CBB2068F41AB9F2BF1D2C5D0DDB02C6B0B7AAFA28EED52BC1C48D7873C3934DD', N'olga.titova@gmail.com', N'Ольга Титова', 1, 0, CAST(N'2026-03-12T13:30:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (8, N'ilya_v', N'CBB2068F41AB9F2BF1D2C5D0DDB02C6B0B7AAFA28EED52BC1C48D7873C3934DD', N'ilya.vasiliev@yandex.ru', N'Илья Васильев', 2, 0, CAST(N'2026-03-18T17:25:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (9, N'ekaterina_n', N'5A99A99E930FDF6359161A73BAFDAD4665038EE93024D8EB49A45365B6C5419A', N'ekaterina.novikova@mail.ru', N'Екатерина Новикова', 2, 0, CAST(N'2026-04-02T09:45:00.000' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (22, N'has', N'A4DF506FD00683F82DAC112BAEFCD7FFA24493F917A1130B4ECDEAE008EC336D', N'has@', N'has', 2, 0, CAST(N'2026-10-24T20:00:39.860' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Login], [PasswordHash], [Email], [DisplayName], [RoleID], [IsFrozen], [CreatedAt]) VALUES (23, N'nune77', N'A3BB429DC29B095C760164CBD8B469E6D7A0F842BB01E12F99BD5202679111EE', N'pnune77@mail.ru', N'петросян нунэ', 2, 0, CAST(N'2026-10-24T21:29:31.217' AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
/****** Object:  Index [UQ_CartItems_UserBook]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[CartItems] ADD  CONSTRAINT [UQ_CartItems_UserBook] UNIQUE NONCLUSTERED 
(
	[UserID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Genres_Name]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[Genres] ADD  CONSTRAINT [UQ_Genres_Name] UNIQUE NONCLUSTERED 
(
	[GenreName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Purchases_UserBook]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[Purchases] ADD  CONSTRAINT [UQ_Purchases_UserBook] UNIQUE NONCLUSTERED 
(
	[UserID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_ReadingLists_UserBook]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[ReadingLists] ADD  CONSTRAINT [UQ_ReadingLists_UserBook] UNIQUE NONCLUSTERED 
(
	[UserID] ASC,
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Roles_Name]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[Roles] ADD  CONSTRAINT [UQ_Roles_Name] UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Users_Email]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [UQ_Users_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Users_Login]    Script Date: 2026-10-24 10:18:33 PM ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [UQ_Users_Login] UNIQUE NONCLUSTERED 
(
	[Login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Books] ADD  CONSTRAINT [DF_Books_Price]  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[Books] ADD  CONSTRAINT [DF_Books_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CartItems] ADD  CONSTRAINT [DF_CartItems_AddedAt]  DEFAULT (getdate()) FOR [AddedAt]
GO
ALTER TABLE [dbo].[Complaints] ADD  CONSTRAINT [DF_Complaints_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Purchases] ADD  CONSTRAINT [DF_Purchases_PaymentStatus]  DEFAULT (N'Ожидает оплаты') FOR [PaymentStatus]
GO
ALTER TABLE [dbo].[Purchases] ADD  CONSTRAINT [DF_Purchases_PurchasedAt]  DEFAULT (getdate()) FOR [PurchasedAt]
GO
ALTER TABLE [dbo].[ReadingLists] ADD  CONSTRAINT [DF_ReadingLists_AddedAt]  DEFAULT (getdate()) FOR [AddedAt]
GO
ALTER TABLE [dbo].[Reviews] ADD  CONSTRAINT [DF_Reviews_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsFrozen]  DEFAULT ((0)) FOR [IsFrozen]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BookGenres]  WITH CHECK ADD  CONSTRAINT [FK_BookGenres_Book] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[BookGenres] CHECK CONSTRAINT [FK_BookGenres_Book]
GO
ALTER TABLE [dbo].[BookGenres]  WITH CHECK ADD  CONSTRAINT [FK_BookGenres_Genre] FOREIGN KEY([GenreID])
REFERENCES [dbo].[Genres] ([GenreID])
GO
ALTER TABLE [dbo].[BookGenres] CHECK CONSTRAINT [FK_BookGenres_Genre]
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD  CONSTRAINT [FK_CartItems_Book] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[CartItems] CHECK CONSTRAINT [FK_CartItems_Book]
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD  CONSTRAINT [FK_CartItems_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[CartItems] CHECK CONSTRAINT [FK_CartItems_User]
GO
ALTER TABLE [dbo].[Complaints]  WITH CHECK ADD  CONSTRAINT [FK_Complaints_Book] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[Complaints] CHECK CONSTRAINT [FK_Complaints_Book]
GO
ALTER TABLE [dbo].[Complaints]  WITH CHECK ADD  CONSTRAINT [FK_Complaints_Review] FOREIGN KEY([ReviewID])
REFERENCES [dbo].[Reviews] ([ReviewID])
GO
ALTER TABLE [dbo].[Complaints] CHECK CONSTRAINT [FK_Complaints_Review]
GO
ALTER TABLE [dbo].[Complaints]  WITH CHECK ADD  CONSTRAINT [FK_Complaints_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Complaints] CHECK CONSTRAINT [FK_Complaints_User]
GO
ALTER TABLE [dbo].[Purchases]  WITH CHECK ADD  CONSTRAINT [FK_Purchases_Book] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[Purchases] CHECK CONSTRAINT [FK_Purchases_Book]
GO
ALTER TABLE [dbo].[Purchases]  WITH CHECK ADD  CONSTRAINT [FK_Purchases_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Purchases] CHECK CONSTRAINT [FK_Purchases_User]
GO
ALTER TABLE [dbo].[ReadingLists]  WITH CHECK ADD  CONSTRAINT [FK_ReadingLists_Book] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[ReadingLists] CHECK CONSTRAINT [FK_ReadingLists_Book]
GO
ALTER TABLE [dbo].[ReadingLists]  WITH CHECK ADD  CONSTRAINT [FK_ReadingLists_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[ReadingLists] CHECK CONSTRAINT [FK_ReadingLists_User]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_Book] FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Book]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_User]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Roles] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Roles] ([RoleID])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Roles]
GO
ALTER TABLE [dbo].[Complaints]  WITH CHECK ADD  CONSTRAINT [CK_Complaints_Target] CHECK  (([BookID] IS NOT NULL AND [ReviewID] IS NULL OR [BookID] IS NULL AND [ReviewID] IS NOT NULL))
GO
ALTER TABLE [dbo].[Complaints] CHECK CONSTRAINT [CK_Complaints_Target]
GO
ALTER TABLE [dbo].[Purchases]  WITH CHECK ADD  CONSTRAINT [CK_Purchases_PaymentStatus] CHECK  (([PaymentStatus]=N'Возврат' OR [PaymentStatus]=N'Отменено' OR [PaymentStatus]=N'Оплачено' OR [PaymentStatus]=N'Ожидает оплаты'))
GO
ALTER TABLE [dbo].[Purchases] CHECK CONSTRAINT [CK_Purchases_PaymentStatus]
GO
ALTER TABLE [dbo].[Purchases]  WITH CHECK ADD  CONSTRAINT [CK_Purchases_Price] CHECK  (([Price]>=(0)))
GO
ALTER TABLE [dbo].[Purchases] CHECK CONSTRAINT [CK_Purchases_Price]
GO
ALTER TABLE [dbo].[ReadingLists]  WITH CHECK ADD  CONSTRAINT [CK_ReadingLists_Status] CHECK  (([Status]=N'Прочитано' OR [Status]=N'Читаю' OR [Status]=N'В планах' OR [Status]=N'Заброшено'))
GO
ALTER TABLE [dbo].[ReadingLists] CHECK CONSTRAINT [CK_ReadingLists_Status]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [CK_Reviews_Rating] CHECK  (([Rating]>=(1) AND [Rating]<=(10)))
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [CK_Reviews_Rating]
GO
USE [master]
GO
ALTER DATABASE [BookShop] SET  READ_WRITE 
GO
