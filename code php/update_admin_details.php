<?php
header('Content-Type: application/json');
include 'db_connect.php'; // Your database connection

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["status" => "error", "message" => "Invalid request method. Only POST allowed."]);
    exit;
}

$contentType = $_SERVER['CONTENT_TYPE'] ?? '';
if (stripos($contentType, 'multipart/form-data') !== 0) {
    echo json_encode(["status" => "error", "message" => "Content-Type must be multipart/form-data"]);
    exit;
}

$name = $_POST['name'] ?? null;
$phone = $_POST['phone'] ?? null;

if (!empty($name) && !empty($phone)) {
    $query = "UPDATE users SET name = ? WHERE phone = ?";
    
    if ($stmt = $conn->prepare($query)) {
        $stmt->bind_param("ss", $name, $phone);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Admin details updated successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update admin details", "error" => $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Query preparation failed", "error" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Both name and phone number are required."]);
}

$conn->close();
?>
