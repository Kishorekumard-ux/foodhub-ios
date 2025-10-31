<?php

include 'db_connect.php'; // Ensure this connects to $conn (MySQLi)

// First, try to get breakfast category with discount
$sql = "SELECT category, MAX(discount) as max_discount 
        FROM food_items 
        WHERE discount > 0 AND category = 'breakfast'
        GROUP BY category 
        LIMIT 1";
$result = $conn->query($sql);

if ($result && $row = $result->fetch_assoc()) {
    echo json_encode([
        "category" => $row["category"],
        "discount" => (int)$row["max_discount"]
    ]);
} else {
    // If not found, get the highest discount among all categories
    $sql2 = "SELECT category, MAX(discount) as max_discount 
            FROM food_items 
            WHERE discount > 0 
            GROUP BY category 
            ORDER BY max_discount DESC 
            LIMIT 1";
    $result2 = $conn->query($sql2);
    if ($result2 && $row2 = $result2->fetch_assoc()) {
        echo json_encode([
            "category" => $row2["category"],
            "discount" => (int)$row2["max_discount"]
        ]);
    } else {
        echo json_encode([]);
    }
}
$conn->close();
?>
