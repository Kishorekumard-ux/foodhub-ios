<?php
header('Content-Type: application/json');
include 'db_connect.php'; // Assumes $conn is a valid mysqli connection

// Allow only POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode([
        "success" => false,
        "data" => [],
        "message" => "Only POST method is allowed. Please use POST to access this endpoint."
    ]);
    exit;
}

$statusFilter = $_POST['status'] ?? null;

// ✅ Added `transaction_id` to the SELECT statement
$sql = "SELECT id, user_name, phone_number, address, order_type, delivery_date, delivery_time, total_items, total_price, payment_method, cart_items, created_at, status, transaction_id FROM payment_details";

$params = [];
$types = '';

if (!empty($statusFilter)) {
    $sql .= " WHERE status = ?";
    $params[] = $statusFilter;
    $types .= 's';
}

$sql .= " ORDER BY delivery_date ASC, delivery_time ASC";

try {
    if (!empty($params)) {
        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        $result = $stmt->get_result();
    } else {
        $result = $conn->query($sql);
    }

    $response = [];

    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            // Decode cart_items JSON array
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
            "message" => "No orders found."
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
