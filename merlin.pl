#!/usr/bin/perl 

use Digest::MD5 qw(md5_hex);
use IO::Socket::INET;
use IO::Socket::SSL;
use HTML::Entities;
use LWP::UserAgent;
use HTTP::Request;
use MIME::Base64;
require LWP;
use LWP;
$|++;



my $process   = "merlin-irc-bot";
my $ircserver = "irc.server.net";
my $port      = "6697";
my $nickname  = "Merlin";
my $channel = "";
my $admin = "c0d3d";


$SIG{'INT'},IGNORE;
$SIG{'HUP'},IGNORE;
$SIG{'DIE'},IGNORE;
$SIG{'PIPE'},IGNORE;

my $os= "$^O";
if ($os eq 'MSWin32'){
    print "\n   Your Operating System is $os, therefore, this program may not function efficiently.\n";
    print "\n	I advice you re-run on a Linux system. However, I'll proceed with connection.\n";
    sleep(10);
    system("cls");
    }else{
        system("clear");
    }

    print "\n*===============================================*\n";
    print "   IRC Bot - Merlin\n";
    print "   Merlin is an IRC Bot written in perl language\n";
    print "   Sometimes in our irc life, we all need an interactive channel bot,\n";
    print "   So here comes Merlin. Feel free to update and share,\nbut please reserve the author's credit. \n";
    print "   \n";
    print "   Your operating system is $os \n";
    print "*===============================================*\n\n";


    my $pid = fork;
    exit if $pid;
    $0 = "$process" . "\0" x 16;

#Default Connection Protocol is SSL. You can switch to IO::Socket::INET if your server does not support SSL.
#And remember to scroll back up to change the server port from 6697 to whateva your setting is. :-)
my $dsp = IO::Socket::SSL->new(
    PeerAddr => "$ircserver",
    PeerPort => "$port",
    Proto => "tcp"
    ) or die "Cannot connect to server!\n";
$dsp->autoflush(1);
print $dsp "NICK $nickname\r\n";
print $dsp "USER MatriX 8 *  : I am From ZioN \r\n";
#print $dsp "NickServ identify password\r\n"; #Assign a nickserv pass to authenticate bot on server.
sleep(1);


while ($line = <$dsp>) { #This line makes sure the bot keeps listening to chat contents.

#This portion makes sure the bot don't timeout often.
$line =~ s/\r\n$//;
if ($line =~ /^PING \:(.*)/) {
    print $dsp "PONG :$1\r\n";
}

if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!iplocation\s+(.*)/){
    my $ipasker = $1;
    my $askchan = $3;
    my $ip = $4;
    if (length($ip) > 17) {
        &msg($askchan,"Location for [ $ip ] Not Found!");
    }
    else{
        my $ua = LWP::UserAgent->new();
        my $contents = $ua->get('http://www.melissadata.com/lookups/iplocation.asp?ipaddress='.$ip);
        my $found = $contents->content;
        if ($found =~ /<tr><td class='columresult'>Country<\/td><td align='left'><b>(.*)<\/b><\/td><\/tr>/) {
            &msg($askchan,"[ $ipasker ] The Location for [ $ip ] is [ $1 ]");
        }
        else{
            &msg($askchan,"Location for [ $ip ] Not Found!");
        }
    }
}


