<?php
header('Content-Type: application/json');
include 'db_connect.php'; // Ensure this connects to $conn (MySQLi)

// Get the order ID from the request
$order_id = isset($_POST['id']) ? $_POST['id'] : '';

if (empty($order_id)) {
    echo json_encode(array("status" => "error", "message" => "Order ID is required"));
    exit();
}

// Update the order status to 'cancelled'
$sql = "UPDATE event_details SET status='cancelled' WHERE id='$order_id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(array("status" => "success", "message" => "Order cancelled successfully"));
} else {
    echo json_encode(array("status" => "error", "message" => "Error cancelling order: " . $conn->error));
}

$conn->close();
?>