<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "foodhub";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Assuming you have a user_id to fetch the details
$user_id = $_GET['user_id'];

$sql = "SELECT full_name, phone_number, address FROM users WHERE user_id = $user_id";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode($row);
} else {
    echo json_encode([]);
}

$conn->close();
?>