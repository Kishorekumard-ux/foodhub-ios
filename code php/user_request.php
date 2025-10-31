<?php
// Update DB connection as needed
include 'db_connect.php';

$user_name = $_POST['user_name'] ?? '';
$phone_number = $_POST['phone_number'] ?? '';
$question = $_POST['question'] ?? '';

if (!$user_name || !$phone_number || !$question) {
    http_response_code(400);
    echo "Missing fields";
    exit;
}

$stmt = $conn->prepare("INSERT INTO faq_requests (user_name, phone_number, question) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $user_name, $phone_number, $question);

if ($stmt->execute()) {
    echo "success";
} else {
    http_response_code(500);
    echo "Failed to insert";
}
$stmt->close();
$conn->close();
