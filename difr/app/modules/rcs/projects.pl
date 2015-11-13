#!/usr/bin/perl
# scopeofwork module for DIFR
# If you don't know the code, don't mess around below -bciv

my $projects_table="rcs_scopeofwork";
my $personnel_table="rcs_personnel";
my $project_members_table="rcs_project_members";

my @mm=["00","01","02","03","04","05","06","07","08","09","10","11","12"];
my @dd=["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"];
my @yyyy=["0000","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024"];
my @projectstatuses=["Active","Closed","Pending","Tabled","Suspended"];
my @role_list=["Primary Investigator","Co-Primary Investigator","Co-Investigator","Research Coordinator","Contractor","Staff","Other"];

# for module scopeofwork
my($scopeid,$uid,$irbnumber,$projecttitle,$description,$pi,$received,$status);

my $query_fields="scopeid,uid,irbnumber,projecttitle,description,pi,received,status";

print qq(<div id="page_effect">\n);

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'investigators',
  'default_function'=>'investigators',
  'function'=>{
    'add'=>'add',
    'new'=>'editor',
    'edit'=>'editor',
    'update'=>'update',
    'delete'=>'delete_project',
    'remove'=>'remove',
    'remove_member'=>'remove_member',
    'add_member'=>'add_member',
    'list'=>'add_member',
    'insert_member'=>'insert_member',
    'modify_role'=>'modify_role',
    'view'=>'view',
    'investigators'=>'investigators',
    'members'=>'members',
    'projects'=>'projects',
  }
); &$function;
1; # end module

