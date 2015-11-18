#!/usr/bin/perl
# license module for DIFR
# If you don't know the code, don't mess around below -bciv

#
my $license_table="rcs_license";
my $license_fields="lid,uid,type,number,state,received,expires,status";
my $personnel_table="rcs_personnel";

# for module license
my($lid,$uid,$type,$number,$state,$received,$expires,$verified);
my @states=("N/A","Alabama","Alaska","Arizona","Arkansas","California","Colorado",
"Connecticut","D.C.","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana",
"Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan",
"Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
"New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma",
"Oregon","Pennsylvania","Puerto Rico","Rhode Island","South Carolina","South Dakota","Tennessee",
"Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming",
);

print qq(<div id="page_effect">\n);

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'view',
  'default_function'=>'view',
  'function'=>{
    'add'=>'add',
    'new'=>'editor',
    'edit'=>'editor',
    'view'=>'view',
    'update'=>'update',
    'delete'=>'del',
    'type_editor'=>'type_editor',
  }
); &$function;
1; # end module

sub add{
  $g->event("license","adding $g->{type} license \($g->{number}\) for $g->{uid}");
  $g->{dbh}->do("insert into $license_table values('0',\"$g->{uid}\",\"$g->{type}\",\"$g->{number}\",
  \"$g->{state}\",\"$g->{received}\",\"$g->{expires}\",\"$g->{status}\")");
  view();
}

sub del{
  $g->event("license","deleting license \($g->{lid}\) from $g->{uid}");
  $g->{dbh}->do("delete from $license_table where lid like \"$g->{lid}\"") or die "can not delete record $g->{lid} from table : $!<br />";
  view();
}

sub update{
  #print "updating record...\n";
  #$g->yyyymmdd("received","expires","verified");
  $g->event("license","updating $g->{type} license \($g->{number}\) for $g->{uid}");
  my $query="update $license_table set type=\"$g->{type}\",number=\"$g->{number}\",state=\"$g->{state}\",
  received=\"$g->{received}\",expires=\"$g->{expires}\",status=\"$g->{status}\" where lid=\"$g->{lid}\"";
  #print "$query\n";
  $g->event("License","Updated uid: $g->{uid} License: $g->{number} Status: $g->{status} Received: $g->{received} Expires: $g->{expires}");
  $g->{dbh}->do("$query");
  editor();
}

sub view{
  my ($first,$middle,$last,$suffix)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix from $personnel_table where uid like $g->{uid}");
  $g->event("license","viewing $g->{uid} $last, $first, $middle $suffix licenses");

  print
  $g->{CGI}->div({-id=>"submenu"},"&nbsp;"),
  $g->{CGI}->div({-id=>"navlinks"},"&nbsp;",
    $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}"},"To Personnel Record"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=new&uid=$g->{uid}&name=$first $middle $last $suffix"},"Add License"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=type_editor&uid=$g->{uid}"},"Edit License Types"),
  );

  if($first ne ""){
    print $g->{CGI}->div({-id=>"title"},
	  	$g->{CGI}->h3("Licenses/Certificates for: ".$g->tc("$first $middle $last $suffix")),
		);
	  print qq(<div id="subtitle"><p>&nbsp;</p></div>\n);

		#print qq(\n<div id="main">\n);
    $sth=$g->{dbh}->prepare("select $license_fields from $license_table where uid like \"$g->{uid}\" order by received"); $sth->execute();
    my $flag=0;
    while(($lid,$uid,$type,$number,$state,$received,$expires,$status)=$sth->fetchrow_array()){
      if($status eq ""){$status="active";}

      print $g->{CGI}->div({-id=>"record"},
        $g->{CGI}->div({-id=>"floatright"},
          $g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&lid=$lid&uid=$g->{uid}"},"<div align=\"center\">Edit"),
          "&nbsp;&#149;&nbsp;",
          $g->{CGI}->a({-href=>"$g->{scriptname}?action=delete&lid=$lid&uid=$g->{uid}"},"Delete</div>"),
        ),
        $g->{CGI}->p("license type: <b>$type</b>&nbsp;&nbsp;&nbsp;status: <b>$status</b"),
        $g->{CGI}->p("number: <b>$number</b>&nbsp;&nbsp;&nbsp;State/Commonwealth: <b>$state</b>"),
        $g->{CGI}->p("received: <b>$received</b>&nbsp;&nbsp;&nbsp;expires on: <b>$expires</b>&nbsp;&nbsp;&nbsp;"),
        $g->{CGI}->br(),
      );
      $flag=1;
    }
    if($flag==0){
      print $g->{CGI}->div({-id=>"record"},"There are no licenses or certificates listed for this record.");
    }
  }
  else{
    print $g->{CGI}->br(),$g->{CGI}->h3("Personnel :: Licenses"),
	  $g->{CGI}->p("The record you requested does not exist.");
  }
}

