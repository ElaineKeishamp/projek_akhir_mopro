<?php
header("Access-Control-Allow-Origin: *");
$conn = new mysqli("localhost", "root", "", "campus_store");

$nama = $_POST['nama']; $kategori = $_POST['kategori'];
$harga = $_POST['harga']; $stok = $_POST['stok']; $deskripsi = $_POST['deskripsi'];
$seller_id = $_POST['seller_id']; // ID Penjual
$seller_name = $_POST['seller_name']; // Nama Penjual

$imagePath = "images/default.jpg";
if (isset($_FILES['image']['name'])) {
    $target = "uploads/" . time() . "_" . basename($_FILES["image"]["name"]);
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target)) $imagePath = "uploads/" . basename($target);
}

$sql = "INSERT INTO produk (nama, kategori, harga, stok, img, deskripsi, seller_id, seller_name) VALUES ('$nama', '$kategori', '$harga', '$stok', '$imagePath', '$deskripsi', '$seller_id', '$seller_name')";

if ($conn->query($sql) === TRUE) echo json_encode(["status"=>"success"]);
else echo json_encode(["status"=>"error"]);
$conn->close();
?>