-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 16, 2025 at 10:24 AM
-- Server version: 8.0.36
-- PHP Version: 8.3.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `prediksi_air`
--

-- --------------------------------------------------------

--
-- Table structure for table `botol_default`
--

CREATE TABLE `botol_default` (
  `id` int NOT NULL,
  `nama` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `ukuran` float NOT NULL COMMENT 'Ukuran dalam liter',
  `warna` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `jenis` enum('botol','gelas','mug','lainnya') COLLATE utf8mb4_general_ci NOT NULL,
  `gambar` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Path ke gambar botol/gelas'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `botol_default`
--

INSERT INTO `botol_default` (`id`, `nama`, `ukuran`, `warna`, `jenis`, `gambar`) VALUES
(1, 'Aqua Gelas', 0.24, '#BBDEFB', 'gelas', 'assets/images/bottles/aqua_gelas.png'),
(2, 'Aqua Botol Kecil', 0.33, '#2196F3', 'botol', 'assets/images/bottles/aqua_kecil.png'),
(3, 'Aqua Botol Sedang', 0.6, '#1976D2', 'botol', 'assets/images/bottles/aqua_sedang.png'),
(4, 'Aqua Botol Besar', 1.5, '#0D47A1', 'botol', 'assets/images/bottles/aqua_besar.png'),
(5, 'Tumbler Kecil', 0.5, '#4CAF50', 'botol', 'assets/images/bottles/tumbler_kecil.png'),
(6, 'Tumbler Sedang', 0.75, '#388E3C', 'botol', 'assets/images/bottles/tumbler_sedang.png'),
(7, 'Tumbler Besar', 1, '#1B5E20', 'botol', 'assets/images/bottles/tumbler_besar.png'),
(8, 'Gelas Standar', 0.25, '#FFC107', 'gelas', 'assets/images/bottles/gelas_standar.png'),
(9, 'Mug Kopi', 0.35, '#795548', 'mug', 'assets/images/bottles/mug_kopi.png');

-- --------------------------------------------------------

--
-- Table structure for table `botol_kustom`
--

CREATE TABLE `botol_kustom` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `nama` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `ukuran` float NOT NULL COMMENT 'Ukuran dalam liter',
  `warna` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '#2196F3',
  `jenis` enum('botol','gelas','mug','lainnya') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'botol',
  `is_favorite` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `botol_kustom`
--

INSERT INTO `botol_kustom` (`id`, `user_id`, `nama`, `ukuran`, `warna`, `jenis`, `is_favorite`, `created_at`) VALUES
(1, 9, 'Botol Bedul', 1, '#4caf50', 'botol', 1, '2025-06-06 15:24:05'),
(2, 11, 'Botol Minum Bedul', 1, '#2196f3', 'botol', 0, '2025-06-06 23:45:05'),
(3, 11, 'Tumbler Bedul yang besar', 2.5, '#2196f3', 'botol', 0, '2025-06-07 02:45:29'),
(4, 13, 'Botol Gelas Aku', 1, '#2196f3', 'botol', 0, '2025-06-09 08:22:59'),
(5, 13, 'bedull', 2, '#e91e63', 'botol', 0, '2025-06-09 09:02:40'),
(6, 11, 'tumbler kalcer arel', 2, '#03a9f4', 'botol', 1, '2025-06-09 20:58:09'),
(7, 17, 'Tumbler bedul', 2, '#03a9f4', 'botol', 0, '2025-06-12 19:16:55');

-- --------------------------------------------------------

--
-- Table structure for table `detail_user`
--

CREATE TABLE `detail_user` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `usia` int NOT NULL,
  `berat_badan` float NOT NULL,
  `tinggi_badan` float NOT NULL,
  `jenis_kelamin` enum('L','P') COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_user`
--

INSERT INTO `detail_user` (`id`, `user_id`, `nama`, `usia`, `berat_badan`, `tinggi_badan`, `jenis_kelamin`) VALUES
(1, 1, 'Dina', 23, 55, 165, 'P'),
(2, 2, 'Abdul', 21, 63, 173, 'L'),
(3, 3, 'Abdul', 21, 64, 175, 'L'),
(4, 4, 'Abdul', 21, 64, 175, 'L'),
(5, 6, 'revoer bedul', 22, 64, 175, 'L'),
(6, 7, 'aja aja', 16, 49, 162, 'P'),
(7, 8, 'Abdul Latif', 22, 64, 174, 'L'),
(8, 9, 'Pak Remon', 41, 75, 162, 'L'),
(9, 11, 'Bedulll', 22, 66, 173, 'L'),
(10, 12, 'Abdul Latif', 22, 66, 173, 'L'),
(11, 13, 'bedull', 22, 63, 175, 'L'),
(12, 14, 'akun baru', 21, 63, 175, 'L'),
(13, 15, 'labdul', 22, 67, 176, 'L'),
(14, 16, 'pitok', 22, 63, 165, 'L'),
(15, 17, 'Akun Test', 22, 64, 175, 'L'),
(16, 18, 'Abdul Latif', 21, 67, 175, 'L'),
(17, 19, 'Test User', 25, 70, 175, 'L'),
(18, 20, 'Test User', 25, 70, 175, 'L'),
(19, 21, 'Security Test User', 25, 70, 175, 'L'),
(20, 22, 'Security Test User', 25, 70, 175, 'L'),
(21, 23, 'Security Test User', 25, 70, 175, 'L'),
(22, 24, 'Security Test User', 25, 70, 175, 'L'),
(23, 25, 'Security Test User', 25, 70, 175, 'L'),
(24, 26, 'Test User', 25, 70, 175, 'L'),
(25, 27, 'Test User', 25, 70, 175, 'L'),
(26, 28, 'Test User', 25, 70, 175, 'L'),
(27, 29, 'Test User', 25, 70, 175, 'L'),
(28, 30, 'Test User', 25, 70, 175, 'L'),
(29, 31, 'Test User', 25, 70, 175, 'L'),
(30, 32, 'Test User', 25, 70, 175, 'L'),
(31, 33, 'Test User', 25, 70, 175, 'L'),
(32, 34, 'Test User', 25, 70, 175, 'L'),
(33, 35, 'Test User', 25, 70, 175, 'L'),
(34, 36, 'Test User', 25, 70, 175, 'L'),
(35, 37, 'Test User', 25, 70, 175, 'L'),
(36, 38, 'Test User', 25, 70, 175, 'L'),
(37, 39, 'Test User', 25, 70, 175, 'L'),
(38, 40, 'Test User', 25, 70, 175, 'L'),
(39, 41, 'Test User', 25, 70, 175, 'L'),
(40, 42, 'Test User', 25, 70, 175, 'L'),
(41, 43, 'Test User', 25, 70, 175, 'L'),
(42, 44, 'Test User', 25, 70, 175, 'L'),
(43, 45, 'Test User', 25, 70, 175, 'L'),
(44, 46, 'Test User', 25, 70, 175, 'L'),
(45, 47, 'Test User', 25, 70, 175, 'L'),
(46, 48, 'Test User', 25, 70, 175, 'L'),
(47, 49, 'Test User', 25, 70, 175, 'L'),
(48, 50, 'Test User', 25, 70, 175, 'L'),
(49, 51, 'Test User', 25, 70, 175, 'L'),
(50, 52, 'Test User', 25, 70, 175, 'L'),
(51, 53, 'Pengguna Tes', 25, 70, 175, 'L'),
(52, 54, 'Pengguna Tes', 25, 70, 175, 'L'),
(53, 55, 'Pengguna Tes', 25, 70, 175, 'L');

-- --------------------------------------------------------

--
-- Table structure for table `kompetisi`
--

CREATE TABLE `kompetisi` (
  `id` int NOT NULL,
  `nama` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `deskripsi` text COLLATE utf8mb4_general_ci,
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date NOT NULL,
  `status` enum('upcoming','ongoing','completed') COLLATE utf8mb4_general_ci NOT NULL,
  `tipe` enum('harian','mingguan','bulanan','kustom') COLLATE utf8mb4_general_ci NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kompetisi`
--

INSERT INTO `kompetisi` (`id`, `nama`, `deskripsi`, `tanggal_mulai`, `tanggal_selesai`, `status`, `tipe`, `created_by`, `created_at`) VALUES
(1, 'Lomba Minum Air Rutin 30 Hari', 'ayo', '2025-07-07', '2025-08-07', 'ongoing', 'bulanan', 11, '2025-06-07 09:08:23'),
(2, 'Seminggu Full Streak', '', '2025-06-12', '2025-06-19', 'ongoing', 'mingguan', 11, '2025-06-12 08:30:11'),
(3, 'Challenge minum air sebulan ', '', '2025-08-13', '2025-08-15', 'upcoming', 'bulanan', 11, '2025-06-13 02:19:01');

-- --------------------------------------------------------

--
-- Table structure for table `kompetisi_konsumsi`
--

CREATE TABLE `kompetisi_konsumsi` (
  `id` int NOT NULL,
  `kompetisi_id` int NOT NULL,
  `user_id` int NOT NULL,
  `jumlah` float NOT NULL,
  `tanggal` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kompetisi_konsumsi`
--

INSERT INTO `kompetisi_konsumsi` (`id`, `kompetisi_id`, `user_id`, `jumlah`, `tanggal`) VALUES
(5, 2, 11, 2, '2025-07-15 15:19:44'),
(6, 2, 11, 0.5, '2025-07-15 15:21:33');

-- --------------------------------------------------------

--
-- Table structure for table `kompetisi_peserta`
--

CREATE TABLE `kompetisi_peserta` (
  `id` int NOT NULL,
  `kompetisi_id` int NOT NULL,
  `user_id` int NOT NULL,
  `target_harian` float NOT NULL,
  `total_konsumsi` float DEFAULT '0',
  `streak_current` int DEFAULT '0',
  `streak_best` int DEFAULT '0',
  `peringkat` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kompetisi_peserta`
--

INSERT INTO `kompetisi_peserta` (`id`, `kompetisi_id`, `user_id`, `target_harian`, `total_konsumsi`, `streak_current`, `streak_best`, `peringkat`) VALUES
(1, 1, 9, 2, 0, 0, 0, 0),
(2, 1, 11, 2, 0, 0, 0, 0),
(3, 2, 11, 2, 2.5, 1, 0, 1),
(4, 2, 9, 2, 0, 0, 0, 3),
(5, 2, 3, 2, 0, 0, 0, 2),
(6, 2, 14, 2, 0, 0, 0, 4),
(7, 3, 3, 2, 0, 0, 0, 0),
(8, 3, 9, 2, 0, 0, 0, 0),
(9, 3, 11, 2, 0, 0, 0, 0),
(10, 3, 14, 2, 0, 0, 0, 0),
(11, 3, 16, 2, 0, 0, 0, 0),
(12, 3, 17, 2, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `pencapaian`
--

CREATE TABLE `pencapaian` (
  `id` int NOT NULL,
  `judul` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `deskripsi` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `nama_ikon` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `nilai_target` int NOT NULL,
  `jenis_pencapaian` enum('total_konsumsi','streak_harian','minggu_sempurna','jumlah_harian') COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pencapaian`
--

INSERT INTO `pencapaian` (`id`, `judul`, `deskripsi`, `nama_ikon`, `nilai_target`, `jenis_pencapaian`) VALUES
(1, 'Tetes Pertama', 'Melakukan pencatatan konsumsi air pertama', 'water_drop', 1, 'total_konsumsi'),
(2, 'Pemula Hidrasi', 'Konsumsi total 10L air', 'water_glass', 10, 'total_konsumsi'),
(3, 'Hidrasi Reguler', 'Konsumsi total 25L air', 'water_bottle', 25, 'total_konsumsi'),
(4, 'Ahli Hidrasi', 'Konsumsi total 50L air', 'water_bottle_full', 50, 'total_konsumsi'),
(5, 'Master Hidrasi', 'Konsumsi total 100L air', 'water_waves', 100, 'total_konsumsi'),
(6, 'Hydration Expert', 'Konsumsi total 250L air', 'water_trophy', 250, 'total_konsumsi'),
(7, 'Pemula Konsisten', 'Mencatat konsumsi air 3 hari berturut-turut', 'streak3', 3, 'streak_harian'),
(8, 'Konsisten Mingguan', 'Mencatat konsumsi air 7 hari berturut-turut', 'streak7', 7, 'streak_harian'),
(9, 'Konsisten 2 Minggu', 'Mencatat konsumsi air 14 hari berturut-turut', 'streak14', 14, 'streak_harian'),
(10, 'Konsisten Bulanan', 'Mencatat konsumsi air 30 hari berturut-turut', 'streak30', 30, 'streak_harian'),
(11, 'Konsistensi Tingkat Dewa', 'Mencatat konsumsi air 90 hari berturut-turut', 'streak90', 90, 'streak_harian'),
(12, 'Minggu Pertama', 'Menyelesaikan satu minggu dengan konsumsi air sesuai target setiap hari', 'perfect_week1', 1, 'minggu_sempurna'),
(13, 'Bulan Sempurna', 'Menyelesaikan empat minggu dengan konsumsi air sesuai target setiap hari', 'perfect_month', 4, 'minggu_sempurna'),
(14, 'Tetesan Awal', 'Konsumsi 1L air dalam satu hari', 'drop_small', 1, 'jumlah_harian'),
(15, 'Hidrasi Standar', 'Konsumsi 2L air dalam satu hari', 'drop_medium', 2, 'jumlah_harian'),
(16, 'Hidrasi Plus', 'Konsumsi 3L air dalam satu hari', 'drop_large', 3, 'jumlah_harian'),
(17, 'Super Hidrasi', 'Konsumsi 4L air dalam satu hari', 'drop_xlarge', 4, 'jumlah_harian'),
(18, 'Hidrasi Ultra', 'Konsumsi 5L air dalam satu hari', 'waterfall', 5, 'jumlah_harian');

-- --------------------------------------------------------

--
-- Table structure for table `pencapaian_pengguna`
--

CREATE TABLE `pencapaian_pengguna` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `pencapaian_id` int NOT NULL,
  `terbuka` tinyint(1) DEFAULT '0',
  `progres` float DEFAULT '0',
  `tanggal_terbuka` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pencapaian_pengguna`
--

INSERT INTO `pencapaian_pengguna` (`id`, `user_id`, `pencapaian_id`, `terbuka`, `progres`, `tanggal_terbuka`) VALUES
(55, 11, 1, 1, 1, '2025-06-06 14:21:45'),
(56, 11, 2, 1, 1, '2025-06-07 02:36:24'),
(57, 11, 3, 1, 1, '2025-06-07 02:58:49'),
(58, 11, 4, 1, 1, '2025-06-09 20:57:36'),
(59, 11, 5, 0, 0.692055, NULL),
(60, 11, 6, 0, 0.276822, NULL),
(61, 11, 7, 0, 0.666667, NULL),
(62, 11, 8, 0, 0.285714, NULL),
(63, 11, 9, 0, 0.142857, NULL),
(64, 11, 10, 0, 0.0666667, NULL),
(65, 11, 11, 0, 0.0222222, NULL),
(66, 11, 12, 0, 0, NULL),
(67, 11, 13, 0, 0, NULL),
(68, 11, 14, 1, 1, '2025-06-06 14:21:45'),
(69, 11, 15, 1, 1, '2025-06-06 14:21:45'),
(70, 11, 16, 1, 1, '2025-06-06 14:21:45'),
(71, 11, 17, 1, 1, '2025-06-06 14:21:45'),
(72, 11, 18, 1, 1, '2025-06-06 14:21:45'),
(253, 9, 1, 1, 1, '2025-06-06 14:25:59'),
(254, 9, 2, 1, 1, '2025-06-06 14:27:03'),
(255, 9, 3, 1, 1, '2025-06-06 15:23:37'),
(256, 9, 4, 0, 0.50966, NULL),
(257, 9, 5, 0, 0.25483, NULL),
(258, 9, 6, 0, 0.101932, NULL),
(259, 9, 7, 1, 1, '2025-06-06 14:27:03'),
(260, 9, 8, 1, 1, '2025-06-06 14:27:03'),
(261, 9, 9, 1, 1, '2025-06-06 14:27:03'),
(262, 9, 10, 1, 1, '2025-06-06 14:27:03'),
(263, 9, 11, 0, 0.555556, NULL),
(264, 9, 12, 0, 0, NULL),
(265, 9, 13, 0, 0, NULL),
(266, 9, 14, 1, 1, '2025-06-06 14:25:59'),
(267, 9, 15, 1, 1, '2025-06-06 14:25:59'),
(268, 9, 16, 1, 1, '2025-06-06 14:25:59'),
(269, 9, 17, 1, 1, '2025-06-06 14:25:59'),
(270, 9, 18, 1, 1, '2025-06-06 14:25:59'),
(433, 12, 1, 0, 0, NULL),
(434, 12, 2, 0, 0, NULL),
(435, 12, 3, 0, 0, NULL),
(436, 12, 4, 0, 0, NULL),
(437, 12, 5, 0, 0, NULL),
(438, 12, 6, 0, 0, NULL),
(439, 12, 7, 0, 0, NULL),
(440, 12, 8, 0, 0, NULL),
(441, 12, 9, 0, 0, NULL),
(442, 12, 10, 0, 0, NULL),
(443, 12, 11, 0, 0, NULL),
(444, 12, 12, 0, 0, NULL),
(445, 12, 13, 0, 0, NULL),
(446, 12, 14, 0, 0, NULL),
(447, 12, 15, 0, 0, NULL),
(448, 12, 16, 0, 0, NULL),
(449, 12, 17, 0, 0, NULL),
(450, 12, 18, 0, 0, NULL),
(577, 14, 1, 1, 1, '2025-06-09 09:13:03'),
(578, 14, 2, 0, 0.83315, NULL),
(579, 14, 3, 0, 0.33326, NULL),
(580, 14, 4, 0, 0.16663, NULL),
(581, 14, 5, 0, 0.083315, NULL),
(582, 14, 6, 0, 0.033326, NULL),
(583, 14, 7, 0, 0.333333, NULL),
(584, 14, 8, 0, 0.142857, NULL),
(585, 14, 9, 0, 0.0714286, NULL),
(586, 14, 10, 0, 0.0333333, NULL),
(587, 14, 11, 0, 0.0111111, NULL),
(588, 14, 12, 0, 0, NULL),
(589, 14, 13, 0, 0, NULL),
(590, 14, 14, 1, 1, '2025-06-09 09:13:03'),
(591, 14, 15, 1, 1, '2025-06-09 09:13:03'),
(592, 14, 16, 1, 1, '2025-06-09 09:18:15'),
(593, 14, 17, 1, 1, '2025-06-09 09:18:15'),
(594, 14, 18, 1, 1, '2025-06-09 09:18:18'),
(595, 15, 1, 1, 1, '2025-06-09 11:55:14'),
(596, 15, 2, 0, 0.321, NULL),
(597, 15, 3, 0, 0.1284, NULL),
(598, 15, 4, 0, 0.0642, NULL),
(599, 15, 5, 0, 0.0321, NULL),
(600, 15, 6, 0, 0.01284, NULL),
(601, 15, 7, 0, 0.333333, NULL),
(602, 15, 8, 0, 0.142857, NULL),
(603, 15, 9, 0, 0.0714286, NULL),
(604, 15, 10, 0, 0.0333333, NULL),
(605, 15, 11, 0, 0.0111111, NULL),
(606, 15, 12, 0, 0, NULL),
(607, 15, 13, 0, 0, NULL),
(608, 15, 14, 1, 1, '2025-06-09 11:55:14'),
(609, 15, 15, 1, 1, '2025-06-09 11:55:14'),
(610, 15, 16, 1, 1, '2025-06-09 11:55:25'),
(611, 15, 17, 0, 0.8025, NULL),
(612, 15, 18, 0, 0.642, NULL),
(613, 16, 1, 1, 1, '2025-06-09 20:28:36'),
(614, 16, 2, 0, 0.318, NULL),
(615, 16, 3, 0, 0.1272, NULL),
(616, 16, 4, 0, 0.0636, NULL),
(617, 16, 5, 0, 0.0318, NULL),
(618, 16, 6, 0, 0.01272, NULL),
(619, 16, 7, 0, 0.333333, NULL),
(620, 16, 8, 0, 0.142857, NULL),
(621, 16, 9, 0, 0.0714286, NULL),
(622, 16, 10, 0, 0.0333333, NULL),
(623, 16, 11, 0, 0.0111111, NULL),
(624, 16, 12, 0, 0, NULL),
(625, 16, 13, 0, 0, NULL),
(626, 16, 14, 1, 1, '2025-06-09 20:28:36'),
(627, 16, 15, 1, 1, '2025-06-09 20:28:36'),
(628, 16, 16, 1, 1, '2025-06-09 20:28:44'),
(629, 16, 17, 0, 0.795, NULL),
(630, 16, 18, 0, 0.636, NULL),
(631, 17, 1, 1, 1, '2025-06-12 19:15:45'),
(632, 17, 2, 0, 0.508, NULL),
(633, 17, 3, 0, 0.2032, NULL),
(634, 17, 4, 0, 0.1016, NULL),
(635, 17, 5, 0, 0.0508, NULL),
(636, 17, 6, 0, 0.02032, NULL),
(637, 17, 7, 0, 0.333333, NULL),
(638, 17, 8, 0, 0.142857, NULL),
(639, 17, 9, 0, 0.0714286, NULL),
(640, 17, 10, 0, 0.0333333, NULL),
(641, 17, 11, 0, 0.0111111, NULL),
(642, 17, 12, 0, 0, NULL),
(643, 17, 13, 0, 0, NULL),
(644, 17, 14, 1, 1, '2025-06-12 19:15:45'),
(645, 17, 15, 1, 1, '2025-06-12 19:15:45'),
(646, 17, 16, 1, 1, '2025-06-12 19:17:03'),
(647, 17, 17, 1, 1, '2025-06-12 19:17:03'),
(648, 17, 18, 1, 1, '2025-06-12 19:17:13'),
(649, 18, 1, 1, 1, '2025-06-25 04:57:04'),
(650, 18, 2, 0, 0.4553, NULL),
(651, 18, 3, 0, 0.18212, NULL),
(652, 18, 4, 0, 0.09106, NULL),
(653, 18, 5, 0, 0.04553, NULL),
(654, 18, 6, 0, 0.018212, NULL),
(655, 18, 7, 0, 0.333333, NULL),
(656, 18, 8, 0, 0.142857, NULL),
(657, 18, 9, 0, 0.0714286, NULL),
(658, 18, 10, 0, 0.0333333, NULL),
(659, 18, 11, 0, 0.0111111, NULL),
(660, 18, 12, 0, 0, NULL),
(661, 18, 13, 0, 0, NULL),
(662, 18, 14, 1, 1, '2025-06-25 04:57:04'),
(663, 18, 15, 1, 1, '2025-06-25 04:57:04'),
(664, 18, 16, 1, 1, '2025-06-25 04:58:04'),
(665, 18, 17, 1, 1, '2025-06-25 04:58:24'),
(666, 18, 18, 0, 0.9106, NULL),
(667, 19, 1, 1, 1, '2025-07-15 17:45:41'),
(668, 19, 2, 0, 0.272, NULL),
(669, 19, 3, 0, 0.1088, NULL),
(670, 19, 4, 0, 0.0544, NULL),
(671, 19, 5, 0, 0.0272, NULL),
(672, 19, 6, 0, 0.01088, NULL),
(673, 19, 7, 0, 0.333333, NULL),
(674, 19, 8, 0, 0.142857, NULL),
(675, 19, 9, 0, 0.0714286, NULL),
(676, 19, 10, 0, 0.0333333, NULL),
(677, 19, 11, 0, 0.0111111, NULL),
(678, 19, 12, 0, 0, NULL),
(679, 19, 13, 0, 0, NULL),
(680, 19, 14, 1, 1, '2025-07-15 17:45:41'),
(681, 19, 15, 1, 1, '2025-07-15 17:45:41'),
(682, 19, 16, 0, 0.906667, NULL),
(683, 19, 17, 0, 0.68, NULL),
(684, 19, 18, 0, 0.544, NULL),
(685, 20, 1, 0, 0, NULL),
(686, 20, 2, 0, 0, NULL),
(687, 20, 3, 0, 0, NULL),
(688, 20, 4, 0, 0, NULL),
(689, 20, 5, 0, 0, NULL),
(690, 20, 6, 0, 0, NULL),
(691, 20, 7, 0, 0, NULL),
(692, 20, 8, 0, 0, NULL),
(693, 20, 9, 0, 0, NULL),
(694, 20, 10, 0, 0, NULL),
(695, 20, 11, 0, 0, NULL),
(696, 20, 12, 0, 0, NULL),
(697, 20, 13, 0, 0, NULL),
(698, 20, 14, 0, 0, NULL),
(699, 20, 15, 0, 0, NULL),
(700, 20, 16, 0, 0, NULL),
(701, 20, 17, 0, 0, NULL),
(702, 20, 18, 0, 0, NULL),
(703, 21, 1, 0, 0, NULL),
(704, 21, 2, 0, 0, NULL),
(705, 21, 3, 0, 0, NULL),
(706, 21, 4, 0, 0, NULL),
(707, 21, 5, 0, 0, NULL),
(708, 21, 6, 0, 0, NULL),
(709, 21, 7, 0, 0, NULL),
(710, 21, 8, 0, 0, NULL),
(711, 21, 9, 0, 0, NULL),
(712, 21, 10, 0, 0, NULL),
(713, 21, 11, 0, 0, NULL),
(714, 21, 12, 0, 0, NULL),
(715, 21, 13, 0, 0, NULL),
(716, 21, 14, 0, 0, NULL),
(717, 21, 15, 0, 0, NULL),
(718, 21, 16, 0, 0, NULL),
(719, 21, 17, 0, 0, NULL),
(720, 21, 18, 0, 0, NULL),
(721, 22, 1, 0, 0, NULL),
(722, 22, 2, 0, 0, NULL),
(723, 22, 3, 0, 0, NULL),
(724, 22, 4, 0, 0, NULL),
(725, 22, 5, 0, 0, NULL),
(726, 22, 6, 0, 0, NULL),
(727, 22, 7, 0, 0, NULL),
(728, 22, 8, 0, 0, NULL),
(729, 22, 9, 0, 0, NULL),
(730, 22, 10, 0, 0, NULL),
(731, 22, 11, 0, 0, NULL),
(732, 22, 12, 0, 0, NULL),
(733, 22, 13, 0, 0, NULL),
(734, 22, 14, 0, 0, NULL),
(735, 22, 15, 0, 0, NULL),
(736, 22, 16, 0, 0, NULL),
(737, 22, 17, 0, 0, NULL),
(738, 22, 18, 0, 0, NULL),
(739, 23, 1, 0, 0, NULL),
(740, 23, 2, 0, 0, NULL),
(741, 23, 3, 0, 0, NULL),
(742, 23, 4, 0, 0, NULL),
(743, 23, 5, 0, 0, NULL),
(744, 23, 6, 0, 0, NULL),
(745, 23, 7, 0, 0, NULL),
(746, 23, 8, 0, 0, NULL),
(747, 23, 9, 0, 0, NULL),
(748, 23, 10, 0, 0, NULL),
(749, 23, 11, 0, 0, NULL),
(750, 23, 12, 0, 0, NULL),
(751, 23, 13, 0, 0, NULL),
(752, 23, 14, 0, 0, NULL),
(753, 23, 15, 0, 0, NULL),
(754, 23, 16, 0, 0, NULL),
(755, 23, 17, 0, 0, NULL),
(756, 23, 18, 0, 0, NULL),
(757, 24, 1, 0, 0, NULL),
(758, 24, 2, 0, 0, NULL),
(759, 24, 3, 0, 0, NULL),
(760, 24, 4, 0, 0, NULL),
(761, 24, 5, 0, 0, NULL),
(762, 24, 6, 0, 0, NULL),
(763, 24, 7, 0, 0, NULL),
(764, 24, 8, 0, 0, NULL),
(765, 24, 9, 0, 0, NULL),
(766, 24, 10, 0, 0, NULL),
(767, 24, 11, 0, 0, NULL),
(768, 24, 12, 0, 0, NULL),
(769, 24, 13, 0, 0, NULL),
(770, 24, 14, 0, 0, NULL),
(771, 24, 15, 0, 0, NULL),
(772, 24, 16, 0, 0, NULL),
(773, 24, 17, 0, 0, NULL),
(774, 24, 18, 0, 0, NULL),
(775, 25, 1, 0, 0, NULL),
(776, 25, 2, 0, 0, NULL),
(777, 25, 3, 0, 0, NULL),
(778, 25, 4, 0, 0, NULL),
(779, 25, 5, 0, 0, NULL),
(780, 25, 6, 0, 0, NULL),
(781, 25, 7, 0, 0, NULL),
(782, 25, 8, 0, 0, NULL),
(783, 25, 9, 0, 0, NULL),
(784, 25, 10, 0, 0, NULL),
(785, 25, 11, 0, 0, NULL),
(786, 25, 12, 0, 0, NULL),
(787, 25, 13, 0, 0, NULL),
(788, 25, 14, 0, 0, NULL),
(789, 25, 15, 0, 0, NULL),
(790, 25, 16, 0, 0, NULL),
(791, 25, 17, 0, 0, NULL),
(792, 25, 18, 0, 0, NULL),
(793, 26, 1, 1, 1, '2025-07-15 17:48:21'),
(794, 26, 2, 0, 0.272, NULL),
(795, 26, 3, 0, 0.1088, NULL),
(796, 26, 4, 0, 0.0544, NULL),
(797, 26, 5, 0, 0.0272, NULL),
(798, 26, 6, 0, 0.01088, NULL),
(799, 26, 7, 0, 0.333333, NULL),
(800, 26, 8, 0, 0.142857, NULL),
(801, 26, 9, 0, 0.0714286, NULL),
(802, 26, 10, 0, 0.0333333, NULL),
(803, 26, 11, 0, 0.0111111, NULL),
(804, 26, 12, 0, 0, NULL),
(805, 26, 13, 0, 0, NULL),
(806, 26, 14, 1, 1, '2025-07-15 17:48:21'),
(807, 26, 15, 1, 1, '2025-07-15 17:48:21'),
(808, 26, 16, 0, 0.906667, NULL),
(809, 26, 17, 0, 0.68, NULL),
(810, 26, 18, 0, 0.544, NULL),
(811, 27, 1, 0, 0, NULL),
(812, 27, 2, 0, 0, NULL),
(813, 27, 3, 0, 0, NULL),
(814, 27, 4, 0, 0, NULL),
(815, 27, 5, 0, 0, NULL),
(816, 27, 6, 0, 0, NULL),
(817, 27, 7, 0, 0, NULL),
(818, 27, 8, 0, 0, NULL),
(819, 27, 9, 0, 0, NULL),
(820, 27, 10, 0, 0, NULL),
(821, 27, 11, 0, 0, NULL),
(822, 27, 12, 0, 0, NULL),
(823, 27, 13, 0, 0, NULL),
(824, 27, 14, 0, 0, NULL),
(825, 27, 15, 0, 0, NULL),
(826, 27, 16, 0, 0, NULL),
(827, 27, 17, 0, 0, NULL),
(828, 27, 18, 0, 0, NULL),
(829, 28, 1, 1, 1, '2025-07-15 17:50:33'),
(830, 28, 2, 0, 0.272, NULL),
(831, 28, 3, 0, 0.1088, NULL),
(832, 28, 4, 0, 0.0544, NULL),
(833, 28, 5, 0, 0.0272, NULL),
(834, 28, 6, 0, 0.01088, NULL),
(835, 28, 7, 0, 0.333333, NULL),
(836, 28, 8, 0, 0.142857, NULL),
(837, 28, 9, 0, 0.0714286, NULL),
(838, 28, 10, 0, 0.0333333, NULL),
(839, 28, 11, 0, 0.0111111, NULL),
(840, 28, 12, 0, 0, NULL),
(841, 28, 13, 0, 0, NULL),
(842, 28, 14, 1, 1, '2025-07-15 17:50:33'),
(843, 28, 15, 1, 1, '2025-07-15 17:50:33'),
(844, 28, 16, 0, 0.906667, NULL),
(845, 28, 17, 0, 0.68, NULL),
(846, 28, 18, 0, 0.544, NULL),
(847, 29, 1, 0, 0, NULL),
(848, 29, 2, 0, 0, NULL),
(849, 29, 3, 0, 0, NULL),
(850, 29, 4, 0, 0, NULL),
(851, 29, 5, 0, 0, NULL),
(852, 29, 6, 0, 0, NULL),
(853, 29, 7, 0, 0, NULL),
(854, 29, 8, 0, 0, NULL),
(855, 29, 9, 0, 0, NULL),
(856, 29, 10, 0, 0, NULL),
(857, 29, 11, 0, 0, NULL),
(858, 29, 12, 0, 0, NULL),
(859, 29, 13, 0, 0, NULL),
(860, 29, 14, 0, 0, NULL),
(861, 29, 15, 0, 0, NULL),
(862, 29, 16, 0, 0, NULL),
(863, 29, 17, 0, 0, NULL),
(864, 29, 18, 0, 0, NULL),
(865, 30, 1, 1, 1, '2025-07-15 17:51:50'),
(866, 30, 2, 0, 0.272, NULL),
(867, 30, 3, 0, 0.1088, NULL),
(868, 30, 4, 0, 0.0544, NULL),
(869, 30, 5, 0, 0.0272, NULL),
(870, 30, 6, 0, 0.01088, NULL),
(871, 30, 7, 0, 0.333333, NULL),
(872, 30, 8, 0, 0.142857, NULL),
(873, 30, 9, 0, 0.0714286, NULL),
(874, 30, 10, 0, 0.0333333, NULL),
(875, 30, 11, 0, 0.0111111, NULL),
(876, 30, 12, 0, 0, NULL),
(877, 30, 13, 0, 0, NULL),
(878, 30, 14, 1, 1, '2025-07-15 17:51:50'),
(879, 30, 15, 1, 1, '2025-07-15 17:51:50'),
(880, 30, 16, 0, 0.906667, NULL),
(881, 30, 17, 0, 0.68, NULL),
(882, 30, 18, 0, 0.544, NULL),
(883, 31, 1, 0, 0, NULL),
(884, 31, 2, 0, 0, NULL),
(885, 31, 3, 0, 0, NULL),
(886, 31, 4, 0, 0, NULL),
(887, 31, 5, 0, 0, NULL),
(888, 31, 6, 0, 0, NULL),
(889, 31, 7, 0, 0, NULL),
(890, 31, 8, 0, 0, NULL),
(891, 31, 9, 0, 0, NULL),
(892, 31, 10, 0, 0, NULL),
(893, 31, 11, 0, 0, NULL),
(894, 31, 12, 0, 0, NULL),
(895, 31, 13, 0, 0, NULL),
(896, 31, 14, 0, 0, NULL),
(897, 31, 15, 0, 0, NULL),
(898, 31, 16, 0, 0, NULL),
(899, 31, 17, 0, 0, NULL),
(900, 31, 18, 0, 0, NULL),
(901, 32, 1, 0, 0, NULL),
(902, 32, 2, 0, 0, NULL),
(903, 32, 3, 0, 0, NULL),
(904, 32, 4, 0, 0, NULL),
(905, 32, 5, 0, 0, NULL),
(906, 32, 6, 0, 0, NULL),
(907, 32, 7, 0, 0, NULL),
(908, 32, 8, 0, 0, NULL),
(909, 32, 9, 0, 0, NULL),
(910, 32, 10, 0, 0, NULL),
(911, 32, 11, 0, 0, NULL),
(912, 32, 12, 0, 0, NULL),
(913, 32, 13, 0, 0, NULL),
(914, 32, 14, 0, 0, NULL),
(915, 32, 15, 0, 0, NULL),
(916, 32, 16, 0, 0, NULL),
(917, 32, 17, 0, 0, NULL),
(918, 32, 18, 0, 0, NULL),
(919, 33, 1, 1, 1, '2025-07-15 17:53:24'),
(920, 33, 2, 0, 0.272, NULL),
(921, 33, 3, 0, 0.1088, NULL),
(922, 33, 4, 0, 0.0544, NULL),
(923, 33, 5, 0, 0.0272, NULL),
(924, 33, 6, 0, 0.01088, NULL),
(925, 33, 7, 0, 0.333333, NULL),
(926, 33, 8, 0, 0.142857, NULL),
(927, 33, 9, 0, 0.0714286, NULL),
(928, 33, 10, 0, 0.0333333, NULL),
(929, 33, 11, 0, 0.0111111, NULL),
(930, 33, 12, 0, 0, NULL),
(931, 33, 13, 0, 0, NULL),
(932, 33, 14, 1, 1, '2025-07-15 17:53:24'),
(933, 33, 15, 1, 1, '2025-07-15 17:53:24'),
(934, 33, 16, 0, 0.906667, NULL),
(935, 33, 17, 0, 0.68, NULL),
(936, 33, 18, 0, 0.544, NULL),
(937, 34, 1, 0, 0, NULL),
(938, 34, 2, 0, 0, NULL),
(939, 34, 3, 0, 0, NULL),
(940, 34, 4, 0, 0, NULL),
(941, 34, 5, 0, 0, NULL),
(942, 34, 6, 0, 0, NULL),
(943, 34, 7, 0, 0, NULL),
(944, 34, 8, 0, 0, NULL),
(945, 34, 9, 0, 0, NULL),
(946, 34, 10, 0, 0, NULL),
(947, 34, 11, 0, 0, NULL),
(948, 34, 12, 0, 0, NULL),
(949, 34, 13, 0, 0, NULL),
(950, 34, 14, 0, 0, NULL),
(951, 34, 15, 0, 0, NULL),
(952, 34, 16, 0, 0, NULL),
(953, 34, 17, 0, 0, NULL),
(954, 34, 18, 0, 0, NULL),
(955, 35, 1, 1, 1, '2025-07-15 17:53:27'),
(956, 35, 2, 0, 0.272, NULL),
(957, 35, 3, 0, 0.1088, NULL),
(958, 35, 4, 0, 0.0544, NULL),
(959, 35, 5, 0, 0.0272, NULL),
(960, 35, 6, 0, 0.01088, NULL),
(961, 35, 7, 0, 0.333333, NULL),
(962, 35, 8, 0, 0.142857, NULL),
(963, 35, 9, 0, 0.0714286, NULL),
(964, 35, 10, 0, 0.0333333, NULL),
(965, 35, 11, 0, 0.0111111, NULL),
(966, 35, 12, 0, 0, NULL),
(967, 35, 13, 0, 0, NULL),
(968, 35, 14, 1, 1, '2025-07-15 17:53:27'),
(969, 35, 15, 1, 1, '2025-07-15 17:53:27'),
(970, 35, 16, 0, 0.906667, NULL),
(971, 35, 17, 0, 0.68, NULL),
(972, 35, 18, 0, 0.544, NULL),
(973, 36, 1, 0, 0, NULL),
(974, 36, 2, 0, 0, NULL),
(975, 36, 3, 0, 0, NULL),
(976, 36, 4, 0, 0, NULL),
(977, 36, 5, 0, 0, NULL),
(978, 36, 6, 0, 0, NULL),
(979, 36, 7, 0, 0, NULL),
(980, 36, 8, 0, 0, NULL),
(981, 36, 9, 0, 0, NULL),
(982, 36, 10, 0, 0, NULL),
(983, 36, 11, 0, 0, NULL),
(984, 36, 12, 0, 0, NULL),
(985, 36, 13, 0, 0, NULL),
(986, 36, 14, 0, 0, NULL),
(987, 36, 15, 0, 0, NULL),
(988, 36, 16, 0, 0, NULL),
(989, 36, 17, 0, 0, NULL),
(990, 36, 18, 0, 0, NULL),
(991, 37, 1, 1, 1, '2025-07-15 17:53:44'),
(992, 37, 2, 0, 0.272, NULL),
(993, 37, 3, 0, 0.1088, NULL),
(994, 37, 4, 0, 0.0544, NULL),
(995, 37, 5, 0, 0.0272, NULL),
(996, 37, 6, 0, 0.01088, NULL),
(997, 37, 7, 0, 0.333333, NULL),
(998, 37, 8, 0, 0.142857, NULL),
(999, 37, 9, 0, 0.0714286, NULL),
(1000, 37, 10, 0, 0.0333333, NULL),
(1001, 37, 11, 0, 0.0111111, NULL),
(1002, 37, 12, 0, 0, NULL),
(1003, 37, 13, 0, 0, NULL),
(1004, 37, 14, 1, 1, '2025-07-15 17:53:44'),
(1005, 37, 15, 1, 1, '2025-07-15 17:53:44'),
(1006, 37, 16, 0, 0.906667, NULL),
(1007, 37, 17, 0, 0.68, NULL),
(1008, 37, 18, 0, 0.544, NULL),
(1009, 38, 1, 0, 0, NULL),
(1010, 38, 2, 0, 0, NULL),
(1011, 38, 3, 0, 0, NULL),
(1012, 38, 4, 0, 0, NULL),
(1013, 38, 5, 0, 0, NULL),
(1014, 38, 6, 0, 0, NULL),
(1015, 38, 7, 0, 0, NULL),
(1016, 38, 8, 0, 0, NULL),
(1017, 38, 9, 0, 0, NULL),
(1018, 38, 10, 0, 0, NULL),
(1019, 38, 11, 0, 0, NULL),
(1020, 38, 12, 0, 0, NULL),
(1021, 38, 13, 0, 0, NULL),
(1022, 38, 14, 0, 0, NULL),
(1023, 38, 15, 0, 0, NULL),
(1024, 38, 16, 0, 0, NULL),
(1025, 38, 17, 0, 0, NULL),
(1026, 38, 18, 0, 0, NULL),
(1027, 39, 1, 1, 1, '2025-07-15 17:53:47'),
(1028, 39, 2, 0, 0.272, NULL),
(1029, 39, 3, 0, 0.1088, NULL),
(1030, 39, 4, 0, 0.0544, NULL),
(1031, 39, 5, 0, 0.0272, NULL),
(1032, 39, 6, 0, 0.01088, NULL),
(1033, 39, 7, 0, 0.333333, NULL),
(1034, 39, 8, 0, 0.142857, NULL),
(1035, 39, 9, 0, 0.0714286, NULL),
(1036, 39, 10, 0, 0.0333333, NULL),
(1037, 39, 11, 0, 0.0111111, NULL),
(1038, 39, 12, 0, 0, NULL),
(1039, 39, 13, 0, 0, NULL),
(1040, 39, 14, 1, 1, '2025-07-15 17:53:47'),
(1041, 39, 15, 1, 1, '2025-07-15 17:53:47'),
(1042, 39, 16, 0, 0.906667, NULL),
(1043, 39, 17, 0, 0.68, NULL),
(1044, 39, 18, 0, 0.544, NULL),
(1045, 40, 1, 1, 1, '2025-07-15 17:54:54'),
(1046, 40, 2, 0, 0.272, NULL),
(1047, 40, 3, 0, 0.1088, NULL),
(1048, 40, 4, 0, 0.0544, NULL),
(1049, 40, 5, 0, 0.0272, NULL),
(1050, 40, 6, 0, 0.01088, NULL),
(1051, 40, 7, 0, 0.333333, NULL),
(1052, 40, 8, 0, 0.142857, NULL),
(1053, 40, 9, 0, 0.0714286, NULL),
(1054, 40, 10, 0, 0.0333333, NULL),
(1055, 40, 11, 0, 0.0111111, NULL),
(1056, 40, 12, 0, 0, NULL),
(1057, 40, 13, 0, 0, NULL),
(1058, 40, 14, 1, 1, '2025-07-15 17:54:54'),
(1059, 40, 15, 1, 1, '2025-07-15 17:54:54'),
(1060, 40, 16, 0, 0.906667, NULL),
(1061, 40, 17, 0, 0.68, NULL),
(1062, 40, 18, 0, 0.544, NULL),
(1063, 41, 1, 0, 0, NULL),
(1064, 41, 2, 0, 0, NULL),
(1065, 41, 3, 0, 0, NULL),
(1066, 41, 4, 0, 0, NULL),
(1067, 41, 5, 0, 0, NULL),
(1068, 41, 6, 0, 0, NULL),
(1069, 41, 7, 0, 0, NULL),
(1070, 41, 8, 0, 0, NULL),
(1071, 41, 9, 0, 0, NULL),
(1072, 41, 10, 0, 0, NULL),
(1073, 41, 11, 0, 0, NULL),
(1074, 41, 12, 0, 0, NULL),
(1075, 41, 13, 0, 0, NULL),
(1076, 41, 14, 0, 0, NULL),
(1077, 41, 15, 0, 0, NULL),
(1078, 41, 16, 0, 0, NULL),
(1079, 41, 17, 0, 0, NULL),
(1080, 41, 18, 0, 0, NULL),
(1081, 42, 1, 1, 1, '2025-07-15 17:54:57'),
(1082, 42, 2, 0, 0.272, NULL),
(1083, 42, 3, 0, 0.1088, NULL),
(1084, 42, 4, 0, 0.0544, NULL),
(1085, 42, 5, 0, 0.0272, NULL),
(1086, 42, 6, 0, 0.01088, NULL),
(1087, 42, 7, 0, 0.333333, NULL),
(1088, 42, 8, 0, 0.142857, NULL),
(1089, 42, 9, 0, 0.0714286, NULL),
(1090, 42, 10, 0, 0.0333333, NULL),
(1091, 42, 11, 0, 0.0111111, NULL),
(1092, 42, 12, 0, 0, NULL),
(1093, 42, 13, 0, 0, NULL),
(1094, 42, 14, 1, 1, '2025-07-15 17:54:57'),
(1095, 42, 15, 1, 1, '2025-07-15 17:54:57'),
(1096, 42, 16, 0, 0.906667, NULL),
(1097, 42, 17, 0, 0.68, NULL),
(1098, 42, 18, 0, 0.544, NULL),
(1099, 43, 1, 0, 0, NULL),
(1100, 43, 2, 0, 0, NULL),
(1101, 43, 3, 0, 0, NULL),
(1102, 43, 4, 0, 0, NULL),
(1103, 43, 5, 0, 0, NULL),
(1104, 43, 6, 0, 0, NULL),
(1105, 43, 7, 0, 0, NULL),
(1106, 43, 8, 0, 0, NULL),
(1107, 43, 9, 0, 0, NULL),
(1108, 43, 10, 0, 0, NULL),
(1109, 43, 11, 0, 0, NULL),
(1110, 43, 12, 0, 0, NULL),
(1111, 43, 13, 0, 0, NULL),
(1112, 43, 14, 0, 0, NULL),
(1113, 43, 15, 0, 0, NULL),
(1114, 43, 16, 0, 0, NULL),
(1115, 43, 17, 0, 0, NULL),
(1116, 43, 18, 0, 0, NULL),
(1117, 44, 1, 1, 1, '2025-07-15 17:56:12'),
(1118, 44, 2, 0, 0.261, NULL),
(1119, 44, 3, 0, 0.1044, NULL),
(1120, 44, 4, 0, 0.0522, NULL),
(1121, 44, 5, 0, 0.0261, NULL),
(1122, 44, 6, 0, 0.01044, NULL),
(1123, 44, 7, 0, 0.333333, NULL),
(1124, 44, 8, 0, 0.142857, NULL),
(1125, 44, 9, 0, 0.0714286, NULL),
(1126, 44, 10, 0, 0.0333333, NULL),
(1127, 44, 11, 0, 0.0111111, NULL),
(1128, 44, 12, 0, 0, NULL),
(1129, 44, 13, 0, 0, NULL),
(1130, 44, 14, 1, 1, '2025-07-15 17:56:12'),
(1131, 44, 15, 1, 1, '2025-07-15 17:56:12'),
(1132, 44, 16, 0, 0.87, NULL),
(1133, 44, 17, 0, 0.6525, NULL),
(1134, 44, 18, 0, 0.522, NULL),
(1135, 45, 1, 0, 0, NULL),
(1136, 45, 2, 0, 0, NULL),
(1137, 45, 3, 0, 0, NULL),
(1138, 45, 4, 0, 0, NULL),
(1139, 45, 5, 0, 0, NULL),
(1140, 45, 6, 0, 0, NULL),
(1141, 45, 7, 0, 0, NULL),
(1142, 45, 8, 0, 0, NULL),
(1143, 45, 9, 0, 0, NULL),
(1144, 45, 10, 0, 0, NULL),
(1145, 45, 11, 0, 0, NULL),
(1146, 45, 12, 0, 0, NULL),
(1147, 45, 13, 0, 0, NULL),
(1148, 45, 14, 0, 0, NULL),
(1149, 45, 15, 0, 0, NULL),
(1150, 45, 16, 0, 0, NULL),
(1151, 45, 17, 0, 0, NULL),
(1152, 45, 18, 0, 0, NULL),
(1153, 46, 1, 1, 1, '2025-07-15 17:56:15'),
(1154, 46, 2, 0, 0.261, NULL),
(1155, 46, 3, 0, 0.1044, NULL),
(1156, 46, 4, 0, 0.0522, NULL),
(1157, 46, 5, 0, 0.0261, NULL),
(1158, 46, 6, 0, 0.01044, NULL),
(1159, 46, 7, 0, 0.333333, NULL),
(1160, 46, 8, 0, 0.142857, NULL),
(1161, 46, 9, 0, 0.0714286, NULL),
(1162, 46, 10, 0, 0.0333333, NULL),
(1163, 46, 11, 0, 0.0111111, NULL),
(1164, 46, 12, 0, 0, NULL),
(1165, 46, 13, 0, 0, NULL),
(1166, 46, 14, 1, 1, '2025-07-15 17:56:15'),
(1167, 46, 15, 1, 1, '2025-07-15 17:56:15'),
(1168, 46, 16, 0, 0.87, NULL),
(1169, 46, 17, 0, 0.6525, NULL),
(1170, 46, 18, 0, 0.522, NULL),
(1171, 47, 1, 0, 0, NULL),
(1172, 47, 2, 0, 0, NULL),
(1173, 47, 3, 0, 0, NULL),
(1174, 47, 4, 0, 0, NULL),
(1175, 47, 5, 0, 0, NULL),
(1176, 47, 6, 0, 0, NULL),
(1177, 47, 7, 0, 0, NULL),
(1178, 47, 8, 0, 0, NULL),
(1179, 47, 9, 0, 0, NULL),
(1180, 47, 10, 0, 0, NULL),
(1181, 47, 11, 0, 0, NULL),
(1182, 47, 12, 0, 0, NULL),
(1183, 47, 13, 0, 0, NULL),
(1184, 47, 14, 0, 0, NULL),
(1185, 47, 15, 0, 0, NULL),
(1186, 47, 16, 0, 0, NULL),
(1187, 47, 17, 0, 0, NULL),
(1188, 47, 18, 0, 0, NULL),
(1189, 48, 1, 1, 1, '2025-07-15 17:56:52'),
(1190, 48, 2, 0, 0.261, NULL),
(1191, 48, 3, 0, 0.1044, NULL),
(1192, 48, 4, 0, 0.0522, NULL),
(1193, 48, 5, 0, 0.0261, NULL),
(1194, 48, 6, 0, 0.01044, NULL),
(1195, 48, 7, 0, 0.333333, NULL),
(1196, 48, 8, 0, 0.142857, NULL),
(1197, 48, 9, 0, 0.0714286, NULL),
(1198, 48, 10, 0, 0.0333333, NULL),
(1199, 48, 11, 0, 0.0111111, NULL),
(1200, 48, 12, 0, 0, NULL),
(1201, 48, 13, 0, 0, NULL),
(1202, 48, 14, 1, 1, '2025-07-15 17:56:52'),
(1203, 48, 15, 1, 1, '2025-07-15 17:56:52'),
(1204, 48, 16, 0, 0.87, NULL),
(1205, 48, 17, 0, 0.6525, NULL),
(1206, 48, 18, 0, 0.522, NULL),
(1207, 49, 1, 0, 0, NULL),
(1208, 49, 2, 0, 0, NULL),
(1209, 49, 3, 0, 0, NULL),
(1210, 49, 4, 0, 0, NULL),
(1211, 49, 5, 0, 0, NULL),
(1212, 49, 6, 0, 0, NULL),
(1213, 49, 7, 0, 0, NULL),
(1214, 49, 8, 0, 0, NULL),
(1215, 49, 9, 0, 0, NULL),
(1216, 49, 10, 0, 0, NULL),
(1217, 49, 11, 0, 0, NULL),
(1218, 49, 12, 0, 0, NULL),
(1219, 49, 13, 0, 0, NULL),
(1220, 49, 14, 0, 0, NULL),
(1221, 49, 15, 0, 0, NULL),
(1222, 49, 16, 0, 0, NULL),
(1223, 49, 17, 0, 0, NULL),
(1224, 49, 18, 0, 0, NULL),
(1225, 50, 1, 1, 1, '2025-07-15 17:56:55'),
(1226, 50, 2, 0, 0.261, NULL),
(1227, 50, 3, 0, 0.1044, NULL),
(1228, 50, 4, 0, 0.0522, NULL),
(1229, 50, 5, 0, 0.0261, NULL),
(1230, 50, 6, 0, 0.01044, NULL),
(1231, 50, 7, 0, 0.333333, NULL),
(1232, 50, 8, 0, 0.142857, NULL),
(1233, 50, 9, 0, 0.0714286, NULL),
(1234, 50, 10, 0, 0.0333333, NULL),
(1235, 50, 11, 0, 0.0111111, NULL),
(1236, 50, 12, 0, 0, NULL),
(1237, 50, 13, 0, 0, NULL),
(1238, 50, 14, 1, 1, '2025-07-15 17:56:55'),
(1239, 50, 15, 1, 1, '2025-07-15 17:56:55'),
(1240, 50, 16, 0, 0.87, NULL),
(1241, 50, 17, 0, 0.6525, NULL),
(1242, 50, 18, 0, 0.522, NULL),
(1243, 51, 1, 0, 0, NULL),
(1244, 51, 2, 0, 0, NULL),
(1245, 51, 3, 0, 0, NULL),
(1246, 51, 4, 0, 0, NULL),
(1247, 51, 5, 0, 0, NULL),
(1248, 51, 6, 0, 0, NULL),
(1249, 51, 7, 0, 0, NULL),
(1250, 51, 8, 0, 0, NULL),
(1251, 51, 9, 0, 0, NULL),
(1252, 51, 10, 0, 0, NULL),
(1253, 51, 11, 0, 0, NULL),
(1254, 51, 12, 0, 0, NULL),
(1255, 51, 13, 0, 0, NULL),
(1256, 51, 14, 0, 0, NULL),
(1257, 51, 15, 0, 0, NULL),
(1258, 51, 16, 0, 0, NULL),
(1259, 51, 17, 0, 0, NULL),
(1260, 51, 18, 0, 0, NULL),
(1261, 52, 1, 1, 1, '2025-07-15 17:58:03'),
(1262, 52, 2, 0, 0.522, NULL),
(1263, 52, 3, 0, 0.2088, NULL),
(1264, 52, 4, 0, 0.1044, NULL),
(1265, 52, 5, 0, 0.0522, NULL),
(1266, 52, 6, 0, 0.02088, NULL),
(1267, 52, 7, 0, 0.333333, NULL),
(1268, 52, 8, 0, 0.142857, NULL),
(1269, 52, 9, 0, 0.0714286, NULL),
(1270, 52, 10, 0, 0.0333333, NULL),
(1271, 52, 11, 0, 0.0111111, NULL),
(1272, 52, 12, 0, 0, NULL),
(1273, 52, 13, 0, 0, NULL),
(1274, 52, 14, 1, 1, '2025-07-15 17:58:03'),
(1275, 52, 15, 1, 1, '2025-07-15 17:58:03'),
(1276, 52, 16, 1, 1, '2025-07-15 17:58:05'),
(1277, 52, 17, 1, 1, '2025-07-15 17:58:05'),
(1278, 52, 18, 1, 1, '2025-07-15 17:58:05'),
(1279, 53, 1, 0, 0, NULL),
(1280, 53, 2, 0, 0, NULL),
(1281, 53, 3, 0, 0, NULL),
(1282, 53, 4, 0, 0, NULL),
(1283, 53, 5, 0, 0, NULL),
(1284, 53, 6, 0, 0, NULL),
(1285, 53, 7, 0, 0, NULL),
(1286, 53, 8, 0, 0, NULL),
(1287, 53, 9, 0, 0, NULL),
(1288, 53, 10, 0, 0, NULL),
(1289, 53, 11, 0, 0, NULL),
(1290, 53, 12, 0, 0, NULL),
(1291, 53, 13, 0, 0, NULL),
(1292, 53, 14, 0, 0, NULL),
(1293, 53, 15, 0, 0, NULL),
(1294, 53, 16, 0, 0, NULL),
(1295, 53, 17, 0, 0, NULL),
(1296, 53, 18, 0, 0, NULL),
(1297, 54, 1, 0, 0, NULL),
(1298, 54, 2, 0, 0, NULL),
(1299, 54, 3, 0, 0, NULL),
(1300, 54, 4, 0, 0, NULL),
(1301, 54, 5, 0, 0, NULL),
(1302, 54, 6, 0, 0, NULL),
(1303, 54, 7, 0, 0, NULL),
(1304, 54, 8, 0, 0, NULL),
(1305, 54, 9, 0, 0, NULL),
(1306, 54, 10, 0, 0, NULL),
(1307, 54, 11, 0, 0, NULL),
(1308, 54, 12, 0, 0, NULL),
(1309, 54, 13, 0, 0, NULL),
(1310, 54, 14, 0, 0, NULL),
(1311, 54, 15, 0, 0, NULL),
(1312, 54, 16, 0, 0, NULL),
(1313, 54, 17, 0, 0, NULL),
(1314, 54, 18, 0, 0, NULL),
(1315, 55, 1, 0, 0, NULL),
(1316, 55, 2, 0, 0, NULL),
(1317, 55, 3, 0, 0, NULL),
(1318, 55, 4, 0, 0, NULL),
(1319, 55, 5, 0, 0, NULL),
(1320, 55, 6, 0, 0, NULL),
(1321, 55, 7, 0, 0, NULL),
(1322, 55, 8, 0, 0, NULL),
(1323, 55, 9, 0, 0, NULL),
(1324, 55, 10, 0, 0, NULL),
(1325, 55, 11, 0, 0, NULL),
(1326, 55, 12, 0, 0, NULL),
(1327, 55, 13, 0, 0, NULL),
(1328, 55, 14, 0, 0, NULL),
(1329, 55, 15, 0, 0, NULL),
(1330, 55, 16, 0, 0, NULL),
(1331, 55, 17, 0, 0, NULL),
(1332, 55, 18, 0, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pertemanan`
--

CREATE TABLE `pertemanan` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `friend_id` int NOT NULL,
  `status` enum('pending','accepted','rejected','blocked') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pertemanan`
--

INSERT INTO `pertemanan` (`id`, `user_id`, `friend_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 9, 11, 'accepted', '2025-06-07 08:59:43', '2025-06-07 09:07:50'),
(2, 3, 11, 'accepted', '2025-06-07 09:15:02', '2025-06-09 13:31:31'),
(3, 3, 9, 'pending', '2025-06-07 09:15:09', '2025-06-07 09:15:09'),
(4, 14, 9, 'pending', '2025-06-09 16:53:49', '2025-06-09 16:53:49'),
(5, 14, 11, 'accepted', '2025-06-09 16:54:03', '2025-06-09 17:11:49'),
(6, 15, 11, 'pending', '2025-06-09 18:57:58', '2025-06-09 18:57:58'),
(7, 16, 11, 'accepted', '2025-06-10 03:29:03', '2025-06-10 03:29:23'),
(8, 17, 11, 'accepted', '2025-06-13 02:17:51', '2025-06-13 02:18:09');

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_konsumsi`
--

CREATE TABLE `riwayat_konsumsi` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `jumlah` float NOT NULL,
  `tanggal` datetime NOT NULL,
  `botol_id` int DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `riwayat_konsumsi`
--

INSERT INTO `riwayat_konsumsi` (`id`, `user_id`, `jumlah`, `tanggal`, `botol_id`, `is_default`) VALUES
(1, 11, 2.6, '2025-06-06 14:21:45', NULL, 1),
(2, 11, 2.6, '2025-06-06 14:21:45', NULL, 1),
(3, 3, 2.53, '2025-06-06 14:23:31', NULL, 1),
(4, 3, 2.53, '2025-06-06 14:23:31', NULL, 1),
(5, 3, 2.53, '2025-06-06 14:23:33', NULL, 1),
(6, 3, 2.53, '2025-06-06 14:24:33', NULL, 1),
(7, 3, 2.53, '2025-06-06 14:24:33', NULL, 1),
(8, 3, 2.53, '2025-06-06 14:24:35', NULL, 1),
(9, 9, 2.92, '2025-06-06 14:25:59', NULL, 1),
(10, 9, 2.92, '2025-06-06 14:25:59', NULL, 1),
(11, 9, 2.92, '2025-06-06 14:27:03', NULL, 1),
(12, 9, 2.92, '2025-06-06 14:27:03', NULL, 1),
(13, 9, 2.92, '2025-06-06 15:06:48', NULL, 1),
(18, 9, 2.92, '2025-06-06 15:09:29', NULL, 1),
(22, 9, 2.92, '2025-06-06 15:21:08', NULL, 1),
(23, 9, 0.24, '2025-06-06 15:21:10', NULL, 1),
(24, 9, 0.0015, '2025-06-06 15:22:38', NULL, 1),
(25, 9, 0.0015, '2025-06-06 15:22:39', NULL, 1),
(26, 9, 0.6, '2025-06-06 15:22:56', NULL, 1),
(27, 9, 0.6, '2025-06-06 15:22:58', NULL, 1),
(28, 9, 1.8, '2025-06-06 15:23:37', NULL, 1),
(29, 9, 1.8, '2025-06-06 15:23:37', NULL, 1),
(30, 11, 2.51, '2025-06-06 23:44:21', NULL, 1),
(31, 11, 0.001, '2025-06-06 23:45:10', NULL, 1),
(32, 11, 0.001, '2025-06-06 23:45:12', NULL, 1),
(33, 11, 2.71, '2025-06-07 02:36:24', NULL, 1),
(34, 11, 2.71, '2025-06-07 02:44:36', NULL, 1),
(35, 11, 0.33, '2025-06-07 02:44:44', NULL, 1),
(36, 11, 2.71, '2025-06-07 02:45:12', NULL, 1),
(37, 11, 2.5, '2025-06-07 02:45:37', NULL, 1),
(38, 11, 2.5, '2025-06-07 02:45:37', NULL, 1),
(39, 11, 0.24, '2025-06-07 02:45:41', NULL, 1),
(40, 11, 2.67, '2025-06-07 02:58:37', NULL, 1),
(41, 11, 2.5, '2025-06-07 02:58:49', NULL, 1),
(42, 11, 2.5, '2025-06-07 02:58:49', NULL, 1),
(43, 11, 2.63, '2025-06-09 06:32:02', NULL, 1),
(44, 12, 2.51, '2025-06-09 07:44:08', NULL, 1),
(45, 13, 2.41, '2025-06-09 08:22:30', NULL, 1),
(46, 13, 2.37, '2025-06-09 09:02:30', NULL, 1),
(47, 13, 2, '2025-06-09 09:02:44', NULL, 1),
(48, 13, 0, '2025-06-09 09:02:46', NULL, 1),
(49, 14, 2.37, '2025-06-09 09:13:03', NULL, 1),
(50, 14, 0, '2025-06-09 09:13:05', NULL, 1),
(51, 14, 0, '2025-06-09 09:13:12', NULL, 1),
(52, 14, 0, '2025-06-09 09:13:14', NULL, 1),
(53, 14, 2.37, '2025-06-09 09:18:15', NULL, 1),
(54, 14, 0.24, '2025-06-09 09:18:17', NULL, 1),
(55, 14, 0.24, '2025-06-09 09:18:18', NULL, 1),
(56, 14, 2.37, '2025-06-09 09:27:40', NULL, 1),
(57, 14, 0.24, '2025-06-09 09:27:43', NULL, 1),
(58, 14, 0.0015, '2025-06-09 09:28:05', NULL, 1),
(59, 14, 0.5, '2025-06-09 09:28:16', NULL, 1),
(60, 11, 2.47, '2025-06-09 10:14:59', NULL, 1),
(61, 11, 0.24, '2025-06-09 10:15:01', NULL, 1),
(62, 15, 2.47, '2025-06-09 11:55:14', NULL, 1),
(63, 15, 0.24, '2025-06-09 11:55:17', NULL, 1),
(64, 15, 0.5, '2025-06-09 11:55:25', NULL, 1),
(65, 11, 2.43, '2025-06-09 12:42:35', NULL, 1),
(66, 11, 0.24, '2025-06-09 12:43:27', NULL, 1),
(67, 11, 0.0025, '2025-06-09 12:43:31', NULL, 1),
(68, 11, 0.0025, '2025-06-09 12:43:32', NULL, 1),
(69, 11, 0.0025, '2025-06-09 12:43:33', NULL, 1),
(70, 11, 0.0025, '2025-06-09 12:43:33', NULL, 1),
(71, 11, 0.0025, '2025-06-09 12:43:34', NULL, 1),
(72, 11, 0.0025, '2025-06-09 12:43:34', NULL, 1),
(73, 11, 0.0025, '2025-06-09 12:43:34', NULL, 1),
(74, 11, 0.0025, '2025-06-09 12:43:34', NULL, 1),
(75, 11, 2.47, '2025-06-09 20:24:43', NULL, 1),
(76, 11, 2.47, '2025-06-09 20:27:04', NULL, 1),
(77, 16, 2.37, '2025-06-09 20:28:36', NULL, 1),
(78, 16, 0.24, '2025-06-09 20:28:38', NULL, 1),
(79, 16, 0.24, '2025-06-09 20:28:41', NULL, 1),
(80, 16, 0.33, '2025-06-09 20:28:44', NULL, 1),
(81, 11, 2.47, '2025-06-09 20:32:26', NULL, 1),
(82, 11, 2.47, '2025-06-09 20:33:43', NULL, 1),
(83, 11, 2.55, '2025-06-09 20:36:04', NULL, 1),
(84, 11, 0.33, '2025-06-09 20:36:17', NULL, 1),
(85, 11, 2.55, '2025-06-09 20:57:36', NULL, 1),
(86, 11, 0.002, '2025-06-09 20:58:19', NULL, 1),
(87, 11, 2.64, '2025-06-12 01:30:39', NULL, 1),
(88, 11, 0.24, '2025-06-12 01:30:42', NULL, 1),
(89, 17, 2.51, '2025-06-12 19:15:45', NULL, 1),
(90, 17, 2, '2025-06-12 19:17:03', NULL, 1),
(91, 17, 0.24, '2025-06-12 19:17:11', NULL, 1),
(92, 17, 0.33, '2025-06-12 19:17:13', NULL, 1),
(93, 11, 2.59, '2025-06-12 20:02:15', NULL, 1),
(94, 11, 2.71, '2025-06-23 20:40:49', NULL, 1),
(95, 11, 0.0015, '2025-06-23 20:40:53', NULL, 1),
(96, 11, 0.6, '2025-06-23 20:40:55', NULL, 1),
(97, 11, 0.6, '2025-06-23 20:40:56', NULL, 1),
(98, 11, 0.6, '2025-06-23 20:40:56', NULL, 1),
(99, 11, 0.6, '2025-06-23 20:40:57', NULL, 1),
(100, 11, 0.6, '2025-06-23 20:40:57', NULL, 1),
(101, 11, 0.6, '2025-06-23 20:40:57', NULL, 1),
(102, 11, 0.6, '2025-06-23 20:40:57', NULL, 1),
(103, 11, 0.6, '2025-06-23 20:40:57', NULL, 1),
(104, 11, 0.6, '2025-06-23 20:40:58', NULL, 1),
(105, 11, 0.6, '2025-06-23 20:40:58', NULL, 1),
(106, 11, 0.6, '2025-06-23 20:41:07', NULL, 1),
(107, 18, 2.71, '2025-06-25 04:57:04', NULL, 1),
(108, 18, 0.24, '2025-06-25 04:57:59', NULL, 1),
(109, 18, 0.6, '2025-06-25 04:58:04', NULL, 1),
(110, 18, 0.0015, '2025-06-25 04:58:13', NULL, 1),
(111, 18, 0.0015, '2025-06-25 04:58:15', NULL, 1),
(112, 18, 0.5, '2025-06-25 04:58:24', NULL, 1),
(113, 18, 0.5, '2025-06-25 04:58:24', NULL, 1),
(114, 11, 2, '2025-07-15 15:19:44', NULL, 1),
(115, 11, 0.5, '2025-07-15 15:21:33', NULL, 1),
(116, 19, 2.72, '2025-07-15 17:45:41', NULL, 1),
(117, 26, 2.72, '2025-07-15 17:48:20', NULL, 1),
(118, 28, 2.72, '2025-07-15 17:50:33', NULL, 1),
(119, 30, 2.72, '2025-07-15 17:51:50', NULL, 1),
(120, 33, 2.72, '2025-07-15 17:53:24', NULL, 1),
(121, 35, 2.72, '2025-07-15 17:53:27', NULL, 1),
(122, 37, 2.72, '2025-07-15 17:53:44', NULL, 1),
(123, 39, 2.72, '2025-07-15 17:53:47', NULL, 1),
(124, 40, 2.72, '2025-07-15 17:54:54', NULL, 1),
(125, 42, 2.72, '2025-07-15 17:54:57', NULL, 1),
(126, 44, 2.61, '2025-07-15 17:56:12', NULL, 1),
(127, 46, 2.61, '2025-07-15 17:56:15', NULL, 1),
(128, 48, 2.61, '2025-07-15 17:56:52', NULL, 1),
(129, 50, 2.61, '2025-07-15 17:56:55', NULL, 1),
(130, 52, 2.61, '2025-07-15 17:58:03', NULL, 1),
(131, 52, 2.61, '2025-07-15 17:58:05', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_prediksi`
--

CREATE TABLE `riwayat_prediksi` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `usia` int DEFAULT NULL,
  `berat_badan` float DEFAULT NULL,
  `tinggi_badan` float DEFAULT NULL,
  `jenis_kelamin` varchar(1) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `tingkat_aktivitas` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `rekomendasi_air` float DEFAULT NULL,
  `satuan` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'liter/hari',
  `tanggal` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `riwayat_prediksi`
--

INSERT INTO `riwayat_prediksi` (`id`, `user_id`, `usia`, `berat_badan`, `tinggi_badan`, `jenis_kelamin`, `tingkat_aktivitas`, `rekomendasi_air`, `satuan`, `tanggal`) VALUES
(1, 1, 23, 55, 165, 'P', 'tinggi', 2.25, 'liter/hari', '2025-04-22 01:44:57'),
(2, 1, 23, 55, 165, 'P', 'tinggi', 2.25, 'liter/hari', '2025-04-22 01:56:29'),
(3, 1, 23, 55, 165, 'P', 'tinggi', 2.25, 'liter/hari', '2025-04-22 01:58:50'),
(4, 1, 23, 55, 165, 'P', 'tinggi', 2.25, 'liter/hari', '2025-04-22 02:00:18'),
(9, 4, 21, 64, 175, 'L', 'sedang', 2.22, 'liter/hari', '2025-05-05 17:50:19'),
(10, 3, 21, 63, 175, 'L', 'sedang', 2.2, 'liter/hari', '2025-05-05 17:51:05'),
(11, 4, 21, 64, 175, 'L', 'sedang', 31.22, 'liter/hari', '2025-05-05 17:52:00'),
(13, 4, 21, 64, 175, 'L', 'sedang', 2.22, 'liter/hari', '2025-05-05 17:54:08'),
(14, 4, 21, 64, 175, 'L', 'tinggi', 2.52, 'liter/hari', '2025-05-05 17:54:13'),
(15, 4, 21, 64, 175, 'L', 'tinggi', 2.52, 'liter/hari', '2025-05-05 17:54:21'),
(16, 4, 21, 64, 175, 'L', 'rendah', 1.92, 'liter/hari', '2025-05-05 17:54:24'),
(17, 3, 21, 63, 175, 'L', 'sedang', 2.2, 'liter/hari', '2025-05-05 18:46:50'),
(18, 3, 21, 63, 175, 'L', 'sedang', 2.2, 'liter/hari', '2025-05-05 19:11:05'),
(19, 3, 21, 63, 175, 'L', 'sedang', 2.2, 'liter/hari', '2025-05-05 19:11:21'),
(20, 3, 21, 63, 175, 'L', 'rendah', 1.89, 'liter/hari', '2025-05-05 19:11:23'),
(21, 4, 21, 64, 175, 'L', 'rendah', 1.92, 'liter/hari', '2025-05-05 19:11:40'),
(22, 4, 21, 64, 175, 'L', 'rendah', 2.24, 'liter/hari', '2025-05-05 20:02:38'),
(24, 4, 21, 64, 175, 'L', 'rendah', 2.53, 'liter/hari', '2025-05-06 09:01:20'),
(25, 3, 21, 63, 175, 'L', 'sedang', 2.5, 'liter/hari', '2025-05-06 09:01:39'),
(26, 3, 21, 63, 175, 'L', 'sedang', 2.5, 'liter/hari', '2025-05-06 09:22:26'),
(27, 3, 21, 64, 175, 'L', 'sedang', 2.64, 'liter/hari', '2025-05-06 10:54:29'),
(28, 4, 21, 64, 175, 'L', 'rendah', 2.44, 'liter/hari', '2025-05-07 03:42:14'),
(29, 4, 21, 64, 175, 'L', 'rendah', 2.55, 'liter/hari', '2025-05-07 10:38:30'),
(30, 8, 22, 64, 174, 'L', 'tinggi', 2.55, 'liter/hari', '2025-05-07 10:41:21'),
(31, 3, 21, 64, 175, 'L', 'sedang', 2.52, 'liter/hari', '2025-06-03 08:40:31'),
(32, 9, 41, 75, 162, 'L', 'sedang', 2.94, 'liter/hari', '2025-06-03 21:00:13'),
(33, 3, 21, 64, 175, 'L', 'tinggi', 2.53, 'liter/hari', '2025-06-06 12:53:01'),
(34, 3, 21, 64, 175, 'L', 'sedang', 2.53, 'liter/hari', '2025-06-06 13:49:26'),
(35, 3, 21, 64, 175, 'L', 'sedang', 2.53, 'liter/hari', '2025-06-06 13:56:25'),
(36, 3, 21, 64, 175, 'L', 'sedang', 2.53, 'liter/hari', '2025-06-06 14:14:30'),
(37, 11, 22, 66, 173, 'L', 'sedang', 2.6, 'liter/hari', '2025-06-06 14:17:48'),
(38, 11, 22, 66, 173, 'L', 'tinggi', 2.6, 'liter/hari', '2025-06-06 14:19:11'),
(39, 11, 22, 66, 173, 'L', 'tinggi', 2.6, 'liter/hari', '2025-06-06 14:21:45'),
(40, 3, 21, 64, 175, 'L', 'sedang', 2.53, 'liter/hari', '2025-06-06 14:23:31'),
(41, 3, 21, 64, 175, 'L', 'sedang', 2.53, 'liter/hari', '2025-06-06 14:24:33'),
(42, 9, 41, 75, 162, 'L', 'sedang', 2.92, 'liter/hari', '2025-06-06 14:25:59'),
(43, 9, 41, 75, 162, 'L', 'sedang', 2.92, 'liter/hari', '2025-06-06 14:27:03'),
(44, 9, 41, 75, 162, 'L', 'sedang', 2.92, 'liter/hari', '2025-06-06 15:06:48'),
(45, 9, 41, 75, 162, 'L', 'tinggi', 2.92, 'liter/hari', '2025-06-06 15:09:29'),
(46, 9, 41, 75, 162, 'L', 'sedang', 2.92, 'liter/hari', '2025-06-06 15:21:08'),
(47, 11, 22, 66, 173, 'L', 'rendah', 2.51, 'liter/hari', '2025-06-06 23:44:21'),
(48, 11, 22, 66, 173, 'L', 'sedang', 2.71, 'liter/hari', '2025-06-07 02:36:24'),
(49, 11, 22, 66, 173, 'L', 'sedang', 2.71, 'liter/hari', '2025-06-07 02:44:36'),
(50, 11, 22, 66, 173, 'L', 'tinggi', 2.71, 'liter/hari', '2025-06-07 02:45:12'),
(51, 11, 22, 66, 173, 'L', 'sedang', 2.67, 'liter/hari', '2025-06-07 02:58:37'),
(52, 11, 22, 66, 173, 'L', 'sedang', 2.63, 'liter/hari', '2025-06-09 06:32:02'),
(53, 12, 22, 66, 173, 'L', 'sedang', 2.51, 'liter/hari', '2025-06-09 07:44:08'),
(54, 13, 22, 63, 175, 'L', 'sedang', 2.41, 'liter/hari', '2025-06-09 08:22:30'),
(55, 13, 22, 63, 175, 'L', 'sedang', 2.37, 'liter/hari', '2025-06-09 09:02:30'),
(56, 14, 21, 63, 175, 'L', 'sedang', 2.37, 'liter/hari', '2025-06-09 09:13:03'),
(57, 14, 21, 63, 175, 'L', 'sedang', 2.37, 'liter/hari', '2025-06-09 09:18:15'),
(58, 14, 21, 63, 175, 'L', 'sedang', 2.37, 'liter/hari', '2025-06-09 09:27:40'),
(59, 11, 22, 66, 173, 'L', 'sedang', 2.47, 'liter/hari', '2025-06-09 10:14:59'),
(60, 15, 22, 67, 176, 'L', 'sedang', 2.47, 'liter/hari', '2025-06-09 11:55:14'),
(61, 11, 22, 66, 173, 'L', 'sedang', 2.43, 'liter/hari', '2025-06-09 12:42:35'),
(62, 11, 22, 66, 173, 'L', 'sedang', 2.47, 'liter/hari', '2025-06-09 20:24:43'),
(63, 11, 22, 66, 173, 'L', 'rendah', 2.47, 'liter/hari', '2025-06-09 20:27:04'),
(64, 16, 22, 63, 165, 'L', 'tinggi', 2.37, 'liter/hari', '2025-06-09 20:28:36'),
(65, 11, 22, 66, 173, 'L', 'sedang', 2.47, 'liter/hari', '2025-06-09 20:32:26'),
(66, 11, 22, 66, 173, 'L', 'tinggi', 2.47, 'liter/hari', '2025-06-09 20:33:43'),
(67, 11, 22, 66, 173, 'L', 'sedang', 2.55, 'liter/hari', '2025-06-09 20:36:04'),
(68, 11, 22, 66, 173, 'L', 'sedang', 2.55, 'liter/hari', '2025-06-09 20:57:36'),
(69, 11, 22, 66, 173, 'L', 'tinggi', 2.64, 'liter/hari', '2025-06-12 01:30:39'),
(70, 17, 22, 64, 175, 'L', 'tinggi', 2.51, 'liter/hari', '2025-06-12 19:15:45'),
(71, 11, 22, 66, 173, 'L', 'sedang', 2.59, 'liter/hari', '2025-06-12 20:02:15'),
(72, 11, 22, 66, 173, 'L', 'sedang', 2.71, 'liter/hari', '2025-06-23 20:40:49'),
(73, 18, 21, 67, 175, 'L', 'sedang', 2.71, 'liter/hari', '2025-06-25 04:57:04'),
(74, 19, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:45:41'),
(75, 26, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:48:20'),
(76, 28, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:50:33'),
(77, 30, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:51:49'),
(78, 33, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:53:24'),
(79, 35, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:53:27'),
(80, 37, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:53:43'),
(81, 39, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:53:46'),
(82, 40, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:54:53'),
(83, 42, 25, 70, 175, 'L', 'sedang', 2.72, 'liter/hari', '2025-07-15 17:54:56'),
(84, 44, 25, 70, 175, 'L', 'sedang', 2.61, 'liter/hari', '2025-07-15 17:56:11'),
(85, 46, 25, 70, 175, 'L', 'sedang', 2.61, 'liter/hari', '2025-07-15 17:56:15'),
(86, 48, 25, 70, 175, 'L', 'sedang', 2.61, 'liter/hari', '2025-07-15 17:56:51'),
(87, 50, 25, 70, 175, 'L', 'sedang', 2.61, 'liter/hari', '2025-07-15 17:56:55'),
(88, 52, 25, 70, 175, 'L', 'sedang', 2.61, 'liter/hari', '2025-07-15 17:58:03'),
(89, 52, 25, 70, 175, 'L', 'sedang', 2.61, 'liter/hari', '2025-07-15 17:58:05');

-- --------------------------------------------------------

--
-- Table structure for table `streak_pengguna`
--

CREATE TABLE `streak_pengguna` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `nilai_streak` int DEFAULT '1',
  `terakhir_update` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `streak_pengguna`
--

INSERT INTO `streak_pengguna` (`id`, `user_id`, `nilai_streak`, `terakhir_update`) VALUES
(5, 11, 1, '2025-07-15'),
(12, 3, 1, '2025-06-06'),
(17, 9, 50, '2025-06-06'),
(27, 12, 1, '2025-06-09'),
(28, 13, 1, '2025-06-09'),
(36, 14, 1, '2025-06-09'),
(37, 15, 1, '2025-06-09'),
(38, 16, 1, '2025-06-09'),
(39, 17, 1, '2025-06-12'),
(40, 18, 1, '2025-06-25'),
(41, 19, 1, '2025-07-15'),
(42, 20, 1, '2025-07-15'),
(43, 21, 1, '2025-07-15'),
(44, 22, 1, '2025-07-15'),
(45, 23, 1, '2025-07-15'),
(46, 24, 1, '2025-07-15'),
(47, 25, 1, '2025-07-15'),
(48, 26, 1, '2025-07-15'),
(49, 27, 1, '2025-07-15'),
(50, 28, 1, '2025-07-15'),
(51, 29, 1, '2025-07-15'),
(52, 30, 1, '2025-07-15'),
(53, 31, 1, '2025-07-15'),
(54, 32, 1, '2025-07-15'),
(55, 33, 1, '2025-07-15'),
(56, 34, 1, '2025-07-15'),
(57, 35, 1, '2025-07-15'),
(58, 36, 1, '2025-07-15'),
(59, 37, 1, '2025-07-15'),
(60, 38, 1, '2025-07-15'),
(61, 39, 1, '2025-07-15'),
(62, 40, 1, '2025-07-15'),
(63, 41, 1, '2025-07-15'),
(64, 42, 1, '2025-07-15'),
(65, 43, 1, '2025-07-15'),
(66, 44, 1, '2025-07-15'),
(67, 45, 1, '2025-07-15'),
(68, 46, 1, '2025-07-15'),
(69, 47, 1, '2025-07-15'),
(70, 48, 1, '2025-07-15'),
(71, 49, 1, '2025-07-15'),
(72, 50, 1, '2025-07-15'),
(73, 51, 1, '2025-07-15'),
(74, 52, 1, '2025-07-15'),
(75, 53, 1, '2025-07-15'),
(76, 54, 1, '2025-07-15'),
(77, 55, 1, '2025-07-15');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`) VALUES
(1, 'test@mail.com', 'scrypt:32768:8:1$QFPDjmRFSn8Tomqt$97f454c66bb1d9b24a7e2ff0ae21cb8a6917218413f208bf84ddf9a4e2ef935ede9036295fb26e093d16bf6c8ebe25c538cc32835d69cd389fea8ebeff00fdda'),
(2, 'test1@gmail.com', 'scrypt:32768:8:1$t7AUV0dC447z3l7r$e84a12aa8ceb4233dbef0cf04cec56375619a0cbc5bb9edc905a07df7a19efac294e8abcbb1e15acc8689308092a734ef8e3ce7e47d439ff0dbe01d297bf8ae2'),
(3, 'bedul@gmail.com', 'scrypt:32768:8:1$Qp6jNVCfKKpHcNNR$3be897e05b3915172fd81eea8be6e1f537b5eb508e14d377ead86b20016fc9602b91a16240a6c5feab30aea8b6c7daa0a0122c775423707e75f4a4dcb4e4f6e8'),
(4, 'coba1@gmail.com', 'scrypt:32768:8:1$F6fXhHNaGRK1M5Xt$e96e695af658383f54c94c8c0ac1dcc7b58690b3aa8203a9f3c068ae33b703d1a54d06640419ba3cd4e747c0d0dd732f7a1aefda9b2ee49d95f62d4223eba0ed'),
(5, 'abdul@gmail.com', 'scrypt:32768:8:1$84bAgZSm67kBmVPM$52e3ad73fe3b95ed1553fa5a3bbc65685cc1e0ac0156634c6227b3c84da07b51f928a2296729c2d55654df4625b034cc6fe1097de7accbbe34dc4cf421eefde3'),
(6, 'revoer@gmail.com', 'scrypt:32768:8:1$WzpmvbQbbFFMUZad$d97917e4decf0627630379338888c0845a52f1747c09a3da2ee2b423e153381e835ff393b2ffd208cc462ec97f8138aa9ea798002c9392c8e7900c56862024ab'),
(7, 'aja@gmail.com', 'scrypt:32768:8:1$4TqAHPJuTWjkH7OP$d5b37043296ea87ebbd72a4ed7299175a08b7dd40fe56c278774a3a49ab032f94d6f0dcbcccce67ae7094bda9cd0a4830291f4bd31a48e4b076df4d4e6991510'),
(8, 'cobadaftar@gmail.com', 'scrypt:32768:8:1$iYi5cUazOxjoQ1ie$60db972c5f5f88936c492c454444604a54dbaadd3839babb43f5840498438d5245380ee1dfc708eebfa2e44595a003424639cb21f37b74e71df71414a0723ea4'),
(9, 'pakremon@gmail.com', 'scrypt:32768:8:1$rZuQ3P3PwjvSc9af$9d1bae4f7559c22ae198de5b798b38f26a146617b02913ff43265b36860f636740bc35fdae2271cc12fa88f55f56201ef0c9c80fad692b66b497ed8e45fdda20'),
(11, 'dullatief@gmail.com', 'scrypt:32768:8:1$Qp6jNVCfKKpHcNNR$3be897e05b3915172fd81eea8be6e1f537b5eb508e14d377ead86b20016fc9602b91a16240a6c5feab30aea8b6c7daa0a0122c775423707e75f4a4dcb4e4f6e8'),
(12, 'labdul3916@gmail.com', 'scrypt:32768:8:1$fWOiHMfDubTjikRG$5ab423772daa82c840476ff831fa55e5d744485dd426446a74aefa17ae96a58958881130f6abc07892f339505b9e59129f22041ed52627d6b54cad8a0a93f04b'),
(13, 'bedulmencoba@gmail.com', 'scrypt:32768:8:1$gkFYGdF9Un1XLV52$b0ea20dfd89e6899456e67fe3f12f87c13f52046cc675d9c4b423099eac47cd37fbb3efce2b121f8ecb128e270a6ac3eb38a574a168d588d69dbb0a8e3c2ebe6'),
(14, 'baru@gmail.com', 'scrypt:32768:8:1$wjYDmUdspab91M0p$a82fe132b1515bf95fffcfa8eb6fd5dcfcf6888daec3cfde1138b4d822e9b58b3eae2c32ad3338186109cdaf8aa00ddd427be8e142cf513bf2901b3e0fe2a0fe'),
(15, 'labdul391@yahoo.com', 'scrypt:32768:8:1$vMD5uvWcQM3frrFx$753eaa034cbe59c301408fb5edb988d8f2590feddc80239ad1a6325cc51ddbdbd56a24116742246da9aea89e26f787a453cbee6e0311221c63a91caf3dac45bd'),
(16, 'pitok@gmail.com', 'scrypt:32768:8:1$JxVpKhlSG3to0G1D$a3b4557c79635858c13ff18250bfaefe8561b69b42d3c8f141d9652d46993cb62c48480a2ded5e094b30c8814129f27a64a72034a8098cd2d7ff72233fa49d29'),
(17, 'akuntest@gmail.com', 'scrypt:32768:8:1$aS5cXTUQg4nS4k8S$85db6ce3d224dfe541a9ea8c13dc3da19f5caf565b93416a838f73b12341ff6b9469fba5a118cc04f995acc44a87d04a47fb1262a438c65c0dd114f4954ed763'),
(18, 'bedulll@gmail.com', 'scrypt:32768:8:1$tfTzquj9VSknNJsn$a5f03bcd2b10df2a285765eadd4fe444144f9fd26e64485721fc1cd854d69eb74c43642496a5da5c3e80ce9ed43a1e49f55a94a3c6fd24b7ba137d914244232e'),
(19, 'test_prediction_1752601539@example.com', 'scrypt:32768:8:1$bT0qkBnQe7ymFwZY$8fb1678826d287988f14cebe83b2c9191f85801444cc2996cc700e512aaddad7324a0d040098a87734f6a9f13545ddd06d494d1ebe826c5a2f7c16884b7cb848'),
(20, 'test_prediction_1752601541@example.com', 'scrypt:32768:8:1$e5ftlC5vwAz7Tlgd$486ebf60e1396f949292d8f1255b1c82e07bb6b20b07a6d19676079c16ca68ba943e5a6e71baa9796de003a1a79184d882d1e37d8714952b4fe18bd591686ad2'),
(21, 'test_security_zb7xvd8r@example.com', 'scrypt:32768:8:1$tl9mNKTs7vDjzvJ7$40d99baadde476e77ffdd99742fc97e82beefc687bc251d052835b0febad92bdddd1511ae73b47825fb7775b23e0e4f4a8a01fe622e715a864e0dce75d82c0d4'),
(22, 'test_security_i423tcyp@example.com', 'scrypt:32768:8:1$wPiVgTQlmu3Ms6zM$50c91674da56075f1a72fb5afab95cc5c428a7d354bb9d9b9af57232f655b7249eda02424b5b842a6f593a6f0c760300e0e1a9b0e29a242075cb3e63f77657cc'),
(23, 'test_security_2h8krez0@example.com', 'scrypt:32768:8:1$cLBgpY6oLhDM0XPe$29df06f4da065677ef5b2b9febcc5d29704fe9c179a7fcd4a2d0eabab41e8d8ef13a07b5b433e357a4f499fc9cde47893494cad3df58f0a6ee75096172005ada'),
(24, 'test_security_e7y4crhm@example.com', 'scrypt:32768:8:1$0vppQYQ8rcb5U7bL$4ab399938a0eb4eddb3d3e59795b7874a1df51b01b7f8dd575654a4cc5e25a8ea7f62eaab5e40036916ef861249405381da4aba67fcb748b33e02476b13e32aa'),
(25, 'test_security_csuvz5ss@example.com', 'scrypt:32768:8:1$gBWStuZZFe4lxePC$232d2e46a663bf2bc0732692feff7a638ce1f4763f47e6a2e689d622b7f482613ddf647f2086d28f26ab45c394ab69821ae2a9cc6b46d77caef55669716fa9cf'),
(26, 'test_prediction_1752601698@example.com', 'scrypt:32768:8:1$28zSbH3OeMhXRVPe$92ddba802fef07097c370890312ce69bd4677c38c07bf043f2e12aa135d21bc1e8718a3553362b10c820387cdd624e796b6382ceafe8f07c11e2e3b2e3603b72'),
(27, 'test_prediction_1752601700@example.com', 'scrypt:32768:8:1$jd9unBczcpA7NX3Q$752eb558013d7b4e59394d7ff4e857a9b6c126fd00f0e6d50890e9994e689425412b3c027d550330bbc08c0e64289a3fe42e1ae4d8edb9b1c6b85ad925a02e46'),
(28, 'test_prediction_1752601831@example.com', 'scrypt:32768:8:1$aKYNuThWPOMTrkDD$0b03cb865fc87657641a9c8bdbf90e2fba88f765f8fa4db651a0f82d4f6c184a78145a2b0c060c08eb18edb693638ca5076cd5bbe2b5dbbdf2ae621dc0ed5ae0'),
(29, 'test_prediction_1752601833@example.com', 'scrypt:32768:8:1$nBIZ5eEj3ELDUERw$dde1a1d3e1cc23bcac4503de4010b3886fa5fc920653c54d1163bc5439aa211feecdb696ddd9ec9e6921719b0fc5fd5475d67875999c620d3ce970b108ce7931'),
(30, 'test_1752601907@example.com', 'scrypt:32768:8:1$VrBrSmwshEhJ73qq$2e61f69d0e03ee75bc611d45774bb82f47e03e03a7100db9207127bd13baf8ed0a1d5c79778a6fbc1afb6b980140fbe732b29a3a46f08c763a63f605d19bd3e4'),
(31, 'test_1752601910@example.com', 'scrypt:32768:8:1$SpdceGr2wZXrdQIw$5bf51434b3d631899cdecf816efd07430ddf50ee88d5ccb917fd0dbc6a6f5b4d5910f6921ed743b847e0ba526f48e85ce664d5ccefddcdd8f08c6f9284116520'),
(32, 'test_prediction_1752602000@example.com', 'scrypt:32768:8:1$GJ812d820uycYB3d$73e24009f9718406a6e95768551eacff35ad13f6897a4af9410887f8be92590ec7996b22273041ae5c356d1ec054fd13a354ab23a4e8826462e7f1c827c54224'),
(33, 'test_prediction_1752602002@example.com', 'scrypt:32768:8:1$N21lgU3rqHza4sMe$279f87ad46e14d9ff24f7d3fab138c5a55e719acd09a3d7361967aea61bc2c83896a24c2b0d63d51401443538a7cd454b94629d9ccec5a9bae1bd3da4182ee76'),
(34, 'test_prediction_1752602004@example.com', 'scrypt:32768:8:1$QYlvoD3FhlzgrB12$3173b3e4a82666c5470830418a107820da1a68a9e085049c64dc6b22c62ee000f47d1bcd6702f82d41ba8a41e851c9214cc368f19ad483ed34ce4ad4ddb4fa9f'),
(35, 'test_prediction_1752602005@example.com', 'scrypt:32768:8:1$Zv7pRc0f8U2mjR2y$bd3d3753df146757006ed9eeed3fee5b40e43ba8567a34181b5f1a31c7b1a5dc73a43bb6b924bc0660c58a55b850ae9176f9c4e6d1a483a26a7f6d46eca86104'),
(36, 'test_prediction_1752602019@example.com', 'scrypt:32768:8:1$5cr9FotyokKdav8B$8e6ce57f7e85d19e165d806439ef9c80580566ffff0381dae70ef0541ed696e33d0334b35b6fcb147a8e4257476522995aa57c62c81d799eb3b230e2cca8a4f0'),
(37, 'test_prediction_1752602020@example.com', 'scrypt:32768:8:1$GXwRGVsIcpf8IIm1$a0a87a3beb739dfd7c6a5b7ad670fe6b35b14e67eed2b43327678584b35efa5fe2bfdecc4f5b5b2a93fe1edf542e542db70c6a5adcdb66dd73c6d97f74ed0d07'),
(38, 'test_prediction_1752602023@example.com', 'scrypt:32768:8:1$YTcu5euZ3JEod6DT$77c2ce1c0d52fdafc6a125ffb29f1fd4611a1981b7c10e304c75bb780f2663139a8268c397a56101a8a6921e2b42ec210e925147ef1ff0921c61b6ad5d3dd800'),
(39, 'test_prediction_1752602024@example.com', 'scrypt:32768:8:1$MeUNDVbMuv36ti7E$7cc6244aed454c68cdd1e2da68b146ad07710d49cd4ef5f5f9a0aeda09861be6741c6fd9b4e535c129d10fda7885d701c1a4f28ff41e36374a4a74354b05304b'),
(40, 'test_pred_1752602092@example.com', 'scrypt:32768:8:1$LFHfjiBMrzmcFQzd$f702794ba57c89290f7b7749403b39b98a678ed48bcc7624a0440af6ba1b431a863c78baf60ca7a64c20212afd57c10744297628b0c8345d7971811c7ed12245'),
(41, 'test_pred_1752602093@example.com', 'scrypt:32768:8:1$ShmbHkRx0vd2u2rW$ce01a4b1922676597f6e10e662fa63ce13792d0ed91fcd16dc3c7490005c75205be217352d5e5c846dd57735c157586428d2b5d26f5d01cf9d3768be427b3db8'),
(42, 'test_pred_1752602094@example.com', 'scrypt:32768:8:1$beDjevPhLP6ZfQbr$437ab5d34fe9e789aa30e0d582234efc7c24320762f837a75a92e2ad2cbce64f56a2afd58b74089f6db82b965d72efa84085ad155d1246d2f7e76e22bd657c29'),
(43, 'test_pred_1752602096@example.com', 'scrypt:32768:8:1$mLHZhocpqp1d0vQD$27c155bf32a04227c5a68eb294eded49ebb01b404fcc89daa0cbc817641f800cffc3ed747f325c2de7b9fc10e2f2a7ce8b6c3a9200e16a59a4e831fcada3c14f'),
(44, 'test_1752602169@example.com', 'scrypt:32768:8:1$eSz3fZ9xEqJPPu7R$a0ef1ec0c933723bd00285273f516f63fd80392d78833f4cec4d36a1d4c9dc707c3cf387061a8f61ac415aa0c6b96145feaef307dd2ef67864b34d2f47c50ee2'),
(45, 'test_1752602172@example.com', 'scrypt:32768:8:1$srH6QpsEbfLXbtBk$54b160a70116caa8a10cf6d5f6e82ce999d8c45a446be149e59d3fb9fa2890c300298ff38f6ed6bc9462bb3885d58adba93f865ae6ea3310e8ca23686db264c0'),
(46, 'test_1752602173@example.com', 'scrypt:32768:8:1$Ke6NAJoaTeXE33W4$b8535db4f983ecef9daec259979705948b5de81fc2de312ed7f013820ceaa18cbb645715c73f8911586d58d2a12980f156a8d7a9379efcce252b656bd83e7415'),
(47, 'test_1752602175@example.com', 'scrypt:32768:8:1$lQDGmUFJN5vFubeh$4fb48b2c2aa14a40f0dcc064c13f65e287fee4505fcf158f823842e8edae12d3cebfbb107455f167ddb2d085e1c26577289815b49881f1c8848d201a46c809e3'),
(48, 'test_1752602210@example.com', 'scrypt:32768:8:1$dirwqBRzLRL7QNPi$53419262d0f7a23f9a17bfaf0ffbce73d427a9480ef9b558f2e2f7c8af05646389994aa6b9025095d8af97e2da086b23eb0dae490b8c6e840f18d64215dfb595'),
(49, 'test_1752602211@example.com', 'scrypt:32768:8:1$Hx10rh8XJqRbvcTX$419e96901e42221d9b8bfb34a9f11955e76b1bcf3222595165c84f9131251ba34fecac5b6cb2c8bcbf869ab67338b0df521086de7b3f2cd5f9fcf933a0e1f9a1'),
(50, 'test_1752602212@example.com', 'scrypt:32768:8:1$pHxuXhjyMoBeoXBo$479aca7045b6cf035ae7fd693be8370f3513f1769f4ed6566686a4168da75bd99d003da1bb0f8ba45694d0af37fb94a7b908e2a3c00ac99d39c308eba3c428a1'),
(51, 'test_1752602215@example.com', 'scrypt:32768:8:1$gue9E4R0umFUbJPC$7f327830dc9503dea2f555def6ad7495ef087e114f592e81802a578951f38fee4e31f1e679edabc4b7533469add5a65990378689054a7db940fdf2e5b79d7e3f'),
(52, 'once_test_1752602281@example.com', 'scrypt:32768:8:1$h8k3vWcGmnE15JKB$059d1ba2c1d63f48e52083246af4730e2ef81df278f1b81c797dac6f3c78e2ed5a737f074b6a7c5883c522e5556c50f0030d84046cc03f743f6c9f49be53e72a'),
(53, 'test_keamanan_nb5vyqw9@example.com', 'scrypt:32768:8:1$y6mm1H9mOs0wmzSq$10a1ea09d4ce6f7157e74d334003fb9e925a9b6eada3a141a9ef5175c733d7c454f82611a25d8b2d9e23a6ba64e472fc6b65f1cba712ad8cfe6990d4ac1818fd'),
(54, 'weak_1752603163@example.com', 'scrypt:32768:8:1$5W1eyBSyfrHoW0zG$a0f4d95fed2231d03deeb66c57477baabda919ea6bada557e57cbfef609caf9837e394ad22d6ccc56c6a0f0a95cfb197ae23e106fb4c3843d1da59ed4f193d95'),
(55, 'strong_1752603163@example.com', 'scrypt:32768:8:1$yKXWtPuAifbihslR$abe22218bfd5b47aca2504608b04b7a4d5accad55d6473768fab57b0bf9fe33c688f503c108e9c6d77b0ba0e8f0e54aec5b7808ef2ab72bba7a78375dfac60fa');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `botol_default`
--
ALTER TABLE `botol_default`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `botol_kustom`
--
ALTER TABLE `botol_kustom`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `detail_user`
--
ALTER TABLE `detail_user`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `kompetisi`
--
ALTER TABLE `kompetisi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `kompetisi_konsumsi`
--
ALTER TABLE `kompetisi_konsumsi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kompetisi_id` (`kompetisi_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `kompetisi_peserta`
--
ALTER TABLE `kompetisi_peserta`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kompetisi_id` (`kompetisi_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `pencapaian`
--
ALTER TABLE `pencapaian`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pencapaian_pengguna`
--
ALTER TABLE `pencapaian_pengguna`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pencapaian_id` (`pencapaian_id`);

--
-- Indexes for table `pertemanan`
--
ALTER TABLE `pertemanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`friend_id`),
  ADD KEY `friend_id` (`friend_id`);

--
-- Indexes for table `riwayat_konsumsi`
--
ALTER TABLE `riwayat_konsumsi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `botol_id` (`botol_id`);

--
-- Indexes for table `riwayat_prediksi`
--
ALTER TABLE `riwayat_prediksi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `streak_pengguna`
--
ALTER TABLE `streak_pengguna`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `botol_default`
--
ALTER TABLE `botol_default`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `botol_kustom`
--
ALTER TABLE `botol_kustom`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `detail_user`
--
ALTER TABLE `detail_user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `kompetisi`
--
ALTER TABLE `kompetisi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `kompetisi_konsumsi`
--
ALTER TABLE `kompetisi_konsumsi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `kompetisi_peserta`
--
ALTER TABLE `kompetisi_peserta`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `pencapaian`
--
ALTER TABLE `pencapaian`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `pencapaian_pengguna`
--
ALTER TABLE `pencapaian_pengguna`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1333;

--
-- AUTO_INCREMENT for table `pertemanan`
--
ALTER TABLE `pertemanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `riwayat_konsumsi`
--
ALTER TABLE `riwayat_konsumsi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT for table `riwayat_prediksi`
--
ALTER TABLE `riwayat_prediksi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT for table `streak_pengguna`
--
ALTER TABLE `streak_pengguna`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `botol_kustom`
--
ALTER TABLE `botol_kustom`
  ADD CONSTRAINT `botol_kustom_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `detail_user`
--
ALTER TABLE `detail_user`
  ADD CONSTRAINT `detail_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kompetisi`
--
ALTER TABLE `kompetisi`
  ADD CONSTRAINT `kompetisi_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `kompetisi_konsumsi`
--
ALTER TABLE `kompetisi_konsumsi`
  ADD CONSTRAINT `kompetisi_konsumsi_ibfk_1` FOREIGN KEY (`kompetisi_id`) REFERENCES `kompetisi` (`id`),
  ADD CONSTRAINT `kompetisi_konsumsi_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `kompetisi_peserta`
--
ALTER TABLE `kompetisi_peserta`
  ADD CONSTRAINT `kompetisi_peserta_ibfk_1` FOREIGN KEY (`kompetisi_id`) REFERENCES `kompetisi` (`id`),
  ADD CONSTRAINT `kompetisi_peserta_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `pencapaian_pengguna`
--
ALTER TABLE `pencapaian_pengguna`
  ADD CONSTRAINT `pencapaian_pengguna_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `pencapaian_pengguna_ibfk_2` FOREIGN KEY (`pencapaian_id`) REFERENCES `pencapaian` (`id`);

--
-- Constraints for table `pertemanan`
--
ALTER TABLE `pertemanan`
  ADD CONSTRAINT `pertemanan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `pertemanan_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `riwayat_konsumsi`
--
ALTER TABLE `riwayat_konsumsi`
  ADD CONSTRAINT `riwayat_konsumsi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `riwayat_konsumsi_ibfk_2` FOREIGN KEY (`botol_id`) REFERENCES `botol_kustom` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `riwayat_prediksi`
--
ALTER TABLE `riwayat_prediksi`
  ADD CONSTRAINT `riwayat_prediksi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
