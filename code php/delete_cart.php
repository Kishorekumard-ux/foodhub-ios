<?php
include 'db_connect.php';

$cart_item_id = $_POST['cart_item_id'];

$query = "DELETE FROM cart WHERE id = '$cart_item_id'";
$result = mysqli_query($conn, $query);

if ($result) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => mysqli_error($conn)]);
}
?>
