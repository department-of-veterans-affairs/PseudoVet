#!/usr/bin/perl
# leads module for DIFR
# If you don't know the code, don't mess around below -bciv

my @states=["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO",
            "MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"];

#tables
#my $training_table="rcs_trainingrequired";
my $table_leads="sales_leads";
my $query_fields="uid,alias,lastname,firstname,middle,suffix,degree,jobtitle,company,
  addressline1,addressline2,city,stateprovince,postalcode,country,language,
  homephone,facilityid,mailcode,workphone,workext,cellphone,fax,email,status,
  comment";

# for module specific database calls (leads table)
my ($uid,$alias,$lastname,$firstname,$middle,$suffix,$degree,$jobtitle,$company,
  $addressline1,$addressline2,$city,$stateprovince,$postalcode,$country,$language,
  $homephone,$facilityid,$mailcode,$workphone,$workext,$cellphone,$fax,$email,$status,
  $comment);
    
# run function for selected action
unless(defined($g->{action})){view();}
elsif($g->{action} eq "view"){view();}
elsif($g->{action} eq "list" or $g->{action} eq "query"){view();}
elsif($g->{action} eq "new"){ editor(); }
elsif($g->{action} eq "insert"){ insert(); }
elsif($g->{action} eq "edit" or $g->{action} eq "update"){ editor(); }
elsif($g->{action} eq "delete"){ delete_record();}
1; # end module

