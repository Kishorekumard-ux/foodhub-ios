<?php
include 'db_connect.php'; // Ensure this connects to $conn (MySQLi)

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id = $_POST['id'] ?? '';
    $answer = $_POST['answer'] ?? '';

    if (!empty($id) && !empty($answer)) {
        $stmt = $conn->prepare("UPDATE faq_requests SET answer = ? WHERE id = ?");
        $stmt->bind_param("si", $answer, $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Answer submitted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Database update failed"]);
        }

        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Missing id or answer"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}

$conn->close();
?>
