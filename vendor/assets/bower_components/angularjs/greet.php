<?php
error_reporting(0);
$name = $_GET['name'];
$callback = $_GET['callback'];
$salutations = array(
    "Adab",
    "Ahoj",
    "An-nyeong-ha-se-yo",
    "Apa khabar",
    "Barev Dzez",
    "Buenos días",
    "Bula Vinaka",
    "Chào",
    "Ciao",
    "Dia Duit",
    "Hallo",
    "Hallå",
    "Halló",
    "Halo",
    "Haye",
    "Hei",
    "Hej",
    "Hello",
    "Helo",
    "Hola",
    "Kamusta",
    "Konnichiwa",
    "Merhaba",
    "Mingalarba",
    "Namaskar",
    "Namaste",
    "Olá",
    "Pryvit",
    "Pryvitannie",
    "Përshëndetje",
    "Salam",
    "Salut",
    "Sat Sri Akal",
    "Sholem aleikhem",
    "Sveiki",
    "Szia",
    "Tere",
    "Zdraveĭte",
    "Zdravo" );
$salutation = $salutations[rand(0, count($salutations) - 1)];
$greeting = $salutation . ' ' . $name . '!';
$data = array(
  "name" => $name,
  "salutation" => $salutation,
  "greeting" => $greeting );  
$json = json_encode($data);  
header("Content-type: text/javascript");  
if ($callback)
  echo $callback .' (' . $json . ');';  
else
  echo $json;  
?>