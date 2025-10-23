<?php
try{
$server = "mysql:host=localhost;dbname=ai";
$user = "root";
$pass = "" ;
$pdo = new PDO($server,$user ,$pass);
$pdo->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
echo "connected successfully";


}
catch(PDOException $e){
            echo "Error ".$e->getMessage();
}

?>