sub delete_record{
  print qq(<div id="horizontalmenu">&nbsp;</div>);
  unless($g->{confirmation} eq "true"){
    print qq(\n\t\t<h3>Lead Removal Confirmation</h3>\n<div id="main">\n);
    print $g->{CGI}->h4("Are you sure you want to remove '<b><em>$g->{lastname}, $g->{firstname} $g->{middle} $g->{suffix} $g->{degree}</em></b> from DIFR?"),
    $g->{CGI}->br,
    $g->{CGI}->p("If you click 'Yes', they will no longer be in the DIFR database."),
    $g->{CGI}->br,
    $g->{CGI}->start_form(),
    $g->{CGI}->hidden({-name=>"action", -value=>"delete",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"confirmation", -value=>"true",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"uid", -value=>"$g->{uid}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"lastname", -value=>"$g->{lastname}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"firstname", -value=>"$g->{firstname}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"middle", -value=>"$g->{middle}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"suffix", -value=>"$g->{suffix}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"degree", -value=>"$g->{degree}",-override=>"1"}),
    $g->{CGI}->h2({-align=>"center"},
      $g->{CGI}->submit("Remove Lead"),
      $g->{CGI}->button({-value=>"Cancel",-onClick=>"history.go(-1);"}),
    ),
    $g->{CGI}->end_form;
  }
  else{
    print qq(\n     <div id="title"><h3>Lead Removal</h3></div>\n);
    $g->{dbh}->do("delete from $table_leads where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_training where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_groups where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_license where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_education where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_scopeofwork where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_exclusionary_data where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_trainingrequired where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_project_members where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_credentialing where uid like '$g->{uid}'");
#    $g->{dbh}->do("delete from rcs_allergy where uid like '$g->{uid}'");
    $g->event("leads","deleted record $g->{uid}");

    print $g->{CGI}->p("'<b><em>$g->{lastname}, $g->{firstname} $g->{middle} $g->{suffix} $g->{degree}</em></b>' has been deleted from DIFR</b>"),
    $g->{CGI}->br,
    $g->{CGI}->h2({-align=>"center"},
      $g->{CGI}->button({-value=>"Continue",-onClick=>"location.href='$g->{scriptname}?action=view'"}),
    );
  }
}

sub insert{
  # check for duplicate entry...
  my($tlast,$tfirst,$tmiddle,$temail); my $fail='false';
  ($tlast,$tfirst,$tmiddle,$tssn)=$g->{dbh}->selectrow_array("select lastname,firstname,middle,email from $table_leads where lastname=\"$g->{lastname}\" and firstname=\"$g->{firstname}\" and middle=\"$g->{middle}\" and suffix=\"$g->{suffix}\" and email=\"$g->{email}\"");
  if($g->{lastname} eq $tlast and $g->{firstname} eq $tfirst and $g->{middle} eq $tmiddle and $temail eq $g->{email}){
    print $g->{CGI}->h4({-align=>"center"},"The record you are creating for $g->{firstname} $g->{middle} $g->{lastname} $g->{suffix}"),
    $g->{CGI}->h4({-align=>"center"},"is already in the system."),
    $g->{CGI}->h4({-align=>"center"},"Please Click the back button on your browser to correct your entry");
    $g->event("leads","detected duplicate name $g->{lastname},$g->{firstname} $g->{middle} $g->{email} record");
    $fail='true';
  }
  
  if($fail eq 'false'){
    print "\n<!-- action: $g->{action} uid: $g->{uid} -->\n";
    my $insert_query="insert into sales_leads
    values(0,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    print qq(<!-- $insert_query -->\n);
    $sth=$g->{dbh}->prepare("$insert_query")
      or $g->call_support("An Error Occurred Preparing To Add New Lead","$DBI::errstr");
    $sth->execute(
      $g->{alias},$g->{lastname},$g->{firstname},$g->{middle},$g->{suffix},
      $g->{degree},$g->{jobtitle},$g->{company},
      $g->{addressline1},$g->{addressline2},$g->{city},$g->{stateprovince},$g->{postalcode},
      $g->{country},$g->{language},$g->{homephone},
      $g->{facilityid},$g->{mailcode},
      $g->{workphone},$g->{workext},$g->{cellphone},$g->{fax},
      $g->{email},$g->{status},$g->{comment}
    )
      or $g->call_support("An Error Occurred Executing Add For New Lead","$DBI::errstr");      
    my($uid)=$g->{dbh}->selectrow_array("select uid from $table_leads where lastname=\"$g->{lastname}\" and firstname=\"$g->{firstname}\" and middle=\"$g->{middle}\" and suffix=\"$g->{suffix}\" and degree=\"$g->{degree}\"");

        # generate payload for email to confirm account
        # compose email message payload

    my $filename="$g->{username}.message";

    # compose email message payload
    my $message="MIME-Version: 1.0\nContent-Type: text/html\n";
    $message.="Subject:$g->{sitename} :: New Lead Notification\n";
    $message.="<img src=\"$g->{site_logo}\" />";
    $message.="\n\n";
    $message.="<h3>New Sales Lead added to $g->{sitename}</h3>\n\n";
    $message.="<table cols=2 border=1 padding=2>\n";
    #my(@fields)=("lastname","firstname","middle","suffix","degree","jobtitle","company","comment");
    #foreach $field (@fields){$message.="<tr><td>$field</td><td>$g->{$field}</td></tr>\n";}
    $message.=qq(<tr><td>Name</td><td>$g->{lastname}, $g->{firstname} $g->{middle} $g->{suffix} $g->{degree}&nbsp;</td></tr>);
    $message.=qq(<tr><td>Title</td><td>$g->{jobtitle}&nbsp;</td></tr>);
    $message.=qq(<tr><td>Email</td><td>$g->{email}&nbsp;</td></tr>);
    $message.=qq(<tr><td>Work</td><td>$g->{workphone} $g->{workext}&nbsp;</td></tr>);
    $message.=qq(<tr><td>Cell</td><td>$g->{cellphone}&nbsp;</td></tr>);
    $message.=qq(<tr><td>Comment</td><td>$g->{comment}&nbsp;</td></tr>);
    $message.="</table>\n";
    #$message.="<a href=\"https://$g->{domainname}/portal/register.pl?action=validate&key=$md5_hash&email=$g->{email}&user$g->{username}\">https://$g->{domainname}/portal/register.pl?action=validate&key=$md5_hash&email=$g->{email}&user$g->{username}</a></p>\n\n";
    $message.="<p>Lead added by: $g->{sys_username} on $g->{timestamp}</p>\n";
    #After confirming your registration, you will be able to log into EtherFeat.</p>\n\n";
    #$message.="<i>If you did not request to create an account on EtherFeat you can safely disregard this message.</i>";

    # create file to write the contents of this email alert message
    open(ALRT,"+>$g->{tempfiles}/$filename") or die "Error.  Check permissions of $g->{tempfiles}.\nCannot create $filename : @!\n";
    #print $message;
    print ALRT $message;
    close(ALRT);

    # send an email to the email address on file for the username
    my $emailcmd="/usr/sbin/sendmail -F'$g->{sitename}' -f'$g->{email_support}' -v $g->{email_sales} < $g->{tempfiles}/$filename >> $g->{tempfiles}/mail.log";
    #print "$emailcmd\n";
    system("$emailcmd");

    unlink "$g->{tempfiles}/$filename";

    $g->event("leads","added $g->{lastname},$g->{firstname} $g->{middle} uid: $uid to leads");

#    # add a training record for each trainingtype in the system for the new Lead
#    $sth=$g->{dbh}->prepare("select name,optional from rcs_trainingtypes order by name"); $sth->execute();
#    while(my ($name,$optional)=$sth->fetchrow_array()){
#      print qq(<!-- name=$name optional=$optional -->);
#      my $optionalvalue='';
#      if($optional eq 'true'){$optionalvalue='true';}elsif($optional eq 'false'){$optionalvalue='mandatory';}
#      $g->{dbh}->do("insert into rcs_trainingrequired values('$uid','$name','$optionalvalue','0000-00-00')");
#      $g->event("leads","added employee training $training_type record: $g->{lastname},$g->{firstname} $g->{middle} uid: $uid");
#    }

#    # find out how many training groups there are so the uid can be entered into the rcs_groups table
#  	my $c=$g->{dbh}->selectcol_arrayref("select distinct(template) from rcs_trainingtypes order by template");
#    foreach $type (@{$c}){$g->{dbh}->do("insert into rcs_groups values($uid,'training','$type','')");}

#    # insert a record into rcs_credentialing
#    $g->{dbh}->do("insert into rcs_credentialing values(\"$uid\",\"$g->{lastcred}\",\"$g->{recurring_credentialing}\")");
#    $g->event("leads","added employee credentialing record: $g->{lastname},$g->{firstname} $g->{middle} uid: $uid");

#    # insert a record into rcs_allergy
#    $g->{dbh}->do("insert into rcs_allergy values(\"$uid\",\"0000-00-00\",\"0000-00-00\",\"Yes\")");
#    $g->event("leads","added employee allergy record: $g->{lastname},$g->{firstname} $g->{middle} uid: $uid");

    $g->{uid}=$uid;
#    # find out how many exclusionary lists are in exclusionary table so uid can be entered into exclusionary_data
#    $null=""; $sth=$g->{dbh}->prepare("show fields from rcs_exclusionary_data"); $sth->execute();
#    while(my ($row)=$sth->fetchrow_array()){if($row=~m/^ex\_/){$null=$null.",\"f\"";}}
#    $g->{dbh}->do("insert into rcs_exclusionary_data values($uid,NULL,\"0000-00-00\"$null)");
#    $g->event("leads","added employee exclusionary_data record: $g->{lastname},$g->{firstname} $g->{middle} uid: $uid");

#    # get list of trainingtypes
#    my $tsth=$g->{dbh}->prepare("select name from rcs_trainingtypes"); $tsth->execute();
#    while(my($ttype)=$tsth->fetchrow_array()){
#      # insert a check to see if a record for the uid exists, if not create one
#      #print "<br /><em>$ttype</em><br />\n";
#      my ($check)=$g->{dbh}->selectrow_array("select trainingtype from $training_table where uid=\"$uid\" and trainingtype=\"$ttype\"");
#      if($check eq $ttype){ #print "$ttype exists for $uid<br />\n";
#      }
#      else{
#      #print "$ttype does not exists for $uid<br />\n";
#      $g->{dbh}->do("insert into $training_table values(\"$uid\",\"$ttype\",\"0000-00-00\",\"Required\")");
#      }
#      $check="";
#    }

    $g->event("leads","created $uid $g->{lastname},$g->{firstname} $g->{middle} record");
    $g->{action}="update";
    editor();
  }
}

sub view{
  my $query='';

  print $g->{CGI}->div({-id=>"navlinks"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=new"},"Add Lead"),);

  analytics();
  search();

  my $status_filter='';
#  unless($g->{status_filter} eq "I"){$status_filter="suspended not like \"I\"";}

  if($g->{action} eq "list"){
    # list query by matching ^$g->{letter}
    unless($status_filter eq ''){$status_filter="and suspended not like \"I\"";}
    #$sth=$g->{dbh}->prepare("select $query_fields from $table_leads where lastname like \"$g->{letter}%\" $status_filter order by lastname"); $sth->execute();
    $query="select $query_fields from $table_leads where lastname like \"$g->{letter}%\" $status_filter order by lastname";
  }
  elsif($g->{action} eq "query"){ # list records =~ $g->{query} [lastname|firstname|ssn]
    unless($status_filter eq ''){$status_filter="and suspended not like \"I\"";}
    #$sth=$g->{dbh}->prepare("select $query_fields from $table_leads where (lastname like \"$g->{query}%\"
    #or firstname like \"$g->{query}%\" or ssn like \"$g->{query}%\" or alias like \"$g->{query}%\") $status_filter order by lastname"); $sth->execute();
    $query="select $query_fields from $table_leads where (lastname like \"$g->{query}%\"
    or firstname like \"$g->{query}%\" or email like \"$g->{query}%\" or alias like \"$g->{query}%\") $status_filter order by lastname";
  }
  else{ # give full listing for people that use the scroll bar...
    unless($status_filter eq ''){$status_filter="where suspended not like \"I\"";}
    #$sth=$g->{dbh}->prepare("select $query_fields from $table_leads $status_filter order by lastname"); $sth->execute();
    $query="select $query_fields from $table_leads $status_filter order by lastname";
  }

  if($g->{query} ne '' or $g->{action} ne ''){
    print
    $g->{CGI}->start_table({-cols=>"6",-cellspacing=>"1",-cellpadding=>"4",-border=>"0",-width=>"99%"}),
      $g->{CGI}->Tr({-align=>"left"},
        $g->{CGI}->th({-width=>"30%"},"Name"),
        $g->{CGI}->th({-width=>"10%"},"Status"),
        $g->{CGI}->th({-width=>"20%"},"Email"),
        $g->{CGI}->th({-width=>"20%"},"Work Phone & Extension"),
        $g->{CGI}->th({-width=>"9%"},"Action"),
      );
    $sth=$g->{dbh}->prepare("$query"); $sth->execute();

    my $grey=1;
    while(my ($uid,$alias,$lastname,$firstname,$middle,$suffix,$degree,$jobtitle,$company,
              $addressline1,$addressline2,$city,$stateprovince,$postalcode,$country,$language,
              $homephone,$facilityid,$mailcode,$workphone,$workext,$cellphone,$fax,$email,$status,
              $comment)=$sth->fetchrow_array()){
      my $suspendedview='';
      if($suspended eq 'A'){$suspendedview="Active";}
      elsif($suspended eq 'I'){$suspendedview="Inactive";}
      elsif($suspended eq 'P'){$suspendedview="Pending";}
      elsif($suspended eq 'S'){$suspendedview="Suspended";}

      my $class='even';
      if($grey eq "1"){$grey=0; print "<Tr class=\"even\">";}
      else{$grey=1; $class='odd'; print "<Tr class=\"odd\">";}
        print
        $g->{CGI}->td({-class=>"$class"},$g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&uid=$uid"},"$lastname, $firstname $middle $suffix $degree")),
        $g->{CGI}->td({-class=>"$class"},"$suspendedview"),
        $g->{CGI}->td({-class=>"$class"},$g->{CGI}->a({-href=>"mailto:$email"},"$email")),
        $g->{CGI}->td({-class=>"$class"},"$workphone $workext");

        if($g->{my_roles}=~m/delete/){
          print $g->{CGI}->td({-class=>"$class"},$g->{CGI}->a({-href=>"$g->{scriptiname}?action=delete&uid=$uid&lastname=$lastname&firstname=$firstname&middle=$middle&suffix=$suffix&degree=$degree"},"delete"));
        }
        else{
          print $g->{CGI}->td({-class=>"$class"},"&nbsp;");
        }
        print "</Tr>";

    }
    print $g->{CGI}->end_table();
  }
  else{
    print $g->{CGI}->h3({-align=>"center"},"View All, Search, or List Leads by Last Names");
  }
}

sub editor{
  if($g->{action} eq "new"){
    #print "action: $g->{action} uid: $g->{uid}<br />\n";
    $workaddress1="";
    $workcity=""; $workstate=""; $workzip="";
    $workphone="";
    $g->{action}="insert";
  }
  elsif($g->{action} eq "update"){ # update record after a change is made...
    print qq(\n<!-- update -->\n);
        
    my($tuid,$tlast,$tfirst,$tmiddle,$temail)=$g->{dbh}->selectrow_array("select uid,lastname,firstname,middle,email from $table_leads where lastname like \"$g->{lastname}\" and firstname like \"$g->{firstname}\" and middle like \"$g->{middle}\" and suffix like \"$g->{suffix}\" and degree like \"$g->{degree}\"");
    if($temail eq "$g->{email}" and $tuid ne "$g->{uid}"){
      $g->event("leads","duplicate entry attempt: $temail ($g->{uid})");
      print $g->{CGI}->h3("leads :: Duplicate Alert"),
        $g->{CGI}->h4({-align=>"center"},"The email address you have entered:"),
        $g->{CGI}->h3({-align=>"center"},"<font color=orange>$temail</font>"),
        $g->{CGI}->h4({-align=>"center"},"is already in the system assigned to:"),
        $g->{CGI}->h3({-align=>"center"},"<font color=orange>$tfirst $tmiddle $tlast</font>"),
        $g->{CGI}->h4({-align=>"center"},"Please Click the back button on your browser to correct your entry");
    }
    else{
      # update record tables
      $g->{comment}=~s/ /\&nbsp;/g;
      #$g->{ssn}=~s/(\d\d\d)(\d\d)(\d\d\d\d)/$1-$2-$3/;
      #if($g->{ssn}!~m/\d\d\d-\d\d-\d\d\d\d/){$g->{ssn}='Unavailable';}

      my $query="update sales_leads set alias='$g->{alias}', lastname='$g->{lastname}', firstname='$g->{firstname}', middle='$g->{middle}',
      suffix='$g->{suffix}', degree='$g->{degree}', jobtitle='$g->{jobtitle}', company='$g->{company}',
      addressline1='$g->{addressline1}', addressline2='$g->{addressline2}',
      city='$g->{city}', stateprovince='$g->{stateprovince}', postalcode='$g->{postalcode}', country='$g->{country}', language='$g->{language}',
      homephone='$g->{homephone}', facilityid='$g->{facilityid}', mailcode='$g->{mailcode}', workphone='$g->{workphone}', workext='$g->{workext}',
      cellphone='$g->{cellphone}', fax='$g->{fax}', email='$g->{email}', status='$g->{status}', comment='$g->{comment}'
      where uid=$g->{uid}";

      print qq(\n<!-- $query -->\n);

      $sth=$g->{dbh}->do("$query");

#      # update rcs_credentialing
#      $g->{dbh}->do("update rcs_credentialing set lastcred='$g->{lastcred}',recur='$g->{recurring_credentialing}' where uid=$g->{uid}");
#      $g->event("leads","Updated uid $g->{uid} credentialing last credentialed: $g->{reccred_received} recur: $g->{recurring_credentialing}");

#      # update rcs_allergy
#      my $allergy_check=$g->{dbh}->selectrow_array("select uid from rcs_allergy where uid=$g->{uid}");
#      print "\n<!-- allergy check -->\n";
#      if($allergy_check eq "$g->{uid}"){
#        print "\n<!-- allergy entry for $g->{uid} exists... updating with $g->{initialdate} $g->{lastdate} $g->{required} -->\n";
#        $g->{dbh}->do("update rcs_allergy set initialdate='$g->{initialdate}',lastdate='$g->{lastdate}',required='$g->{required}' where uid=$g->{uid}");
#        $g->event("leads","Updated uid $g->{uid} allergy lastdate: $g->{lastdate} initialdate: $g->{initialdate} required: $g->{required}");
#      }
#      else{
#        print "\n<!-- allergy entry for $g->{uid} does not exist... inserting with $g->{initialdate} $g->{lastdate} $g->{required} -->\n";
#        $g->{dbh}->do("insert into rcs_allergy values('$g->{uid}','$g->{initialdate}','$g->{lastdate}','$g->{required}')");
#      }

    }
  }
  my %i; # investigator hash
  $sth=$g->{dbh}->prepare(
    "select uid,alias,lastname,firstname,middle,suffix,degree from $table_leads where investigator like 'T'"
  ); $sth->execute();
  while(my ($iuid,$ialias,$ilast,$ifirst,$imiddle,$isuf,$ideg)=$sth->fetchrow_array()){
    $i{$iuid}="$ilast, $ifirst $imiddle $isuf $ideg";
  }
  if($g->{action} eq "edit"){$g->{action}="update";}
  ($uid,$alias,$lastname,$firstname,$middle,$suffix,$degree,$jobtitle,$company,
  $addressline1,$addressline2,$city,$stateprovince,$postalcode,$country,$language,
  $homephone,$facilityid,$mailcode,$workphone,$workext,$cellphone,$fax,$email,$status,
  $comment)=$g->{dbh}->selectrow_array("select $query_fields from $table_leads where uid like \"$g->{uid}\"");
  $g->event("leads",ucfirst($g->{action})." $g->{uid} $firstname $lastname\'s record");

  my $suspendedcolor='Black'; my $suspendedvalue='';
  my $suspendeda=''; if($suspended eq 'A'){$suspendeda='selected'; $suspendedcolor='Green'; $suspendedvalue='Active';}
  my $suspendedi=''; if($suspended eq 'I'){$suspendedi='selected'; $suspendedcolor='Orange'; $suspendedvalue='Inactive';}
  my $suspendedp=''; if($suspended eq 'P'){$suspendedp='selected'; $suspendedcolor='Gold'; $suspendedvalue='Pending';}
  my $suspendeds=''; if($suspended eq 'S'){$suspendeds='selected'; $suspendedcolor='Red'; $suspendedvalue='Suspended';}

#  my $fingerprintsnone=''; if($fingerprints eq 'None'){$fingerprintsnone='Selected';}
#  my $fingerprintsonfile=''; if($fingerprints eq 'On File'){$fingerprintsonfile='Selected';}

#  my $employeeorientationcompleted=''; if($employeeorientation eq 'Completed'){$employeeorientationcompleted='Selected';}
#  my $employeeorientationnotcompleted=''; if($employeeorientation eq 'Not Completed'){$employeeorientationnotcompleted='Selected';}
#  my $employeeorientationnotapplicable=''; if($employeeorientation eq 'Not Applicable'){$employeeorientationnotapplicable='Selected';}

  my $navtitle_text="Cancel Record Creation";
  if($g->{action} ne "insert"){$navtitle_text="Select Different Record";}

  #if($ssn)
  #
  #my $notchecked; my $checkmark="checked";
  #if($g->{uid} ne ""){
  #  # get status of exclusionary lists
  #  my $x=0; my %ex; $sth=$g->{dbh}->prepare("show fields from rcs_exclusionary_data"); $sth->execute();
  #  while(my ($field)=$sth->fetchrow_array()){
  #    if($field=~m/^ex/){my($prefix,$xid)=split(/\_/,$field);
  #      ($ex{name},$ex{auth})=$g->{dbh}->selectrow_array("select name,authority from rcs_exclusionary_lists where id=\"$xid\"");
  #      $ex{$field}="$ex{name},$ex{auth}";
  #      my($fieldstatus)=$g->{dbh}->selectrow_array("select $field from rcs_exclusionary_data where uid=\"$g->{uid}\"");
  #      if($fieldstatus eq "f" or $fieldstatus eq "o"){$notchecked="$ex{name},$ex{auth} "; $checkmark="unchecked";}
  #  } }
  #}

  unless($g->{action} eq 'insert'){
    print
    qq(<div id="horizontalmenu">),
    qq(<ul id="horizontalmenu">),
    $g->{CGI}->li($g->{CGI}->a({-href=>"$g->{scriptname}?chmod=sales_tracking&action=view&uid=$uid"},"Tracking"),),    
#    $g->{CGI}->li($g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_education&action=view&uid=$uid&name=$firstname $middle $lastname"},"Education"),),
#    $g->{CGI}->li($g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_license&action=view&uid=$uid"},"Licenses/Certificates"),),
#    $g->{CGI}->li($g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_projects&action=view&uid=$uid"},"Projects"),),
#    $g->{CGI}->li($g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_training&action=view&uid=$uid"},"Training"),),
#    $g->{CGI}->li(
#      $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_exclusionary&action=view&uid=$g->{uid}",-title=>"$notchecked"},"Exclusionary Lists"),
#      $g->{CGI}->img({-src=>"images/$checkmark\.png",-width=>"25",-title=>"$notchecked"}),
#    ),
    qq(</ul>\n</div>\n);
  }


  print qq(\n<div id='navlinks'>\n);
  if($g->{action} eq 'update'){
    print $g->{CGI}->a({-href=>"$g->{scriptname}?action=new"},"Add Lead");
  }
  print $g->{CGI}->a({-href=>"$g->{scriptname}"},"$navtitle_text"),
  qq(\n</div>\n),
  $g->{CGI}->h3("Editing $firstname $middle $lastname $suffix $degree ",
  $g->{CGI}->font({-style=>"color: $suspendedcolor"},"$suspendedvalue"));

  print $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
  $g->{CGI}->div({-class=>""},$g->{CGI}->submit("Save Changes"),),
  $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>"1"}),
  $g->{CGI}->hidden({-name=>"uid",-value=>"$uid"});

  # BEGIN ---- Lead Details ----
  my %suspended_labels = ('A'=>'Active','I'=>'Inactive','P'=>'Pending','S'=>'Suspended');
  print $g->{CGI}->h4("Lead Details"),
  $g->{CGI}->div({-id=>"record"},
    $g->{CGI}->label({-for=>"firstname"},"Firstname"),
    $g->{CGI}->textfield({-name=>"firstname",-value=>"$firstname",-size=>"20",-override=>"1"}),
    $g->{CGI}->label({-for=>"middle"},"INI"),
    $g->{CGI}->textfield({-name=>"middle",-value=>"$middle",-size=>"2",-override=>"1"}),
    $g->{CGI}->label({-for=>"lastname"},"Lastname"),
    $g->{CGI}->textfield({-name=>"lastname",-value=>"$lastname",-size=>"40",-override=>"1"}),
    $g->{CGI}->label({-for=>"suffix"},"Suffix"),
    $g->{CGI}->textfield({-name=>"suffix",-value=>"$suffix",-size=>"4",-override=>"1"}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"degree"},"Degree"),
    $g->{CGI}->textfield({-name=>"degree",-value=>"$degree",-size=>"22",-override=>"1"}),
    $g->{CGI}->label({-for=>"alias"},"Alias"),
    $g->{CGI}->textfield({-name=>"alias",-value=>"$alias",-size=>"12",-override=>"1"}),
    $g->{CGI}->label({-for=>"suspended"},"Status"),
    $g->{CGI}->popup_menu({-name=>"suspended",-default=>"$suspended",
			   -values=>['A','I','P','S'],-labels=>\%suspended_labels,-size=>"1",-override=>"1"}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"jobtitle"},"Job Title"),
    $g->{CGI}->textfield({-name=>"jobtitle",-value=>"$jobtitle",-size=>"40",-override=>"1"}),
    $g->{CGI}->label({-for=>"company"},"Company"),
    $g->{CGI}->textfield({-name=>"company",-value=>"$company",-size=>"80",-override=>"1"}),
    $g->{CGI}->br(),
    $g->{CGI}->br(),    
    $g->{CGI}->label({-for=>"comment"},"Comments"),
    $g->{CGI}->textfield({-name=>"comment",-value=>"$comment",-override=>"1",-size=>"100"}),
  ); # END ---- Lead Details ----

#  # BEGIN ---- Studies ----
#  my $humanchecked=''; if($human eq 'true'){$humanchecked='checked';}
#  my $nonhumanchecked=''; if($nonhuman eq 'true'){$nonhumanchecked='checked';}
#  my $basicchecked=''; if($basic eq 'true'){$basicchecked='checked';}
#  print $g->{CGI}->h4("Studies"),
#  #$g->{CGI}->div({-id=>"record"},
#  qq(<div id="record">),
#    $g->{CGI}->checkbox({-name=>"human",-value=>'true',-selected=>$humanchecked,-label=>"Human Studies"}),
#    $g->{CGI}->checkbox({-onclick=>"showMe('animal',this);",-name=>"nonhuman",-value=>'true',-selected=>$nonhumanchecked,-label=>"Animal Studies"}),
#    $g->{CGI}->checkbox({-name=>"basic",-value=>'true',-selected=>$basicchecked,-label=>"Basic Sciences"});
#    my $animalformstate='display:none;'; if($nonhumanchecked eq 'checked'){$animalformstate='';}
#    print qq(<div id="animal" style="$animalformstate">);
#    #if($nonhumanchecked ne 'checked'<h3>animal</h3>
#    # lid,uid,type,number,state,received,expires,status
#    # 0,$g->{uid},"CompMed/IACUC",
#    my ($lid,$animalnumber,$animalexpires,$animalstatus)=$g->{dbh}->selectrow_array("select lid,number,expires,status from rcs_license where uid='$g->{uid}' and type='CompMed/IACUC'");
#    if($animalnumber ne ''){
#      print $g->{CGI}->fieldset(
#        $g->{CGI}->p("CompMed/IACUC Certification #: <b>$animalnumber</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recertify by: <b>$animalexpires</b>&nbsp;&nbsp;&nbsp;&nbsp;&#149;&nbsp;",
#          $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_license&action=edit&lid=$lid&uid=$g->{uid}"},"Update License"),
#        ),
#      );
#    }
#    else{
#      print $g->{CGI}->fieldset("No CompMed/IACUC Certification number on file.  &#149;",
#        $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_license&action=new&uid=$g->{uid}&name=$g->{firstname} $g->{middle} $g->{lastname} $g->{suffix}&type=CompMed/IACUC"},"Add License"),
#      );
#    }
#    print qq(</div>);
#  print qq(</div>);
#  #); # END ---- Studies ----

#  # BEGIN ---- Classification ----
#  my $investigatorchecked=''; if($investigator eq 'true' or $investigator eq 't'){$investigatorchecked='checked';}
#  my $studystaffchecked=''; if($studystaff eq 'true' or $studystaff eq 't'){$studystaffchecked='checked';}
#  my $rnd_memberchecked=''; if($rnd_member eq 'true' or $rnd_member eq 't'){$rnd_memberchecked='checked';}
#  my $irb_memberchecked=''; if($irb_member eq 'true' or $irb_member eq 't'){$irb_memberchecked='checked';}
#  my $iacuc_memberchecked=''; if($iacuc_member eq 'true' or $iacuc_member eq 't'){$iacuc_memberchecked='checked';}
#  my $safetychecked=''; if($safety eq 'true' or $safety eq 't'){$safetychecked='checked';}
#  my $officechecked=''; if($office eq 'true' or $office eq 't'){$officechecked='checked';}
#  my $otherchecked=''; if($other eq 'true' or $other eq 't'){$otherchecked='checked';}
#  print $g->{CGI}->h4("Classification"),
#  $g->{CGI}->div({-id=>"record"},
#    $g->{CGI}->checkbox({-name=>"investigator",-value=>'true',-selected=>$investigatorchecked,-label=>"Investigator"}),
#    $g->{CGI}->checkbox({-name=>"studystaff",-value=>'true',-selected=>$studystaffchecked,-label=>"Study Staff"}),
#    $g->{CGI}->checkbox({-name=>"rnd_member",-value=>'true',-selected=>$rnd_memberchecked,-label=>"R&D Member"}),
#    $g->{CGI}->checkbox({-name=>"irb_member",-value=>'true',-selected=>$irb_memberchecked,-label=>"IRB Member"}),
#    $g->{CGI}->checkbox({-name=>"iacuc_member",-value=>'true',-selected=>$iacuc_memberchecked,-label=>"IACUC Member"}),
#    $g->{CGI}->checkbox({-name=>"safety",-value=>'true',-selected=>$safetychecked,-label=>"Safety Member"}),
#    $g->{CGI}->checkbox({-name=>"office",-value=>'true',-selected=>$officechecked,-label=>"Office Staff"}),
#    $g->{CGI}->checkbox({-name=>"other",-value=>'true',-selected=>$otherchecked,-label=>"Other"}),
#  ); # END ---- Classification ----

#  # BEGIN ---- Credentialing ----
#  my $statusva=''; if($status eq 'VA'){$statusva='selected';}
#  my $statuswoc=''; if($status eq 'WOC'){$statuswoc='selected';}
#  my $statusvawoc=''; if($status eq 'VA WOC'){$statusvawoc='selected';}
#  my $statuswoce=''; if($status eq 'WOC Exempt'){$statuswoce='selected';}
#  my $statusfoundation=''; if($status eq 'Foundation'){$statusfoundation='selected';}
#  my $credentialededu=''; if($credentialed eq 'Edu Only'){ $credentialededu='selected'; }
#  my $credentialedvetpro=''; if($credentialed eq 'VetPro'){ $credentialedvetpro='selected'; }
#  my $credentialedpending=''; if($credentialed eq 'Pending'){ $credentialedpending='selected'; }
#  my $credentialedna=''; if($credentialed eq 'Not Applicable'){ $credentialedna='selected'; }
#  #my $credreqyes=''; if($credreq eq 'Yes'){$credreqyes='selected';}
#  #my $credreqno=''; if($credreq eq 'No'){$credreqno='selected';}
#  my %status_labels=('VA'=>'VA','VA WOC'=>'VA WOC','WOC'=>'WOC','WOC Exempt'=>'WOC Exempt','Foundation'=>'Foundation');
#  my $recurring_credentialing="0"; my $expiration_date="Not Set";
#  my %credreq=('0'=>'Not Applicable','1'=>'Recurs every 1 year','2'=>'Recurs every 2 years');
#  #print "uid: $g->{uid}<br />\n";
#  my ($uid,$lastcred,$interval,$expiration_date);
#  if($g->{uid} ne ""){
#    ($uid,$lastcred,$interval,$expiration_date)=$g->{dbh}->selectrow_array("select uid,lastcred,recur,date_add(lastcred, interval recur year) as expires from rcs_credentialing where uid=\"$g->{uid}\"");
#  }

#  print $g->{CGI}->h4("Credentialing"),
#    $g->{CGI}->div({-id=>"record"},
#    $g->{CGI}->label({-for=>"status"},"Work Status:"),
#    $g->{CGI}->popup_menu({-name=>"status",-default=>"$status",
#			   -values=>['VA','VA WOC','WOC','WOC Exempt','Foundation'],-labels=>\%status_labels,-size=>"1",-override=>"1"}),
#    $g->{CGI}->label({-for=>"credreq"},"Credentialing Required?"),
#    $g->{CGI}->popup_menu({-name=>"credreq",-default=>"$credreq",-values=>['Yes','No'],-size=>"1",-override=>"1"}),
#    $g->{CGI}->br(),$g->{CGI}->br(),
#    $g->{CGI}->label({-for=>"credentialed"},"Credentialing Service"),
#    $g->{CGI}->popup_menu({-name=>"credentialed",-default=>"$credentialed",
#			   -values=>['Not Applicable','Pending','VetPro','Edu Only'],-size=>"1",-override=>"1"}),
#    # reccred_receivedmm reccred_receiveddd recred_received_yyyy recurring_credentialing rcs_credentialing
#    $g->{CGI}->label({-for=>"lastcred"},"Received: "),
#    $g->{CGI}->textfield({-id=>"datepicker1",-name=>"lastcred",-value=>"$lastcred",-size=>"11",-override=>1}),
#    $g->{CGI}->br(),
#    $g->{CGI}->label({-for=>"recurring_credentialing"},"Recurring Credentialing?"),
#    $g->{CGI}->popup_menu({-name=>"recurring_credentialing",-size=>"1",-default=>"$interval",-value=>\%credreq,-override=>1}),
#    $g->{CGI}->b("Credentialing Expires:"),"$expiration_date",
#    $g->{CGI}->p("*If the interval is set to a recurring interval, the expiration date will update once the record is saved."),
#    $g->{CGI}->label({-for=>"comment"},"Comment"),
#    $g->{CGI}->textfield({-name=>"credcomment",-value=>"$credcomment",-override=>"1",-size=>"80"}),
#    $g->{CGI}->br(),
#  ); # END ---- Credentialing ----

#  # BEGIN --- Background Information ---
#  print $g->{CGI}->h4("Background Information"),
#  $g->{CGI}->div({-id=>"record"},
#    $g->{CGI}->label({-for=>"nacicleared"},"NACI Cleared:"),
#    $g->{CGI}->textfield({-id=>"datepicker2",-name=>"nacicleared",-value=>"$nacicleared",-size=>"11",-override=>1}),
#    $g->{CGI}->label({-for=>"saccleared"},"SAC Cleared:"),
#    $g->{CGI}->textfield({-id=>"datepicker3",-name=>"saccleared",-value=>"$saccleared",-size=>"11",-override=>1}),
#    $g->{CGI}->br(),
#    $g->{CGI}->label({-for=>"fingerprints"},"Fingerprints"),
#    $g->{CGI}->popup_menu({-name=>"fingerprints",-size=>"1",-default=>"$fingerprints",-value=>['On File','None'],-override=>"1",-title=>"Fingerprints"}),
#    $g->{CGI}->br(),
#    $g->{CGI}->label({-for=>"backgroundcomment"},"Background Comment:"),
#    $g->{CGI}->textfield({-size=>"80",-name=>"backgroundcomment",-value=>"$backgroundcomment",-override=>"1"}),
#  ); # END ---- Background Information ----

#  # BEGIN ---- WOC Details ----
#  my @property=["Not Applicable","Unsigned","Signed"];
#  if($propertyagreement eq ''){$propertyagreement='Not Applicable';}

#  print
#  $g->{CGI}->div({-id=>"woc"},
#    $g->{CGI}->h4("WOC Details"),
#    $g->{CGI}->div({-id=>"record"},
#    $g->{CGI}->label({-for=>"propertyagreement"},"WOC Appointment Letter"),
#    $g->{CGI}->popup_menu({-name=>"propertyagreement",-size=>"1",-default=>"$propertyagreement",-value=>@property,-override=>1}),
#    $g->{CGI}->label({-for=>"wocinit"},"Initial Appt Date: "),
#    $g->{CGI}->textfield({-id=>"datepicker4",-name=>"wocinit",-value=>"$wocinit",-size=>"11",-override=>1}),
#    $g->{CGI}->br(),
#    $g->{CGI}->br(),
#    $g->{CGI}->div({-id=>"record"},$g->{CGI}->legend("Current Appointment"),
#      $g->{CGI}->label({-for=>"wocstart"},"Start: "),
#      $g->{CGI}->textfield({-id=>"datepicker5",-name=>"wocstart",-value=>"$wocstart",-size=>"11",-override=>1}),
#      "&nbsp;&nbsp;&nbsp;",
#      $g->{CGI}->label({-for=>"wocend"},"End: "),
#      $g->{CGI}->textfield({-id=>"datepicker6",-name=>"wocend",-value=>"$wocend",-size=>"11",-override=>1}),
#    ),
#    $g->{CGI}->br(),
#    ),
#  ); # END ---- WOC Details ----
#  if($status=~m/WOC/){print "<script language='javascript'>toggleLayer('woc');</script>";}

#  # BEGIN ---- Other ----
#  my ($initialdate,$lastdate,$required);
#  if($g->{uid} ne ""){
#    ($initialdate,$lastdate,$required)=$g->{dbh}->selectrow_array("select initialdate,lastdate,required from rcs_allergy where uid='$g->{uid}'");
#  }

#  print $g->{CGI}->h4("Other"),
#  $g->{CGI}->div({-id=>"record"},
#    $g->{CGI}->label({-for=>"employeeorientation"},"Employee Orientation"),
#    $g->{CGI}->popup_menu({-name=>"employeeorientation",-size=>"1",-default=>"$employeeorientation",-value=>['Not Completed','Completed','Not Applicable'],-override=>"1",-title=>""}),
#    $g->{CGI}->label({-for=>"tbtest"},"TB Test"),
#    $g->{CGI}->popup_menu({-name=>"tbtest",-size=>"1",-default=>"$tbtest",-value=>['Not Completed','Completed','Declined'],-override=>"1",-title=>""}),
#    $g->{CGI}->label({-for=>"healthsummary"},"Health Summary"),
#    $g->{CGI}->popup_menu({-name=>"healthsummary",-size=>"1",-default=>"$healthsummary",-value=>['Not Completed','Completed','Not Applicable'],-override=>"1",-title=>""}),
#    $g->{CGI}->br(),
#    $g->{CGI}->h3("Allergy Questionnaire"),
#    $g->{CGI}->label({-for=>"initialdate"},"Initial Date"),
#    $g->{CGI}->textfield({-id=>"datepicker7",-name=>"initialdate",-value=>"$initialdate",-size=>"11",-override=>1}),
#    $g->{CGI}->label({-for=>"lastdate"},"Last Update"),
#    $g->{CGI}->textfield({-id=>"datepicker8",-name=>"lastdate",-value=>"$lastdate",-size=>"11",-override=>1}),
#    $g->{CGI}->label({-for=>"required"},"Required?"),
#    $g->{CGI}->popup_menu({-name=>"required",-size=>"1",-default=>"$required",-value=>['Yes','No'],-override=>1}),
#    $g->{CGI}->br(),
#  );
#  # END ---- Other ----

#my ($uid,$alias,$lastname,$firstname,$middle,$suffix,$degree,$jobtitle,$company,
#  $addressline1,$addressline2,$city,$stateprovince,$postalcode,$country,$language,
#  $homephone,$facilityid,$mailcode,$workphone,$workext,$cellphone,$fax,$email,$status,
#  $comment);
#
# this is where I am at...

  my @countries=$g->countries($g->{countryfile});
  my @languages=("English","Esperanto","French","German","Italian","Spanish","Russian");

  # START ---- Contact Information ----
  print $g->{CGI}->h4("Contact Information"),
  $g->{CGI}->div({-id=>"record"},
    $g->{CGI}->label({-for=>"language"},"Language"),
    $g->{CGI}->popup_menu({-name=>"language",-default=>"$language",-values=>\@languages,-override=>1}),
    $g->{CGI}->label({-for=>"email"},"Email"),
    $g->{CGI}->textfield({-name=>"email",-value=>"$email",-size=>"40",-override=>"1"}),    
    $g->{CGI}->label({-for=>"workphone"},"Work Phone"),
    $g->{CGI}->textfield({-name=>"workphone",-value=>"$workphone",-size=>"22",-override=>"1"}),
    $g->{CGI}->label({-for=>"workext"},"Extension"),
    $g->{CGI}->textfield({-name=>"workext",-value=>"$workext",-size=>"7",-override=>"1"}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"cellphone"},"Cell Phone"),
    $g->{CGI}->textfield({-name=>"cellphone",-value=>"$cellphone",-size=>"12",-override=>"1"}),
    $g->{CGI}->label({-for=>"fax"},"Fax"),
    $g->{CGI}->textfield({-name=>"fax",-value=>"$fax",-size=>"12",-override=>"1"}),
		 
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"addressline1"},"Address Line 1"),
    $g->{CGI}->textfield({-name=>"addressline1",-value=>"$addressline1",-override=>"1",-size=>"80"}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"addressline2"},"Address Line 2"),
    $g->{CGI}->textfield({-name=>"addressline2",-value=>"$addressline2",-override=>"1",-size=>"80"}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"city"},"City"),
    $g->{CGI}->textfield({-name=>"city",-value=>"$city",-override=>"1",-size=>"40"}),
    $g->{CGI}->label({-for=>"stateprovince"},"State/Province"),
    $g->{CGI}->textfield({-name=>"stateprovince",-value=>"$stateprovince",-size=>"40",-override=>"1"}),
    #$g->{CGI}->popup_menu({-name=>"stateprovince",-default=>"$stateprovince",-size=>"1",-value=>@states}),
    $g->{CGI}->label({-for=>"postalcode"},"Postal Code"),
    $g->{CGI}->textfield({-name=>"postalcode",-value=>"$postalcode",-override=>"1",-size=>"10"}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"country"},"Country"), # country
    $g->{CGI}->popup_menu({-name=>"country",-default=>"$country",-values=>\@countries,-override=>1}),
    $g->{CGI}->hidden({-name=>"facilityid",-value=>""}),
    $g->{CGI}->hidden({-name=>"mailcode",-value=>""}),
  ); # END ---- Home Contact Information ----

