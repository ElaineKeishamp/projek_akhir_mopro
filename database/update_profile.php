<?php
header("Access-Control-Allow-Origin: *");
$conn = new mysqli("localhost", "root", "", "campus_store");

$old_username = $_POST['old_username']; // Kunci untuk mencari user
$new_fullname = $_POST['fullname'];
$new_nim = $_POST['nim'];

$sql = "UPDATE users SET fullname='$new_fullname', nim='$new_nim' WHERE username='$old_username'";

// Cek jika ada upload foto baru
if (isset($_FILES['image']['name'])) {
    $target = "uploads/" . time() . "_" . basename($_FILES["image"]["name"]);
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target)) {
        $sql = "UPDATE users SET fullname='$new_fullname', nim='$new_nim', img='$target' WHERE username='$old_username'";
    }
}

if ($conn->query($sql) === TRUE) echo json_encode(["status"=>"success"]);
else echo json_encode(["status"=>"error"]);
?>