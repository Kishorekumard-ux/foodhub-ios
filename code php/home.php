// food.php
<?php
include 'db_connect.php'; // Ensure this connects to $conn (MySQLi)

$sql = "SELECT * FROM food_items";
$result = $conn->query($sql);

$foodItems = array();

if ($result->num_rows > 0) {
  // output data of each row
  while($row = $result->fetch_assoc()) {
    $foodItems[] = $row;
  }
}

echo json_encode($foodItems);

$conn->close();
?>
