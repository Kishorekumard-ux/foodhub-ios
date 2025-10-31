<?php
header('Content-Type: application/json');
include 'db_connect.php'; // Assumes $conn is your mysqli connection

// Allow only POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        "success" => false,
        "data" => [],
        "message" => "Only POST method is allowed."
    ]);
    exit;
}

// Get phone number from form-data (not from JSON or URL-encoded)
$phoneNumber = $_POST['phoneNumber'] ?? '';

if (empty($phoneNumber)) {
    echo json_encode([
        "success" => false,
        "data" => [],
        "message" => "Phone number is required."
    ]);
    exit;
}

$sql = "SELECT id, user_name, phone_number, address, order_type, delivery_date, delivery_time, total_items, total_price, payment_method, cart_items, created_at, status 
        FROM payment_details 
        WHERE phone_number = ? 
        ORDER BY delivery_date ASC, delivery_time ASC";

try {
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $phoneNumber);
    $stmt->execute();
    $result = $stmt->get_result();

    $response = [];

    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            // Decode cart_items array from JSON to readable string
            $cartItems = json_decode($row['cart_items'], true);
            $formattedCartItems = [];

            if (is_array($cartItems)) {
                foreach ($cartItems as $item) {
                    if (isset($item['name'], $item['quantity'], $item['price'])) {
                        $formattedCartItems[] = $item['name'] . " (x" . $item['quantity'] . ", ₹" . $item['price'] . ")";
                    }
                }
            }

            $row['cart_items'] = implode(", ", $formattedCartItems);
            $response[] = $row;
        }

        echo json_encode([
            "success" => true,
            "data" => $response
        ]);
    } else {
        echo json_encode([
            "success" => true,
            "data" => [],
            "message" => "No orders found for this number."
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "data" => [],
        "message" => "Server error: " . $e->getMessage()
    ]);
}

$conn->close();
?>