#					                                                                            INVESTIGATORS
sub investigators{
  tabs();

  if($g->{method} eq "projects"){
    print $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}"},"Back To Investigator Listing"),
    );
  }

  my $title_text="Primary Investigators";
  if($g->{uid} ne ""){
    my $query="select lastname,firstname,middle,suffix,degree from rcs_personnel where uid=\"$g->{uid}\"";
    my($lastname,$firstname,$middle,$suffix,$degree)=$g->{dbh}->selectrow_array($query);
    $title_text="$firstname $middle $lastname $suffix, $degree's Projects";
  }

  print $g->{CGI}->br(),$g->{CGI}->h3("$title_text");

  # investigator's analytics
  if($g->{uid} eq ''){
    print qq(\n<div id="analytics">\n);
    my $pi_total=$g->analytic('Total PI\'s','',"distinct",'uid','rcs_project_members',"where role='Primary Investigator'",'');
    my $pi_active=$g->analytic('Active PI\'s','',"*",'','rcs_project_members',
    "left join rcs_personnel on rcs_project_members.uid=rcs_personnel.uid
     where rcs_personnel.suspended='A'","percentage:$pi_total");
    my $pi_inactive=$g->analytic('Inactive PI\'s','',"*",'','rcs_project_members',
    "left join rcs_personnel on rcs_project_members.uid=rcs_personnel.uid
     where rcs_personnel.suspended='I'","percentage:$pi_total");
    my $pi_pending=$g->analytic('Pending PI\'s','',"*",'','rcs_project_members',
    "left join rcs_personnel on rcs_project_members.uid=rcs_personnel.uid
     where rcs_personnel.suspended='P'","percentage:$pi_total");
    my $pi_suspended=$g->analytic('Suspended PI\'s','',"*",'','rcs_project_members',
     "left join rcs_personnel on rcs_project_members.uid=rcs_personnel.uid
     where rcs_personnel.suspended='S'","percentage:$pi_total");
    print qq(\n</div> <!-- end analytics -->\n);
  }

  my $query_criteria=""; if($g->{limit} eq ""){$g->{limit}="50";} if($g->{startwith} eq ""){$g->{startwith}="0";}
  print $g->{CGI}->div({-id=>"search"},
    $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"projects"}),
      $g->{CGI}->hidden({-name=>"startwith",-value=>"$g->{startwith}",-override=>"1"}),
      $g->{CGI}->hidden({-name=>"limit",-value=>"$g->{limit}",-default=>"50",-override=>"1"}),
      $g->{CGI}->label({-for=>"query"},"Search For Primary Investigators"),
      $g->{CGI}->textfield({-size=>"50",-name=>"query",-value=>"$g->{query}",-override=>"1"}),
      $g->{CGI}->submit({-value=>"Search"}),
    $g->{CGI}->end_form(),
  );

  my $personnel_table="rcs_personnel";
  #print qq(<div id="page_effect">\n);

  unless(defined($g->{method})){

    if(defined($g->{query}) and $g->{query} ne ""){
      my @qarray=split(/\ /,$g->{query});
      foreach $element (@qarray){
        $query_criteria="and $query_criteria ($personnel_table.lastname regexp \"$element\" or
        $personnel_table.firstname regexp \"$element\" or
        $personnel_table.middle regexp \"$element\" or
        $personnel_table.suffix regexp \"$element\" or
        $personnel_table.degree regexp \"$element\") ";
      }
      #$query_criteria=substr("where $query_criteria",0,-3);
      #print "<-- query: \n$query_criteria \n-->\n";
    }

    # query only primary investigators by lastname, firstname, middle, and suffix
    my $query="select $project_members_table.uid,rcs_personnel.lastname,rcs_personnel.firstname,rcs_personnel.middle,rcs_personnel.suffix,rcs_personnel.degree
               from $project_members_table left join rcs_personnel on $project_members_table.uid=rcs_personnel.uid where role='Primary Investigator'
               $query_criteria
               order by lastname,firstname,middle,suffix";

    my $sth=$g->{dbh}->prepare($query); $sth->execute();
    my $temp_uid='';
    while(($uid,$lastname,$firstname,$middle,$suffix,$degree)=$sth->fetchrow_array()){
      if($uid ne $temp_uid){
        print $g->{CGI}->div({-id=>"record"},
          $g->{CGI}->p("$lastname, $firstname $middle $suffix $degree",
            $g->{CGI}->a({-href=>"$g->{scriptname}?action=investigators&method=projects&uid=$uid"},"View Projects"),
          ),
        );
      }
      $temp_uid=$uid;
    }
  }
  elsif($g->{method} eq 'projects'){
    # query only projects respective to the selected primary investigator
    # select rcs_projects.scopeid,rcs_projects.name from rcs_projects right join rcs_project_members on rcs_projects.scopeid=rcs_project_members.scopeid where rcs_project_members.role='Primary Investigator' and rcs_project_members.uid=1024;

    my $query="select $project_members_table.scopeid, $projects_table.irbnumber, $projects_table.projecttitle,
               rcs_personnel.lastname, rcs_personnel.firstname, rcs_personnel.middle, rcs_personnel.suffix, rcs_personnel.degree
               from $project_members_table left outer join $projects_table on $project_members_table.scopeid=$projects_table.scopeid
               left join rcs_personnel on rcs_project_members.uid=rcs_personnel.uid
               where $project_members_table.uid=\"$g->{uid}\" and $project_members_table.role=\"Primary Investigator\"";

    my $sth=$g->{dbh}->prepare($query); $sth->execute();
    my $record_exists='';
    while(($scopeid,$irbnumber,$projecttitle,$lastname,$firstname,$middle,$suffix,$degree,$name)=$sth->fetchrow_array()){
      if($scopeid ne ''){ $record_exists=1;
        if(not defined($irbnumber) or $irbnumber eq ""){$irbnumber="Not Defined";}
        print
        $g->{CGI}->div({-id=>"record"},
          $g->{CGI}->p("IRB/IACUC/MIRB Number: <b>$irbnumber</b><br />",
          	"Project Title: <b>$projecttitle</b>",
          	  $g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&method=projects&uid=$g->{uid}&scopeid=$scopeid"},"View Project"),
          ),
        );
      }
    }
    if($record_exists eq ''){
      print $g->{CGI}->h4("This Primary Investigator is not assigned to any Projects.");
    }
  }
  else{
    print $g->{CGI}->h3("The requested method does not exist.");
  }
  #print "</div>";
}

#									                                                    MEMBERS
sub members{
  tabs();

  print $g->{CGI}->br(),$g->{CGI}->h3("Project Members");

  print qq(\n<div id="analytics">\n);
  my $total_members=$g->analytic('Total Project Members','',"distinct",'uid','rcs_project_members','','');
  # iterate through roles to generate an dynamic analytic display based on roles
  my @role_list=('Primary Investigator','Co-Primary Investigator','Co-Investigator','Research Coordinator','Staff','Other');
  foreach $role (@role_list){
    $g->analytic("$role",'',"*",'','rcs_project_members',"where role='$role'","percentage:$total_members");
  }
  print qq(\n</div> <!-- end analytics -->\n);

  my $query_criteria=""; if($g->{limit} eq ""){$g->{limit}="50";} if($g->{startwith} eq ""){$g->{startwith}="0";}
  print $g->{CGI}->div({-id=>"search"},
    $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"projects"}),
      $g->{CGI}->hidden({-name=>"startwith",-value=>"$g->{startwith}",-override=>"1"}),
      $g->{CGI}->hidden({-name=>"limit",-value=>"$g->{limit}",-default=>"50",-override=>"1"}),
      $g->{CGI}->label({-for=>"query"},"Search For Project Members"),
      $g->{CGI}->textfield({-size=>"50",-name=>"query",-value=>"$g->{query}",-override=>"1"}),
      $g->{CGI}->submit({-value=>"Search"}),
    $g->{CGI}->end_form(),
  );

  #print qq(<div id="page_effect">\n);

  #print $g->{CGI}->div({-id=>"subnavlink"},
  #        $g->{CGI}->a({-href=>"$g->{scriptname}?action=new&uid=$g->{uid}&name=$first $middle $last $suffix"},"Add A Project"),
  #      );
  my $personnel_table="rcs_personnel";

  if(defined($g->{query}) and $g->{query} ne ""){
    my @qarray=split(/\ /,$g->{query});
    foreach $element (@qarray){
      $query_criteria="$query_criteria ($personnel_table.lastname regexp \"$element\" or
      $personnel_table.firstname regexp \"$element\" or
      $personnel_table.middle regexp \"$element\" or
      $personnel_table.suffix regexp \"$element\" or
      $personnel_table.degree regexp \"$element\") and";
    }
    $query_criteria=substr("where $query_criteria",0,-3);
    #print "<-- query: \n$query_criteria \n-->\n";
  }

  $sth=$g->{dbh}->prepare(
    "select $project_members_table.scopeid,$projects_table.irbnumber,$projects_table.projecttitle,$project_members_table.uid,
     $project_members_table.role,$personnel_table.lastname,$personnel_table.firstname,$personnel_table.middle,
     $personnel_table.suffix,$personnel_table.degree,$project_members_table.comment
     from $project_members_table
     left join $projects_table on $project_members_table.scopeid=$projects_table.scopeid
     left join $personnel_table on $project_members_table.uid=$personnel_table.uid
     $query_criteria
     order by $personnel_table.lastname,$personnel_table.firstname,
     $personnel_table.middle,$personnel_table.suffix,$project_members_table.role"
  );

  $sth->execute();
  my $temp_uid=""; my $count="0";
  my $highlight='odd';
  while(($scopeid,$irbnumber,$projecttitle,$uid,$role,$lastname,$firstname,$middle,$suffix,$degree,$comment)=$sth->fetchrow_array()){
    if($highlight eq 'even'){$highlight='odd';}
    elsif($highlight eq 'odd'){$highlight='even';}

    # a new employee's records are being iterated through, start a new record div
    if($temp_uid ne $uid){

      # the first employee's records have to close the last record div unless first one
      if($temp_uid ne ""){print qq(\n      </table>\n</div>\n\n);}
      print qq(<div id='record'><h3>$lastname, $firstname $middle $suffix $degree\'s Projects</h3><a name=\"$uid\">&nbsp;</a>\n);

      # start table
      print $g->{CGI}->start_table({-cols=>6}),
      $g->{CGI}->Tr(
        $g->{CGI}->th({-width=>"8%"},"ScopeID"),$g->{CGI}->th({-width=>"9%"},"IRB IACUC MIRB#"),$g->{CGI}->th({-width=>"50%"},"Project Title"),
        $g->{CGI}->th({-width=>"12%"},"Role"),$g->{CGI}->th({-width=>"20%"},"Comment"),$g->{CGI}->th("Action"),
      );
    }

    # added 20101228 to replace commented out stuff below this...
    print $g->{CGI}->Tr({-class=>"$highlight"},
      $g->{CGI}->td("$scopeid"),$g->{CGI}->td("$irbnumber"),$g->{CGI}->td("$projecttitle"),
      $g->{CGI}->td("$role"),$g->{CGI}->td("$comment"),$g->{CGI}->td(
        $g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&scopeid=$scopeid"},"Edit"),
      ),
    );

    $temp_uid=$uid;
    ++$count;
  }

  # no more records... close last record div
  if($temp_uid ne ""){print qq(\n      </table></div>\n);}
  if($count eq "0"){
    print $g->{CGI}->div({-id=>"record"},"There are no results found.");
  }
  #print qq(</div>\n);
}

