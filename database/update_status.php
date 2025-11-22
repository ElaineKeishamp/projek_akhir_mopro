<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Tampilkan error untuk debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$conn = new mysqli("localhost", "root", "", "campus_store");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "DB Connection Failed"]));
}

$id = isset($_POST['order_id']) ? $_POST['order_id'] : '';
$status = isset($_POST['status']) ? $_POST['status'] : '';

if (empty($id) || empty($status)) {
    echo json_encode(["status" => "error", "message" => "ID atau Status kosong"]);
    exit();
}

// Update status
$sql = "UPDATE orders SET status='$status' WHERE id='$id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Status berhasil diubah"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal Update: " . $conn->error]);
}

$conn->close();
?>