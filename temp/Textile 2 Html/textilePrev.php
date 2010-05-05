<?php
require_once('classTextile.php');

	$fileIn = $GLOBALS['argv'][1];
	$style  = 'style.css';

	$hIn     = fopen($fileIn, 'r') or die("Can't open file");
	$hStyle  = fopen($style, 'r') or die("Can't open style file");
	$data    = fread($hIn, filesize($fileIn));
	$style   = fread($hStyle, filesize($style));
	fclose($hIn);
	
	$textile = new Textile();
	$data = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><HTML><HEAD><style type="text/css">' . $style . '</STYLE></HEAD><BODY>' . 
			$textile->TextileThis($data) . '</BODY></HTML>'; 


	$fileOut = getenv('TEMP') . "\_mm_textile_preview.html";
	if (file_exists($fileOut)) unlink($fileOut);

	if (!$hOut = fopen($fileOut, 'a')){
		echo "Cannot open file for writting";
		exit;
	}

	if (fwrite($hOut, $data) === FALSE) {
		   echo "Cannot write to file ($fileOut)";
		   exit;
	}
	fclose($hOut);
	exec($fileOut);
?>
