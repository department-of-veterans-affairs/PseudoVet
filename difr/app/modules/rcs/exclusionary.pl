#!/usr/bin/perl
# exclusionary module for DIFR - If you don't know the code, don't mess around below -bciv

my $table_exclusionary_data="rcs_exclusionary_data";
my $table_exclusionary_lists="rcs_exclusionary_lists";
my $table_personnel="rcs_personnel";

print qq(<div id="page_effect">\n);

unless(defined($g->{action})){view();}
elsif($g->{action} eq "view"){view();}
elsif($g->{action} eq "edit"){editor();}
elsif($g->{action} eq "update"){
  #$g->{expiration} = $g->{expirationyyyy}."-".$g->{expirationmm}."-".$g->{expirationdd};
  if($g->{field}=~m/^ex/){
    if($g->{$g->{field}} eq "cleared"){$g->{$g->{field}}="t";}
    elsif($g->{$g->{field}} eq "not cleared"){$g->{$g->{field}}="f";}
    elsif($g->{$g->{field}} eq "on list"){$g->{$g->{field}}="o";}
    elsif($g->{$g->{field}} eq "not applicable"){$g->{$g->{field}}="n";}
  }
  #print "update exclusionary_data set $g->{field}=\"$g->{$g->{field}}\" where uid=\"$g->{uid}\"<br />";
  $g->{dbh}->do("update $table_exclusionary_data set $g->{field}=\"$g->{$g->{field}}\",expiration=\"$g->{expiration}\" where uid=\"$g->{uid}\"");
  view();
}
1; # end module

