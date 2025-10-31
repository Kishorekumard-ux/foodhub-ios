<?php
include 'db_connect.php';

header('Content-Type: application/json');

// If filtering is needed from POST
$foodName = isset($_POST['foodName']) ? $_POST['foodName'] : null;
$userName = isset($_POST['userName']) ? $_POST['userName'] : null;

$feedbacks = [];

// Build query dynamically if filtering is needed
$query = "SELECT * FROM feedbacks";
$conditions = [];

if ($foodName) {
    $conditions[] = "foodName LIKE '%" . $conn->real_escape_string($foodName) . "%'";
}

if ($userName) {
    $conditions[] = "userName = '" . $conn->real_escape_string($userName) . "'";
}

if (!empty($conditions)) {
    $query .= " WHERE " . implode(" AND ", $conditions);
}

$query .= " ORDER BY date DESC";

// Fetch feedbacks
if ($result = $conn->query($query)) {
    while ($row = $result->fetch_assoc()) {
        $date = new DateTime($row["date"]);

        $feedbacks[] = [
            "id" => (int)$row["id"],
            "userName" => $row["userName"],
            "foodName" => $row["foodName"],
            "rating" => (int)$row["rating"],
            "feedback" => $row["feedback"],
            "imageUrl" => $row["imageUrl"],
            "date" => $date->format(DateTime::ATOM)
        ];
    }
    $result->free();
} else {
    echo json_encode(["error" => "Query failed: " . $conn->error]);
    exit;
}

$conn->close();
echo json_encode($feedbacks);
?>
