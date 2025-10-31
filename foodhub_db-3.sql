-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 25, 2025 at 06:05 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foodhub_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `faq`
--

CREATE TABLE `faq` (
  `id` int(11) NOT NULL,
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faq`
--

INSERT INTO `faq` (`id`, `question`, `answer`, `is_active`, `created_at`, `updated_at`) VALUES
(1, '🍽 What types of food do you offer?', 'We offer a variety of snacks, breakfast items, vegetarian and non-vegetarian meals.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(2, '🕒 What are your food availability timings?', 'Each food item has specific availability hours. Please check the app for time slots.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(3, '💸 Is there any discount on food?', 'Currently, we offer discounts on select categories like Snacks. More offers coming soon!', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(4, '🚫 What if an item is out of stock?', 'Out-of-stock items will be shown as unavailable and cannot be added to your cart.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(5, '🛒 How can I place an order?', 'Just browse categories, add items to your cart, and proceed to checkout.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(6, '📍 Where do you deliver?', 'Currently, we serve only within the specified delivery zones shown in the app.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(7, '📦 Can I pre-order for later?', 'Currently, we serve based on availability time. Pre-ordering and bulk orders are coming soon!', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(8, '🎉 Do you accept bulk orders?', 'Yes, we accept bulk orders! Please contact our support for customized arrangements.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(9, '💳 What payment methods are available?', 'We accept cash on delivery and digital payments. More options coming soon.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(10, '📞 How can I contact support?', 'Use the in-app chat or call us via the support number listed in the Help section.', 1, '2025-06-14 05:07:39', '2025-06-14 05:07:39'),
(11, 'Hotel timing', '6 am to 10 pm', 1, '2025-07-23 05:31:29', '2025-07-23 05:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `faq_requests`
--

CREATE TABLE `faq_requests` (
  `id` int(11) NOT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `question` text DEFAULT NULL,
  `answer` text DEFAULT NULL,
  `status` enum('pending','answered') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faq_requests`
--

INSERT INTO `faq_requests` (`id`, `user_name`, `phone_number`, `question`, `answer`, `status`, `created_at`) VALUES
(11, 'kis', '6369676963', 'Price of burger', '1000', 'pending', '2025-06-30 10:52:38'),
(12, 'User', '1234567890', 'What is the hotel timing', '8 to 10', 'pending', '2025-07-23 11:07:20');

-- --------------------------------------------------------

--
-- Table structure for table `feedbacks`
--

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL,
  `userName` varchar(100) DEFAULT NULL,
  `foodName` varchar(100) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `imageUrl` text DEFAULT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feedbacks`
--

INSERT INTO `feedbacks` (`id`, `userName`, `foodName`, `feedback`, `rating`, `imageUrl`, `date`) VALUES
(3, 'Test User', 'Burger', 'Good', 2, 'http://localhost/foodhub/assets/6858e345c377f_image.jpg', '2025-06-23 10:46:53'),
(4, 'Test User', 'Burger', 'Nice', 2, 'http://localhost/foodhub/assets/6858fc0712cf9_image.jpg', '2025-06-23 12:32:31'),
(5, 'Test User', 'Cheese', 'Good', 5, 'http://localhost/foodhub/assets/6870c83a1f0a6_image.jpg', '2025-07-11 13:45:54');

-- --------------------------------------------------------

--
-- Table structure for table `food_items`
--

CREATE TABLE `food_items` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `price` int(11) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `availability_time` varchar(255) DEFAULT NULL,
  `stock_level` int(11) NOT NULL DEFAULT 0,
  `popularity` int(11) DEFAULT NULL,
  `discount` decimal(5,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `food_items`
--

INSERT INTO `food_items` (`id`, `name`, `category`, `description`, `price`, `image_url`, `availability_time`, `stock_level`, `popularity`, `discount`) VALUES
(1, 'Chicken Burger', 'snack', 'speciy burger', 200, 'assets/chickenburger.png', '6:00 AM - 10:00 PM', 50, 3, 5.00),
(5, 'Heart Pizza', 'snack', 'Steamed or fried dumplings filled with veggies or meat.', 200, 'assets/heart pizza.jpg', '8:00 AM - 10:00 PM', 20, 7, 5.00),
(6, 'Pepperoni Pizza', 'snack', 'Crispy chips served with a creamy dip.', 230, 'assets/pepperoni.png', '6:00 PM - 10:00 PM', 25, 1, 5.00),
(8, 'Beef Shawarma', 'snack', 'Soft bread filled with fresh veggies and hummus', 150, 'assets/beeshawarma.png', '6:00 AM - 11:00 PM', 50, 0, 5.00),
(9, 'Veg Shawarma', 'snack', 'Soft bread filled with fresh veggies and hummus', 100, 'assets/vegshawarma.png', '6:00 PM - 11:00 PM', 60, 0, 5.00),
(11, 'Paneer Samosa', 'snack', 'A crispy snack filled with cottage cheese and spices', 40, 'assets/paneersamosa.png', '3:00 PM - 8:00 PM', 70, 0, 5.00),
(12, 'Veg Samosa', 'snack', 'A crispy snack filled with spiced potatoes and peas', 30, 'assets/vegsamosa.png', '3:00 PM - 8:00 PM', 100, 0, 5.00),
(13, 'Classic Fries', 'snack', 'Crispy, golden fries with a little salt', 80, 'assets/fries1.png', '2:00 PM - 7:00 PM', 90, 1, 5.00),
(14, 'Spicy Peri-Peri Fries', 'snack', 'Fries coated with spicy peri-peri seasoning', 100, 'assets/fries2.png', '2:00 PM - 7:00 PM', 80, 0, 5.00),
(15, 'Plain Idly', 'Breakfast', 'Soft steamed rice cakes served with chutney and sambar', 30, 'assets/idly.png', '6:00 AM - 10:00 PM', 100, 2, 5.00),
(16, 'Rava Idly', 'Breakfast', 'Fluffy idly made from semolina, served with coconut chutney', 40, 'assets/rava.png', '6:00 AM - 10:00 PM', 80, 1, 5.00),
(17, 'Mini Idly', 'Breakfast', 'Small idlies soaked in hot and tasty sambar', 50, 'assets/miniidly.png', '6:00 AM - 10:00 PM', 60, 0, 5.00),
(19, 'Masala Dosa', 'Breakfast', 'Crispy dosa filled with spiced potato masala, served with chutney and sambar', 60, 'assets/masaladosa.png', '6:00 AM - 10:00 PM', 100, 8, 5.00),
(20, 'Rava Dosa', 'Breakfast', 'Crispy dosa made from semolina, served with chutney and sambar', 50, 'assets/rava_dosa.png', '6:00 AM - 10:00 PM', 90, 0, 5.00),
(21, 'Ven Pongal', 'Breakfast', 'A savory dish made from rice and lentils, flavored with spices and ghee', 50, 'assets/venpongal.png', '6:00 AM - 10:00 PM', 80, 0, 5.00),
(22, 'Sweet Pongal', 'Breakfast', 'A sweet dish made from rice, jaggery, and ghee', 60, 'assets/sweetpongal.png', '6:00 AM - 10:00 PM', 70, 0, 5.00),
(23, 'Plain Poori with Potato Masala', 'Breakfast', 'Soft, puffed wheat bread served with potato curry', 50, 'assets/puri.png', '6:00 AM - 10:00 PM', 60, 0, 5.00),
(24, 'Masala Poori', 'Breakfast', 'Poori topped with spicy masala and chutney', 50, 'assets/poorimasala.png', '6:00 AM - 10:00 PM', 80, 0, 5.00),
(25, 'Chappathi with Kurma', 'Breakfast', 'Soft chappathi served with spicy vegetable kurma', 50, 'assets/chappathimasala.png', '8:00 AM - 10:00 PM', 100, 0, 5.00),
(26, 'Chappathi with Paneer Butter Masala', 'Breakfast', 'Chappathi brushed with butter, served with chutney', 60, 'assets/pannerchappathi.png', '7:00 AM - 10:00 PM', 90, 0, 5.00),
(27, 'Medu Vadai', 'Breakfast', 'Crispy deep-fried lentil doughnuts served with chutney and sambar', 50, 'assets/vadai.png', '6:00 AM - 10:00 PM', 120, 0, 5.00),
(32, 'Veg Meal', 'Veg', 'A complete meal with rice, sambar, rasam, curd, poriyal, kootu, papad, and pickle.', 150, 'assets/veg.png', '12:00 PM - 3:00 PM', 50, 8, 3.00),
(33, 'Mini Meals', 'Veg', 'A smaller portion of rice, sambar, rasam, curd, and one side dish.', 100, 'assets/minimeals.png', '12:00 PM - 3:00 PM', 40, 0, 3.00),
(35, 'Lemon Rice', 'Veg', 'Flavored rice with tangy lemon, spices, and curry leaves.', 80, 'assets/lemon.png', '12:00 PM - 3:00 PM', 60, 1, 3.00),
(36, 'Tomato Rice', 'Veg', 'Spicy rice cooked with tomatoes and aromatic spices.', 80, 'assets/tomatorice.png', '12:00 PM - 3:00 PM', 60, 0, 3.00),
(37, 'Coconut Rice', 'Veg', 'Light rice dish made with grated coconut and mild spices.', 80, 'assets/coconutrice.jpg', '12:00 PM - 3:00 PM', 50, 0, 3.00),
(38, 'Ven Pongal', 'Veg', 'A savory dish made from rice and lentils, flavored with spices and ghee.', 50, 'assets/venpongal.png', '7:00 AM - 10:00 AM', 80, 0, 3.00),
(39, 'Veg Biryani', 'Veg', 'Aromatic rice cooked with fresh vegetables and mild spices.', 120, 'assets/vegbiryani.png', '12:00 PM - 3:00 PM', 70, 0, 3.00),
(40, 'Mushroom Biryani', 'Veg', 'Flavorful biryani made with fresh mushrooms and spices.', 140, 'assets/mushroombiryani.png', '12:00 PM - 3:00 PM', 60, 0, 3.00),
(41, 'Paneer Biryani', 'Veg', 'Biryani cooked with soft paneer pieces and fragrant spices.', 150, 'assets/panner biryani.png', '12:00 PM - 3:00 PM', 50, 0, 3.00),
(43, 'Parotta with Kurma', 'Veg', 'Soft parotta served with spicy kurma.', 60, 'assets/parotta.png', '10:00 AM - 10:00 PM', 30, 1, 3.00),
(44, 'Curd Rice', 'Veg', 'A rich and creamy curry made with paneer and buttery tomato sauce.', 70, 'assets/curdrice.png', '12:00 PM - 3:00 PM', 80, 0, 3.00),
(45, 'Biryani', 'Non-Veg', 'Aromatic and flavorful rice dish with perfectly spiced meat.', 250, 'assets/biryani.png', '12:00 PM - 3:00 PM', 60, 11, 1.00),
(46, 'Mutton Biryani', 'Non-Veg', 'Juicy mutton pieces cooked with flavorful rice, saffron, and spices.', 350, 'assets/muttonbiryani.png', '12:00 PM - 3:00 PM', 50, 0, 1.00),
(47, 'Fish Biryani', 'Non-Veg', 'Soft fish fillets cooked in spicy masala and layered with rice.', 300, 'assets/fish biryani.png', '12:00 PM - 3:00 PM', 40, 0, 1.00),
(48, 'Egg Biryani', 'Non-Veg', 'Boiled eggs with mildly spiced rice and flavorful masala.', 200, 'assets/egg biryani.png', '12:00 PM - 3:00 PM', 80, 1, 1.00),
(49, 'Prawn Biryani', 'Non-Veg', 'Fresh prawns cooked in a rich, spicy rice blend.', 400, 'assets/prawn biryani.png', '12:00 PM - 3:00 PM', 30, 1, 1.00),
(50, 'Chettinad Chicken Curry', 'Non-Veg', 'Chicken simmered in a rich tomato and onion-based gravy.', 200, 'assets/chettinadchickencurry.png', '6:00 PM - 10:00 PM', 50, 0, 1.00),
(51, 'Mutton Curry', 'Non-Veg', 'Spicy and tender mutton pieces in a flavorful curry sauce.', 200, 'assets/mutton curry.png', '6:00 PM - 10:00 PM', 40, 0, 1.00),
(52, 'Fish Curry', 'Non-Veg', 'Fresh fish cooked in tangy tamarind gravy with coastal spices.', 250, 'assets/fishcurry.png', '6:00 PM - 10:00 PM', 30, 0, 1.00),
(53, 'Prawn Curry', 'Non-Veg', 'Prawns cooked in coconut milk with a hint of tamarind and spices.', 350, 'assets/prawn curry.png', '6:00 PM - 10:00 PM', 25, 0, 1.00),
(54, 'Chicken Varuval', 'Non-Veg', 'Dry and spicy South Indian chicken fry.', 280, 'assets/chickenvaruval.png', '6:00 PM - 10:00 PM', 35, 0, 1.00),
(55, 'Chettinad Chicken Curry', 'Non-Veg', 'A traditional South Indian curry with bold, spicy flavors.', 320, 'assets/chettinadchickencurry.png', '6:00 PM - 10:00 PM', 30, 0, 1.00),
(56, 'Egg Rice', 'Non-Veg', 'Stir-fried rice with scrambled eggs and spices.', 120, 'assets/eggrice.png', '12:00 PM - 3:00 PM', 70, 0, 1.00),
(57, 'Chicken Rice', 'Non-Veg', 'Fragrant rice with tender chicken and mild spices.', 180, 'assets/chickenrice.png', '12:00 PM - 3:00 PM', 60, 0, 1.00),
(58, 'Rice with Chicken Kulambu', 'Non-Veg', 'Steamed rice with spicy chicken gravy.', 200, 'assets/ricechickenkulampu.png', '12:00 PM - 3:00 PM', 50, 0, 1.00),
(59, 'Rice with Egg Kulambu', 'Non-Veg', 'Rice served with rich egg curry.', 150, 'assets/riceeggkulampu.png', '12:00 PM - 3:00 PM', 60, 0, 1.00),
(74, 'chicken fry ', 'Non-Veg', 'speciy hot 🔥', 201, 'assets/1000018969.jpg', '12:00 PM - 3:00 PM', 25, 9, 1.00),
(75, 'Burger ', 'snack', 'Tasty Burger😋', 300, 'assets/1000018670.jpg', '10:00 AM - 10:00 PM', 50, NULL, 5.00);

-- --------------------------------------------------------

--
-- Table structure for table `payment_details`
--

CREATE TABLE `payment_details` (
  `id` int(11) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `order_type` varchar(50) NOT NULL,
  `delivery_date` date DEFAULT NULL,
  `delivery_time` varchar(10) DEFAULT NULL,
  `total_items` int(11) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `cart_items` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(50) DEFAULT 'Pending',
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_details`
--

INSERT INTO `payment_details` (`id`, `user_name`, `phone_number`, `address`, `order_type`, `delivery_date`, `delivery_time`, `total_items`, `total_price`, `payment_method`, `transaction_id`, `cart_items`, `created_at`, `status`, `description`) VALUES
(68, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-09', '11:40:44', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-09 06:10:50', 'Pending', 'Please deliver hot.'),
(69, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-09', '11:40:44', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-09 06:10:57', 'Pending', 'Please deliver hot.'),
(70, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-09', '11:42:20', 3, 120.00, 'Cash on Delivery', '', '[{\"price\":60,\"name\":\"Pizza\",\"quantity\":2}]', '2025-07-09 06:12:26', 'Pending', 'Please deliver hot.'),
(71, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-09', '11:43:01', 3, 120.00, 'Cash on Delivery', '', '[{\"price\":60,\"name\":\"Pizza\",\"quantity\":2}]', '2025-07-09 06:13:06', 'Pending', 'Please deliver hot.'),
(72, 'Kishore Kumar', '9876543210', 'Chennai', 'Regular', NULL, '13:43:00', 2, 66.00, 'Cash on Delivery', '', '[{\"name\":\"Plain Idly\",\"price\":28.5,\"quantity\":1},{\"quantity\":1,\"price\":38,\"name\":\"Rava Idly\"}]', '2025-07-09 06:14:08', 'Pending', ''),
(73, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-11', '13:39:16', 3, 120.00, 'Cash on Delivery', '', '[{\"name\":\"Pizza\",\"quantity\":2,\"price\":60}]', '2025-07-11 08:09:22', 'Pending', 'Please deliver hot.'),
(74, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-11', '13:39:42', 3, 120.00, 'Cash on Delivery', '', '[{\"name\":\"Pizza\",\"quantity\":2,\"price\":60}]', '2025-07-11 08:09:45', 'Pending', 'Please deliver hot.'),
(75, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-11', '13:40:17', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-11 08:10:31', 'Pending', 'Please deliver hot.'),
(76, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-11', '13:41:57', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-11 08:12:01', 'Pending', 'Please deliver hot.'),
(77, 'kis', '6369676963', 'KK', 'Regular', NULL, '16:35:00', 22, 508.00, 'Cash on Delivery', '', '[{\"price\":28.5,\"name\":\"Plain Idly\",\"quantity\":21},{\"quantity\":1,\"name\":\"Rava Idly\",\"price\":38}]', '2025-07-11 09:06:22', 'Delivered', ''),
(78, 'kishore', '6381908503', 'KK', 'Regular', NULL, '16:09:00', 24, 916.00, 'Google Pay', '2334', '[{\"name\":\"Plain Idly\",\"quantity\":21,\"price\":28.5},{\"name\":\"Rava Idly\",\"quantity\":1,\"price\":38},{\"price\":190,\"quantity\":1,\"name\":\"Chicken Burger\"},{\"quantity\":1,\"name\":\"Heart Pizza\",\"price\":190}]', '2025-07-14 08:40:02', 'Delivered', ''),
(79, 'kishore', '6381908503', 'KK', 'Regular', NULL, '12:01:00', 25, 1106.00, 'Cash on Delivery', '', '[{\"name\":\"Plain Idly\",\"quantity\":21,\"price\":28.5},{\"price\":38,\"name\":\"Rava Idly\",\"quantity\":1},{\"name\":\"Chicken Burger\",\"quantity\":1,\"price\":190},{\"price\":190,\"quantity\":2,\"name\":\"Heart Pizza\"}]', '2025-07-22 04:31:31', 'Delivered', ''),
(80, 'kishore', '6381908503', 'Chennai ', 'Regular', NULL, '11:36:00', 26, 1296.00, 'Google Pay', '1234555', '[{\"price\":28.5,\"quantity\":21,\"name\":\"Plain Idly\"},{\"quantity\":1,\"price\":38,\"name\":\"Rava Idly\"},{\"quantity\":2,\"name\":\"Chicken Burger\",\"price\":190},{\"quantity\":2,\"name\":\"Heart Pizza\",\"price\":190}]', '2025-07-23 05:05:57', 'Delivered', ''),
(81, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-23', '15:44:46', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-23 10:14:52', 'Delivered', 'Please deliver hot.'),
(82, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-23', '15:53:30', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-23 10:23:33', 'Delivered', 'Please deliver hot.'),
(83, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-23', '15:55:40', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"price\":60,\"name\":\"Pizza\"}]', '2025-07-23 10:25:43', 'Delivered', 'Please deliver hot.'),
(84, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-23', '15:59:34', 3, 120.00, 'Cash on Delivery', '', '[{\"price\":60,\"quantity\":2,\"name\":\"Pizza\"}]', '2025-07-23 10:29:36', 'Delivered', 'Please deliver hot.'),
(85, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-23', '16:03:27', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-23 10:33:34', 'cancelled', 'Please deliver hot.'),
(86, 'Kishore Kumar', '9876543210', 'KK', 'Regular', NULL, '18:03:00', 2, 66.00, 'Cash on Delivery', '', '[{\"price\":28.5,\"name\":\"Plain Idly\",\"quantity\":1},{\"name\":\"Rava Idly\",\"price\":38,\"quantity\":1}]', '2025-07-23 10:34:08', 'cancelled', ''),
(87, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-24', '12:52:49', 3, 120.00, 'Cash on Delivery', '', '[{\"quantity\":2,\"name\":\"Pizza\",\"price\":60}]', '2025-07-24 07:22:53', 'cancelled', 'Please deliver hot.'),
(88, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-24', '12:57:03', 3, 120.00, 'Google Pay', '12345', '[{\"name\":\"Pizza\",\"price\":60,\"quantity\":2}]', '2025-07-24 07:27:13', 'Refunded', 'Please deliver hot.'),
(89, 'Kishore Kumar', '9876543210', '123 Street, City', 'Regular', '2025-07-24', '13:05:32', 3, 120.00, 'Google Pay', '1234', '[{\"name\":\"Pizza\",\"quantity\":2,\"price\":60}]', '2025-07-24 07:35:43', 'Refunded', 'Please deliver hot.'),
(90, 'kis', '6369676963', '77b,anna street,chennai', 'Regular', NULL, '15:12:00', 2, 342.00, 'Google Pay', '12234556', '[{\"quantity\":1,\"price\":190,\"name\":\"Chicken Burger\"},{\"name\":\"Heart Pizza\",\"quantity\":1,\"price\":190}]', '2025-07-24 07:43:17', 'cancelled', 'Make it hot');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `role` varchar(50) NOT NULL DEFAULT 'user',
  `address` varchar(255) DEFAULT NULL,
  `feedback` varchar(255) DEFAULT NULL,
  `preferred_category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `password`, `created_at`, `role`, `address`, `feedback`, `preferred_category`) VALUES
(1, 'kis', '6369676963', '$2y$10$D13bMfCCmO/WaTJ7pv84ReEpA817WEZx7Cm.ZO/yxw/cbh94uIO7K', '2024-12-26 08:21:00', 'user', NULL, NULL, NULL),
(2, 'logu', '6369676967', '$2y$10$QK4dGAG6zcYbynbiRPxWAut49cHzIPPtQf1Hke0OJ6uCT1Dagjqi2', '2024-12-26 08:34:12', 'user', NULL, NULL, NULL),
(3, 'kishore', '6369676965', '$2y$10$ygD0AA62acQfKg6LH.Jq/ug6./H.vw75LQP8UEyUSBwwTJwXAj5SW', '2024-12-26 09:09:55', 'user', NULL, NULL, NULL),
(7, 'kishorekumar', '6381908503', '$2y$10$wU6Og9ktF0wvLSY5ADwefOaESf/zGgNtUdTbKvlxxbQ6VlG7M4.pm', '2024-12-31 13:29:59', 'admin', NULL, NULL, NULL),
(8, 'durai murugan ', '9965416644', '$2y$10$Ymz4acPvziXr5F3jFYGqYOSYqrM7WfTBKlsJXi7/23lEkq3f0.F.a', '2025-01-05 12:49:30', 'user', NULL, NULL, NULL),
(9, 'Mukesh', '9952583422', '$2y$10$wXKD7W5SR4z2cTq12Sb1je4GUQPZYHDaUDQThHNikHF94Vvda.paq', '2025-01-10 03:02:52', 'user', NULL, NULL, NULL),
(10, 'Mukesh', '6652583422', 'Mukesh', '2025-01-10 03:04:59', 'user', NULL, NULL, NULL),
(12, 'prasanth', '12315', '$2y$10$J3p0oVWLiyLIWKJyFzu0aeAgVL5Rzh/QxajK6YDrq3wqsLfqrdmqK', '2025-01-10 08:57:35', 'user', NULL, NULL, NULL),
(13, 'kk', '9965416655', '$2y$10$Nx9uF3c1YeJSIoqa9klv0.SO0Uj.bXGlNeIz97cbqWvrCUo/Plm.e', '2025-01-18 06:20:33', 'user', NULL, NULL, NULL),
(14, 'mohan', '7676839767', '$2y$10$l1Z8b30WKWQUknKuS68Mhea1PnmycQ21THSbLy8tdIU9zgAu0GSA6', '2025-06-05 05:09:01', 'user', NULL, NULL, NULL),
(15, 'Gokul', '9876489987', '$2y$10$xhF19dp860sg3e0cWjYpPO.okzDLlsUvZsgJ.TPebUrbVijlOJTUa', '2025-06-06 05:29:10', 'user', NULL, NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `faq`
--
ALTER TABLE `faq`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faq_requests`
--
ALTER TABLE `faq_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `feedbacks`
--
ALTER TABLE `feedbacks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `food_items`
--
ALTER TABLE `food_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `payment_details`
--
ALTER TABLE `payment_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `faq`
--
ALTER TABLE `faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `faq_requests`
--
ALTER TABLE `faq_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `feedbacks`
--
ALTER TABLE `feedbacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `food_items`
--
ALTER TABLE `food_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `payment_details`
--
ALTER TABLE `payment_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
