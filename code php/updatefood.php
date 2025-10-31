<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Show errors for debugging (remove in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'db_connect.php'; // Should define $conn directly

// Check connection
if (!$conn || $conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// Check required fields
$required = ['id', 'name', 'description', 'price', 'category', 'availability_time', 'stock_level'];
foreach ($required as $field) {
    if (!isset($_POST[$field])) {
        http_response_code(400);
        die(json_encode(["error" => "Missing required field: $field"]));
    }
}

// Sanitize input
$id = intval($_POST['id']);
$name = $_POST['name'];
$description = $_POST['description'];
$price = floatval($_POST['price']);
$category = $_POST['category'];
$availability_time = $_POST['availability_time'];
$stock_level = intval($_POST['stock_level']);
$image_url = '';

// Handle image upload (multipart/form-data)
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $image_tmp_name = $_FILES['image']['tmp_name'];
    $image_name = basename($_FILES['image']['name']);
    $image_path = "assets/" . uniqid() . "_" . $image_name;

    if (move_uploaded_file($image_tmp_name, $image_path)) {
        $image_url = $image_path;
    } else {
        http_response_code(500);
        die(json_encode(["error" => "Failed to upload image"]));
    }
} else {
    // No new image — retain existing
    $result = $conn->query("SELECT image_url FROM food_items WHERE id = $id");
    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $image_url = $row['image_url'];
    } else {
        http_response_code(404);
        die(json_encode(["error" => "Food item not found"]));
    }
}

// Prepare update statement
$sql = "UPDATE food_items 
        SET name = ?, description = ?, price = ?, category = ?, availability_time = ?, stock_level = ?, image_url = ? 
        WHERE id = ?";

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["error" => "SQL preparation failed: " . $conn->error]));
}

$stmt->bind_param("ssdssisi", $name, $description, $price, $category, $availability_time, $stock_level, $image_url, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => "Food item updated successfully"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to update food item"]);
}

$stmt->close();
$conn->close();
?>
