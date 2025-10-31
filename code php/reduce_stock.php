<?php
header('Content-Type: application/json');

// Allow only POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Only POST method is allowed."]);
    exit();
}

// Check if the content type is form data
$contentType = $_SERVER["CONTENT_TYPE"] ?? '';
if (strpos($contentType, 'application/x-www-form-urlencoded') !== 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Only form data (application/x-www-form-urlencoded) is allowed."]);
    exit();
}

include 'db_connect.php'; // Make sure this connects to your database

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Get item name and quantity from form data
$item_name = $_POST['itemName'] ?? '';
$quantity = isset($_POST['quantity']) ? intval($_POST['quantity']) : 0;

// Validate inputs
if (empty($item_name) || $quantity <= 0) {
    echo json_encode(["status" => "error", "message" => "Invalid item name or quantity."]);
    exit();
}

// Prepare and execute SQL safely
$stmt = $conn->prepare("UPDATE food_items SET stock_level = stock_level - ? WHERE name = ?");
$stmt->bind_param("is", $quantity, $item_name);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Stock level updated successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Item not found or stock not changed."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Database error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
