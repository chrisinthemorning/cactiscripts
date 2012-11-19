<?PHP
// wget -O- --user nsroot --password nsroot http://192.168.255.56/nitro/v1/stat/lbvserver | tr ',' '\n'

// jSON URL which should be requested

$json_url = 'http://192.168.255.56/nitro/v1/stat/lbvserver';
//$json_url = 'http://192.168.255.56/nitro/v1/stat/protocoltcp';
 
$username = 'nsroot';  // authentication
$password = 'nsroot';  // authentication

// $host     = $ARGV[0];
// $username = $ARGV[1];
// $password = $ARGV[2];
// $nitroapi = $ARGV[3];
// $json_url = "http://$host/nitro/v1/stat/$nitroapi/";
 
// Curl
$ch = curl_init( $json_url );
$options = array(
CURLOPT_RETURNTRANSFER => true,
CURLOPT_BINARYTRANSFER => true,
CURLOPT_SSL_VERIFYPEER => false,
CURLOPT_USERPWD => $username . ":" . $password,   // authentication
);
curl_setopt_array( $ch, $options );
$result =  curl_exec($ch); // Getting jSON result string

// Json
$json_result=json_decode($result,true);

// Memcache
//$memcache = new Memcache;
//$memcache->connect('localhost', 11211) or die ("Could not connect");
//$memcache->set('key', $json_result, false, 10) or die ("Failed to save data at the server");
//$get_result = $memcache->get('key');

// Split out json kvpairs into memcache kvpairs
foreach ($json_result as $key1 => $val1) { // This will search in the 2 jsons
  if (is_array($val1)) {
     foreach($val1 as $key2 => $val2) {
//			if (is_array($value) && $value['name'] == 'blah3') {
			if (is_array($val2)) {
				foreach($val2 as $key3 => $val3) {
				echo "$key3 $val3\n";
				}
			} else {
				 // if ( looks_like_number($value) ) {
					 // my $rvalue = sprintf "%.0f", $value;
				echo "$key2:$val2\n";
			}
		}
    } 
}


// Output
// echo var_dump($get_result)

?>

