#!/usr/bin/perl -w


#use strict;
use JSON -support_by_pp;
use HTTP::Request;
use LWP::UserAgent;
use Scalar::Util qw(looks_like_number);

my $host = $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];
my $nitroapi = $ARGV[3];
my $json_url = "http://$host/nitro/v1/stat/$nitroapi/";
my $content;

$content = fetch_json($json_url);

my $json = new JSON;
my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);

while (my ($key, $value) = each %{$json_text->{$nitroapi}}) {
 if (looks_like_number($value)) {
    my $rvalue = sprintf "%.0f", $value;
    print "$key:$rvalue ";
 }
}

sub fetch_json {
   my ($url) = @_;
   my $request = HTTP::Request->new(GET => $url);
   my $ua = LWP::UserAgent->new;
   $ua->credentials("$host:80", "NITRO", $username, $password);
   my $response = $ua->request($request);
   # Should do some error checking
   return $response->content();
}
