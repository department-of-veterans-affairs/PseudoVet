#!/usr/bin/perl
# license module for DIFR
# If you don't know the code, don't mess around below -bciv

#

#my $license_table="rcs_license";
#my $license_fields="lid,uid,type,number,state,received,expires,status";
#my $personnel_table="rcs_personnel";
my $tracking_table="sales_tracking";
my $tracking_fields="tid,uid,contact,reference,comment,timestamp,mood";
my $leads_table="sales_leads";

# for module license
my($tid,$uid,$contact,$reference,$comment,$timestamp,$mood);

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'search',
  'default_function'=>'search',
  'function'=>{
    'add'=>'add',
    'delete'=>'del',
    'edit'=>'editor',
    'new'=>'editor',
		'search'=>'search',
    'update'=>'update',
    'view'=>'view',
    'type_editor'=>'type_editor',
  }
); &$function;
1; # end module

sub add{
  $g->event("sales_tracking","adding mood:$g->{mood} $g->{reference} $g->{contact} with $g->{uid}");
  $g->{dbh}->do("insert into $tracking_table values('0',\"$g->{uid}\",\"$g->{contact}\",\"$g->{reference}\",
  \"$g->{comment}\",NULL,\"$g->{mood}\")");
	
	# get extra data needed for email notification
	my ($first,$middle,$last,$suffix,$company)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix,company from $leads_table where uid like $g->{uid}");
	
  # generate payload for email to confirm account
	# compose email message payload

    my $filename="$g->{username}.message";
    # compose email message payload
    my $message="MIME-Version: 1.0\nContent-Type: text/html\n";
    $message.="Subject:EtherFeat :: Tracking Notification\n";
    $message.="<img src=\"http://www.etherfeat.com/logo.gif\" />";
    $message.="\n\n";
    $message.="<h3>Ref: $first $middle $last $suffix from $company</h3>\n\n";
    $message.="<table cols=2 border=1>\n";
    my(@fields)=("mood","reference","contact","comment");
    foreach $field (sort @fields){$message.="<tr><td>$field</td><td>$g->{$field}</td></tr>\n";}
    $message.="</table>\n";
    #$message.="<a href=\"https://$g->{domainname}/portal/register.pl?action=validate&key=$md5_hash&email=$g->{email}&user$g->{username}\">https://$g->{domainname}/portal/register.pl?action=validate&key=$md5_hash&email=$g->{email}&user$g->{username}</a></p>\n\n";
    $message.="<p>Tracking added by: $g->{sys_username} on $g->{timestamp}</p>\n";
    # create file to write the contents of this email alert message
    open(ALRT,"+>$g->{tempfiles}/$filename") or die "Error.  Check permissions of $g->{tempfiles}.\nCannot create $filename : @!\n";
    print ALRT $message;
    close(ALRT);
    # send an email to the email address on file for the username
    my $emailcmd="/usr/sbin/sendmail -F'EtherFeat' -f'support\@etherfeat.com' -v support\@etherfeat.com < $g->{tempfiles}/$filename >> $g->{tempfiles}/mail.log";
    system("$emailcmd");
    unlink "$g->{tempfiles}/$filename";	
	
  view();
}

sub del{
  $g->event("sales_tracking","deleting tracking \($g->{tid}\) from $g->{uid}");
  $g->{dbh}->do("delete from $tracking_table where tid like \"$g->{tid}\"") or die "can not delete record $g->{tid} from table : $!<br />";
  view();
}

sub update{
  #my($tid,$uid,$contact,$reference,$comment,$timestamp,$mood);
  my $query="update $tracking_table set contact=\"$g->{contact}\",reference=\"$g->{reference}\",comment=\"$g->{comment}\",
  timestamp=\"$g->{timestamp}\",mood=\"$g->{mood}\" where tid=\"$g->{tid}\"";
  #print "$query\n";
  $g->event("sales_tracking","updated $g->{tid} mood:$g->{mood} $g->{reference} $g->{contact} with $g->{uid}");
  $g->{dbh}->do("$query");
  editor();
}

