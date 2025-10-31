<?php
header("Content-Type: application/json");
include "config.php"; // Make sure this connects to your DB

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $phone = $_POST['phone'] ?? '';

    if (empty($phone)) {
        echo json_encode(['status' => 'error', 'message' => 'Phone number is required']);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM users WHERE phone = ?");
    $stmt->bind_param("s", $phone);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Account deleted']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to delete account']);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
}
?>
