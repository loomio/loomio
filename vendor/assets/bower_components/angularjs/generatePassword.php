<?php
$callback = $_GET['callback'];
$password = '';
for($counter = rand(3,10); $counter > 0; $counter --) {
  $password = $password . chr(rand(33, 126));
}
$data = array(
  "password" => $password );  
$json = json_encode($data);  
header("Content-type: text/javascript");  
if ($callback)
  echo $callback .' (' . $json . ');';  
else
  echo $json;  
?>