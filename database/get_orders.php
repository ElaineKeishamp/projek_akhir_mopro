<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "campus_store");

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if ($user_id) {
    // Customer: Lihat pesanan sendiri
    $sql = "SELECT * FROM orders WHERE user_id = '$user_id' ORDER BY id DESC";
} else {
    // Admin: Lihat semua pesanan + Nama Pembeli
    $sql = "SELECT orders.*, users.fullname 
            FROM orders 
            LEFT JOIN users ON orders.user_id = users.id 
            ORDER BY orders.id DESC";
}

$result = $conn->query($sql);
$orders = [];

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $oid = $row['id'];
        
        // Ambil Item
        $item_res = $conn->query("SELECT * FROM order_items WHERE order_id = '$oid'");
        $items = [];
        if ($item_res) {
            while($i = $item_res->fetch_assoc()) {
                $items[] = $i;
            }
        }
        $row['items'] = $items;
        
        // Fallback jika fullname kosong (untuk Admin)
        if (!isset($row['fullname'])) $row['fullname'] = "Customer";
        
        $orders[] = $row;
    }
}

echo json_encode($orders);
$conn->close();
?>