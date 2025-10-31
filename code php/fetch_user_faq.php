<?php
// Set header
header("Content-Type: application/json");

// Connect to database
$conn = new mysqli("localhost", "root", "", "foodhub_db");

// Check connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Database connection failed"]);
    exit();
}

// Get phone number from POST form data
$phoneNumber = $_POST['phone_number'] ?? '';

if (empty($phoneNumber)) {
    echo json_encode(["error" => "Phone number is required"]);
    exit();
}

// Prepare and execute SQL query
$stmt = $conn->prepare("SELECT question, answer, status, created_at FROM faq_requests WHERE phone_number = ? ORDER BY created_at DESC");
$stmt->bind_param("s", $phoneNumber);
$stmt->execute();
$result = $stmt->get_result();

$faqData = [];

while ($row = $result->fetch_assoc()) {
    $faqData[] = [
        "question" => $row["question"],
        "answer" => $row["answer"] ?: "Not answered yet",
        "status" => $row["status"],
        "created_at" => $row["created_at"]
    ];
}

// Return as JSON
echo json_encode($faqData);
?>
