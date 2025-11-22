<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "campus_store");

$user_id = $_POST['user_id'] ?? '';
$total = $_POST['total'] ?? 0;
$address = $_POST['address'] ?? '';
$payment = $_POST['payment'] ?? 'COD';
$promo = $_POST['promo'] ?? '';
$items = json_decode($_POST['items'], true);

if (empty($user_id) || empty($items)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit();
}

// Query Insert dengan kolom baru
$sql = "INSERT INTO orders (user_id, total_price, status, shipping_address, payment_method, promo_code) 
        VALUES ('$user_id', '$total', 'pending', '$address', '$payment', '$promo')";

if ($conn->query($sql) === TRUE) {
    $order_id = $conn->insert_id;
    foreach ($items as $item) {
        $p_id = $item['id'];
        $p_name = $conn->real_escape_string($item['nama']);
        $qty = $item['qty'];
        $price = $item['harga'];
        $img = $item['img'];
        $conn->query("INSERT INTO order_items (order_id, product_id, product_name, quantity, price, img) VALUES ('$order_id', '$p_id', '$p_name', '$qty', '$price', '$img')");
    }
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "SQL Error: " . $conn->error]);
}
$conn->close();
?>