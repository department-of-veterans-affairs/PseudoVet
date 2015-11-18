#!/usr/bin/perl
#
print 
qq(<div id='page_effect'>),
$g->{CGI}->h1({-align=>"center"},"logging $g->{sys_username} $g->{sys_sid} out of DIFR..."),
$g->{CGI}->img({-align=>"center",-src=>"themes/$g->{sys_theme}/wait30trans.gif"});

$g->{dbh}->do("update interface_sessions set expire=date_sub(now(),interval 0 minute) where id=$g->{sys_sid}");
my ($exp)=$g->{dbh}->selectrow_array("select expire from interface_sessions where id=$g->{sys_sid}");
$g->event("Logout","$g->{sys_username} logged off of DIFR session $g->{sys_sid} at $exp");
print $g->{CGI}->h3({-align=>"center"},"session $g->{sys_sid} expired on: $exp");
print "<script>window.location='http://$g->{domainname}/'</script>";
1;
