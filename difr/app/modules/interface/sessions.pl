#!/usr/bin/perl
# sessions module for DIFR
# If you don't know the code, don't mess around below -bciv

my($isid,$suname,$shost,$sip,$sdate,$sexpire);

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'sessions',
  "default_function"=>'sessions',
  "function"=>{
    "sessions"=>'sessions',
    "events"=>'events',
    "authentication"=>'authentication'
  },
); &$function;

1; # end module

#functions...
sub authentication{
  print $g->{CGI}->h3("Authentication"),
  qq(\n<div id="page_effect">\n);
  print $g->{CGI}->p("DIFR can be configured to authenticate users in an LDAP database such as Active Directory.");  
  # show current settings

  # have button to begin configuring LDAP settings with warning that if they proceed and users are currently
  # being authenticated via active directory, that they will no longer be able to log into the system.

  
}

sub sessions{
  print $g->{CGI}->h3("Sessions"),
  qq(\n<div id ="page_effect">\n);

  #my $forwarder=$ENV{X-FORWARDED_BY};
  #print "forwardedby: $forwarder<br />\n";

  my $query_fields="id,username,hostname,ip,vars,begin,expire";

  print "<p>To view the events of a user session, select a session id (sid) number.</p>",

  $g->{CGI}->start_table({-align=>"center",-border=>"1",-cellspacing=>"0",-cellpadding=>"0",-cols=>"5"}),
  $g->{CGI}->Tr({-bgcolor=>"#bfbfbf"},
    $g->{CGI}->th({-width=>"5%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=session"},"sid")),
    $g->{CGI}->th({-width=>"10%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=user"},"username")),
    $g->{CGI}->th({-width=>"25%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=host"},"hostname")),
    $g->{CGI}->th({-width=>"10%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=ip"},"host ip")),
    $g->{CGI}->th({-width=>"10%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=vars"},"vars")),
    $g->{CGI}->th({-width=>"10%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=begin"},"begin")),
    $g->{CGI}->th({-width=>"10%"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=session&function=expire"},"expires")),
  );
  if(defined($g->{function})){
    if($g->{function} eq "user"){ #event("View All Sessions by user","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by username, id desc");
    }
    if($g->{function} eq "session"){ #event("View All Sessions by SID","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by id desc");
    }
    if($g->{function} eq "host"){ #event("View All Sessions by hostname","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by hostname desc");
    }
    if($g->{function} eq "ip"){ #event("View All Sessions by ip","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by ip desc");
    }
    if($g->{function} eq "vars"){ #event("View All Sessions by ip","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by vars desc");
    }
    if($g->{function} eq "begin"){ #event("View All Sessions by date","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by begin desc");
    }
    if($g->{function} eq "expire"){ #event("View All Sessions by date","$title");
      $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by expire desc");
    }
  }
  else{ #event("View All Sessions","$title");
    $sth=$g->{dbh}->prepare("select $query_fields from interface_sessions order by id desc");
  }
  $sth->execute;
  my $grey=1;
  while(my ($isid,$suname,$shost,$sip,$svars,$sbegin,$sexpire)=$sth->fetchrow_array()){
    if($grey =~ "1"){print "<Tr class='odd'>"; --$grey;}
    else{print "<Tr class='even'>"; ++$grey;}
    print
      $g->{CGI}->td({-align=>"center"},
        $g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=session&qsid=$isid"},"$isid"),
      ),
      $g->{CGI}->td({-align=>"center"},"$suname"),
      $g->{CGI}->td({-align=>"center"},"$shost"),
      $g->{CGI}->td({-align=>"center"},"$sip"),
      $g->{CGI}->td({-align=>"left"},"$svars"),
      $g->{CGI}->td({-align=>"left"},"$sbegin"),
      $g->{CGI}->td({-align=>"left"},"$sexpire"),
    "</Tr>";
  }
  $g->event("sessions","viewing sessions");
  print $g->{CGI}->end_table;
}

sub events2{
  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}"},"Select A Different Session"),
  ),
  $g->{CGI}->h3("Events for Session: $g->{qsid}");

	print qq(\n<div id ="page_effect">\n);

  my $query_fields=$g->fields('interface_events');
  $g->table_list('difr_'.$g->{type},'id',$options);
}

