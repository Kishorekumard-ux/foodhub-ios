<?php
include 'db_connect.php';

$uploadDir = $_SERVER['DOCUMENT_ROOT'] . "/foodhub/assets/";

// ✅ Validate image
if (!isset($_FILES["image"]) || $_FILES["image"]["error"] !== UPLOAD_ERR_OK) {
    echo "Image upload error: " . $_FILES["image"]["error"];
    exit;
}

// ✅ Validate form fields
if (!isset($_POST['userName'], $_POST['foodName'], $_POST['feedback'], $_POST['rating'])) {
    echo "Missing form data";
    exit;
}

$filename = uniqid() . "_" . basename($_FILES["image"]["name"]);
$targetFile = $uploadDir . $filename;

if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
    $userName = $_POST['userName'];
    $foodName = $_POST['foodName'];
    $feedback = $_POST['feedback'];
    $rating = floatval($_POST['rating']);
    $imageUrl = "http://localhost/foodhub/assets/" . $filename;

    // ✅ Removed uid — use `id` (auto_increment) instead
    $stmt = $conn->prepare("INSERT INTO feedbacks (userName, foodName, feedback, rating, imageUrl, date) VALUES (?, ?, ?, ?, ?, NOW())");
    $stmt->bind_param("sssds", $userName, $foodName, $feedback, $rating, $imageUrl);

    if ($stmt->execute()) {
        echo "Success";
    } else {
        echo "Database insert error: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
} else {
    error_log("Upload failed. Debug info: " . print_r($_FILES, true));
    echo "Failed to upload image";
}
?>