if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!s\s+(.*)/){
    my $s_link;
    my $schan = $3;
    my $search = $4;
    my $ua = LWP::UserAgent->new();
    $ua->agent( "Mozilla/5.0 (X11; Linux i686; rv:2.0.0) Gecko/20100101" );
    my $contents = $ua->get("http://www.bing.com/search?q=".$search);
    if ( $contents->is_success ) {
        my $resp = $contents->content;
        if($resp =~ m/<li><a href=\"htt([^>\"]*)\"/ig){
            my $s_link = htt.$1;
            if($s_link =~ /microsoft/){
                &msg($schan,"Search Result - No result found for $search");
                }else{
                    &msg($schan,"Search Result - $s_link\n");
                }
            }
            if($resp =~ m/<p><strong>([^>\"]*)<\/strong>([^>\"]*)<\/p><\/div><\/div><\/li>/ig){
                my $s_say = $1;
                my $s_say2 = $2;
                $s_say = decode_entities($s_say);
                $s_say2 = decode_entities($s_say2);
                &msg($schan,"$s_say $s_say2");
            }
        }
    }


    if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!urban\s+(.*)/){
        my $uchan = $3;
        my $usearch = $4;
        my $ua = LWP::UserAgent->new();
        $ua->agent( "Mozilla/5.0 (X11; Linux i686; rv:2.0.0) Gecko/20100101" );
        my $contents = $ua->get("http://www.urbandictionary.com/define.php?term=".$usearch);
        if ( $contents->is_success ) {
            my $resp = $contents->content;
            if($resp =~ m/<meta content='(.+)' name='Description'/g){
                my $ubrez = $1;
                $ubrez = $s_say = decode_entities($ubrez);
                &msg($uchan,"Urban $usearch - $ubrez\n");
                }else{
                    &msg($uchan,"No result found for $usearch\n");
                }
            }
        }

        if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!w\s+(.*)/){
            my $val;
            my $wechan = $3;
            my $wesearch = $4;
            my $ua = LWP::UserAgent->new();
            $ua->agent( "Mozilla/5.0 (X11; Linux i686; rv:2.0.0) Gecko/20100101" );
            my $contents = $ua->get("http://www.wunderground.com/cgi-bin/findweather/getForecast?bannertypeclick=htmlSticker&query=".$wesearch."&GO=GO");
            if ( $contents->is_success ) {
                my $resp = $contents->content;
                if($resp =~ m/<meta property="og:title" content="(.+) \| (.+) \| (.+)" \/>/g){
                    my $one = $1;
                    my $two = $2;
                    my $three = $3;
                    $two =~ s/&deg;//;
                    $cel = ($two - 32) * 5/9;
                    $cel =~ s/\...*//;
                    $celc = $cel.'&deg;';
                    $celc = decode_entities($celc);
                    if($resp =~ m/<div class="local-time"><i class="fi-clock"><\/i> <span>(.+)<\/span>(.+)<\/div>/g){
                        my $time = $1;
                        my $gmt = $2;
                        if($resp =~ m/<span class="wx-value">(.+)<\/span><span class="wx-unit">\%<\/span>/g){
                            my $hum = $1;
                            &msg($wechan,"Weather For $one is $three and $celc C In temperature [Humidity $hum%] [ $time ] -$gmt\n");
                        }
                    }
                    }else{
                        &msg($wechan,"No Result Found (Try !w City State Country)\n");
                    }
                }
            }

            if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!md5\s+(.*)/){
                my $asker = $1;
                my $mchan = $3;
                my $md5_hash = $4;
                my $md5_generated = md5_hex($md5_hash);
                &msg($mchan,"[ $asker ] the md5 hash for [ $md5_hash ]  is  [ $md5_generated ]");
            }

            if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!crack\s+(.*)/){
                my $asker = $1;
                my $hchan = $3;
                my $hash = $4;
                if (length($hash) != 33) {
                    &msg($hchan,"[ $asker ] $hash is not a valid md5 hash");
                }
                else{
                    my $ua = LWP::UserAgent->new();
                    my $contents = $ua->get('http://md5.rednoize.com/?p&s=md5&q='.$hash);
                    my $cracked = $contents->content;
                    if ($cracked) {
                        &msg($hchan,"[ $asker ] Cracked $hash => [ $cracked ]");
                    }
                    else{
                        &msg($hchan,"[ $asker ] Crack not found for [ $hash ]");
                    }
                }
            }



            if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!base64 encode\s+(.*)/){
                my $base64 = $4;
                my $asker = $1;
                my $bchan = $3;
                $base64_encoded = encode_base64($base64);
                &msg($bchan,"[ $asker ] base64 Encode for $base64 is [ $base64_encoded ]");
            }


            if($line =~ /:(.*)!(.*) PRIVMSG (.*) :!base64 decode\s+(.*)/){
                my $base64d = $4;
                my $dchan = $3;
                my $asker = $1;
                my $base64_decoded = decode_base64($base64d);
                &msg($dchan,"$asker - base64 Decode for $base64d is $base64_decoded");
            }

            if ( $line =~ /PRIVMSG (.*) :!check\s+(.*?)\s+(.*)/ ) { 
                my $cchan = $1; 
                my $host = $2; 
                my $port = $3; 
                $scansock = IO::Socket::INET->new(
                   PeerAddr => $host, 
                   PeerPort => $port, 
                   Proto => 'tcp', 
                   Timeout => 8
                   ); 
                if ($scansock) {
                    &msg($cchan,"Port: $port is open on the $host");
                    $scansock->close;
                }
                else
                {
                    &msg($cchan,"Port: $port is closed on $host");
                }
            }


#Here is the calculating section. Maths is very important :-)
if ( $line =~ /PRIVMSG (.*) :!cal\s+(.*)/ ) {
    my $matchan = $1;
    my $maths = $2;
    $maths =~ s/x/\*/;
    $answer = `echo |awk '{print $maths}'`;
    &msg($matchan,"Answer: $answer");
}

if ($line=~ /:(.*)!(.*) PRIVMSG \Q$nickname\E :!lev/){ #This command makes the bot leave the server.
    $asker = $1;
    if ($asker == c0d3d){
        print $dsp "Quit on request\r\n";
    }
}


