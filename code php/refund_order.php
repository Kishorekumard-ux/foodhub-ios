<?php
header('Content-Type: application/json');

$host = "localhost";
$dbname = "foodhub_db";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "❌ DB connection failed"]);
    exit();
}

$orderId = isset($_POST['id']) ? $_POST['id'] : null;
$status = isset($_POST['status']) ? $_POST['status'] : null;

if (empty($orderId) || !in_array(strtolower($status), ["refunded", "delivered"])) {
    echo json_encode(["success" => false, "message" => "❗ Invalid or missing data", "received" => $_POST]);
    exit();
}

if (strtolower($status) === "refunded") {
    $sql = "UPDATE payment_details SET status = 'Refunded' WHERE id = ? AND LOWER(status) = 'cancelled'";
} else if (strtolower($status) === "delivered") {
    $sql = "UPDATE payment_details SET status = 'Delivered' WHERE id = ? AND LOWER(status) != 'delivered'";
} else {
    echo json_encode(["success" => false, "message" => "❌ Invalid status"]);
    exit();
}

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $orderId);

if ($stmt->execute() && $stmt->affected_rows > 0) {
    echo json_encode(["success" => true, "message" => "✅ Status updated to $status"]);
} else {
    echo json_encode(["success" => false, "message" => "❌ Status update failed or already set"]);
}

$stmt->close();
$conn->close();
?>
