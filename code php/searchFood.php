<?php
header('Content-Type: application/json');

include 'db_connect.php'; // Ensure this connects and defines $conn

// Check database connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Allow only POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Only POST method allowed"]);
    exit();
}

// Get the search query from POST data (works with multipart/form-data)
$searchQuery = isset($_POST['query']) ? trim($_POST['query']) : '';
if (empty($searchQuery)) {
    echo json_encode(["error" => "Search query is empty"]);
    exit();
}

// Prepare the search term for SQL LIKE
$searchQuery = '%' . $searchQuery . '%';

// SQL query to find matching food items
$sql = "SELECT * FROM food_items WHERE name LIKE ?";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["error" => "Query preparation failed: " . $conn->error]);
    exit();
}

$stmt->bind_param("s", $searchQuery);

if (!$stmt->execute()) {
    echo json_encode(["error" => "Query execution failed: " . $stmt->error]);
    exit();
}

// Fetch results
$result = $stmt->get_result();
$foodItems = [];

// Base URL to prepend to image paths if needed
$baseUrl = "http://localhost/foodhub/";

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $imageUrl = isset($row['image_url']) ? $row['image_url'] : '';

        // If not a full URL, prepend the correct path
        if (!empty($imageUrl) && strpos($imageUrl, 'http') === false) {
            // If already starts with 'assets/', just add base URL
            if (strpos($imageUrl, 'assets/') === 0) {
                $imageUrl = $baseUrl . $imageUrl;
            } else {
                $imageUrl = $baseUrl . "assets/" . $imageUrl;
            }
        }

        // Add food item to response array
        $foodItems[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'image_url' => $imageUrl,
            'category' => $row['category'],
        ];
    }

    echo json_encode($foodItems);
} else {
    echo json_encode(["message" => "No items found"]);
}

// Close connections
$stmt->close();
$conn->close();
?>