#					                                                                    PROJECTS
sub projects{
  tabs();

  my $query_criteria=""; if($g->{limit} eq ""){$g->{limit}="50";} if($g->{startwith} eq ""){$g->{startwith}="0";}
  my $filter_criteria="";

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=new&uid=$g->{uid}&name=$first $middle $last $suffix"},"Add A Project"),
  ),
  $g->{CGI}->h3("Project Listing");

  analytics();

  if($g->{filter} eq ""){$filter_criteria="where $projects_table.status not like 'Inactive'";}
  elsif($g->{filter} eq "inactive"){$filter_criteria="where $projects_table.status=\"Inactive\"";}

  print $g->{CGI}->div({-id=>"search"},
    $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"projects"}),
      $g->{CGI}->hidden({-name=>"startwith",-value=>"$g->{startwith}",-override=>"1"}),
      $g->{CGI}->hidden({-name=>"limit",-value=>"$g->{limit}",-default=>"50",-override=>"1"}),
      $g->{CGI}->label({-for=>"query"},"Search For Projects"),
        $g->{CGI}->textfield({-size=>"50",-name=>"query",-value=>"$g->{query}",-override=>"1"}),
      $g->{CGI}->submit({-value=>"Search"}),
    $g->{CGI}->end_form(),
  );

  #print qq(\n<div id="page_effect">\n);

  if(defined($g->{query}) and $g->{query} ne ""){
    my @qarray=split(/\ /,$g->{query});
    foreach $element (@qarray){
      #print "$element ";
      $query_criteria="$query_criteria $projects_table.projecttitle regexp \"$element\" and";
    }
    $query_criteria=substr("$query_criteria",0,-3);
    if($g->{query}=~m/^\d\d\d/){
    $query_criteria="($projects_table.irbnumber like \"$g->{query}\" or $query_criteria)";
    }
    print "<p>Searching for: $query_criteria</p>\n";
  }

  my $and="";
  if($query_criteria ne ""){$and="and";}
  my $project_query_fields="$projects_table.scopeid,$projects_table.irbnumber,$projects_table.pi,$projects_table.projecttitle,$projects_table.status,$project_members_table.uid,
  $project_members_table.role,
  rcs_personnel.lastname,rcs_personnel.firstname,rcs_personnel.middle,rcs_personnel.suffix,rcs_personnel.degree,
  $project_members_table.comment";

  my $project_query="select $project_query_fields from $projects_table
     left join $project_members_table on $projects_table.scopeid=$project_members_table.scopeid
     left join rcs_personnel on $project_members_table.uid=rcs_personnel.uid
     $filter_criteria $and
     $query_criteria
     order by $projects_table.scopeid,
     field($project_members_table.role, 'Primary Investigator', 'Co-Primary Investigator', 'Co-Investigator','Research Coordinator', 'Staff', 'Other'),
     rcs_personnel.lastname,rcs_personnel.firstname,rcs_personnel.middle,rcs_personnel.suffix";

  print "<!-- $project_query -->\n";

  $sth=$g->{dbh}->prepare($project_query); $sth->execute();

  my $temp_scopeid=""; my $previous_scopeid=""; my $project_increment=0; my $temp_role=""; my $count=0;
  my $highlight='odd';
  while(($scopeid,$irbnumber,$pi,$projecttitle,$status,$uid,$role,$lastname,$firstname,$middle,$suffix,$degree,$comment)=$sth->fetchrow_array()){
    if($highlight eq 'even'){$highlight='odd';}
    elsif($highlight eq 'odd'){$highlight='even';}

    # close div for last project record group
    if($temp_scopeid ne $scopeid){
	    # if project record is not the first one close the last record div
      if($temp_scopeid ne ""){print qq(\n</table><br />\n</div> <!-- end record ~ new record starts -->\n); $highlight='even';}

	    # start a new record div for this project
      print qq(\n<div id="record">\n);
      $temp_role="";
      my $titleinclude=""; if($projecttitle ne ""){$titleinclude="<h4>$projecttitle</h4>";}
      my $irbinclude=""; if($irbnumber ne ""){$irbinclude="&nbsp;&nbsp;&nbsp;IRB/IACUC/MIRB Number:<b>$irbnumber</b>";}
      print $g->{CGI}->h4("$projecttitle"),
      $g->{CGI}->p(
        "Status:",$g->{CGI}->b("$status"),
        "$irbinclude",
        $g->{CGI}->center(
          $g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&scopeid=$scopeid"},"Edit Project"),
        ),
      );

	    $temp_scopeid=$scopeid; $project_increment++;

	    # begin table for project members
	    print $g->{CGI}->start_table({-cols=>"4",-width=>"100%"}),
	    $g->{CGI}->Tr(
	      $g->{CGI}->th({-width=>"20%"},"Employee"),
	      $g->{CGI}->th({-width=>"20%"},"Role"),
	      $g->{CGI}->th({-width=>"40%"},"Comment"),
	      $g->{CGI}->th({-width=>"20%"},"Action"),
	    );
    }

    if($role ne ""){
    # iterating through project members for listing
    print $g->{CGI}->Tr({-class=>"$highlight"},
      $g->{CGI}->td({-width=>"20%"},"$lastname, $firstname $middle $suffix $degree"),
      $g->{CGI}->td({-width=>"20%"},"$role"),
      $g->{CGI}->td({-width=>"40%"},"$comment"),
      $g->{CGI}->td({-width=>"20%"},
        $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$uid"},"View Projects"),
      ),
    );
    }
    else{
      print $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-colspan=>"4"},$g->{CGI}->center("<b>This project has no members assigned.</b>")));
      #if($g->{role}=~m/delete/){
        print $g->{CGI}->center($g->{CGI}->a({-href=>"$g->{scriptname}?action=delete&scopeid=$scopeid"},"Delete Project"));
      #}
    }
    $temp_role=$role;
    $previous_scopeid=$scopeid;
    $temp_scopeid=$scopeid;
    ++$count;
  }
  # there are no more records, close last project record div unless there were no projects
  if($temp_scopeid ne ""){print "</table><br /></div\> <!-- end record no more records -->\n";}
  if($count eq "0"){
    print $g->{CGI}->h4("There are no results found.");
  }
  #print qq(</div>\n);
}



