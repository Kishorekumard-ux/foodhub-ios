<?php
header("Content-Type: application/json; charset=UTF-8");
include 'db_connect.php';

$category = isset($_POST['category']) ? trim($_POST['category']) : "";
$search = isset($_POST['search']) ? trim($_POST['search']) : "";

if (!$category) {
    http_response_code(400);
    echo json_encode(["error" => "Category is required"]);
    exit;
}

$allowedCategories = ['snack', 'Breakfast', 'veg', 'non-veg'];
if (!in_array($category, $allowedCategories)) {
    http_response_code(400);
    echo json_encode(["error" => "Invalid category"]);
    exit;
}

$sql = "SELECT id, name, description, price, image_url, availability_time, stock_level, discount FROM food_items WHERE category = ?";
if ($search) {
    $sql .= " AND name LIKE ?";
}

$stmt = $conn->prepare($sql);
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Database prepare failed: " . $conn->error]);
    exit;
}

if ($search) {
    $searchParam = "%$search%";
    $stmt->bind_param("ss", $category, $searchParam);
} else {
    $stmt->bind_param("s", $category);
}

$stmt->execute();
$result = $stmt->get_result();

$items = [];
date_default_timezone_set('Asia/Kolkata'); // Ensure timezone is set to your server's timezone
$now = strtotime(date("H:i"));

// Helper function to check if current time is within the range (inclusive)
function is_time_in_range($start, $end, $now) {
    // If end is less than or equal to start, it means the range passes midnight
    if ($end <= $start) {
        return ($now >= $start || $now <= $end);
    } else {
        return ($now >= $start && $now <= $end);
    }
}

while ($row = $result->fetch_assoc()) {
    $row['image_url'] = "http://localhost/foodhub/" . $row['image_url'];

    if ($row['availability_time']) {
        list($start, $end) = explode("-", $row['availability_time']);
        $start = str_replace(".", " ", trim($start));
        $end = str_replace(".", " ", trim($end));
        $startTime = strtotime($start);
        $endTime = strtotime($end);

        // Make end time inclusive for the full minute
        $endTime += 59;

        $row['is_available'] = is_time_in_range($startTime, $endTime, $now);
    } else {
        $row['is_available'] = false;
    }

    // Calculate discount if available
    $discountPercent = isset($row['discount']) ? floatval($row['discount']) : 0;
    $originalPrice = floatval($row['price']);
    if ($discountPercent > 0) {
        $discountedPrice = round($originalPrice * (1 - $discountPercent / 100), 2);
        $row['original_price'] = intval(round($originalPrice)); // Ensure integer for frontend
        $row['price'] = $discountedPrice;
        $row['discount_percent'] = $discountPercent;
    } else {
        $row['original_price'] = intval(round($originalPrice)); // Ensure integer for frontend
        $row['discount_percent'] = 0.0;
    }
    unset($row['discount']);

    $items[] = $row;
}

if (empty($items)) {
    echo json_encode([
        "message" => "No {$category} items available",
        "data" => []
    ]);
} else {
    echo json_encode([
        "message" => "Success",
        "data" => $items
    ]);
}

$stmt->close();
$conn->close();
?>
