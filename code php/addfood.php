<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php'; // defines $servername, $username, $password, $dbname

// Allow only POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Only POST method is allowed"]);
    exit;
}

// Check Content-Type header for multipart/form-data
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';
if (stripos($contentType, 'multipart/form-data') !== 0) {
    http_response_code(400);
    echo json_encode(["error" => "Content-Type must be multipart/form-data"]);
    exit;
}

// Connect to database
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Database connection failed: " . $conn->connect_error]);
    exit;
}

// Collect and validate form fields
$name = $_POST['name'] ?? null;
$description = $_POST['description'] ?? null;
$price = $_POST['price'] ?? null;
$category = $_POST['category'] ?? null;
$availability_time = $_POST['availability_time'] ?? null;
$stock_level = $_POST['stock_level'] ?? null;
$image_url = '';

if (!$name || !$description || !$price || !$category || !$availability_time || !$stock_level) {
    http_response_code(400);
    echo json_encode(["error" => "Missing required fields"]);
    $conn->close();
    exit;
}

// Handle image upload
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $image_tmp_name = $_FILES['image']['tmp_name'];
    $image_name = basename($_FILES['image']['name']);
    $upload_dir = 'assets/';

    // Create directory if it doesn't exist
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }

    // To avoid overwriting, you can prefix the image name with a timestamp or unique id
    $unique_image_name = time() . '_' . $image_name;
    $image_path = $upload_dir . $unique_image_name;

    if (move_uploaded_file($image_tmp_name, $image_path)) {
        $image_url = $image_path;
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Failed to upload image"]);
        $conn->close();
        exit;
    }
} else {
    http_response_code(400);
    echo json_encode(["error" => "Image is required"]);
    $conn->close();
    exit;
}

// Prepare SQL insert statement
$sql = "INSERT INTO food_items (name, description, price, category, availability_time, stock_level, image_url) 
        VALUES (?, ?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "SQL preparation failed: " . $conn->error]);
    $conn->close();
    exit;
}

// Bind parameters and execute
// Bind types: s = string, d = double/float, i = integer
$stmt->bind_param("ssdssis", $name, $description, $price, $category, $availability_time, $stock_level, $image_url);

if ($stmt->execute()) {
    echo json_encode(["success" => "Food item added successfully"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to add food item", "details" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
