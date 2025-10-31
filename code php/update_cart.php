<?php
include 'db_connect.php';

$cart_item_id = $_POST['cart_item_id'];
$quantity = $_POST['quantity'];

$query = "UPDATE cart SET quantity = '$quantity' WHERE id = '$cart_item_id'";
$result = mysqli_query($conn, $query);

if ($result) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => mysqli_error($conn)]);
}
?>
