<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Show errors for debugging (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'db_connect.php'; 


if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// Ensure this is a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die(json_encode(["error" => "Only POST method is allowed"]));
}

// Get search term from form data (multipart/form-data)
$searchQuery = isset($_POST['search']) ? trim($_POST['search']) : "";

$sql = "SELECT id, name, description, price, image_url, category, availability_time, stock_level FROM food_items";

if (!empty($searchQuery)) {
    $sql .= " WHERE name LIKE ?";
}

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["error" => "SQL statement preparation failed: " . $conn->error]));
}

if (!empty($searchQuery)) {
    $searchPattern = "%" . $searchQuery . "%";
    $stmt->bind_param("s", $searchPattern);
}

$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $foodItems = [];
    while ($row = $result->fetch_assoc()) {
        
        $row['image_url'] = "http://localhost/foodhub/" . $row['image_url'];
        $foodItems[] = $row;
    }
    echo json_encode($foodItems);
} else {
    echo json_encode([]);
}

$stmt->close();
$conn->close();
?>
