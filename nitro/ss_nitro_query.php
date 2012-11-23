?PHP
// wget -O- --user nsroot --password nsroot http://192.168.255.56/nitro/v1/stat/lbvserver | tr ',' '\n'

// jSON URL which should be requested

//$json_url = 'http://192.168.255.56/nitro/v1/stat/lbvserver';
//$json_url = 'http://192.168.255.56/nitro/v1/stat/protocoltcp';
 
//$username = 'nsroot';  // authentication
//$password = 'nsroot';  // authentication

$host     = $argv[1];
$username = $argv[2];
$password = $argv[3];
$nitroapi = $argv[4];
$json_url = "http://$host/nitro/v1/stat/$nitroapi/";
 
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
	  	if ($argv[5] == 'num_indexes') {
	  		echo count($val1);
	  	} else {
	     foreach($val1 as $key2 => $val2) {
	//			if (is_array($value) && $value['name'] == 'blah3') {
				if (is_array($val2)) {
					if($argv[5] == 'get' && $argv[8] == $val2[$argv[6]] && !is_null($val2[$argv[7]]) ) {
						echo $val2[$argv[7]];
					} elseif ($argv[5] == 'query' ) {
                        echo $val2[$argv[6]] . "!" . $val2[$argv[7]] . "\n";
					} elseif ($argv[5] == 'index' && !is_null($val2[$argv[6]]) ) {
						echo $val2[$argv[6]] . "\n";
					}
				} else {
					if (is_numeric($val2)) {
						 $prettyval2 = sprintf("%.0f", $val2);
						 echo "$key2:$prettyval2 ";
					}
				}
			}
	    }
    } 
}
// Output
