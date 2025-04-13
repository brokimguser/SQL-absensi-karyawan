-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 13, 2025 at 02:07 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uts_dbl_absensiperhotelan`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `proses_persetujuan_cuti` (IN `p_user_id` INT, IN `p_cuti_id` INT, IN `p_status` VARCHAR(20))   BEGIN
    -- Pastikan hanya status valid yang bisa dimasukkan
    IF p_status IN ('disetujui', 'ditolak') THEN
        UPDATE request_cuti
        SET status = p_status
        WHERE id = p_cuti_id AND user_id = p_user_id AND status = 'diajukan';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rekap_absensi_karyawan` (IN `p_user_id` INT)   BEGIN
    DECLARE jml_hadir INT DEFAULT 0;
    DECLARE jml_sakit INT DEFAULT 0;
    DECLARE jml_izin INT DEFAULT 0;
    DECLARE jml_alpha INT DEFAULT 0;
    DECLARE jml_terlambat INT DEFAULT 0;
    DECLARE jml_cuti INT DEFAULT 0;
    DECLARE jml_sakit_izin INT DEFAULT 0;

    SELECT COUNT(*) INTO jml_hadir
    FROM kehadiran
    WHERE user_id = p_user_id AND status = 'hadir';

    SELECT COUNT(*) INTO jml_sakit
    FROM kehadiran
    WHERE user_id = p_user_id AND status = 'sakit';

    SELECT COUNT(*) INTO jml_izin
    FROM kehadiran
    WHERE user_id = p_user_id AND status = 'izin';

    SELECT COUNT(*) INTO jml_alpha
    FROM kehadiran
    WHERE user_id = p_user_id AND status = 'alpha';

    SELECT COUNT(*) INTO jml_terlambat
    FROM kehadiran
    WHERE user_id = p_user_id AND jam_masuk > '08:00:00' AND status = 'hadir';

    SELECT COUNT(*) INTO jml_cuti
    FROM request_cuti
    WHERE user_id = p_user_id AND status = 'disetujui';

    SET jml_sakit_izin = jml_sakit + jml_izin;

    SELECT 
        jml_hadir AS hadir,
        jml_sakit AS sakit,
        jml_izin AS izin,
        jml_alpha AS alpha,
        jml_terlambat AS terlambat,
        jml_cuti AS cuti,
        jml_sakit_izin AS total_sakit_izin;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ubah_status_kehadiran` (`p_id` INT, `p_status` VARCHAR(50))   BEGIN
    UPDATE kehadiran
    SET status = p_status
    WHERE id = p_id;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `hitung_hari_cuti` (`p_user_id` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE total_hari INT;

    SELECT 
        IFNULL(SUM(DATEDIFF(tanggal_selesai, tanggal_mulai) + 1), 0)
    INTO total_hari
    FROM request_cuti
    WHERE user_id = p_user_id AND status = 'disetujui';

    RETURN total_hari;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hitung_jam_kerja` (`p_user_id` INT, `p_tanggal` DATE) RETURNS TIME DETERMINISTIC BEGIN
    DECLARE total_jam TIME;

    SELECT TIMEDIFF(jam_keluar, jam_masuk) INTO total_jam
    FROM kehadiran
    WHERE user_id = p_user_id AND tanggal = p_tanggal AND jam_masuk IS NOT NULL AND jam_keluar IS NOT NULL;

    RETURN total_jam;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `jumlah_cuti_karyawan` (`p_user_id` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE total_cuti INT;

    -- Hitung jumlah total baris cuti berdasarkan user_id
    SELECT COUNT(*) INTO total_cuti
    FROM request_cuti
    WHERE user_id = p_user_id AND status = 'disetujui';

    RETURN total_cuti;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `user_id`, `nama`, `email`, `password`, `role`) VALUES
(1, 3, 'Clara Wijaya', 'clara@gmail.com', 'pass789', 'admin'),
(2, 6, 'Fina Maharani', 'fina@gmail.com', 'pass987', 'admin');

-- --------------------------------------------------------

--
-- Table structure for table `departemen`
--

