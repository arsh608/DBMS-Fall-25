<?php
include("dbcon.php");
$categoryName = $categoryDes = $categoryImageName = "" ;
$categoryNameErr = $categoryDesErr = $categoryImageNameErr = "" ;
if(isset($_POST['addCategory'])){
    $categoryName = $_POST['cName'];
    $categoryDes = $_POST['cDes'];
    $categoryImageName = $_FILES['cImage']['name'];
    $categoryImageTmpName = $_FILES['cImage']['tmp_name'];
    $destination = "images/".$categoryImageName ;
    $extension = pathinfo($categoryImageName , PATHINFO_EXTENSION);//example.pdf ->pdf
    if(empty($categoryName)){
            $categoryNameErr = "category Name is Required";
    }
    if(empty($categoryDes)){
        $categoryDesErr = "Category Description is Required";
    }
    if(empty($categoryImageName)){
            $categoryImageNameErr = "Category Image is Requried";
    }
    else{
        $allowedExtensionArray = ["png","svg","jpg" ,"jpeg","webp"];
        if(!in_array($extension,$allowedExtensionArray)){
            $categoryImageNameErr = "Invalid Extension";
        }
    }
    if(empty($categoryNameErr) && empty($categoryImageNameErr) && empty($categoryDesErr)){
             if(move_uploaded_file($categoryImageTmpName,$destination)){
                $query = $pdo->prepare("insert into categories (name , des , image) values (:cName , :cDes ,:cImage)");
                $query->bindParam("cName",$categoryName);
                $query->bindParam("cDes",$categoryDes);
                $query->bindParam("cImage",$categoryImageName);
                $query->execute();
                echo "<script>alert('category added successfully');location.assign('select.php')</script>";
             }   
    }
}
//super global _post
//global: outside curly brackets: can be accessd any wehre
// update category wORK
if(isset($_POST['updateCategory'])){
    $categoryName = $_POST['cName'];
    $categoryDes = $_POST['cDes'];
    //without image scaneario 1()
    $categoryId = $_GET['cId'];
    $query = $pdo->prepare("update categories set name = :cName, des = :cDes
    where id = :cId");
    if(!empty($_FILES['cImage']['name'])){
        $categoryImageName = $_FILES['cImage']['name'];
        $categoryImageTmpName = $_FILES['cImage']['tmp_name'];
        $extension = pathinfo($categoryImageName, PATHINFO_EXTENSION);
        $categoryImageTmpName = $_FILES['cImage']['tmp_name'];
        $categoryImageTmpName = $_FILES['cImage']['tmp_name'];
        if(move_uploaded_file($categoryImageTmpName, $destination)){
            $query = $pdo->prepare("update categories set name = :cName, des = :cDes
                where id = :cId");
                $query->bindParam('cImage', $categoryImageName);
        }
    }
    $query->bindParam('cId', $categoryId);
    $query->bindParam('cName', $categoryName);
    $query->bindParam('cDes', $categoryDes);
    $query->execute();
    echo "<script>alert('category Updated');location.assign('select.php')</script>";
}

if (isset($_GET['deleteCategory'])) {
    $categoryId = $_GET['deleteCategory'];

    // First, get the image name to delete it from the folder
    $stmt = $pdo->prepare("SELECT image FROM categories WHERE id = :catId");
    $stmt->bindParam(":catId", $categoryId);
    $stmt->execute();
    $category = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($category) {
        $imagePath = "images/" . $category['image'];
        if (file_exists($imagePath)) {
            unlink($imagePath); // delete image file
        }

        // Delete from database
        $deleteStmt = $pdo->prepare("DELETE FROM categories WHERE id = :catId");
        $deleteStmt->bindParam(":catId", $categoryId);
        $deleteStmt->execute();

        echo "<script>alert('Category deleted successfully');location.assign('select.php');</script>";
    } else {
        echo "<script>alert('Category not found');location.assign('select.php');</script>";
    }
}

?>