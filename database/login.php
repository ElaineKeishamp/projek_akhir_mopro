<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "campus_store");

$u = $_POST['username'];
$p = $_POST['password'];

$result = $conn->query("SELECT * FROM users WHERE username='$u' AND password='$p'");

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    // PERBAIKAN: Pastikan 'id' dikirim balik ke Flutter
    echo json_encode([
        "status" => "success",
        "id" => $row['id'],          // <--- INI KUNCINYA (JANGAN SAMPAI HILANG)
        "role" => $row['role'],
        "username" => $row['username'],
        "fullname" => $row['fullname'],
        "nim" => $row['nim'],
        "img" => $row['img']
    ]);
} else {
    echo json_encode(["status"=>"error", "message"=>"Username atau Password Salah"]);
}
$conn->close();
?>