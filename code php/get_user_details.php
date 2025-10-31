<?php
// Include database connection
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $phone = $_POST['phone'];

    // Check if the phone number exists
    $query = "SELECT * FROM users WHERE phone = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $phone);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // User exists, generate OTP
        $otp = rand(1000, 9999); // Generate a 4-digit OTP
        $otp_expiry = date("Y-m-d H:i:s", strtotime("+15 minutes")); // OTP valid for 15 minutes

        // Update OTP and expiry in the database
        $update_query = "UPDATE users SET otp = ?, otp_expiry = ? WHERE phone = ?";
        $update_stmt = $conn->prepare($update_query);
        $update_stmt->bind_param("iss", $otp, $otp_expiry, $phone);
        $update_stmt->execute();

        // Here you can integrate an SMS API to send the OTP
        echo json_encode([
            "success" => true,
            "message" => "OTP has been sent to your phone number."
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Phone number not found."
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid request."
    ]);
}
?>
