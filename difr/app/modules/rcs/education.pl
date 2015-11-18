#!/usr/bin/perl
# education module for DIFR
# If you don't know the code, don't mess around below -bciv

# for module education
my $education_table="rcs_education";
my $personnel_table="rcs_personnel";
my($eid,$uid,$degree,$graddate,$universityaddr,$phone,$firstreq,$secondreq,$verified);
my $query_fields="eid,uid,degree,graddate,universityaddr,phone,firstreq,secondreq,verified";

unless(defined($g->{action})){view();}
elsif($g->{action} eq "view"){view();}
elsif($g->{action} eq "new" or $g->{action} eq "edit"){editor();}
elsif($g->{action} eq "add"){
  packuniversityaddr();
  $g->{dbh}->do("insert into $education_table values('0',\"$g->{uid}\",\"$g->{degree}\",\"$g->{graddate}\",
  \"$universityaddr\",\"$g->{phone}\",\"$g->{firstreq}\",\"$g->{secondreq}\",\"$g->{verified}\")");
  view();
}
elsif($g->{action} eq "update"){
  packuniversityaddr();
  $g->{dbh}->do("update $education_table set degree=\"$g->{degree}\", graddate=\"$g->{graddate}\",
  universityaddr=\"$universityaddr\",phone=\"$g->{phone}\",firstreq=\"$g->{firstreq}\",
  secondreq=\"$g->{secondreq}\",verified=\"$g->{verified}\" where eid = $g->{eid}");
  view();
}
elsif($g->{action} eq "delete"){
  $g->{dbh}->do("delete from $education_table where eid like \"$g->{eid}\"")
    or die "can not delete record $g->{eid} from $education_table : $!<br />";
  view();
}

1; # end module

sub view{
  print $g->{CGI}->div({-id=>"submenu"},"&nbsp;");

  if(not defined($g->{uid})){
    print $g->{CGI}->div({-id=>"title"},
      $g->{CGI}->h3("Personnel :: Education"),
      $g->{CGI}->h4("A user record was not submitted for review."),
    ),
    $g->{CGI}->div({-id=>"main"},
      $g->{CGI}->p("You must return to the ",$g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel"},"Personnel")," module and select a user before entering the Education module."),
    );
    return 1;
  }

  my ($first,$middle,$last,$suffix)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix from $personnel_table where uid like $g->{uid}");

  print $g->{CGI}->div({-id=>"navlinks"},
  	$g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}&name=$first $middle $last $suffix"},"Back to Personnel"),
  	$g->{CGI}->a({-href=>"$g->{scriptname}?action=new&uid=$g->{uid}&name=$first $middle $last $suffix"},"Add Degree"),
  );

  if($first ne ""){
  	print $g->{CGI}->br(),$g->{CGI}->h3("Education Record for: $first $middle $last $suffix");

    $sth=$g->{dbh}->prepare("select $query_fields from $education_table where uid like \"$g->{uid}\" order by graddate"); $sth->execute();

    my $flag=0;
    while(($eid,$uid,$degree,$graddate,$universityaddr,$phone,$firstreq,$secondreq,$verified)=$sth->fetchrow_array()){
      print $g->{CGI}->div({-id=>"record"},
        $g->{CGI}->div({-id=>"floatright"},
          $g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&eid=$eid&uid=$g->{uid}"},"<div align=\"center\">edit"),
          "&nbsp;&#149;&nbsp;",
          $g->{CGI}->a({-href=>"$g->{scriptname}?action=delete&eid=$eid&uid=$g->{uid}"},"delete</div>"),
        ),
        $g->{CGI}->p("Degree: <b>$degree</b>&nbsp;&nbsp;&nbsp;Graduation Date: <b>$graddate</b>"),
        $g->{CGI}->p("University Address:<br /><center><b>$universityaddr</b></center><br />"),
        $g->{CGI}->p("University Phone Number: <b>$phone</b><br />"),
        $g->{CGI}->p(
          "First Request: <b>$firstreq</b>&nbsp;&nbsp;&nbsp;
          Second Request: <b>$secondreq</b>&nbsp;&nbsp;&nbsp;
          Verified: <b>$verified</b>",
        ),
      );
      $flag=1;
    }
    if($flag==0){print $g->{CGI}->p({-align=>"center"},"There are no degrees listed for this record.");}
  }
  else{
    print $g->{CGI}->div({-id=>"title"},$g->{CGI}->h2("Personnel :: Education"));
    #print qq(\n<div id="main">),
    $g->{CGI}->p("The record you requested does not exist.");
  }
  #print qq(\n</div> <!-- end main -->\n);
}

