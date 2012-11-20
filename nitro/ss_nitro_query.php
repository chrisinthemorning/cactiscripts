<?PHP

$no_http_headers = true;

/* display No errors */
error_reporting(E_ERROR);

include_once(dirname(__FILE__) . "/../include/config.php");
include_once(dirname(__FILE__) . "/../lib/snmp.php");

if (!isset($called_by_script_server)) {
        array_shift($_SERVER["argv"]);
        print call_user_func_array("ss_nitro", $_SERVER["argv"]);
}
function ss_nitro($host, $username, $password, $nitroapi, $cmd, $arg1 = "", $arg2 = "", $arg3 = "") {
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
        $result =  curl_exec($ch);
        $json_result=json_decode($result,true);
        foreach ($json_result as $key1 => $val1) {
        if (is_array($val1)) {
                        if ($cmd == 'num_indexes') {
                                echo count($val1);
                        } else {
                     foreach($val1 as $key2 => $val2) {
                                        if (is_array($val2)) {
                                                if($cmd == 'get' && $arg3 == $val2[$arg1] && !is_null($val2[$arg2]) ) {
                                                        return $val2[$arg2];
                                                } elseif ($cmd == 'query' ) {
                                print $val2[$arg1] . "!" . $val2[$arg2] . "\n";
                                                } elseif ($cmd == 'index' && !is_null($val2[$arg1]) ) {
                                                        print $val2[$arg1] . "\n";
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
}
?>