sub view{
  my $status; my $realstatus="checked";
  my ($first,$middle,$last,$suffix); my $page_title="Personnel :: Exclusionary Lists";
  print $g->{CGI}->div({-id=>"submenu"},"&nbsp");

  if(defined($g->{uid}) and $g->{uid} ne ""){
    ($first,$middle,$last,$suffix)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix from $table_personnel where uid like $g->{uid}");
    ($g->{expiration})=$g->{dbh}->selectrow_array("select expiration from $table_exclusionary_data where uid=\"$g->{uid}\"");
    #print qq(\n<!-- first: $first -->\n);
    $page_title="Exclusionary List Records For:<b> $first $middle $last $suffix<b>";
    print $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}"},"To Personnel Record"),
    ),
    $g->{CGI}->div({-id=>"title"},
    	$g->{CGI}->h3("$page_title"),
    ),
    $g->{CGI}->div({-id=>"subtitle"},
      $g->{CGI}->p("Enter the date exclusionary list was last checked and click update for each record."),
    );
    #print qq(\n<div id="main">\n);
  }
  else{
    # start -- catch no uid exception code
    # catch exceptions that occur when a uid is not passed to this module -BCIV 20100628
    print
    $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}"},"To Personnel Record"),
    ),
    $g->{CGI}->div({-id=>"title"},
    	$g->{CGI}->h3("$page_title"),
    ),
    $g->{CGI}->div({-id=>"subtitle"},"&nbsp;"),
    #$g->{CGI}->div({-id=>"main"},
      $g->{CGI}->p("This module was not passed the data for an employee record.<br />
                    Please click the 'To Personnel Record' link to select an employee.");
    #);
    return 0;
  } # end -- of catch no uid exception code

  #my $yyyy=sprintf("%04.0f",substr($g->{expiration},0,4));
  #my $mm=sprintf("%02.0f",substr($g->{expiration},5,2));
  #my $dd=sprintf("%02.0f",substr($g->{expiration},8,2));

  if($first ne ""){
    # make sure that there is an entry in exclusionary_data for the selected user
    my ($u)=$g->{dbh}->selectrow_array("select uid from $table_exclusionary_data where uid=$g->{uid}");
    if($u ne "$g->{uid}"){
      print $g->{CGI}->p("There is no exclusionary_data entry for uid: $g->{uid}");
      # create exclusionary data stub for employee
      my $null=""; $sth=$g->{dbh}->prepare("show fields from rcs_exclusionary_data"); $sth->execute();
      while(my($row)=$sth->fetchrow_array()){if($row=~m/^ex\_/){$null=$null.",\"f\"";}}
      $g->{dbh}->do("insert into rcs_exclusionary_data values($g->{uid},NULL,\"0000-00-00\"$null)");
      $g->event("exclusionary","added employee exclusionary_data record: $last,$first $middle $suffix uid: $g->{uid}");
    }
    else{print qq(\n<!-- exclusionary data exists for uid: $g->{uid} [ $first $middle $lastname $suffix $degree ]-->\n);}

    #my @mm=["01","02","03","04","05","06","07","08","09","10","11","12"];
    #my @dd=["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"];
    #my @yyyy=["1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024"];

    # find out what exclusionary lists there are
    $sth=$g->{dbh}->prepare("show fields from $table_exclusionary_data"); $sth->execute();
    my $i=0; my $null; while(my ($field)=$sth->fetchrow_array()){
      if($field eq "uid"){}
      if($field eq "status"){($status)=$g->{dbh}->selectrow_array("select $field from $table_exclusionary_data where uid=\"$g->{uid}\"");}
      elsif($field eq "expiration"){
        print $g->{CGI}->div({-id=>"record"},
          $g->{CGI}->p("&nbsp;&nbsp;&nbsp;&nbsp;Last Date Exclusionary Lists Were Checked:"),
          $g->{CGI}->p(
            $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
              $g->{CGI}->hidden({-name=>"mod",-value=>"rcs_exclusionary",-override=>"1"}),
              $g->{CGI}->hidden({-name=>"action",-value=>"update",-override=>"1"}),
              $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>"1"}),
              $g->{CGI}->hidden({-name=>"field",-value=>"$field",-override=>"1"}),
              $g->{CGI}->textfield({-id=>"datepicker1",-size=>"11",-name=>"expiration",-value=>"$g->{expiration}",-override=>1}),
              #$g->{CGI}->popup_menu({-name=>"expirationmm", -size=>"1", -default=>"$mm", -value=>@mm, -override=>"1",-title=>"MM"}),
              #$g->{CGI}->popup_menu({-name=>"expirationdd", -size=>"1", -default=>"$dd", -value=>@dd, -override=>"1",-title=>"DD"}),
              #$g->{CGI}->popup_menu({-name=>"expirationyyyy",-size=>"1", -default=>"$yyyy", -value=>@yyyy, -override=>"1",-title=>"YYYY"}),
              "&nbsp;&nbsp;&nbsp;&nbsp;",
              $g->{CGI}->submit("Update"),
            $g->{CGI}->end_form(),
            $g->{CGI}->br(),$g->{CGI}->br(),
          ),
        );
      }
      elsif($field=~m/^ex/){
        my($prefix,$xid)=split(/\_/,$field);
        my($name,$auth,$url)=$g->{dbh}->selectrow_array("select name,authority,url from $table_exclusionary_lists where id=\"$xid\"");
        my($fieldstatus)=$g->{dbh}->selectrow_array("select $field from $table_exclusionary_data where uid=\"$g->{uid}\"");
        if($fieldstatus eq "t"){$fieldstatus="cleared"; }
        elsif($fieldstatus eq "f"){$fieldstatus="not cleared"; $realstatus="unchecked";}
        elsif($fieldstatus eq "o"){$fieldstatus="on list"; $realstatus="unchecked";}
        elsif($fieldstatus eq "n"){$fieldstatus="not applicable"; }

        print $g->{CGI}->div({-id=>"record"},
#          $g->{CGI}->div({-id=>"happyright"},
            $g->{CGI}->ol(
            $g->{CGI}->li(
              "Name:<a href=\"$url\">$name</a>",
            ),
            $g->{CGI}->li(
              $g->{CGI}->b("Authority: $auth"),
            ),
            $g->{CGI}->li(
            $g->{CGI}->div({-id=>"floatright"},
            $g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
              $g->{CGI}->hidden({-name=>"mod",-value=>"rcs_exclusionary",-override=>"1"}),
              $g->{CGI}->hidden({-name=>"action",-value=>"update",-override=>"1"}),
              $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>"1"}),
              $g->{CGI}->hidden({-name=>"field",-value=>"$field",-override=>"1"}),
              #$g->{CGI}->textfield({-id=>"datepicker1",-size=>"11",-name=>"expiration",-value=>"$g->{expiration}",-override=>1}),
              $g->{CGI}->hidden({-name=>"expiration",-value=>"$g->{expiration}",-override=>"1"}),
              #$g->{CGI}->hidden({-name=>"expirationdd",-value=>"$dd",-override=>"1"}),
              #$g->{CGI}->hidden({-name=>"expirationyyyy",-value=>"$yyyy",-override=>"1"}),
              $g->{CGI}->popup_menu({-name=>"$field",-size=>"1",-default=>"$fieldstatus",-value=>["cleared","not cleared","on list","not applicable"],-override=>"1"}),
              $g->{CGI}->submit("Update"),
            $g->{CGI}->end_form(),
            ),
            ),
          ),
          $g->{CGI}->br(),
          $g->{CGI}->br(),
        );
      } # end of ex fields
    } # end of while loop for exclusionary_data fields for current uid
    unless($status eq $realstatus){
      $g->{dbh}->do("update $table_exclusionary_data set status=\"$realstatus\" where uid=\"$g->{uid}\"");
    }
    print
    qq();
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->center("status: <b>$realstatus</b>&nbsp;&nbsp;&nbsp;",
        $g->{CGI}->img({-src=>"images/$realstatus\.png",-width=>"30"}),
      ),
    );
  }
  else{
    print $g->{CGI}->div({-id=>"title"},
      $g->{CGI}->h3("Personnel :: Exclusionary Lists"),
    ),
    #$g->{CGI}->div({-id=>"main"},
      $g->{CGI}->p("The record you requested for uid: $g->{uid} does not exist.");
    #);
  }
  #print qq(\n</div> <!-- end main -->\n);
}
