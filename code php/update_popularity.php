<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Allow only POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Invalid request method. Only POST allowed."]);
    exit;
}

// Check Content-Type is multipart/form-data (used by Postman's form-data)
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';
if (stripos($contentType, 'multipart/form-data') !== 0) {
    http_response_code(400);
    echo json_encode(["error" => "Content-Type must be multipart/form-data"]);
    exit;
}

include 'db_connect.php'; // Include your DB connection file
// Connect to database
$conn = new mysqli($host, $username, $password, $database);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Database connection failed: " . $conn->connect_error]);
    exit;
}

// Get food_id from form-data
$food_id = $_POST['food_id'] ?? null;
if (empty($food_id) || !is_numeric($food_id)) {
    http_response_code(400);
    echo json_encode(["error" => "Invalid or missing food_id."]);
    exit;
}

// Prepare and execute query
$sql = "UPDATE food_items SET popularity = popularity + 1 WHERE id = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "SQL preparation failed: " . $conn->error]);
    exit;
}

$stmt->bind_param("i", $food_id);

if ($stmt->execute()) {
    echo json_encode(["success" => "Popularity updated successfully"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to update popularity"]);
}

$stmt->close();
$conn->close();
?>
