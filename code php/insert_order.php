<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
error_reporting(E_ALL);

// CORS and Content-Type headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "error" => "Only POST requests are allowed."]);
    exit;
}

// Accept only form-urlencoded or multipart
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';
if (strpos($contentType, 'application/x-www-form-urlencoded') !== 0 &&
    strpos($contentType, 'multipart/form-data') !== 0) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "Only form data is accepted."]);
    exit;
}

// Collect form data
$userName = $_POST['userName'] ?? '';
$phoneNumber = $_POST['phoneNumber'] ?? '';
$address = $_POST['address'] ?? '';
$description = $_POST['description'] ?? '';
$orderType = $_POST['orderType'] ?? '';
$deliveryDate = $_POST['deliveryDate'] ?? '';
$deliveryTime = $_POST['deliveryTime'] ?? '';
$totalItems = $_POST['totalItems'] ?? '';
$totalPrice = $_POST['totalPrice'] ?? '';
$paymentMethod = $_POST['paymentMethod'] ?? '';
$transactionId = $_POST['transactionId'] ?? ''; // ✅ New
$cartItems = $_POST['cartItems'] ?? ''; // JSON string

// Convert empty deliveryDate and deliveryTime to null
$deliveryDate = ($deliveryDate === '') ? null : $deliveryDate;
$deliveryTime = ($deliveryTime === '') ? null : $deliveryTime;

// Connect to DB
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "foodhub_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => "Connection failed: " . $conn->connect_error]);
    exit;
}

// Require transactionId if paymentMethod is Google Pay
if ($paymentMethod === "Google Pay" && empty($transactionId)) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "Transaction ID is required for Google Pay."]);
    exit;
}

// Insert into DB (add transaction_id field)
$stmt = $conn->prepare("INSERT INTO payment_details 
    (user_name, phone_number, address, description, order_type, delivery_date, delivery_time, total_items, total_price, payment_method, transaction_id, cart_items) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => "Prepare failed: " . $conn->error]);
    exit;
}

// Use "ssssssssssss" for bind_param, but pass null for date/time if needed
$stmt->bind_param(
    "ssssssssssss",
    $userName,
    $phoneNumber,
    $address,
    $description,
    $orderType,
    $deliveryDate,
    $deliveryTime,
    $totalItems,
    $totalPrice,
    $paymentMethod,
    $transactionId,
    $cartItems
);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "✅ Order placed successfully"]);
} else {
    echo json_encode(["success" => false, "error" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
