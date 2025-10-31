<?php
header('Content-Type: application/json');
include 'db_connect.php'; // This file should connect to your MySQL database

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Receive only form-data (application/x-www-form-urlencoded or multipart/form-data)
    $name = $_POST['name'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $password = $_POST['password'] ?? '';

    // Check for empty fields
    if (empty($name) || empty($phone) || empty($password)) {
        echo json_encode([
            "status" => "error",
            "message" => "All fields are required"
        ]);
        exit;
    }

    // Check password length
    if (strlen($password) < 6) {
        echo json_encode([
            "status" => "error",
            "message" => "Password must be at least 6 characters long"
        ]);
        exit;
    }

    // Check if the phone number already exists
    $checkQuery = "SELECT * FROM users WHERE phone = ?";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("s", $phone);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "Phone number already registered"
        ]);
        exit;
    }

    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Insert user
    $insertQuery = "INSERT INTO users (name, phone, password) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($insertQuery);
    $stmt->bind_param("sss", $name, $phone, $hashedPassword);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Account created successfully"
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to create account"
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid request method"
    ]);
}
?>
