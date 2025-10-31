<?php
include 'db_connect.php';

$user_id = $_POST['user_id'];
$query = "SELECT * FROM cart WHERE user_id = '$user_id'";
$result = mysqli_query($conn, $query);

$cart_items = [];
while ($row = mysqli_fetch_assoc($result)) {
    $cart_items[] = $row;
}

echo json_encode($cart_items);
?>
