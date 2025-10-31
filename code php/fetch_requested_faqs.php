<?php
header("Content-Type: application/json");
include 'db_connect.php'; // should define $conn

$sql = "SELECT id, user_name, phone_number, question, answer, status, created_at 
        FROM faq_requests 
        WHERE answer IS NULL OR answer = ''";

$result = $conn->query($sql);

$faqs = [];     

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Cast numeric fields to correct types
        $row['id'] = (int) $row['id'];
        $faqs[] = $row;
    }
} else if (!$result) {
    http_response_code(500);
    echo json_encode(["error" => "Query failed: " . $conn->error]);
    exit();
}

echo json_encode($faqs, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
$conn->close();
?>
    