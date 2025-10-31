<?php
header("Content-Type: application/json");

include 'db_connect.php'; // Include your DB connection file

// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['phone']) || !isset($data['name'])) {
    echo json_encode(["status" => "error", "message" => "Missing phone or name"]);
    exit();
}

$phone = $conn->real_escape_string($data['phone']);
$name = $conn->real_escape_string($data['name']);

// Update the user
$sql = "UPDATE users SET name = '$name' WHERE phone = '$phone'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "User details updated"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update user: " . $conn->error]);
}

$conn->close();
?>
