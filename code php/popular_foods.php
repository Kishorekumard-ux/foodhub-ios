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

$sql = "SELECT id, name, description, price, image_url, category, popularity 
        FROM food_items 
        ORDER BY popularity DESC 
        LIMIT 6";

$result = $conn->query($sql);

$popularItems = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $row['image_url'] = "http://localhost/foodhub/" . $row['image_url'];
        $popularItems[] = $row;
    }
    echo json_encode($popularItems);
} else {
    echo json_encode([]);
}

$conn->close();
?>
