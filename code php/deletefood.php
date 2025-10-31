<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'db_connect.php'; // Ensure this connects to $conn (MySQLi)

// Ensure the request is POST and content-type is multipart/form-data
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die(json_encode(["error" => "Only POST method is allowed"]));
}

if (!isset($_POST['id'])) {
    http_response_code(400);
    die(json_encode(["error" => "Missing 'id' in form data"]));
}

$id = intval($_POST['id']);

$sql = "DELETE FROM food_items WHERE id = ?";

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["error" => "SQL statement preparation failed: " . $conn->error]));
}

$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => "Food item deleted successfully"]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Failed to delete food item"]);
}

$stmt->close();
$conn->close();
?>