if ($line=~ /:(.*)!(.*) PRIVMSG \Q$nickname\E :!kick\s+(.*)\s+(.*)/){ #Kick someone if the bot has the oper privilege
    $kick_chan = $3;
    $kick_nick = $4;
    if ($kick_nick == c0d3d){
        print $dsp "KICK $kick_chan $kick_nick\r\n";
    }
}

#This function gives op to every user as they join the channel. You can remove it if you want.
#if($line =~ /:(.*)!(.*) JOIN :(.*)/ ) {
#my $joinick = $1;
#my $joinchan = $3;
#print $dsp "MODE $joinchan +o $joinick\r\n";
#print $dsp "MODE $joinchan +o $joinick\r\n";
#sleep(1);
#print $dsp "MODE $joinchan +o $joinick\r\n";
#}


if($line =~ /:(.*)!(.*) PRIVMSG (.*) :hello Merlin/){
    my $hellochan = $3;
    my $hellonick = $1;
    &msg($hellochan,"Hello $hellonick"); sleep(2);
    &msg($hellochan,"How are you doing today? :-)");
}

if ($line=~ /:(.*)!(.*) PRIVMSG \Q$nickname\E :!say\s+(.*)\s+(.*)/ ) { #Talk through the bot.
    $sayer = $1;
    $chan_said = $3;
    $said = $4;
    print $dsp "PRIVMSG $chan_said $said\r\n";
}

if($line =~ /:(.*)!(.*) PRIVMSG (.*) :fuck you/){
    my $funick = $1;
    my $fuchan = $3;
    &msg($fuchan,"that was harsh $funick");
}


if($line =~ /:(.*)!(.*) PRIVMSG (.*) :shut up Merlin/){
    my $shunick = $1;
    my $shuchan = $3;
    &msg($shuchan,"whatever");
}


if($line =~ /:(.*)!(.*) PRIVMSG (.*) :attack/){
    my $attnick = $1;
    my $attchan = $3;
    &msg($attchan,"attack sounds legit");
}


if($line =~ /:(.*)!(.*) PRIVMSG (.*) :i will kill you/){
    my $killnick = $1;
    my $killchan = $3;
    &msg($killchan,"A shortgun will be cool for your kill $1");
}


if ($line=~ /:(.*)!(.*) PRIVMSG \Q$nickname\E :!join\s+(.*)/ ) { #This makes the bot join a channel
    print $dsp "Join $3\r\n";
    print $dsp "Join $3\r\n";
    print $dsp "NickServ identify password\r\n";
}

if ($line=~ /:(.*)!(.*) PRIVMSG \Q$nickname\E :!part\s+(.*)/ ) { #This makes the bot part a channel.
    print $dsp "Part $3\r\n";
    print $dsp "Part $3\r\n";
}

#This section looks every chat content for urls and print their titles, and content types and sizes for images and other files.
if($line =~ /:(.*)!(.*) PRIVMSG (.*) :(.*)/){
    my $chanile = $3;
    my $iletalk = $4;
    if($iletalk =~ m/http([^>\ ]*)/g){
        my $st = "http".$1;
        &query2($st,$chanile);
    }
}



sub query2(){
    my $stt = $_[0];
    my $stchan = $_[1];
    my $ua = LWP::UserAgent->new;
    my $agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13";
    $ua->agent($agent);
    $ua->timeout(5);
    my $req = HTTP::Request->new(GET => $stt);
    $req->content_type('text/html');
    $req->protocol('HTTP/1.0');
    my $response = $ua->request($req);
    if ( $response->is_success ) {
        my $resp = $response->content;
        if ($resp =~ m/<title>(.+)<\/title>/g) {
            my $title = $1;
            $title = decode_entities($title); 
            &msg($stchan,"Url Found: $title");
            }else{
                my @resp = $response->headers()->as_string;
                foreach my $resp(@resp){
                    if ($resp =~ m/Content-Length: (.+)
                        Content-Type: (.+)/){
                        my $cont1 = $1;
                        my $cont2 = $2;
                        &msg($stchan,"Url Found: Content Type [$cont2] Size: [$cont1 bytes]");
                    }
                }
            }
        }
    }


    sub query() {
        $link = $_[0];
        my $req = HTTP::Request->new( GET => $link );
        my $ua = LWP::UserAgent->new();
        $ua->agent('Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.16) Gecko/2009121601 Ubuntu/8.10 (intrepid) Firefox/3.0.16');
        $ua->timeout(10);
        my $response = $ua->request($req);
        if ( $response->is_success ) {
            my $resp = $response->content;
            return $resp;
        }
    }

    sub msg(){
        my $rchan = $_[0];
        my $rsaid = $_[1];
        print $dsp "PRIVMSG $rchan :$rsaid\r\n";
    }