sub add{
  $g->{projecttitle}=~s/'/\'/g;
  $g->{projecttitle}=~s/"/\"/g;
  $g->{dbh}->do("insert into $projects_table values('0',\"$g->{uid}\",\"$g->{irbnumber}\",\"$g->{projecttitle}\",
  \"$g->{description}\",\"$g->{pi}\",\"$g->{received}\",\"$g->{status}\")");
  $g->{action}="edit";
  $g->{scopeid}=$g->{dbh}->selectrow_array("select scopeid from $projects_table where projecttitle=\"$g->{projecttitle}\" and
                                            description=\"$g->{description}\" and irbnumber=\"$g->{irbnumber}\"");

  # add employee to project if it was added from personnel record
  if(defined($g->{uid}) and $g->{uid} ne ''){
    $g->{dbh}->do("insert into rcs_project_members values(\"$g->{scopeid}\",\"$g->{uid}\",\"Primary Investigator\",NULL)");
  }

  editor();
}

sub update{
  $g->{projecttitle}=~s/\'/\\'/g;
  $g->{projecttitle}=~s/\"/\\"/g;
  $g->{dbh}->do("update $projects_table set irbnumber=\"$g->{irbnumber}\",projecttitle=\"$g->{projecttitle}\",
  description=\"$g->{description}\",pi=\"$g->{pi}\",
  received=\"$g->{received}\",
  status=\"$g->{status}\" where scopeid=\"$g->{scopeid}\"");
  editor();
}

sub delete_project{
  #print qq(delete from $projects_table where scopeid="$g->{scopeid}"<br />");
  if(defined($g->{validate}) and $g->{validate} eq 'true'){
    my $count=$g->{dbh}->selectrow_array("select count(*) from rcs_project_members where scopeid='$g->{scopeid}'");
    my $msg='There ';
    if($count > 0){
      if($count eq '1'){$msg.='is still a project member assigned to this project.';}
      elsif($count > 1){$msg.="are ($count) project members assigned to this project.";}
      $msg.='  Projects cannot be removed if employees are assigned.  You must remove all
             members from a project before deleting.';
      print $g->{CGI}->br(),$g->{CGI}->br(),$g->{CGI}->h2("Project Deletion"),
      $g->{CGI}->p("$msg"),
      $g->{CGI}->center($g->{CGI}->a({-href=>"$g->{scriptname}?action=projects"},"Back to Projects"));
    }
    else{
      $g->{dbh}->do("delete from $projects_table where scopeid=\"$g->{scopeid}\"") or die "can not delete record $g->{scopeid} from table : $!<br />";
      print $g->{CGI}->h2("Project has been deleted."),
      $g->{CGI}->center($g->{CGI}->a({-href=>"$g->{scriptname}?action=projects"},"Back to Projects"));
    }
  }
  else{
    my($name,$description)=$g->{dbh}->selectrow_array("select projecttitle,description from rcs_scopeofwork where scopeid='$g->{scopeid}'");
    print $g->{CGI}->br(),$g->{CGI}->br(),$g->{CGI}->h2("Project Deletion"),
    $g->{CGI}->p("Are you sure you want to delete this project?"),
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->center(
        $g->{CGI}->h3("$name"),
        $g->{CGI}->h4("$description"),
      ),
    ),
    $g->{CGI}->br(),
    $g->{CGI}->center(
      $g->{CGI}->a({-href=>"$g->{scriptname}?validate=true&action=delete&scopeid=$g->{scopeid}"},"Yes"),
      "&nbsp;&nbsp;&nbsp;",
      $g->{CGI}->a({-href=>"$g->{scriptname}?action=projects"},"No"),
    );
  }
  #view();
}

sub remove{
  #print qq(delete from $projects_members_table where scopeid=\"$g->{scopeid}\" and uid=\"$g->{uid}\"<br />\n);
  $g->{dbh}->do("delete from $project_members_table where scopeid=\"$g->{scopeid}\" and uid=\"$g->{uid}\"") or die "can not delete record $g->{scopeid} from table : $!<br />";
  view();
}

sub remove_member{
  unless($g->{confirmation} eq "true"){
    print qq(<h2>Project Member Removal Confirmation</h2>);
    print $g->{CGI}->h4("Are you sure you want to remove '<b><em>$g->{ilast}, $g->{ifirst} $g->{imiddle} $g->{isuffix} $g->{degree}</em></b> from this Project?"),
    $g->{CGI}->br,
    $g->{CGI}->p("If you click 'Yes', they will no longer be assisgned to this project (DIFR Scope ID Number: <b><em>$g->{scopeid}</em></b>)."),
    $g->{CGI}->br,
    $g->{CGI}->start_form(),
    $g->{CGI}->hidden({-name=>"action", -value=>"remove_member",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"confirmation", -value=>"true",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"iuid", -value=>"$g->{iuid}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"uid", -value=>"$g->{uid}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"scopeid", -value=>"$g->{scopeid}",-override=>"1"}),
    $g->{CGI}->h2({-align=>"center"},
      $g->{CGI}->submit("Remove Investigator"),
      $g->{CGI}->button({-value=>"Cancel",-onClick=>"history.go(-2);"}),
    ),
    $g->{CGI}->end_form;
  }
  else{
    print qq(<h2>Project Member Removal</h2>);
    $g->{dbh}->do("delete from $project_members_table where scopeid like \"$g->{scopeid}\" and uid=\"$g->{iuid}\"") or die "can not delete $g->{iuid} from DIFR Scope ID: $g->{scopeid} : $!<br />";
    print $g->{CGI}->p("'<b><em>$g->{iuid}</em></b>' has been deleted from the project under DIFR Scope ID: <b><em>$g->{scopeid}</em></b>"),
    $g->{CGI}->br,
    $g->{CGI}->h2({-align=>"center"},
      $g->{CGI}->button({-value=>"Continue",-onClick=>"location.href='$g->{scriptname}?action=edit&uid=$g->{uid}&scopeid=$g->{scopeid}'"}),
    );
  }
}

