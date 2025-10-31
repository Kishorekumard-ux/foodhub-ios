<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'db_connect.php';

// Check database connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Check if form-data parameter 'category' is set
    if (isset($_POST['category'])) {
        // Trim and normalize category from form-data
        $category = trim($_POST['category']);

        // Optional: Debug log
        // file_put_contents("debug.log", "Category received: $category\n", FILE_APPEND);

        // Prepare SQL with case-insensitive and trimmed match
        $stmt = $conn->prepare("SELECT id, name, image_url FROM food_items WHERE LOWER(TRIM(category)) = LOWER(TRIM(?))");
        $stmt->bind_param("s", $category);
        $stmt->execute();
        $result = $stmt->get_result();

        $foods = [];

        while ($row = $result->fetch_assoc()) {
            $foods[] = [
                "id" => $row["id"],
                "name" => $row["name"],
                "image_url" => "http://localhost/foodhub/" . $row["image_url"]
            ];
        }

        if (empty($foods)) {
            echo json_encode(["message" => "No food items found for $category."]);
        } else {
            echo json_encode($foods);
        }

        $stmt->close();
    } else {
        echo json_encode(["error" => "Form-data 'category' not provided"]);
    }

} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>