sub type_editor{
  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$g->{uid}"},"Back to License Listing"),
  ),
  $g->{CGI}->h3({-align=>"center"},"Editing License/Certificate Types");

  if($g->{function} eq 'update'){
    $g->{dbh}->do("update rcs_licensetypes set name=\"$g->{newname}\" where name like \"$g->{name}\"");
    $g->{dbh}->do("update rcs_license set type=\"$g->{newname}\" where type=\"$g->{name}\"");
    $g->event("license","renamed '$g->{name}' to '$g->{newname}'");
    print $g->{CGI}->h4("Changed '$g->{name}' to '$g->{newname}'");
  }
  elsif($g->{function} eq 'delete'){
    if($g->{validation} eq 'false'){
      my $count=$g->{dbh}->selectrow_array(
        "select count(*) from rcs_personnel left join rcs_license on rcs_personnel.uid=rcs_license.uid
         where rcs_license.type='$g->{name}'");
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
  my ($first,$middle,$last,$suffix)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix from $personnel_table where uid like $g->{uid}");
  my $title;
  if($g->{action} eq "new"){$g->{action}="add"; $title="Adding";}
  else{$g->{action}="update"; $title="Editing";
    ($lid,$uid,$type,$number,$state,$received,$expires,$status)=
    $g->{dbh}->selectrow_array("select $license_fields from $license_table where lid like $g->{lid}");
  }
  $sth=$g->{dbh}->prepare("select name from rcs_licensetypes order by name"); $sth->execute();
  my @license_types; while(my $type=$sth->fetchrow_array()){push(@license_types,"$type");}

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$g->{uid}"},"Back"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=type_editor&uid=$g->{uid}"},"Edit License Types"),
  ),
  $g->{CGI}->br(),$g->{CGI}->h3("$title License/Certificate for \"$first $middle $last $suffix\"");

  my $lmatchmsg="There was no License match for '$type'.  Please select a License Type from the Dropdown box and save this record.";
  if($type eq ''){$lmatchmsg="";}
  foreach $ltype (@license_types){
    if($ltype eq $type){$lmatchmsg=''; print "\n<!-- match! $ltype = $type -->";}
  }

  if($g->{type} ne '' and $type eq ''){$type="$g->{type}";}

  print
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
        $g->{CGI}->div({-id=>"floatright"},
          $g->{CGI}->submit("Save"),
        ),
        $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>1}),
        $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>"name",-value=>"$g->{name}",-override=>1}),
        $g->{CGI}->hidden({-name=>"lid",-value=>"$g->{lid}",-override=>1}),
        $g->{CGI}->em($lmatchmsg),$g->{CGI}->br(),
        $g->{CGI}->label({-for=>"type"},"License/Certificate Type "),
        $g->{CGI}->popup_menu({-name=>"type",-size=>"1", -default=>"$type",-values=>\@license_types,-override=>"1",-title=>"i.e., MD, RN, ARNP, Social Worker, Dietician etc..."}),
        $g->{CGI}->br(),
        $g->{CGI}->br(),
        $g->{CGI}->label({-for=>"number"},"License/Certificate Number "),
        $g->{CGI}->textfield({-name=>"number",-value=>"$number",-override=>1,-size=>"25",-title=>"license/certificate number"}),
        "&nbsp;&nbsp;&nbsp;",
        $g->{CGI}->label({-for=>"state"},"State/Commonwealth"),
        $g->{CGI}->popup_menu({-name=>"state", -size=>"1",-default=>"$state", -value=>\@states, -override=>"1"}),
        $g->{CGI}->br(),
        $g->{CGI}->br(),
        $g->{CGI}->label({-for=>"received"},"Date Received "),
        $g->{CGI}->textfield({-id=>"datepicker1",-name=>"received",-value=>"$received",-size=>"11",-override=>1}),
        $g->{CGI}->label({-for=>"expires"},"Expiration Date "),
        $g->{CGI}->textfield({-id=>"datepicker2",-name=>"expires",-value=>"$expires",-size=>"11",-override=>1}),
        $g->{CGI}->label({-for=>"status"},"License Status "),
        $g->{CGI}->popup_menu({-name=>"status",-size=>"1",-default=>"$status",-value=>["active","inactive","delinquent","other"],-override=>"1"}),
        $g->{CGI}->br(),
        $g->{CGI}->br(),
      $g->{CGI}->end_form(),
    #),
  );
}