sub search{
  print $g->{CGI}->div({-id=>"listform"},
		$g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
		$g->{CGI}->hidden({-name=>"action",-value=>"search",-override=>1}),
		$g->{CGI}->label({-for=>"query"},"Search"),
		$g->{CGI}->textfield({-name=>"query",-value=>"$g->{query}",-size=>"220",-override=>1}),		
		$g->{CGI}->submit({-class=>"blue",-value=>"Go"}),
		$g->{CGI}->end_form(),
	);
	
	print qq(<div id='results'>\n);
	my $query="select $leads_table.uid, $leads_table.lastname, $leads_table.firstname, $leads_table.middle, $leads_table.suffix, $leads_table.degree, $leads_table.company,
						$tracking_table.tid, $tracking_table.contact, $tracking_table.reference, $tracking_table.comment, $tracking_table.mood
						from $leads_table left join $tracking_table on $leads_table.uid=$tracking_table.uid
						where (($leads_table.uid like \"$g->{query}\") or ($leads_table.lastname like \"$g->{query}\") or ($leads_table.firstname like \"$g->{query}\") or ($leads_table.company like \"$g->{query}\"))
						order by $leads_table.lastname, $leads_table.firstname, $leads_table.company;";
	$sth=$g->{dbh}->prepare("$query"); $sth->execute(); my $count=0;
	print qq(\n<!-- QUERY: $query -->\n);
	while(my ($uid,$lastname,$firstname,$middle,$suffix,$degree,$company,$tid,$contact,$reference,$comment,$mood)=$sth->fetchrow_array()){
		print $g->{CGI}->div({-id=>"listform"},
			$g->{CGI}->h4("&nbsp;&nbsp;$lastname, $firstname $middle $suffix $degree - $company"),
			$g->{CGI}->p("$contact - $mood<br />$comment"),
		);
		++$count;
	}
	if($count==0){print $g->{CGI}->h4("No records found matching the search criteria.");}
	print qq(</div>\n);
	# routine to serve search results...
	# takes 3 parameters:
	#   1.) name of table to search
	#   2.) name of parameter that contains query string
	#   3.) an optional css id to use in div
	# my %results=$g->search("table","results","results");
	sub engine{
		my($table,$query,$css)=@_;
		my $fields=$g->fields($table);
	}
}

sub view{
  my ($first,$middle,$last,$suffix,$company)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix,company from $leads_table where uid like $g->{uid}");
  $g->event("sales_tracking","viewing $g->{uid} $last, $first, $middle $suffix - $companytracking");

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=sales_leads&action=edit&uid=$g->{uid}"},"Back To Record"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=new&uid=$g->{uid}"},"Add Entry"),
    #$g->{CGI}->a({-href=>"$g->{scriptname}?action=type_editor&uid=$g->{uid}"},"Edit Tracking Types"),
  );

  if($first ne ""){
    print $g->{CGI}->h3("Communications with: ".$g->tc("$first $middle $last $suffix ( $company )"));

    $sth=$g->{dbh}->prepare("select $tracking_fields from $tracking_table where uid like \"$g->{uid}\" order by timestamp"); $sth->execute();
    my $flag=0;
		#my($tid,$uid,$contact,$reference,$comment,$timestamp,$mood);
    while(($tid,$uid,$contact,$reference,$comment,$timestamp,$mood)=$sth->fetchrow_array()){
      if($status eq ""){$status="active";}

      print qq(\n    <div id="listform">\n      ); #<div id="floatright">\n);
			# show edit and delete if roles exist for user
			if($g->{my_roles}=~m/delete/){
				print $g->{CGI}->a({-class=>"action",-href=>"$g->{scriptname}?action=delete&tid=$tid&uid=$g->{uid}"},"Delete");
			}
			if($g->{my_roles}=~m/edit/){
        print $g->{CGI}->a({-class=>"action",-href=>"$g->{scriptname}?action=edit&tid=$tid&uid=$g->{uid}"},"Edit");					
			}
      #print qq(</div> <!-- end floatright -->\n),				
			print $g->{CGI}->p("contact type: <b>$contact</b>&nbsp;&nbsp;&nbsp;reference: <b>$reference</b>
										mood: <b>$mood</b>&nbsp;&nbsp;&nbsp;timestamp: <b>$timestamp</b>"),
      $g->{CGI}->p("comment: <b>$comment</b>&nbsp;&nbsp;&nbsp;");
			print qq(\n    </div> <!-- end listform -->\n);
      $flag=1;
    }
    if($flag==0){
      print $g->{CGI}->div({-id=>"listform"},"There are no tracking entries for this lead.");
    }
  }
  else{
    print $g->{CGI}->br(),$g->{CGI}->h3("Sales :: Tracking"),
	  $g->{CGI}->p("The record you requested does not exist.");
  }
}

