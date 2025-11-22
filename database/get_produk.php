<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "campus_store");

$sql = "SELECT p.*, 
        (SELECT AVG(rating) FROM reviews WHERE product_id = p.id) as avg_rating,
        (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) as total_reviews
        FROM produk p ORDER BY id DESC";

$result = $conn->query($sql);
$data = [];
while($row = $result->fetch_assoc()) {
    $row['avg_rating'] = $row['avg_rating'] ? substr($row['avg_rating'], 0, 3) : "0.0";
    $row['total_reviews'] = $row['total_reviews'] ? $row['total_reviews'] : "0";
    $data[] = $row;
}
echo json_encode($data);
$conn->close();
?>