#  # START ---- Work Contact Information ----
#  print qq(
#  <script language="javascript" type="text/javascript"><!--
#    //Browser Support Code
#    function ajaxFunction(){
#      var ajaxRequest;  // The variable that makes Ajax possible!
#      try{
#	// Opera 8.0+, Firefox, Safari
#	ajaxRequest = new XMLHttpRequest();
#      } catch (e){
#	// Internet Explorer Browsers
#	try{
#	  ajaxRequest = new ActiveXObject("Msxml2.XMLHTTP");
#	}
#	catch (e) {
#	  try{
#	    ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
#	  }
#	  catch (e){
#	    // Something went wrong
#	    alert("Your browser broke!");
#	    return false;
#	  }
#	}
#      }
#      // Create a function that will receive data sent from the server
#      ajaxRequest.onreadystatechange = function(){
#	if(ajaxRequest.readyState == 4){
#	  document.myForm.time.value = ajaxRequest.responseText;
#	}
#      }
#      var facilityid = document.getElementById('facilityid').value;
#      var queryString = "?id=" + facilityid;
#      ajaxRequest.open("GET", "bin/ajax_facilities.pl" + queryString, true);
#      ajaxRequest.send(null);
#    }
#    //-->
#    </script>
#  );
#  $sth=$g->{dbh}->prepare("select id,stationid,name from rcs_facilities where stationid regexp \"^000\""); $sth->execute();
#  $sth->{RaiseError}=1; my $facility_ref=$sth->fetchall_arrayref([]); my %f; my @facility_id;
#  foreach $facility (@{$facility_ref}){ # $hash{ $key } = $value;
#    $f{ @{$facility}[0] } = "@{$facility}[1] - @{$facility}[2]";
#    push(@facility_id,@{$facility}[0]); # populate @facility_id
#  } if($facilityid eq ''){$facilityid='6';}
#  my($fid,$stationid,$facilityname,$workaddress1,$workaddress2,$city,$state,$workzipcode,$mainphone)=
#  $g->{dbh}->selectrow_array(
#    "select id,stationid,name,workaddress1,workaddress2,city,state,zipcode,mainphone from rcs_facilities where id=\"$facilityid\""
#  ); if($workaddress2 ne ''){$workaddress2="<br />$workaddress2";}
#  print $g->{CGI}->h4("Work Contact Information"),
#  $g->{CGI}->div({-id=>"record"},
#    $g->{CGI}->label({-for=>"facilityid"},"Facility"),
#    $g->{CGI}->popup_menu({-name=>"facilityid",-default=>"$facilityid",-size=>"1",-value=>\%f,-onChange=>"ajaxFunction()"}),
#    $g->{CGI}->p({-id=>"facilit"},"<b>$facilityname</b><br />
#		 $workaddress1$workaddress2<br />
#		 $city, $state $workzipcode<br />
#		  Main Phone: $mainphone<br />\n"),
#    $g->{CGI}->label({-for=>"mailcode"},"Mail Code"),
#    $g->{CGI}->textfield({-name=>"mailcode",-value=>"$mailcode",-size=>"10",-override=>"1"}),
#    $g->{CGI}->br(),
#  );
  #"</form>\n";
  #print qq(\n</div> <!-- end main -->\n);
}

