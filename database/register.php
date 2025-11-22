<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "campus_store");

$user = $_POST['username'];
$pass = $_POST['password'];
$role = $_POST['role'];
$fullname = $_POST['fullname'];
$nim = $_POST['nim'];

// 1. Cek Username
if ($conn->query("SELECT * FROM users WHERE username='$user'")->num_rows > 0) {
    echo json_encode(["status"=>"error", "message"=>"Username sudah dipakai"]);
    exit();
}

// 2. Proses Upload Foto
$imagePath = "images/profile_default.jpg"; // Default jika tidak upload

if (isset($_FILES['image']['name'])) {
    $target_dir = "uploads/";
    // Nama file unik: timestamp_namafile
    $fileName = time() . "_" . basename($_FILES["image"]["name"]); 
    $target_file = $target_dir . $fileName;

    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
        $imagePath = "uploads/" . $fileName; // Simpan path ini ke DB
    } else {
        echo json_encode(["status"=>"error", "message"=>"Gagal upload gambar"]);
        exit();
    }
}

// 3. Simpan ke Database
$sql = "INSERT INTO users (username, password, role, fullname, nim, img) VALUES ('$user', '$pass', '$role', '$fullname', '$nim', '$imagePath')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status"=>"success"]);
} else {
    echo json_encode(["status"=>"error", "message"=>$conn->error]);
}
$conn->close();
?>