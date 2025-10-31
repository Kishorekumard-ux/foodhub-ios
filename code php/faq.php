<?php
// Enable CORS and set content type
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Database credentials
$host = "localhost";
$username = "root";
$password = "";
$database = "foodhub_db";

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Ensure utf8mb4 is used for full Unicode (emoji) support
if (!$conn->set_charset("utf8mb4")) {
    http_response_code(500);
    echo json_encode(["error" => "Error loading character set utf8mb4: " . $conn->error]);
    exit;
}

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$faqs = [];

// Accept only POST form-data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $search = isset($_POST['q']) ? trim($_POST['q']) : '';
} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(["error" => "Use POST request with form-data."]);
    exit;
}

// Build the prepared statement
if (!empty($search)) {
    $stmt = $conn->prepare("SELECT id, question, answer FROM faq WHERE is_active = 1 AND question LIKE ? ORDER BY id ASC");
    $searchTerm = '%' . $search . '%';
    $stmt->bind_param("s", $searchTerm);
} else {
    $stmt = $conn->prepare("SELECT id, question, answer FROM faq WHERE is_active = 1 ORDER BY id ASC");
}

$stmt->execute();
$result = $stmt->get_result();

while ($row = $result->fetch_assoc()) {
    $faqs[] = [
        "id" => $row["id"],
        "question" => $row["question"],
        "answer" => $row["answer"]
    ];
}

// Output JSON-encoded data
echo json_encode($faqs, JSON_UNESCAPED_UNICODE);

$stmt->close();
$conn->close();
?>
