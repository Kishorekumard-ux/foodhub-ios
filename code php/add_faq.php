<?php
include 'db_connect.php'; // Should define $conn directly

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $question = $_POST['question'];
    $answer = $_POST['answer'];

    $stmt = $conn->prepare("INSERT INTO faq (question, answer, is_active, created_at, updated_at) VALUES (?, ?, 1, NOW(), NOW())");
    $stmt->bind_param("ss", $question, $answer);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "FAQ added successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method."]);
}

$conn->close();
?>
