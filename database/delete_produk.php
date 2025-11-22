<?php
header("Access-Control-Allow-Origin: *");
$conn = new mysqli("localhost", "root", "", "campus_store");

$id = $_POST['id'];
$sql = "DELETE FROM produk WHERE id=$id";

if ($conn->query($sql) === TRUE) echo json_encode(["status"=>"success"]);
else echo json_encode(["status"=>"error"]);
$conn->close();
?>