sub insert_member{
  if($g->{uid} eq "" and $g->{iuid} ne ""){$g->{uid}=$g->{iuid};}
  my $check_record=$g->{dbh}->selectrow_array("select uid from $project_members_table where uid=\"$g->{iuid}\" and scopeid=\"$g->{scopeid}\"");
  if($check_record eq "$g->{iuid}"){
    #print "update $project_members_table set role=\"$g->{irole}\" where uid=\"$g->{uid}\" and scopeid=\"$g->{scopeid}\"";
    $g->{dbh}->do("update $project_members_table set role=\"$g->{irole}\", comment=\"$g->{comment}\" where uid=\"$g->{uid}\" and scopeid=\"$g->{scopeid}\"");
  }
  else{
    #print qq(insert into $project_members_table values(\"$g->{scopeid}\",\"$g->{iuid}\",\"$g->{irole}\",\"$g->{ilast}\",\"$g->{ifirst}\",\"$g->{imiddle}\",\"$g->{isuffix}\",\"$g->{idegree}\",\"$g->{comment}\")<br />);
    $g->{dbh}->do("insert into $project_members_table values(\"$g->{scopeid}\",\"$g->{iuid}\",\"$g->{irole}\",\"$g->{comment}\")");
  }
  $g->{action}="update";
  editor();
}

sub modify_role{
  if($g->{iuid} ne '' and $g->{irole} ne '' and $g->{scopeid} ne ''){ # and $g->{uid} ne ''
    $g->{dbh}->do("update rcs_project_members set role=\"$g->{irole}\",comment=\"$g->{icomment}\" where uid=\"$g->{iuid}\" and scopeid=\"$g->{scopeid}\"");
  }
  editor();
}

sub view{
  my $selected='selected';
  my $allselected=''; if($g->{function} eq ''){$allselected=$selected;}
  my $primaryselected='';  if($g->{function} eq 'Primary Investigator'){$primaryselected=$selected;}
  my $coprimaryselected='';  if($g->{function} eq 'Co-Primary Investigator'){$coprimaryselected=$selected;}
  my $cosselected=''; if($g->{function} eq 'Co-Investigator'){$cosselected=$selected;}
  my $rcselected=''; if($g->{function} eq 'Research Coordinator'){$rcselected=$selected;}
  my $staffselected=''; if($g->{function} eq 'Staff'){$staffselected=$selected;}
  my $otherselected=''; if($g->{function} eq 'Other'){$otherselected=$selected;}

  my $filter=""; unless($g->{function} eq "" and $g->{function} ne "All"){$filter="and role=\"$g->{function}\"";}

  my ($first,$middle,$last,$suffix,$degree)=$g->{dbh}->selectrow_array("select firstname,middle,lastname,suffix,degree from $personnel_table where uid=\"$g->{uid}\"");
  my ($tuid)=$g->{dbh}->selectrow_array("select uid from $personnel_table where uid=\"$g->{uid}\"");

  my $title="Projects";
  if($last ne ""){$title="$last, $first $middle $suffix $degree\'s Projects [uid: $g->{uid}]";}

  tabs();

  if($g->{uid} ne ""){
    print $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}"},"To Personnel Record"),
      #$g->{CGI}->a({-href=>"$g->{scriptname}?action=projects"},"Project Listing"),"&nbsp;&nbsp;&#149;&nbsp;",
      $g->{CGI}->a({-href=>"$g->{scriptname}?action=new&uid=$g->{uid}&name=$first $middle $last $suffix"},"Add A Project"),
    );
  }
  print $g->{CGI}->h3($g->tc("$title"));

  if(not defined($g->{uid}) or $g->{uid} eq ""){
    print qq(
    <div id="search">Roles:
      <ol>
        <li class="$allselected"><a href="$g->{scriptname}?action=view&function=&uid=$g->{uid}">All</a></li>
        <li class="$primaryselected"><a href="$g->{scriptname}?action=view&function=Primary Investigator&uid=$g->{uid}">Primary Investigator</a></li>
        <li class="$coprimaryselected"><a href="$g->{scriptname}?action=view&function=Co-Primary Investigator&uid=$g->{uid}">Co-Primary Investigator</a></li>
        <li class="$coselected"><a href="$g->{scriptname}?action=view&function=Co-Investigator&uid=$g->{uid}">Co-Investigator</a></li>
        <li class="$rcselected"><a href="$g->{scriptname}?action=view&function=Research Coordinator&uid=$g->{uid}">Research Coordinator</a></li>
        <li class="$staffselected"><a href="$g->{scriptname}?action=view&function=Staff&uid=$g->{uid}">Staff</a></li>
        <li class="$otherselected"><a href="$g->{scriptname}?action=view&function=Other&uid=$g->{uid}">Other</a></li>
      </ol>
    </div>);
  }
  else{
  }

  #print qq(\n<div id="page_effect">\n);

    my $member_query_fields="$project_members_table.scopeid, $projects_table.irbnumber,
    $projects_table.projecttitle, $project_members_table.uid, $project_members_table.role,
    $personnel_table.lastname, $personnel_table.firstname, $personnel_table.middle,
    $personnel_table.suffix, $personnel_table.degree, $project_members_table.comment";

  if($g->{uid} eq $tuid){

    $sth=$g->{dbh}->prepare(
      "select $member_query_fields from $project_members_table
       left join $projects_table on $project_members_table.scopeid=$projects_table.scopeid
       left join $personnel_table on $project_members_table.uid=$personnel_table.uid
       where $project_members_table.uid=\"$g->{uid}\" $filter
       order by $project_members_table.scopeid"
    ); $sth->execute();

    my $count=0;
    while(($scopeid,$irbnumber,$projecttitle,$uid,$role,$lastname,$firstname,$middle,$suffix,$degree,$comment)=$sth->fetchrow_array()){
        my $temp_irbnumber=""; my $temp_comment="";
        if($irbnumber eq ""){$temp_irbnumber="None";}else{$temp_irbnumber=$irbnumber;}
        if($comment eq ""){$temp_comment="None";}else{$temp_comment=$comment;}

      print $g->{CGI}->div({-id=>"record"},
        $g->{CGI}->p(
          "DIFR Scope ID:",$g->{CGI}->b("$scopeid"),
          "IRB/IACUC/MIRB Number:",$g->{CGI}->b("$temp_irbnumber"),
          $g->{CGI}->br(),$g->{CGI}->br(),
          "Project Title:",$g->{CGI}->b("$projecttitle"),
        ),
      	$g->{CGI}->div({-id=>"fancyrecord"},
        	$g->{CGI}->ul(
        		$g->{CGI}->li(
        			$g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
          		$g->{CGI}->label({-for=>"irole"},"Role:"),
          		$g->{CGI}->popup_menu({-name=>"irole",-value=>@role_list,-default=>"$role",-override=>1}),
          		$g->{CGI}->submit("Set"),
          		$g->{CGI}->br(),
          		$g->{CGI}->label({-for=>"icomment"},"Comment"),
							$g->{CGI}->textarea({-name=>"icomment",-value=>$comment,-cols=>60,-rows=>3,-override=>1}),
          		$g->{CGI}->hidden({-name=>"iuid",-value=>"$g->{uid}",-override=>1}),
          		$g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>1}),
          		$g->{CGI}->hidden({-name=>"action",-value=>"modify_role",-override=>1}),
          		$g->{CGI}->hidden({-name=>"scopeid",-value=>"$scopeid"}),
        			$g->{CGI}->end_form(),
						), # end li
					), # end ul
      	), # end fancyrecord
      	$g->{CGI}->center(
      		$g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&scopeid=$scopeid&uid=$g->{uid}"},"Edit Project"),
      		"&nbsp;&#149;&nbsp;",
      		#$g->{CGI}->a({-href=>"$g->{scriptname}?action=delete&scopeid=$scopeid&uid=$g->{uid}"},"Delete Project"),
      		#"&nbsp;&#149;&nbsp;",
      		$g->{CGI}->a({-href=>"$g->{scriptname}?action=remove&scopeid=$scopeid&uid=$g->{uid}"},"Remove Employee From Project"),
				),
      );



        $count++;
    }
    if($count==0){
      if($g->{uid} ne '' and $g->{uid} ne '0'){
        print qq(<div id="record">This employee is not currently assigned to any projects.</div>\n);
      }
      else{
        print qq(<div id="record">There are no records matching this criteria.</div>\n);
      }
    }
  }
  else{
    print qq(<div id="record>This employee is not involved in any research projects.</div>\n);
  }
}

