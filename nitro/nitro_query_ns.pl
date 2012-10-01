#!/usr/bin/perl -w

#use strict;
use JSON -support_by_pp;
use HTTP::Request;
use LWP::UserAgent;
use Scalar::Util qw(looks_like_number);
use Cache::Memcached;
use Scalar::Util
  qw(blessed dualvar isweak readonly refaddr reftype tainted weaken isvstring looks_like_number set_prototype);

my $host     = $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];
my $nitroapi = $ARGV[3];
my $json_url = "http://$host/nitro/v1/stat/$nitroapi/";
my $content;

#$content = fetch_json($json_url);

my $check_interval = 50;
my $max_loop_time  = 20;

my $memd = new Cache::Memcached {
    'servers'            => ['127.0.0.1:11211'],
    'debug'              => 0,
    'compress_threshold' => 10_000,
    'namespace'          => "Cacti::Nitro/$host/$nitroapi/",
};

# Check the timestamp
my $timestamp = $memd->get("timestamp");
my $api_json  = $memd->get("api_json");
if ( ( defined $timestamp ) && ( defined $api_json ) ) {

    # Check if we are beyond the check interval based on the last timestamp
    if ( time() >= ( $timestamp + $check_interval ) ) {

# We have exceeded the check interval and might need to fetch an update if no one else is.
        unless ( defined $memd->get("lock") ) {
            $memd->set( "lock", 1 );
            $content = fetch_json($json_url);
            $memd->set( "api_json",  $content );
            $memd->set( "timestamp", time() );
            $memd->delete("lock");
        }
        else {

            #print "Locked\n";
            # Loop for a while waiting for the lock to clear
            my $time_elapsed = 0;
            while ( defined $memd->get("lock") ) {

                #print "locked, looping. time_elapsed = $time_elapsed\n";
                # sleep for a random amount of time from 100-600ms
                my $wait_time = 0.1 + ( int( rand(500) ) * 0.001 );
                select( undef, undef, undef, $wait_time );
                $time_elapsed += $wait_time;
                if ( $time_elapsed >= $max_loop_time ) {

                    # Loop timer elapsed. Something has gone wrong
                    $content = fetch_json($json_url);
                    $memd->set( "api_json",  $content );
                    $memd->set( "timestamp", time() );
                    $memd->delete("lock");
                }
            }

            # Assume that now that the lock is cleared, the data is current
            #print "Lock loop has exited\n";
            $content = $api_json;
        }
    }
    else {

#print "Data in cache is current:" . time() . " > " . ($timestamp + $check_interval) . "\n";
# We don't need to check again, just use the cached value
        $content = $api_json;
    }
}
else {

# timestamp and/or json aren't defined (e.g. first run). We need to fetch the JSON and set the timestamp
    $memd->set( "lock", 1 );
    $content = fetch_json($json_url);
    $memd->set( "api_json",  $content );
    $memd->set( "timestamp", time() );
    $memd->delete("lock");
}

my $json = new JSON;
my $json_text =
  $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote
  ->allow_barekey->decode($content);

if ( reftype $json_text->{$nitroapi} eq 'ARRAY' ) {
    my $nitro_index = 0;
    foreach my $nitroitem ( @{ $json_text->{$nitroapi} } ) {

        while ( my ( $key, $value ) = each %{$nitroitem} ) {
            if (   ( $ARGV[4] eq "get" )
                && ( $ARGV[6] eq $key )
                && ( $ARGV[7] eq ${ %{$nitroitem} }{ $ARGV[5] } ) )
            {
                print $value;
            }
            elsif ( ( $ARGV[4] eq "query" ) && ( $ARGV[6] eq $key ) ) {

                #print "$nitro_index!$value\n";
                print "${%{$nitroitem}}{$ARGV[5]}!$value\n";
            }
            elsif ( ( $ARGV[4] eq "index" ) && ( $ARGV[5] eq $key ) ) {
                print "$value\n";
            }
        }
        $nitro_index++;

        #       if (($ARGV[4] eq "index") && ($ARGV[5] eq $key)) {
        #print "$nitro_index\n";
        #               print "$key\n";
        #       }
    }
    if ( $ARGV[4] eq "num_indexes" ) {
        print "$nitro_index\n";
    }
}
else {
    foreach $key ( sort keys %{ $json_text->{$nitroapi} } ) {
        my $value = ${ $json_text->{$nitroapi} }{$key};
        if ( looks_like_number($value) ) {
            my $rvalue = sprintf "%.0f", $value;
            print "$key:$rvalue ";
        }
    }

}

sub fetch_json {
    my ($url) = @_;
    my $request = HTTP::Request->new( GET => $url );
    my $ua = LWP::UserAgent->new;
    $ua->credentials( "$host:80", "NITRO", $username, $password );
    my $response = $ua->request($request);
    return $response->content();
}
