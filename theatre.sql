-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1
-- Время создания: Окт 12 2025 г., 18:40
-- Версия сервера: 10.4.32-MariaDB
-- Версия PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `theatre`
--

-- --------------------------------------------------------

--
-- Структура таблицы `admin_setting`
--

CREATE TABLE `admin_setting` (
  `id` int(10) UNSIGNED NOT NULL,
  `skey` varchar(100) NOT NULL,
  `svalue` longtext NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `admin_setting`
--

INSERT INTO `admin_setting` (`id`, `skey`, `svalue`, `updated_at`) VALUES
(1, 'security.password_policy', '{ \"min_length\": 8, \"require_digits\": true, \"require_upper\": false }', NULL),
(2, 'backup.policy', '{ \"enabled\": true, \"retention_days\": 14 }', NULL),
(3, 'marketing.utm_default', '{ \"source\":\"site\", \"medium\":\"email\" }', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `auth_log`
--

CREATE TABLE `auth_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `attempted_login` varchar(64) NOT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `is_success` tinyint(1) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `backup_log`
--

CREATE TABLE `backup_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `started_at` datetime NOT NULL,
  `finished_at` datetime DEFAULT NULL,
  `status` enum('started','success','failed') NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `message` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `email_queue`
--

CREATE TABLE `email_queue` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `body_text` text NOT NULL,
  `is_sent` tinyint(1) NOT NULL DEFAULT 0,
  `error_msg` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `sent_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `hall`
--

CREATE TABLE `hall` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `venue` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `hall`
--

INSERT INTO `hall` (`id`, `name`, `venue`) VALUES
(1, 'Большой зал', 'Главная сцена');

-- --------------------------------------------------------

--
-- Структура таблицы `integration`
--

CREATE TABLE `integration` (
  `id` int(10) UNSIGNED NOT NULL,
  `type` enum('payment','email','marketing','analytics') NOT NULL,
  `name` varchar(100) NOT NULL,
  `config` longtext NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `buyer_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `email_to` varchar(255) NOT NULL,
  `payment_method_id` int(10) UNSIGNED NOT NULL,
  `payment_status` enum('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Триггеры `orders`
--
DELIMITER $$
CREATE TRIGGER `trg_orders_bi_chk` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
IF NEW.email_to NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'orders.email_to: некорректный e-mail';
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_orders_bu_chk` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
IF NEW.email_to NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'orders.email_to: некорректный e-mail';
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `payments`
--

CREATE TABLE `payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `method_id` int(10) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'RUB',
  `status` enum('initiated','authorized','captured','failed','refunded') NOT NULL,
  `transaction_ref` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `payment_method`
--

CREATE TABLE `payment_method` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `payment_method`
--

INSERT INTO `payment_method` (`id`, `code`, `name`, `is_active`) VALUES
(1, 'cash', 'Наличные', 1),
(2, 'card', 'Банковская карта', 1),
(3, 'online', 'Онлайн-платёж', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `performance`
--

CREATE TABLE `performance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `production_id` int(10) UNSIGNED NOT NULL,
  `hall_id` int(10) UNSIGNED NOT NULL,
  `starts_at` datetime NOT NULL,
  `base_price` decimal(10,2) NOT NULL,
  `status` enum('scheduled','canceled','finished') NOT NULL DEFAULT 'scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `performance`
--

INSERT INTO `performance` (`id`, `production_id`, `hall_id`, `starts_at`, `base_price`, `status`) VALUES
(1, 1, 1, '2025-10-17 19:00:00', 1500.00, 'scheduled');

-- --------------------------------------------------------

--
-- Структура таблицы `permissions`
--

CREATE TABLE `permissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(100) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `permissions`
--

INSERT INTO `permissions` (`id`, `code`, `name`) VALUES
(1, 'tickets.manage', 'Управление билетами'),
(2, 'reports.view', 'Просмотр отчётности'),
(3, 'settings.edit', 'Изменение настроек'),
(4, 'users.manage', 'Управление пользователями');

-- --------------------------------------------------------

--
-- Структура таблицы `production`
--

CREATE TABLE `production` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(200) NOT NULL,
  `genre` varchar(100) DEFAULT NULL,
  `duration_min` int(10) UNSIGNED DEFAULT NULL,
  `age_rating` varchar(10) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `production`
--

INSERT INTO `production` (`id`, `title`, `genre`, `duration_min`, `age_rating`, `description`) VALUES
(1, 'Щелкунчик', 'Балет', 110, '6+', 'Классическая постановка.');

-- --------------------------------------------------------

--
-- Структура таблицы `roles`
--

CREATE TABLE `roles` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `roles`
--

INSERT INTO `roles` (`id`, `code`, `name`) VALUES
(1, 'admin', 'Администратор'),
(2, 'cashier', 'Кассир'),
(3, 'user', 'Покупатель');

-- --------------------------------------------------------

--
-- Структура таблицы `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_id` int(10) UNSIGNED NOT NULL,
  `permission_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `role_permissions`
--

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4);

-- --------------------------------------------------------

--
-- Структура таблицы `seat`
--

CREATE TABLE `seat` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hall_id` int(10) UNSIGNED NOT NULL,
  `row_number` int(10) UNSIGNED NOT NULL,
  `seat_number` int(10) UNSIGNED NOT NULL,
  `zone_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `seat`
--

INSERT INTO `seat` (`id`, `hall_id`, `row_number`, `seat_number`, `zone_id`) VALUES
(1, 1, 1, 1, 1),
(2, 1, 2, 1, 2),
(3, 1, 3, 1, 3),
(4, 1, 1, 2, 1),
(5, 1, 2, 2, 2),
(6, 1, 3, 2, 3),
(7, 1, 1, 3, 1),
(8, 1, 2, 3, 2),
(9, 1, 3, 3, 3),
(10, 1, 1, 4, 1),
(11, 1, 2, 4, 2),
(12, 1, 3, 4, 3),
(13, 1, 1, 5, 1),
(14, 1, 2, 5, 2),
(15, 1, 3, 5, 3);

-- --------------------------------------------------------

--
-- Структура таблицы `seat_zone`
--

CREATE TABLE `seat_zone` (
  `id` int(10) UNSIGNED NOT NULL,
  `hall_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `price_mult` decimal(5,2) NOT NULL DEFAULT 1.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `seat_zone`
--

INSERT INTO `seat_zone` (`id`, `hall_id`, `name`, `price_mult`) VALUES
(1, 1, 'Партер', 1.20),
(2, 1, 'Амфитеатр', 1.00),
(3, 1, 'Балкон', 0.85);

-- --------------------------------------------------------

--
-- Структура таблицы `ticket`
--

CREATE TABLE `ticket` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `performance_id` bigint(20) UNSIGNED NOT NULL,
  `seat_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('reserved','sold','returned','blocked') NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reserved_until` datetime DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `ticket`
--

INSERT INTO `ticket` (`id`, `performance_id`, `seat_id`, `status`, `price`, `order_id`, `reserved_until`, `updated_at`) VALUES
(1, 1, 1, 'reserved', 1800.00, NULL, '2025-10-10 14:32:05', NULL),
(2, 1, 4, 'reserved', 1800.00, NULL, '2025-10-10 14:32:05', NULL),
(3, 1, 7, 'reserved', 1800.00, NULL, '2025-10-10 14:32:05', NULL),
(4, 1, 10, 'reserved', 1800.00, NULL, '2025-10-10 14:32:05', NULL),
(5, 1, 13, 'reserved', 1800.00, NULL, '2025-10-10 14:32:05', NULL),
(6, 1, 2, 'reserved', 1500.00, NULL, '2025-10-10 14:32:05', NULL),
(7, 1, 5, 'reserved', 1500.00, NULL, '2025-10-10 14:32:05', NULL),
(8, 1, 8, 'reserved', 1500.00, NULL, '2025-10-10 14:32:05', NULL),
(9, 1, 11, 'reserved', 1500.00, NULL, '2025-10-10 14:32:05', NULL),
(10, 1, 14, 'reserved', 1500.00, NULL, '2025-10-10 14:32:05', NULL),
(11, 1, 3, 'reserved', 1275.00, NULL, '2025-10-10 14:32:05', NULL),
(12, 1, 6, 'reserved', 1275.00, NULL, '2025-10-10 14:32:05', NULL),
(13, 1, 9, 'reserved', 1275.00, NULL, '2025-10-10 14:32:05', NULL),
(14, 1, 12, 'reserved', 1275.00, NULL, '2025-10-10 14:32:05', NULL),
(15, 1, 15, 'reserved', 1275.00, NULL, '2025-10-10 14:32:05', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `login` varchar(64) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(200) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `role_id` int(10) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `login`, `password_hash`, `full_name`, `phone`, `email`, `role_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'admin123', '$2y$10$replace_this_hash_with_real_bcrypt', 'Системный Администратор', '8(999)000-00-00', 'admin@example.com', 1, 1, '2025-10-10 09:32:05', NULL);

--
-- Триггеры `users`
--
DELIMITER $$
CREATE TRIGGER `trg_users_bi_chk` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
IF NEW.login NOT REGEXP '^[A-Za-z0-9]{6,}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'login: только латиница/цифры, ≥6 символов';
END IF;
IF NEW.phone NOT REGEXP '^8([0-9]{3})[0-9]{3}-[0-9]{2}-[0-9]{2}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'phone: формат 8(XXX)XXX-XX-XX';
END IF;
IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'email: некорректный формат';
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_users_bu_chk` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
IF NEW.login NOT REGEXP '^[A-Za-z0-9]{6,}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'login: только латиница/цифры, ≥6 символов';
END IF;
IF NEW.phone NOT REGEXP '^8([0-9]{3})[0-9]{3}-[0-9]{2}-[0-9]{2}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'phone: формат 8(XXX)XXX-XX-XX';
END IF;
IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'email: некорректный формат';
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `v_occupancy`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `v_occupancy` (
`performance_id` bigint(20) unsigned
,`title` varchar(200)
,`starts_at` datetime
,`issued_tickets` bigint(21)
,`sold` decimal(22,0)
,`reserved` decimal(22,0)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `v_revenue_daily`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `v_revenue_daily` (
`day` date
,`revenue` decimal(34,2)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `v_sales_by_performance`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `v_sales_by_performance` (
`performance_id` bigint(20) unsigned
,`production_title` varchar(200)
,`starts_at` datetime
,`hall_name` varchar(100)
,`sold_count` decimal(22,0)
,`returned_count` decimal(22,0)
,`total_tickets` bigint(21)
,`revenue` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Структура для представления `v_occupancy`
--
DROP TABLE IF EXISTS `v_occupancy`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_occupancy`  AS SELECT `p`.`id` AS `performance_id`, `pr`.`title` AS `title`, `p`.`starts_at` AS `starts_at`, count(`t`.`id`) AS `issued_tickets`, sum(case when `t`.`status` = 'sold' then 1 else 0 end) AS `sold`, sum(case when `t`.`status` = 'reserved' then 1 else 0 end) AS `reserved` FROM ((`performance` `p` join `production` `pr` on(`pr`.`id` = `p`.`production_id`)) left join `ticket` `t` on(`t`.`performance_id` = `p`.`id`)) GROUP BY `p`.`id` ;

-- --------------------------------------------------------

--
-- Структура для представления `v_revenue_daily`
--
DROP TABLE IF EXISTS `v_revenue_daily`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_revenue_daily`  AS SELECT cast(`o`.`paid_at` as date) AS `day`, sum(case when `o`.`payment_status` = 'paid' then `o`.`total_amount` else 0 end) AS `revenue` FROM `orders` AS `o` GROUP BY cast(`o`.`paid_at` as date) ;

-- --------------------------------------------------------

--
-- Структура для представления `v_sales_by_performance`
--
DROP TABLE IF EXISTS `v_sales_by_performance`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_sales_by_performance`  AS SELECT `p`.`id` AS `performance_id`, `pr`.`title` AS `production_title`, `p`.`starts_at` AS `starts_at`, `h`.`name` AS `hall_name`, sum(case when `t`.`status` = 'sold' then 1 else 0 end) AS `sold_count`, sum(case when `t`.`status` = 'returned' then 1 else 0 end) AS `returned_count`, count(`t`.`id`) AS `total_tickets`, sum(case when `t`.`status` = 'sold' then `t`.`price` else 0 end) AS `revenue` FROM (((`performance` `p` join `production` `pr` on(`pr`.`id` = `p`.`production_id`)) join `hall` `h` on(`h`.`id` = `p`.`hall_id`)) left join `ticket` `t` on(`t`.`performance_id` = `p`.`id`)) GROUP BY `p`.`id` ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `admin_setting`
--
ALTER TABLE `admin_setting`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `skey` (`skey`);

--
-- Индексы таблицы `auth_log`
--
ALTER TABLE `auth_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attempted_login` (`attempted_login`),
  ADD KEY `created_at` (`created_at`),
  ADD KEY `fk_authlog_user` (`user_id`);

--
-- Индексы таблицы `backup_log`
--
ALTER TABLE `backup_log`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `email_queue`
--
ALTER TABLE `email_queue`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `hall`
--
ALTER TABLE `hall`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `integration`
--
ALTER TABLE `integration`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_orders_buyer` (`buyer_user_id`),
  ADD KEY `fk_orders_pm` (`payment_method_id`);

--
-- Индексы таблицы `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transaction_ref` (`transaction_ref`),
  ADD KEY `fk_pay_order` (`order_id`),
  ADD KEY `fk_pay_method` (`method_id`);

--
-- Индексы таблицы `payment_method`
--
ALTER TABLE `payment_method`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `performance`
--
ALTER TABLE `performance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `starts_at` (`starts_at`),
  ADD KEY `hall_id` (`hall_id`,`starts_at`),
  ADD KEY `fk_perf_prod` (`production_id`);

--
-- Индексы таблицы `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `production`
--
ALTER TABLE `production`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `fk_rp_perm` (`permission_id`);

--
-- Индексы таблицы `seat`
--
ALTER TABLE `seat`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_seat` (`hall_id`,`row_number`,`seat_number`),
  ADD KEY `fk_seat_zone` (`zone_id`);

--
-- Индексы таблицы `seat_zone`
--
ALTER TABLE `seat_zone`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_zone` (`hall_id`,`name`);

--
-- Индексы таблицы `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_perf_seat` (`performance_id`,`seat_id`),
  ADD KEY `status` (`status`),
  ADD KEY `performance_id` (`performance_id`,`status`),
  ADD KEY `fk_ticket_seat` (`seat_id`),
  ADD KEY `fk_ticket_order` (`order_id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `login` (`login`),
  ADD KEY `idx_users_email` (`email`),
  ADD KEY `fk_users_role` (`role_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `admin_setting`
--
ALTER TABLE `admin_setting`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `auth_log`
--
ALTER TABLE `auth_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `backup_log`
--
ALTER TABLE `backup_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `email_queue`
--
ALTER TABLE `email_queue`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `hall`
--
ALTER TABLE `hall`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `integration`
--
ALTER TABLE `integration`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `payment_method`
--
ALTER TABLE `payment_method`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `performance`
--
ALTER TABLE `performance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT для таблицы `production`
--
ALTER TABLE `production`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `seat`
--
ALTER TABLE `seat`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT для таблицы `seat_zone`
--
ALTER TABLE `seat_zone`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `ticket`
--
ALTER TABLE `ticket`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `auth_log`
--
ALTER TABLE `auth_log`
  ADD CONSTRAINT `fk_authlog_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_buyer` FOREIGN KEY (`buyer_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_orders_pm` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_method` (`id`);

--
-- Ограничения внешнего ключа таблицы `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_pay_method` FOREIGN KEY (`method_id`) REFERENCES `payment_method` (`id`),
  ADD CONSTRAINT `fk_pay_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Ограничения внешнего ключа таблицы `performance`
--
ALTER TABLE `performance`
  ADD CONSTRAINT `fk_perf_hall` FOREIGN KEY (`hall_id`) REFERENCES `hall` (`id`),
  ADD CONSTRAINT `fk_perf_prod` FOREIGN KEY (`production_id`) REFERENCES `production` (`id`);

--
-- Ограничения внешнего ключа таблицы `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `fk_rp_perm` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `seat`
--
ALTER TABLE `seat`
  ADD CONSTRAINT `fk_seat_hall` FOREIGN KEY (`hall_id`) REFERENCES `hall` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_seat_zone` FOREIGN KEY (`zone_id`) REFERENCES `seat_zone` (`id`);

--
-- Ограничения внешнего ключа таблицы `seat_zone`
--
ALTER TABLE `seat_zone`
  ADD CONSTRAINT `fk_zone_hall` FOREIGN KEY (`hall_id`) REFERENCES `hall` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `ticket`
--
ALTER TABLE `ticket`
  ADD CONSTRAINT `fk_ticket_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ticket_perf` FOREIGN KEY (`performance_id`) REFERENCES `performance` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ticket_seat` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`id`);

--
-- Ограничения внешнего ключа таблицы `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