sub events{
  my ($eid,$esid,$etype,$edesc,$eusr,$ehost,$eip,$edate);
  my $query_fields="id,sid,event_type,event_description,username,hostname,user_ip,date";

  print #$g->{CGI}->div({-id=>"submenu"},"&nbsp;"),
  $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}"},"Select A Different Session"),
  ),
  $g->{CGI}->h3("Events for Session: $g->{qsid}");

	print qq(\n<div id ="page_effect">\n);
	print
	$g->{CGI}->start_table({-cols=>"8"}),
	$g->{CGI}->Tr({-bgcolor=>"#bfbfbf",-align=>"center"},
		$g->{CGI}->th({-width=>"5%",-align=>"center"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=$g->{function}&order=id&qsid=$g->{CGI}sid"},"eid")),
		$g->{CGI}->th({-width=>"5%",-align=>"center"},"sid"),
		$g->{CGI}->th({-width=>"10%",-align=>"center"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=session&order=event_type&qsid=$g->{CGI}sid"},"event type")),
		$g->{CGI}->th({-width=>"15%",-align=>"center"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=$g->{action}&order=event_description&qsid=$g->{CGI}sid"},"event description")),
		$g->{CGI}->th({-width=>"10%",-align=>"center"},"user"),
		$g->{CGI}->th({-width=>"20%",-align=>"center"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=$g->{action}&order=hostname&qsid=$g->{CGI}sid"},"hostname")),
		$g->{CGI}->th({-width=>"10%",-align=>"center"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=$g->{action}&order=user_ip&qsid=$g->{CGI}sid"},"host ip")),
		$g->{CGI}->th({-width=>"20%",-align=>"center"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=events&function=$g->{action}&order=date&qsid=$g->{CGI}sid"},"event date")),
	),"\n\n";
  if(defined($g->{action})){
		if($g->{action} eq "session"){
			if(defined($g->{qsid})){
				event("events","Viewing Session $g->{qsid}");
				if($g->{order} eq "id"){
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by id desc");
				}
				elsif($g->{order} eq "event_type"){
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by event_type");
				}
				elsif($g->{order} eq "event_description"){
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by event_description");
				}
				elsif($g->{order} eq "hostname"){
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by hostname");
				}
				elsif($g->{order} eq "user_ip"){
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by user_ip");
				}
				elsif($g->{order} eq "date"){
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by date");
				}
				else{
					$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by id");
				}
			}
		}
		else{
			$sth=$g->{dbh}->prepare("select $query_fields from interface_events where sid like \"$g->{qsid}\" order by id");
		}
	}
	else{
    $g->event("events","viewing all events");
		$sth=$g->{dbh}->prepare("select $query_fields from interface_events");
	}
	$sth->execute;
	my $row='odd';
	while(($eid,$esid,$etype,$edesc,$eusr,$ehost,$eip,$edate)=$sth->fetchrow_array()){
	  if($row eq 'odd'){$row='even';}else{$row='odd';}
	  print
		$g->{CGI}->Tr({-class=>"$row"},
			$g->{CGI}->td({-align=>"right"},$g->{CGI}->font({-size=>"2"},"$eid")),
			$g->{CGI}->td({-align=>"right"},$g->{CGI}->font({-size=>"2"},"$esid")),
			$g->{CGI}->td({-align=>"center"},$g->{CGI}->font({-size=>"2"},"$etype")),
			$g->{CGI}->td({-align=>"left"},$g->{CGI}->font({-size=>"2"},"$edesc")),
			$g->{CGI}->td({-align=>"center"},$g->{CGI}->font({-size=>"2"},"$eusr")),
			$g->{CGI}->td({-align=>"center"},$g->{CGI}->font({-size=>"2"},"$ehost")),
			$g->{CGI}->td({-align=>"center"},$g->{CGI}->font({-size=>"2"},"$eip")),
			$g->{CGI}->td({-align=>"center"},$g->{CGI}->font({-size=>"2"},"$edate")),
		);
	}
	print $g->{CGI}->end_table;
}

