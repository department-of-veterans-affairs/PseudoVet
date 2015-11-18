#!/usr/bin/perl
# training types module for DIFR by BCIV
# If you don't know the code, don't mess around below -bciv

unless(defined($g->{action})){view();}
elsif($g->{action} eq "new" or $g->{action} eq "edit"){editor();}
elsif($g->{action} eq "insert"){
  $sth=$g->{dbh}->do("insert into rcs_trainingtypes values('0',\"$g->{name}\",\"$g->{desc}\")");
  $sth=$g->{dbh}->do("alter table rcs_training add $g->{name} date not null");
  view();
}
elsif($g->{action} eq "update"){$sth=$g->{dbh}->do("update rcs_trainingtypes set name=\"$g->{name}\",desc=\"$g->{desc}\" where tid=\"$g->{tid}\""); view();}
elsif($g->{action} eq "delete"){
  #print "deleting $g->{tid} from rcs_trainingtypes and $g->{name} from training<br />";
  $sth=$g->{dbh}->do("delete from rcs_trainingtypes where tid=\"$g->{tid}\"");
  $sth=$g->{dbh}->do("alter table rcs_training drop $g->{name}");
  view();
}
else{print "The function you have requested does not exist.";}
$g->{dbh}->disconnect();

sub editor{
  my $title;

  if($g->{action} eq "new"){$g->{action}="insert"; $title="Adding New Training Type";}
  elsif($g->{action} eq "edit"){
    my($name,$desc)=$g->{dbh}->selectrow_array();
    $g->{action}="update"; $title="Editing \"$name\" Training Type";
  }
  print "<center>$title</center><br />",
  $g->{CGI}->start_table({-cols=>"2",-cellspacing=>"0",-cellpadding=>"0",-border=>"0",-width=>"40%",-align=>"center"}),
  $g->{CGI}->Tr(
    $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"post"}),
    $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>"1"}),
    $g->{CGI}->td({-align=>"right",-bgcolor=>"#efefef"},"Training Name"),
    $g->{CGI}->td({-align=>"left",-bgcolor=>"#efefef",-title=>"Don't use spaces."},
      $g->{CGI}->textfield({-name=>"name",-value=>"$name",-override=>"1"}),
  )),
  $g->{CGI}->Tr($g->{CGI}->td({-align=>"right",-bgcolor=>"#efefef"},"Description"),
    $g->{CGI}->td({-align=>"left"},
      $g->{CGI}->textarea({-name=>"desc",-value=>"$desc",-override=>"1"-cols=>"40"}),
    ),
    $g->{CGI}->Tr($g->{CGI}->td({-bgcolor=>"#efefef"},""),
      $g->{CGI}->td({-align=>"center",-bgcolor=>"#efefef"},$g->{CGI}->submit("Save")),
    ),
    $g->{CGI}->end_form(),
  ),
  $g->{CGI}->end_table();
  print "<p style=\"font: font-size: 14pt; color: red; font-style: italic\">*Make sure you do not put spaces in the 'Training Name'</p>";
}

sub view{
  print qq(
  <h2>Training Types</h2>
  <fieldset>
    <a href="$g->{scriptname}?action=new">Add New Training Type</a><br /><br />
  ); #,
  #$g->{CGI}->start_table({-cols=>"1",-cellspacing=>"0",-cellpadding=>"0",-border=>"0",-width=>"30%",-align=>"center"});
  $sth=$g->{dbh}->prepare("select * from rcs_trainingtypes order by name"); $sth->execute();
  while(my($tid,$name,$desc)=$sth->fetchrow_array()){
    print qq(  $name <a href="$g->{scriptname}?action=delete&tid=$tid&name=$name"><div id="floatright">delete</div></a><br />);
  }
  print qq(
  </fieldset>
  );
  #print $g->{CGI}->Tr({-align=>"center"},$g->{CGI}->td("<br />",
  #  $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
  #  $g->{CGI}->hidden({-name=>"action",-value=>"new",-override=>"1"}),
  #  $g->{CGI}->submit("Add New Training Type"),
  #  $g->{CGI}->end_form(),
  #)),
  #$g->{CGI}->end_table();
}

sub event{my($etype,$edesc)=@_; $sth=$g->{dbh}->do(
  "insert into interface_events values('0',\"$g->{sid}\",\"$etype\",\"$edesc\",\"$g->{username}\",\"$g->{hostname}\",\"$g->{user_ip}\",\"$g->{now}\")"
  );
}