CREATE TABLE `departemen` (
  `dept_id` int(11) NOT NULL,
  `nama_dept` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departemen`
--

INSERT INTO `departemen` (`dept_id`, `nama_dept`) VALUES
(1, 'HRD'),
(2, 'IT Support'),
(3, 'Housekeeping'),
(4, 'Front Office'),
(5, 'Food & Beverage'),
(6, 'Maintenance'),
(7, 'Security'),
(8, 'Sales & Marketing');

-- --------------------------------------------------------

--
-- Table structure for table `karyawan`
--

CREATE TABLE `karyawan` (
  `karyawan_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `karyawan`
--

INSERT INTO `karyawan` (`karyawan_id`, `user_id`, `nama`, `email`, `password`, `role`) VALUES
(1, 1, 'Andi Pratama', 'andi@gmail.com', 'pass123', 'HR Staff'),
(2, 2, 'Budi Santoso', 'budi@gmail.com', 'pass456', 'IT Technician'),
(3, 4, 'Dina Lestari', 'dina@gmail.com', 'pass321', 'Room Attendant'),
(4, 5, 'Eko Nugroho', 'eko@gmail.com', 'pass654', 'Receptionist'),
(5, 7, 'Gilang Saputra', 'gilang@gmail.com', 'pass111', 'Waiter'),
(6, 8, 'Hana Fitriani', 'hana@gmail.com', 'pass222', 'Maintenance Staff'),
(7, 9, 'Ivan Rachman', 'ivan@gmail.com', 'pass333', 'Security Officer'),
(8, 10, 'Joko Susilo', 'joko@gmail.com', 'pass444', 'Sales Executive');

-- --------------------------------------------------------

--
-- Table structure for table `kehadiran`
--

CREATE TABLE `kehadiran` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `karyawan_id` int(11) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `jam_masuk` time DEFAULT NULL,
  `jam_keluar` time DEFAULT NULL,
  `alasan` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kehadiran`
--

INSERT INTO `kehadiran` (`id`, `user_id`, `karyawan_id`, `tanggal`, `jam_masuk`, `jam_keluar`, `alasan`, `status`) VALUES
(1, 1, 1, '2025-04-01', '08:00:00', '17:00:00', NULL, 'hadir'),
(2, 2, 2, '2025-04-01', NULL, NULL, 'Sakit demam', 'sakit'),
(3, 1, 1, '2025-04-02', '08:10:00', '17:05:00', NULL, 'hadir'),
(4, 2, 2, '2025-04-02', NULL, NULL, NULL, 'alpha'),
(5, 4, 3, '2025-04-01', '08:05:00', '17:00:00', NULL, 'hadir'),
(6, 5, 4, '2025-04-01', '08:00:00', '17:00:00', NULL, 'hadir'),
(7, 7, 5, '2025-04-01', NULL, NULL, 'Izin keluarga', 'izin'),
(8, 8, 6, '2025-04-01', '08:15:00', '17:10:00', NULL, 'hadir'),
(9, 9, 7, '2025-04-01', NULL, NULL, NULL, 'alpha'),
(10, 10, 8, '2025-04-01', '08:00:00', '17:00:00', NULL, 'hadir');

--
-- Triggers `kehadiran`
--
DELIMITER $$
CREATE TRIGGER `cek_absensi_terlambat` BEFORE INSERT ON `kehadiran` FOR EACH ROW BEGIN
    -- Mengecek apakah jam masuk terlambat (lebih dari jam 09:00:00)
    IF NEW.jam_masuk > '09:00:00' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Anda tidak dapat melakukan absensi setelah jam 09:00:00.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cek_default_kehadiran` BEFORE INSERT ON `kehadiran` FOR EACH ROW BEGIN
-- jika status kehadiran kosong (NULL), maka sistem akan otomatis mengisikan status 'alpha' pada kolom status.
	IF new.status is NULL THEN
    SET new.status = 'alpha';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `request_cuti`
--

CREATE TABLE `request_cuti` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `tanggal_pengajuan` date DEFAULT NULL,
  `tanggal_mulai` date DEFAULT NULL,
  `tanggal_selesai` date DEFAULT NULL,
  `keterangan` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `request_cuti`
--

INSERT INTO `request_cuti` (`id`, `user_id`, `dept_id`, `tanggal_pengajuan`, `tanggal_mulai`, `tanggal_selesai`, `keterangan`, `status`) VALUES
(1, 1, 1, '2025-03-25', '2025-04-03', '2025-04-05', 'Cuti keluarga', 'disetujui'),
(2, 2, 2, '2025-03-26', '2025-04-06', '2025-04-07', 'Cuti pribadi', 'diajukan'),
(3, 4, 3, '2025-03-27', '2025-04-08', '2025-04-09', 'Liburan', 'disetujui'),
(4, 5, 4, '2025-03-28', '2025-04-10', '2025-04-12', 'Menikah', 'disetujui'),
(5, 7, 5, '2025-03-29', '2025-04-13', '2025-04-14', 'Urusan keluarga', 'diajukan'),
(6, 8, 6, '2025-03-30', '2025-04-15', '2025-04-17', 'Liburan', 'diajukan'),
(7, 9, 7, '2025-04-01', '2025-04-18', '2025-04-19', 'Cuti pribadi', 'ditolak'),
(8, 10, 8, '2025-04-02', '2025-04-20', '2025-04-21', 'Cuti tahunan', 'diajukan'),
(9, 1, 1, '2025-04-03', '2025-04-22', '2025-04-24', 'Cuti keluarga', 'disetujui'),
(10, 2, 2, '2025-04-04', '2025-04-25', '2025-04-26', 'Cuti libur', 'diajukan');

--
-- Triggers `request_cuti`
--
DELIMITER $$
CREATE TRIGGER `limit_pengambilan_cuti` BEFORE INSERT ON `request_cuti` FOR EACH ROW BEGIN
    DECLARE jumlah_cuti INT;

    -- Hitung berapa kali user ini sudah mengambil cuti di tahun yang sama
    SELECT COUNT(*) INTO jumlah_cuti
    FROM request_cuti
    WHERE user_id = NEW.user_id
      AND YEAR(tanggal_mulai) = YEAR(NEW.tanggal_mulai);

    -- Kalau sudah 12 kali atau lebih, tolak pengajuan
    IF jumlah_cuti >= 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pengambilan cuti sudah mencapai batas maksimum 12 kali dalam setahun.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `statistik_cuti`
-- (See below for the actual view)
--
CREATE TABLE `statistik_cuti` (
`nama` varchar(100)
,`total_cuti_diajukan` bigint(21)
,`total_cuti_disetujui` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `nama`, `email`, `password`, `phone_number`, `role`) VALUES
(1, 'Andi Pratama', 'andi@gmail.com', 'pass123', '081234567890', 'HR Staff'),
(2, 'Budi Santoso', 'budi@gmail.com', 'pass456', '081234567891', 'IT Technician'),
(3, 'Clara Wijaya', 'clara@gmail.com', 'pass789', '081234567892', 'HR Admin'),
(4, 'Dina Lestari', 'dina@gmail.com', 'pass321', '081234567893', 'Room Attendant'),
(5, 'Eko Nugroho', 'eko@gmail.com', 'pass654', '081234567894', 'Receptionist'),
(6, 'Fina Maharani', 'fina@gmail.com', 'pass987', '081234567895', 'General Admin'),
(7, 'Gilang Saputra', 'gilang@gmail.com', 'pass111', '081234567896', 'Waiter'),
(8, 'Hana Fitriani', 'hana@gmail.com', 'pass222', '081234567897', 'Maintenance Staff'),
(9, 'Ivan Rachman', 'ivan@gmail.com', 'pass333', '081234567898', 'Security Officer'),
(10, 'Joko Susilo', 'joko@gmail.com', 'pass444', '081234567899', 'Sales Executive');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_karyawan_detail`
-- (See below for the actual view)
--
CREATE TABLE `view_karyawan_detail` (
`karyawan_nama` varchar(100)
,`karyawan_email` varchar(100)
,`karyawan_phone_number` varchar(20)
,`karyawan_role` varchar(50)
,`departemen` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_statistik_kehadiran`
-- (See below for the actual view)
--
CREATE TABLE `v_statistik_kehadiran` (
`karyawan_id` int(11)
,`nama` varchar(100)
,`total_hadir` bigint(21)
,`total_tidak_masuk` bigint(21)
,`total_terlambat` bigint(21)
,`persentase_kehadiran` decimal(26,2)
,`rata_rata_jam_masuk` time(4)
,`rata_rata_jam_keluar` time(4)
);

-- --------------------------------------------------------

--
-- Structure for view `statistik_cuti`
--
DROP TABLE IF EXISTS `statistik_cuti`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `statistik_cuti`  AS SELECT `k`.`nama` AS `nama`, count(case when `c`.`status` = 'Diajukan' then 1 end) AS `total_cuti_diajukan`, count(case when `c`.`status` = 'Disetujui' then 1 end) AS `total_cuti_disetujui` FROM (`request_cuti` `c` join `karyawan` `k` on(`c`.`user_id` = `k`.`karyawan_id`)) GROUP BY `k`.`nama` ;

-- --------------------------------------------------------

--
-- Structure for view `view_karyawan_detail`
--
DROP TABLE IF EXISTS `view_karyawan_detail`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_karyawan_detail`  AS SELECT `u`.`nama` AS `karyawan_nama`, `u`.`email` AS `karyawan_email`, `u`.`phone_number` AS `karyawan_phone_number`, `u`.`role` AS `karyawan_role`, `d`.`nama_dept` AS `departemen` FROM ((`karyawan` `ka` join `user` `u` on(`ka`.`user_id` = `u`.`user_id`)) join `departemen` `d` on(`ka`.`karyawan_id` = `d`.`dept_id`)) ORDER BY `u`.`nama` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `v_statistik_kehadiran`
--
DROP TABLE IF EXISTS `v_statistik_kehadiran`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_statistik_kehadiran`  AS SELECT `k`.`karyawan_id` AS `karyawan_id`, `k`.`nama` AS `nama`, count(case when `a`.`status` = 'Hadir' then 1 end) AS `total_hadir`, count(case when `a`.`status` = 'Alpha' then 1 end) AS `total_tidak_masuk`, count(case when `a`.`jam_masuk` > '09:00:00' then 1 end) AS `total_terlambat`, round(count(case when `a`.`status` = 'Hadir' then 1 end) * 100.0 / nullif(count(`a`.`id`),0),2) AS `persentase_kehadiran`, sec_to_time(avg(time_to_sec(`a`.`jam_masuk`))) AS `rata_rata_jam_masuk`, sec_to_time(avg(time_to_sec(`a`.`jam_keluar`))) AS `rata_rata_jam_keluar` FROM (`karyawan` `k` left join `kehadiran` `a` on(`k`.`karyawan_id` = `a`.`karyawan_id`)) GROUP BY `k`.`karyawan_id`, `k`.`nama` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `departemen`
--
ALTER TABLE `departemen`
  ADD PRIMARY KEY (`dept_id`);

--
-- Indexes for table `karyawan`
--
ALTER TABLE `karyawan`
  ADD PRIMARY KEY (`karyawan_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `kehadiran`
--
ALTER TABLE `kehadiran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `karyawan_id` (`karyawan_id`);

--
-- Indexes for table `request_cuti`
--
ALTER TABLE `request_cuti`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `dept_id` (`dept_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `karyawan`
--
ALTER TABLE `karyawan`
  ADD CONSTRAINT `karyawan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `kehadiran`
--
ALTER TABLE `kehadiran`
  ADD CONSTRAINT `kehadiran_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `kehadiran_ibfk_2` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`karyawan_id`);

--
-- Constraints for table `request_cuti`
--
ALTER TABLE `request_cuti`
  ADD CONSTRAINT `request_cuti_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `request_cuti_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `departemen` (`dept_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
