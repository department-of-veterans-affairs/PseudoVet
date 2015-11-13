#!/usr/bin/perl

print $g->{CGI}->div({-id=>"submenu"},"&nbsp"),
$g->{CGI}->div({-id=>"navlinks"},"&nbsp;"),
$g->{CGI}->div({-id=>"title"},$g->{CGI}->h3("Alerts")),
$g->{CGI}->div({-id=>"subtitle"},"&nbsp;");
print qq(<div id='main'>\n);

my $query_fields="id,uid,type,payload,automatic,sent,confirmed,status";
my $alerts_table="rcs_alerts";

$sth=$g->{dbh}->prepare("select $query_fields from $alerts_table order by sent desc"); $sth->execute();
my $check=0;
print $g->{CGI}->start_table(),
    $g->{CGI}->Tr(
    $g->{CGI}->th({},"ID"),
    $g->{CGI}->th({},"UID"),
    $g->{CGI}->th({},"Type"),
    $g->{CGI}->th({},"Payload"),
    $g->{CGI}->th({},"Automatic"),
    $g->{CGI}->th({},"Sent"),
    #$g->{CGI}->th({},"Confirmed"),
    $g->{CGI}->th({},"Status"),
  );

my $highlight='even';
while(my($id,$uid,$type,$payload,$automatic,$sent,$confirmed,$status)=$sth->fetchrow_array()){
  if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
  print $g->{CGI}->Tr({-class=>"$highlight"},
    $g->{CGI}->td({},"$id"),
    $g->{CGI}->td({},"$uid"),
    $g->{CGI}->td({},"$type"),
    $g->{CGI}->td({},"$payload"),
    $g->{CGI}->td({},"$automatic"),
    $g->{CGI}->td({},"$sent"),
    #$g->{CGI}->td({},"$confirmed"),
    $g->{CGI}->td({},"$status"),
  );
  $check=1;
}
if($check eq 0){
  print $g->{CGI}->Tr($g->{CGI}->td({-colspan=>"8"},$g->{CGI}->h2("There are no alerts in the system at this time.")));
}
print $g->{CGI}->end_table();

print qq(\n</div> <!-- end main -->\n);

1; # end of module



sub send_email{
  # code to send message
  # $g->event();
}