sub editor{

  my $project_query_fields="scopeid,uid,irbnumber,projecttitle,description,pi,received,status";
  if($g->{action} eq "new"){$g->{action}="add"; $title="Adding";}
  else{$g->{action}="update"; $title="Editing";
    ($scopeid,$uid,$irbnumber,$projecttitle,$description,$pi,$received,$status)=
    $g->{dbh}->selectrow_array("select $query_fields from $projects_table where scopeid like $g->{scopeid}");
  }
  if($g->{uid} ne "" and $g->{uid} ne "0"){
    my $tuid=$g->{dbh}->selectrow_array("select uid from $project_members_table where uid='$g->{uid}'");
    print qq(<div id="navlinks">\n);
    print $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}"},"Back To Personnel Record");
    #if($tuid ne ''){print $g->{CGI}->a({-href=>"$g->{scriptname}?action=investigators&method=projects&uid=$g->{uid}"},"Other Projects");}
    print qq(</div> <!-- end navlinks -->\n);
    ($lastname,$firstname,$middle,$suffix,$degree)=$g->{dbh}->selectrow_array("select lastname,firstname,middle,suffix,degree from $personnel_table where uid='$g->{uid}'");
    my $extratext; if($g->{action} eq "add"){$extratext="for: $lastname, $firstname $middle $suffix $degree";}
    print $g->{CGI}->h3("$title Project $extratext");
  }
  else{
    print $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?action=projects#$scopeid"},"Back"),
    ),
    $g->{CGI}->h3("$title Project"),
  }

  #print qq(\n<div id="page_effect">\n);

  print $g->{CGI}->div({-id=>"record"},
    $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
    $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>1}),
    $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}"},-override=>1),
    $g->{CGI}->hidden({-name=>"name",-value=>"$g->{name}"}),
    $g->{CGI}->hidden({-name=>"scopeid",-value=>"$scopeid"}),
	  ("\nDIFR Scope ID: \n"),$g->{CGI}->b("$scopeid"),
	  $g->{CGI}->br(),
	  $g->{CGI}->submit("Save"),
	  $g->{CGI}->br(),
	#),
	#$g->{CGI}->div({-id=>"record"},
	  $g->{CGI}->p(
	    $g->{CGI}->br(),
	    $g->{CGI}->label({-for=>"irbnumber"},"IRB/IACUC/MIRB Number:"),
	    $g->{CGI}->textfield({-name=>"irbnumber",-value=>"$irbnumber",-size=>'15',-override=>1}),
    $g->{CGI}->label({-for=>"received"},"Received:"),
    $g->{CGI}->textfield({-id=>"datepicker1",-name=>"received", -value=>"$received",-size=>"11",-override=>"1",-title=>"YYYY-MM-DD"}),
    $g->{CGI}->label({-for=>"status"},"Project Status"),
    $g->{CGI}->popup_menu({-name=>"status", -size=>"1", -default=>"$status", -value=>@projectstatuses, -override=>"1",-title=>"Select Project Status"}),
	  ),
	  $g->{CGI}->label({-for=>"projecttitle"},"Project Title"),$g->{CGI}->br(),
	  $g->{CGI}->textarea({-name=>"projecttitle",-value=>"$projecttitle",-cols=>'60',-rows=>'3',-override=>1}),
    $g->{CGI}->br(),
	  $g->{CGI}->label({-for=>"description"},"Project Description"),$g->{CGI}->br(),
	  $g->{CGI}->textarea({-name=>"description",-value=>"$description",-cols=>'60',-rows=>'3',-override=>1}),
	  $g->{CGI}->hidden({-name=>"pi",-value=>"$pi"}),
    $g->{CGI}->br(),
    $g->{CGI}->br(),
    $g->{CGI}->end_form(),
  );

  # add additional project members (if the project has already been saved)
  if($scopeid ne ""){
    # replaced double query with single linked query - 20100901
    my $query="select rcs_project_members.scopeid,rcs_project_members.uid,rcs_project_members.role,rcs_project_members.comment,
               rcs_personnel.lastname,rcs_personnel.firstname,rcs_personnel.middle,rcs_personnel.suffix,rcs_personnel.degree,rcs_personnel.suspended
               from rcs_project_members left join rcs_personnel on rcs_project_members.uid=rcs_personnel.uid
               where rcs_project_members.scopeid='$g->{scopeid}'
               order by
               field($project_members_table.role, 'Primary Investigator', 'Co-Primary Investigator', 'Co-Investigator','Research Coordinator', 'Staff', 'Other'),
               rcs_personnel.lastname,rcs_personnel.firstname,rcs_personnel.middle,rcs_personnel.suffix";

    print qq(\n    <div id="record">\n),
    $g->{CGI}->b("&nbsp;&nbsp;Project Staff"),
    $g->{CGI}->br(),
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=add_member&scopeid=$g->{scopeid}&uid=$g->{uid}"},"Add A Project Member"),
    $g->{CGI}->br(),
    $g->{CGI}->br();

    $sth=$g->{dbh}->prepare("$query"); $sth->execute();

    # poll investigator table for members that are assigned to a project by irbnumber
    while(my($iscopeid,$iuid,$irole,$icomment,$ilast,$ifirst,$imiddle,$isuffix,$idegree,$isuspended)=$sth->fetchrow_array()){
      my $removefromprojecttext='Remove from this Project';
      my $istatus='Active';
      if($isuspended eq 'I'){$istatus="<font style='color: orange'>Inactive</font>";}
      if($istatus eq 'S'){$istatus="<font style='color: red'>Suspended</font>";}
      if($istatus eq 'P'){$istatus="<font style='color: orange'>Pending</font>";}
      if($irole eq "Primary Investigator"){$removefromprojecttext='';}
      print $g->{CGI}->div({-id=>"fancyrecord"},
        $g->{CGI}->ul(
          $g->{CGI}->li(
            $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}"}),
          	$g->{CGI}->label({-for=>"irole"},"$ilast, $ifirst $imiddle $isuffix $idegree [$istatus]"),
          	$g->{CGI}->popup_menu({-name=>"irole",-value=>@role_list,-default=>"$irole",-override=>1}),
          	$g->{CGI}->submit("Set"),
        	$g->{CGI}->a({-href=>"$g->{scriptname}?action=view&uid=$iuid"},"View This Members Other Projects"),
        	"&nbsp;&#149;&nbsp;",
		$g->{CGI}->a({-href=>"$g->{scriptname}?action=remove_member&scopeid=$g->{scopeid}&uid=$g->{uid}&iuid=$iuid&ilast=$ilast&ifirst=$ifirst&imiddle=$imiddle&isuffix=$isuffix&idegree=$idegree"},"$removefromprojecttext"),
        	$g->{CGI}->br(),
        	$g->{CGI}->label({-for=>"icomment"},"Comment"),
		$g->{CGI}->textarea({-name=>"icomment",-value=>$icomment,-cols=>60,-rows=>3,-override=>1}),
        	$g->{CGI}->hidden({-name=>"iuid",-value=>"$iuid",-override=>1}),
        	$g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>1}),
        	$g->{CGI}->hidden({-name=>"action",-value=>"modify_role",-override=>1}),
        	$g->{CGI}->hidden({-name=>"scopeid",-value=>"$scopeid"}),
            $g->{CGI}->end_form(),
	  ),
      	),
	$g->{CGI}->br(),
	$g->{CGI}->br(),
      );
    }
  }
}

