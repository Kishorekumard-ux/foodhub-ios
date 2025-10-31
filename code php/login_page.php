<?php
header('Content-Type: application/json');
include 'db_connect.php'; // Make sure this connects to your database

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Read form data
    $phone = $_POST['phone'] ?? null;
    $password = $_POST['password'] ?? null;

    if (!empty($phone) && !empty($password)) {
        // Prepare SQL query
        $query = "SELECT * FROM users WHERE phone = ?";
        $stmt = $conn->prepare($query);

        if ($stmt) {
            $stmt->bind_param("s", $phone);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows > 0) {
                $user = $result->fetch_assoc();

                // Verify password (assumes it's hashed in DB)
                if (password_verify($password, $user['password'])) {
                    echo json_encode([
                        "status" => "success",
                        "message" => "Login successful",
                        "data" => [
                            "name" => $user['name'],
                            "phone" => $user['phone'],
                            "role" => $user['role']
                        ]
                    ]);
                } else {
                    echo json_encode([
                        "status" => "error",
                        "message" => "Incorrect password"
                    ]);
                }
            } else {
                echo json_encode([
                    "status" => "error",
                    "message" => "User not found"
                ]);
            }

            $stmt->close();
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Failed to prepare SQL statement"
            ]);
        }
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Phone and password are required"
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid request method"
    ]);
}
?>
