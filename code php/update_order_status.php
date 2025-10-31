<?php
header("Content-Type: application/json");

include 'db_connect.php'; // Should define $conn directly

// Ensure this is a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['status' => 'error', 'message' => 'Only POST requests are allowed']);
    exit();
}

// Check required form fields
if (isset($_POST['user_name']) && isset($_POST['status'])) {
    $user_name = $_POST['user_name'];
    $status = $_POST['status'];

    // Use prepared statements to prevent SQL injection
    $stmt = $conn->prepare("UPDATE payment_details SET status = ? WHERE user_name = ?");
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Query preparation failed']);
        exit();
    }

    $stmt->bind_param("ss", $status, $user_name);
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Order status updated']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to update status']);
    }

    $stmt->close();
} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Missing user_name or status']);
}

$conn->close();
?>
