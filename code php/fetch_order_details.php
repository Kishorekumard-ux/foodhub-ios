<?php
include 'db_connect.php'; // Assuming this file contains your database connection

// Get username from request
$userName = $_GET['userName'];

// Prepare SQL statement to fetch the order details based on user_name
$query = "SELECT id, shop_name, user_name, phone_number, total_price, rent_fee, labor_fee, chef_fee, 
                 duration, event_date, event_time, address, payment_method, menu_items, status
          FROM event_details 
          WHERE user_name = ?";

if ($stmt = $conn->prepare($query)) {
    $stmt->bind_param("s", $userName);
    $stmt->execute();
    $result = $stmt->get_result();

    $orders = [];

    while ($row = $result->fetch_assoc()) {
        $order = [
            'orderId' => $row['id'],
            'shopName' => $row['shop_name'],
            'userName' => $row['user_name'],
            'phoneNumber' => $row['phone_number'],
            'totalPrice' => $row['total_price'],
            'address' => $row['address'],
            'paymentMethod' => $row['payment_method'],
            'menuItems' => json_decode($row['menu_items']), // Decoding the JSON formatted menu items
            'eventDate' => $row['event_date'],
            'eventTime' => $row['event_time'],
            'status' => $row['status'], // Fetch the status column
        ];
        $orders[] = $order;
    }

    // Return the result as JSON
    echo json_encode(['status' => 'success', 'orders' => $orders]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Database query failed']);
}

$conn->close();
?>
