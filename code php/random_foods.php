<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Only POST requests are allowed."]);
    exit;
}

// Include centralized DB connection
include 'db_connect.php';

$sql = "SELECT id, name, description, price, image_url, category 
        FROM food_items 
        ORDER BY RAND() 
        LIMIT 6";

$result = $conn->query($sql);

$foodItems = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $row['image_url'] = "http://localhost/foodhub/" . $row['image_url'];
        $foodItems[] = $row;
    }
    echo json_encode($foodItems);
} else {
    echo json_encode([]);
}

$conn->close();
?>
