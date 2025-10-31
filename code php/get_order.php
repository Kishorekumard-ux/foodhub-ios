<?php
header('Content-Type: application/json');

// Database connection
$servername = "localhost";
$username = "root"; // Replace with your database username
$password = ""; // Replace with your database password
$dbname = "foodhub_db"; // Replace with your database name

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the username from the request
$user = $_GET['username'];

if (!$user) {
    echo json_encode([]);
    exit();
}

// Fetch orders from the database based on the username
$sql = "SELECT id, user_name, address, food_items,phone_number, quantities, total_price, payment_method, order_time, delivery_time, order_type, status FROM orders WHERE phone_number = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $user);
$stmt->execute();
$result = $stmt->get_result();

$orders = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Sanitize food_items to remove unwanted symbols
        $row['food_items'] = preg_replace('/[^A-Za-z0-9, ]/', '', $row['food_items']);
        
        // Sanitize quantities to keep only numeric values
        $row['quantities'] = preg_replace('/[^0-9, ]/', '', $row['quantities']);

        $orders[] = $row;
    }
} else {
    echo json_encode([]);
    exit();
}

// Return the sanitized orders
echo json_encode($orders);

$conn->close();
?>
