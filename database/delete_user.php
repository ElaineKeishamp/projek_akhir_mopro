<?php
header("Access-Control-Allow-Origin: *");
$conn = new mysqli("localhost", "root", "", "campus_store");
$id = $_POST['id'];
if ($conn->query("DELETE FROM users WHERE id=$id") === TRUE) echo json_encode(["status"=>"success"]);
else echo json_encode(["status"=>"error"]);
$conn->close();
?>