sub add_member{
  my $project_name=$g->{dbh}->selectrow_array("select projecttitle from $projects_table where scopeid=\"$g->{scopeid}\"");
  my $query_personnel_fields="uid,lastname,firstname,middle,suffix,degree,workphone,workext,email,suspended";
  if($g->{uid} ne ""){
    print
    $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?action=view&scopeid=$g->{scopeid}&uid=$g->{uid}"},"Return to Project<br />"),
    );
  }
  else{
    print
    $g->{CGI}->div({-id=>"navlinks"},
      $g->{CGI}->a({-href=>"$g->{scriptname}?action=projects"},"Return to Projects<br />"),
    );
  }
  print $g->{CGI}->h4("Select an employee to add to <em>this</em> project (DIFR Scope ID: $g->{scopeid})");

  search();

  #print qq(\n<div id="page_effect">\n);

  if($g->{action} eq "list"){
    # list query by matching ^$g->{letter}
    $sth=$g->{dbh}->prepare("select $query_personnel_fields from $personnel_table where lastname like \"$g->{letter}%\" order by lastname"); $sth->execute();
  }
  elsif($g->{action} eq "query"){ # list records =~ $g->{query} [lastname|firstname|ssn]
    $sth=$g->{dbh}->prepare("select $query_personnel_fields from $personnel_table where (lastname like \"$g->{query}%\"
    or firstname like \"$g->{query}%\" or ssn like \"$g->{query}%\") order by lastname"); $sth->execute();
  }
  else{ # give full listing for people that use the scroll bar...
    $sth=$g->{dbh}->prepare("select $query_personnel_fields from $personnel_table order by lastname"); $sth->execute();
  }
  print qq(\n<div id="record">\n),#$g->{CGI}->div({-id=>"record"},
  $g->{CGI}->start_table({-cols=>"5",-cellspacing=>"1",-cellpadding=>"0",-border=>"0",-width=>"100%"}),
    $g->{CGI}->Tr({-align=>"left",-bgcolor=>"$g->{bgcolor}"},
      $g->{CGI}->th("Name"),
      $g->{CGI}->th("Status"),
      $g->{CGI}->th("Role"),
      $g->{CGI}->th("Comment"),
      $g->{CGI}->th({-width=>"120"},"Action"),
    );
  my $grey=1;
  while(my ($iuid,$ilast,$ifirst,$imiddle,$isuffix,$idegree,$workphone,$workext,$email,$suspended)=$sth->fetchrow_array()){
    my $suspendedview='';
    if($suspended eq 'A'){$suspendedview="Active";}
    elsif($suspended eq 'I'){$suspendedview="Inactive";}
    elsif($suspended eq 'P'){$suspendedview="Pending";}
    elsif($suspended eq 'S'){$suspendedview="Suspended";}
    my ($muid,$role)=$g->{dbh}->selectrow_array("select uid,role from $project_members_table where scopeid=\"$g->{scopeid}\" and uid=\"$iuid\"");

    if($grey eq "1"){$grey=0; print qq(\n<Tr class="odd">\n);}
    else{$grey=1; print qq(\n<Tr class="even">\n);}
      print $g->{CGI}->td(
        $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$iuid",-title=>"Go to this users Personnel Record"},
          "$ilast, $ifirst $imiddle $isuffix $idegree",
        ),
      ),
      $g->{CGI}->td("$suspendedview");

      print
      qq(<td>
          <form action="$g->{scriptname}" method="get">
            <input type="hidden" name="action" value="insert_member">
            <input type="hidden" name="uid" value="$g->{uid}">
            <input type="hidden" name="scopeid" value="$g->{scopeid}">
            <input type="hidden" name="iuid" value="$iuid">
            <input type="hidden" name="ilast" value="$ilast">
            <input type="hidden" name="ifirst" value="$ifirst">
            <input type="hidden" name="imiddle" value="$imiddle">
            <input type="hidden" name="isuffix" value="$isuffix">
            <input type="hidden" name="idegree" value="$idegree">
        );

        my $button_text="Add"; if($role ne ""){$button_text="Modify";}
        my @project_roles=["Select...","Primary Investigator","Co-Primary Investigator","Co-Investigator","Research Coordinator","Staff","Other"];
        print $g->{CGI}->popup_menu({-name=>"irole", -size=>"1", -default=>"$role", -value=>@project_roles, -override=>"1",-title=>"Select Role"}),
        qq(</td>\n
        <td>
            <input type="textfield" size="30" name="comment" value="$comment">
        </td>
        <td>
            <input type="submit" value="$button_text">
          </form>
          );
        if($role ne ""){
          print $g->{CGI}->div({-id=>"fauxbutton"},
            $g->{CGI}->a({-href=>"$g->{scriptname}?action=remove_member&uid=$g->{uid}&scopeid=$g->{scopeid}&iuid=$iuid&ilast=$ilast&ifirst=$ifirst&imiddle=$imiddle&isuffix=$isuffix&idegree=$idegree"},
              "Remove",
            ),
          );
        }
        print qq(</td>\n);
    "</Tr>";
  }
  print $g->{CGI}->end_table();
  print qq(</div> <!-- end record -->\n);
}