sub type_editor{
  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$g->{uid}"},"Back to Tracking Listing"),
  ),
  $g->{CGI}->h3({-align=>"center"},"Editing Tracking Types");

  if($g->{function} eq 'update'){
   # $g->{dbh}->do("update sales_tracking_types set name=\"$g->{newname}\" where name like \"$g->{name}\"");
   # $g->{dbh}->do("update sales_tracking_license set type=\"$g->{newname}\" where type=\"$g->{name}\"");
   # $g->event("license","renamed '$g->{name}' to '$g->{newname}'");
    print $g->{CGI}->h4("Changed '$g->{name}' to '$g->{newname}'");
  }
  elsif($g->{function} eq 'delete'){
    if($g->{validation} eq 'false'){
      my $count=$g->{dbh}->selectrow_array(
        "select count(*) from sales_leads left join sales_tracking on sales_leads.uid=sales_tracking.uid
         where sales_tracking.contact='$g->{name}'");
      if($count==0){
        $g->{dbh}->do("delete from rcs_licensetypes where name='$g->{name}'");
        $g->event("license","deleted license type: '$g->{name}'");
        print $g->{CGI}->h4("No employees had a '$g->{name}' license or certificate."),
              $g->{CGI}->p("The '$g->{name}' license type has been safely deleted from this system.");
      }
      else{
        my $count_message="There are ($count) employees";
        if($count==1){$count_message="There is (1) employee";}
        print $g->{CGI}->h4("$count_message in the system having a license or certificate type of '$g->{name}'.");
        $sth=$g->{dbh}->prepare("select lastname,firstname,middle,suffix,degree from rcs_personnel left join rcs_license on rcs_personnel.uid=rcs_license.uid
                           where rcs_license.type='$g->{name}'"); $sth->execute();
        print qq(\n<p><center>\n);
        while(my($l,$f,$m,$s,$d)=$sth->fetchrow_array()){print "\n$l, $f $m $s $d<br />";
        }print "\n</center></p>\n";

        print $g->{CGI}->p("<i>*Until all employees having this license or certificate type have a different type associated, '$g->{name}' cannot be deleted.</i>");
        #print $g->{CGI}->p("Click ",$g->{CGI}->a({-href=>"javascript:void(0);",-onclick=>""},"here")," to view the list of users.");
      }
    }
    else{
      $sth=$g->{dbh}->prepare("select uid,lastname,firstname,middle,suffix,degree
                               from rcs_personnel left join rcs_license on rcs_personnel.uid=rcs_license.uid
                               where rcs_license.type='$g->{name}'"); $sth->execute();
      $g->{dbh}->do("delete from rcs_licensetypes where name='$g->{name}'");
      $g->event("license","deleted license type: '$g->{name}'");
    }
  }
  elsif($g->{function} eq 'add'){
    # add check to make sure the record doesn't already exist...
    my ($name)=$g->{dbh}->selectrow_array("select name from rcs_licensetypes where name='$g->{newtype}'");
    if($name=~m/$g->{newtype}/i){
      print $g->{CGI}->h4("There is already a '$g->{newtype}' license/certificate type defined.");
      $g->event("license","duplicate insertion attempted by license type: '$g->{newtype}'");
    }
    else{
      $g->{dbh}->do("insert into rcs_licensetypes values(0,'$g->{newtype}')");
      $g->event("license","added license type: '$g->{newtype}'");
      print $g->{CGI}->h4("Added '$g->{newtype}' as a License/Certification type.");
    }
  }

  print $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->start_form({-method=>'get',-action=>"$g->{scriptname}"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'type_editor',-override=>1}),
        $g->{CGI}->hidden({-name=>'function',-value=>'add',-override=>1}),
        $g->{CGI}->label({-for=>'newtype'},"New License/Certificate Type:"),
        $g->{CGI}->textfield({-name=>'newtype',-size=>50,-value=>"",-override=>1}),
        $g->{CGI}->submit("Add New Type"),
      $g->{CGI}->endform(),
      $g->{CGI}->br(),
  );

  $sth=$g->{dbh}->prepare("select name from rcs_licensetypes"); $sth->execute();
  my @license_types; while(my $type=$sth->fetchrow_array()){push(@license_types,"$type");}

  print $g->{CGI}->start_table({-cols=>2,-width=>"98%",-border=>0}),
  $g->{CGI}->Tr($g->{CGI}->th("License/Certificate Type"),$g->{CGI}->th("Action"));
  my $highlight='even';
  foreach my $type (sort @license_types){
    if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
    print $g->{CGI}->Tr({-class=>"$highlight"},
      $g->{CGI}->td({-width=>"80%"},
        $g->{CGI}->start_form({-method=>'get',-action=>"$g->{scriptname}"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'type_editor',-override=>1}),
        $g->{CGI}->hidden({-name=>'function',-value=>'update',-override=>1}),
        $g->{CGI}->hidden({-name=>'name',-value=>"$type",-override=>1}),
        $g->{CGI}->textfield({-name=>'newname',-size=>50,-value=>"$type",-override=>1}),
      ),
      $g->{CGI}->td(
        $g->{CGI}->submit("Update"),
      $g->{CGI}->endform(),
        $g->{CGI}->start_form({-method=>'post',-action=>"$g->{scriptname}",-style=>"float: right;"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'validation',-value=>'false'}),
        $g->{CGI}->hidden({-name=>'action',-value=>'type_editor',-override=>1}),
        $g->{CGI}->hidden({-name=>'function',-value=>'delete',-override=>1}),
        $g->{CGI}->hidden({-name=>'name',-value=>"$type",-override=>1}),
        $g->{CGI}->submit("Delete"),
        $g->{CGI}->endform(),
      ),
    );
  }
  print $g->{CGI}->end_table();
}

sub editor{
  my ($first,$middle,$last,$suffix,$company)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix,company from $leads_table where uid like $g->{uid}");
  my $title;
  if($g->{action} eq "new"){$g->{action}="add"; $title="Adding";}
  else{$g->{action}="update"; $title="Editing";
    ($tid,$uid,$contact,$reference,$comment,$timestamp,$mood)=
    $g->{dbh}->selectrow_array("select $tracking_fields from $tracking_table where tid like $g->{tid}");
  }
  #$sth=$g->{dbh}->prepare("select name from rcs_licensetypes order by name"); $sth->execute();
  #my @license_types; while(my $type=$sth->fetchrow_array()){push(@license_types,"$type");}
	my @contact_types=("Email","Facebook","In Person","MMORPG","Phone","Text Message","Twitter");

	my @reference_types=("DIFR :: General Sales","DIFR :: Research Compliance Suite","DIFR :: Review Suite","DIFR :: ITM", "Nimble Storage","Enterprise Support","DIFR :: Custom Solution","Flying Car");
	
	my @moods; for(my $i=100; $i>0; --$i){ push(@moods,$i);}
	
  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$g->{uid}"},"Back"),
    #$g->{CGI}->a({-href=>"$g->{scriptname}?action=type_editor&uid=$g->{uid}"},"Edit Contact Types"),
  ),
  $g->{CGI}->br(),$g->{CGI}->h3("Tracking for \"$first $middle $last $suffix - $company\"");

  #my $lmatchmsg="There was no tracking match for '$type'.  Please select a License Type from the Dropdown box and save this record.";
  #if($type eq ''){$lmatchmsg="";}
  #foreach $ltype (@license_types){
  #  if($ltype eq $type){$lmatchmsg=''; print "\n<!-- match! $ltype = $type -->";}
  #}

  #if($g->{type} ne '' and $type eq ''){$type="$g->{type}";}

  print $g->{CGI}->div({-id=>"listform"},
    $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>1}),
      $g->{CGI}->hidden({-name=>"tid",-value=>"$g->{tid}",-override=>1}),
      $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>1}),		
			$g->{CGI}->label({-for=>"submit"}," "),
      $g->{CGI}->submit("Save"),
			$g->{CGI}->br(),
      #$g->{CGI}->em($lmatchmsg),$g->{CGI}->br(),
      $g->{CGI}->label({-for=>"contact"},"Contact Type"),
      $g->{CGI}->popup_menu({-name=>"contact",-size=>"1", -default=>"$contact",-values=>\@contact_types,-override=>"1"}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"reference"},"Reference"),
      $g->{CGI}->popup_menu({-name=>"reference",-size=>"1", -default=>"$reference",-values=>\@reference_types,-override=>"1",-title=>"Select a solution"}),
			$g->{CGI}->br(),
      $g->{CGI}->label({-for=>"comment"},"Comment"),
      $g->{CGI}->textarea({-name=>"comment", -cols=>80, -rows=>"3",-value=>"$comment", -override=>"1"}),
      $g->{CGI}->br(),
      $g->{CGI}->label({-for=>"timestamp"},"When "),
      $g->{CGI}->textfield({-id=>"datepicker1",-name=>"timestamp",-value=>"$timestamp",-size=>"20",-override=>1}),
			$g->{CGI}->br(),
      $g->{CGI}->label({-for=>"mood"},"Mood "),
      $g->{CGI}->popup_menu({-name=>"mood", -size=>"1",-default=>"$mood", -value=>\@moods, -override=>"1"}),
    $g->{CGI}->end_form(),
  );
}
