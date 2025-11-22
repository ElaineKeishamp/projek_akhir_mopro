<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
$conn = new mysqli("localhost", "root", "", "campus_store");

$p_id = $_POST['product_id'];
$u_id = $_POST['user_id'];
$username = $_POST['username'];
$rating = $_POST['rating'];
$comment = $conn->real_escape_string($_POST['comment']); // Cegah error tanda kutip

$sql = "INSERT INTO reviews (product_id, user_id, username, rating, comment, created_at) 
        VALUES ('$p_id', '$u_id', '$username', '$rating', '$comment', NOW())";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
$conn->close();
?>