# TABS -------------------------------------------
sub tabs{

  my $selected='selected';
  my $featureselected="featureselected";
  if(not defined($g->{action})){$g->{action}='investigators';}
  my $investigatorsselected=''; if($g->{action} eq 'investigators'){$investigatorsselected=$selected;}
  my $membersselected='';  if($g->{action} eq 'members'){$membersselected=$selected;}
  my $projectsselected=''; if($g->{action} eq 'projects'){$projectsselected=$selected;}
  my $inactiveselected=''; if($g->{action} eq 'projects' and $g->{filter} eq 'inactive'){$inactiveselected=$featureselected;}

  print $g->{CGI}->div({-id=>"horizontalmenu"},
    $g->{CGI}->ul({-id=>"horizontalmenu"},
      $g->{CGI}->li({-id=>"$projectsselected"},$g->{CGI}->span($g->{CGI}->a({-class=>"$projectsselected",-href=>"$g->{scriptname}?action=projects"},"Projects"),),),
      $g->{CGI}->li({-id=>"$membersselected"},$g->{CGI}->span($g->{CGI}->a({-class=>"$membersselected",-href=>"$g->{scriptname}?action=members"},"Members"),),),
      $g->{CGI}->li({-id=>"$investigatorsselected"},$g->{CGI}->span($g->{CGI}->a({-class=>"$investigatorsselected",-href=>"$g->{scriptname}?action=investigators"},"Investigators"),),),
    ),
  );
}

# 					SEARCH
#
sub search{
  my $status_filter="A"; my $status_filter_text="";
  my $linkref="$g->{scriptname}?action=list&irbnumber=$g->{irbnumber}&uid=$g->{uid}";
  if($g->{scopeid} ne ""){$linkref.="&scopeid=$g->{scopeid}";}
  if($g->{status_filter} eq ""){$g->{status_filter}="A";}
  if($g->{status_filter} eq "I"){$status_filter="A"; $status_filter_text="Hide";}
  if($g->{status_filter} eq "A"){$status_filter="I"; $status_filter_text="Show";}

  print qq(\n<div id="search">\n),
    $g->{CGI}->span(
      $g->{CGI}->span(
        $g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
          $g->{CGI}->textfield({-size=>"60",-name=>"query",-value=>"$g->{query}",-override=>"1"}),
          $g->{CGI}->hidden({-name=>"action",-value=>"query",-override=>"1"}),
          $g->{CGI}->hidden({-name=>"status_filter",-value=>"I",-override=>"1"}),
          $g->{CGI}->submit("Search"),
        $g->{CGI}->end_form,
        $g->{CGI}->a({-class=>"floatright",-href=>"$g->{scriptname}?action=view&status_filter=$status_filter"},"$status_filter_text Inactive"),
      ),
    );
  alpha();
  print qq(\n</div> <!-- end search -->\n);

  sub alpha{
    my $alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    print "\t<span>\n",
    "\t\t\t",$g->{CGI}->a({-href=>"$g->{scriptname}?action=list"},"View All&nbsp;"),
    "list last names: \n";
    for(my $digit="0"; $digit<26; ++$digit){
      my $letter=substr($alpha,$digit,1);
      if(defined($g->{letter}) and $g->{letter} eq "$letter"){
        print $g->{CGI}->a({-class=>"selected",-href=>"$linkref&letter=$letter"},"$letter&nbsp");
      }
      else{print $g->{CGI}->a({-href=>"$linkref&letter=$letter"},"$letter&nbsp");}
    }
    print "\n\t\n\t</span>\n";
  }
}

sub analytics{
  print qq(\n<div id="analytics">\n);
  my $total_projects=$g->analytic('Total Projects','',"*",'','rcs_scopeofwork','','');
  my $projectsActive=$g->analytic('Active Projects','',"*",'','rcs_scopeofwork',"where status='active'","percentage:$total_projects");
  my $projectsClosed=$g->analytic('Closed Projects','',"*",'','rcs_scopeofwork',"where status='closed'","percentage:$total_projects");
  print qq(\n</div> <!-- end analytics -->\n);
}

sub analytics_pi{
}
