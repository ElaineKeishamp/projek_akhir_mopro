<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "campus_store");

if ($conn->connect_error) {
    die(json_encode([]));
}

// Query: Ambil semua user KECUALI yang rolenya 'admin'
// Tujuannya agar Admin tidak bisa menghapus dirinya sendiri
$sql = "SELECT * FROM users WHERE role != 'admin' ORDER BY id DESC";

$result = $conn->query($sql);

$users = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

// Selalu kembalikan JSON (walaupun kosong)
echo json_encode($users);

$conn->close();
?>