sub search{
  my $status_filter="A"; my $status_filter_text="";
  if($g->{status_filter} eq ""){$g->{status_filter}="A";}
  if($g->{status_filter} eq "I"){$status_filter="A"; $status_filter_text="Hide";}
  if($g->{status_filter} eq "A"){$status_filter="I"; $status_filter_text="Show";}
  print qq(\n<div id="search">\n); # <span>
  print
  $g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
    $g->{CGI}->textfield({-size=>"60",-name=>"query",-value=>"$g->{query}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"action",-value=>"query",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"status_filter",-value=>"I",-override=>"1"}),
    $g->{CGI}->submit("Search"),("\n"),
    $g->{CGI}->end_form,
  $g->{CGI}->a({-href=>"$g->{scriptname}?action=list"},"View All&nbsp;"),
  "list last names: ";
  my $alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(my $digit="0"; $digit<26; ++$digit){
    my $letter=substr($alpha,$digit,1);
    if(defined($g->{letter}) and $g->{letter} eq "$letter"){
      print $g->{CGI}->a({-href=>"$g->{scriptname}?action=list&letter=$letter&status_filter=$g->{status_filter}"},"<font color=#ff0000>$letter</font>");
    }
    else{
      print $g->{CGI}->a({-href=>"$g->{scriptname}?action=list&letter=$letter&status_filter=$g->{status_filter}"},"$letter");
    }
  }
  print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&status_filter=$status_filter"},"$status_filter_text Inactive"),
  qq(\n</div> <!-- end search -->\n); # </span>
  print "<br />\n";
}


sub analytics{
  print qq(\n<div id="analytics">\n);
  $total_Leads=$g->analytic('Leads','',"*",'','sales_leads','');
  my $active_Leads=$g->analytic('Active Leads','',"*",'','sales_leads',"where suspended='A'","percentage:$total_Leads");
  my $inactive_Leads=$g->analytic('Inactive Leads','',"*",'','sales_leads',"where suspended='I'","percentage:$total_Leads");
  my $suspended_Leads=$g->analytic('Suspended Leads','',"*",'','sales_leads',"where suspended='S'","percentage:$total_Leads");
  print qq(\n</div> <!-- end analytics -->\n);
}

