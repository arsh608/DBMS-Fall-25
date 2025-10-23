<?php
include("php/query.php");
?>
<!doctype html>
<html lang="en">
  <head>
    <title>Title</title>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  </head>
  <body>
    
            <div class="container p-5">
                <form action="" method="post" enctype="multipart/form-data">
                    <div class="form-group">
                      <label for="">Name</label>
                      <input type="text" name="cName" id="" class="form-control" placeholder="" aria-describedby="helpId">
                      <small id="helpId" class="text-danger"><?php echo $categoryNameErr?></small>
                    </div>
                    <div class="form-group">
                      <label for="">Image</label>
                      <input type="file" name="cImage" id="" class="form-control" placeholder="" aria-describedby="helpId">
                      <small id="helpId" class="text-danger"><?php echo $categoryImageNameErr?></small>
                    </div>
                    <div class="form-group">
                      <label for="">Description</label>
                      <textarea type="text" name="cDes" id="" class="form-control" placeholder="" aria-describedby="helpId"></textarea>
                      <small id="helpId" class="text-danger"><?php echo $categoryDesErr?></small>
                    </div>

                    <button class="btn-info btn" name="addCategory">Add Category</button>
                </form>
            </div>
    
  </body>
</html>