<?php
header('Content-Type: application/json');
include 'db_connect.php'; // Ensure this connects to $conn (MySQLi)

// Allow only POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        "success" => false,
        "message" => "Only POST method is allowed."
    ]);
    exit;
}

// Get orderId from POST data
$orderId = $_POST['orderId'] ?? '';

if (empty($orderId)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing orderId."
    ]);
    exit;
}

// Step 1: Fetch the order's created_at and status
$query = "SELECT created_at, status FROM payment_details WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $orderId);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "success" => false,
        "message" => "Order not found."
    ]);
    exit;
}

$order = $result->fetch_assoc();

// Step 2: Check if already cancelled or delivered
if ($order['status'] === 'cancelled') {
    echo json_encode([
        "success" => false,
        "message" => "Order is already cancelled."
    ]);
    exit;
}

if ($order['status'] === 'delivered') {
    echo json_encode([
        "success" => false,
        "message" => "Delivered orders cannot be cancelled."
    ]);
    exit;
}

// Step 3: Check if cancellation is within 10 minutes
$createdAt = strtotime($order['created_at']);
$currentTime = time();

if (($currentTime - $createdAt) > 600) { // 600 seconds = 10 minutes
    echo json_encode([
        "success" => false,
        "message" => "Cancellation period has expired (10 minutes limit)."
    ]);
    exit;
}

// Step 4: Update the order status to 'cancelled'
$updateQuery = "UPDATE payment_details SET status = 'cancelled' WHERE id = ?";
$updateStmt = $conn->prepare($updateQuery);
$updateStmt->bind_param("i", $orderId);

if ($updateStmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Order status updated to cancelled."
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to cancel the order."
    ]);
}

$conn->close();
?>

