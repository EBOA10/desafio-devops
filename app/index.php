<?php
// Define uma variável simples para a mensagem
$mensagem = "<h1>[SUCESSO] O Contêiner PHP está no ar!</h1>";
$hostname = gethostname();

// Exibe a mensagem e o hostname
echo $mensagem;
echo "<p>Este conteúdo está sendo servido pelo hostname do contêiner: <strong>" . $hostname . "</strong></p>";
echo "<p>Versão do PHP: " . phpversion() . "</p>";
?>
