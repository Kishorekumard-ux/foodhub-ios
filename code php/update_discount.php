<?php
// update_discount.php

include 'db_connect.php'; // contains $conn = new mysqli(...) etc.

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $category = $_POST['category'] ?? '';
    $discount = $_POST['discount'] ?? '';

    if ($category && is_numeric($discount)) {
        $discount = floatval($discount);
        $category = mysqli_real_escape_string($conn, $category);

        $query = "UPDATE food_items SET discount = $discount WHERE category = '$category'";

        if (mysqli_query($conn, $query)) {
            echo json_encode(['status' => 'success', 'message' => 'Discount updated']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Database update failed']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