sub editor{
  my $title;
  if($g->{action} eq "new"){$g->{action}="add"; $title="Adding";}
  else{$g->{action}="update"; $title="Editing";
    ($eid,$uid,$degree,$graddate,$universityaddr,$phone,$firstreq,$secondreq,$verified)=
    $g->{dbh}->selectrow_array("select $query_fields from $education_table where eid like $g->{eid}");
    # need to split universityaddr into universityaddr[1..8] so it shows up in the form...
    my @addr=split(/\<br \/\>/,$universityaddr); my $i=1;
    foreach $line (@addr){
      my $temp="universityaddr$i"; ++$i;
      if($line ne ""){$g->{$temp}=$line;}
    }
  }

  print $g->{CGI}->div({-id=>"submenu"},"&nbsp;"),
  $g->{CGI}->div({-id=>"navlinks"},
  	$g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$g->{uid}"},"Cancel $title"),
  ),
  $g->{CGI}->div({-id=>"title"},
  	$g->{CGI}->h3({-align=>"center"},"$title Degree for $g->{name}"),
  );
  #print qq(\n<div id="main">\n);

  # need to parse out universityaddr -> universityaddr[1..8]
  print # $eid,$uid,$degree,$graddate,$universityaddr,$phone,$firstreq,$secondreq,$verified
  print $g->{CGI}->div({-id=>"record"},
  $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>1}),
  $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>1}),
  $g->{CGI}->hidden({-name=>"name",-value=>"$g->{name}",-override=>1}),
  $g->{CGI}->hidden({-name=>"eid",-value=>"$g->{eid}",-override=>1}),
  $g->{CGI}->label({-for=>"degree"},"Degree"),
  $g->{CGI}->textfield({-name=>"degree",-value=>"$degree",-override=>1,-size=>"5",-title=>"i.e., MD, PhD, MBA, etc..."}),
  "&nbsp;&nbsp;&nbsp;",
  $g->{CGI}->label({-for=>"graddate"},"Graduation Date"),
  $g->{CGI}->textfield({-id=>"datepicker1",-size=>"11",-name=>"graddate",-value=>"$graddate",-override=>"1"}),
  "&nbsp;&nbsp;&nbsp;",
  $g->{CGI}->label({-for=>"phone"},"University Phone"),
  $g->{CGI}->textfield({-name=>"phone",-value=>"$phone",-override=>1,-size=>"20"}),
  $g->{CGI}->br(),$g->{CGI}->br(),
  $g->{CGI}->label({-for=>"universityaddr1"},"University Address:"),$g->{CGI}->br(),
  $g->{CGI}->textfield({-name=>"universityaddr1",-value=>"$g->{universityaddr1}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr2",-value=>"$g->{universityaddr2}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr3",-value=>"$g->{universityaddr3}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr4",-value=>"$g->{universityaddr4}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr5",-value=>"$g->{universityaddr5}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr6",-value=>"$g->{universityaddr6}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr7",-value=>"$g->{universityaddr7}",-override=>1,-size=>"60"}),
  $g->{CGI}->textfield({-name=>"universityaddr8",-value=>"$g->{universityaddr8}",-override=>1,-size=>"60"}),
  $g->{CGI}->br(),$g->{CGI}->br(),
  $g->{CGI}->label({-for=>"firstreq"},"First Request:"),
  $g->{CGI}->textfield({-id=>"datepicker2",-size=>"11",-name=>"firstreq",-value=>"$firstreq",-override=>"1"}),
  $g->{CGI}->label({-for=>"recondreq"},"Second Request:"),
  $g->{CGI}->textfield({-id=>"datepicker3",-size=>"11",-name=>"secondreq",-value=>"$secondreq",-override=>"1"}),
  $g->{CGI}->label({-for=>"verified"},"Verified:"),
  $g->{CGI}->textfield({-id=>"datepicker4",-size=>"11",-name=>"verified",-value=>"$verified",-override=>"1"}),
  $g->{CGI}->submit("Save"),
  $g->{CGI}->end_form(),
  );
}

sub packuniversityaddr{
  # insert each universityaddr line {i.e., http variables universityaddr[1..8] from editor form }
  # with a <br /> into a single string for database insertion
  $universityaddr="";
  for(my $i=1; $i<8; $i++){
    my $temp="universityaddr"."$i";
    if($g->{$temp} ne ""){
      if($universityaddr eq ""){$universityaddr="$g->{$temp}";}
      else{$universityaddr=$universityaddr."<br />$g->{$temp}";}
  }}
}
