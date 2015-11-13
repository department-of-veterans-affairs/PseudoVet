#!/usr/bin/perl
# exclusion types module for DIFR by BCIV
# If you don't know the code, don't mess around below -bciv

my $exclusionary_lists_table="rcs_exclusionary_lists";
my $exclusionary_data_table="rcs_exclusionary_data";

$g->system_menu("Facilities"=>"facilities",
                "Exclusionary Lists"=>"exclusionary","Training"=>"training",
                "License Types"=>"licenses","Overview"=>"overview"); # "Alert Settings"=>"alerts",

my $function=$g->controller(
  "key"=>'function',
  "default_key"=>'overview',
  "default_function"=>'view',
  "function"=>{
    "facilities"=>'facilities',
    "alerts"=>'alerts',
    "exclusionary"=>'exclusionary',
    "training"=>'training',
    "training_groups"=>'training_groups',
    "overview"=>'view',
    "licenses"=>'licenses',
  },
); &$function;
1; # end module

sub view{
  print
  qq(<div id="page_effect" style="display:none;">\n),
  $g->{CGI}->br(),$g->{CGI}->br(),
  $g->{CGI}->h4({-align=>"center"},"Select a Settings Function");
  print qq(<p>By default show a list of tasks that need to be completed here.<br />
  If you click on a task it will show the trail of comments including images audio etc...<br />
  There are types of tasks - make 'type' table that will work for a multitude of types of types<br />
  groups of tasks<br />
  groups of individuals that perform tasks<br />
  groups of individuals that assign tasks<br />
  groups of individuals that oversee and approve, reject, or reroute tasks within groups<br />
  tasks are assigned to groups<br />
  task groups have metadata features<br />

  difr_objects {i.e., suites, sources, modules, controllers, types, menus, groups, owners,
  users, assignees, tasks, employees, licenses, training, alerts, analytics, notifications, whatever...}
  objects can have relations {i.e., parents, children, siblings} siblings mean there is a shared object key...
  objects can have groups of children which could also be other objects
  all object have the following core features: a name, a description, a mother, a creator, a creation date
  the mother of a core difr object is difr.  So if there is not a real mother, difr is always the surrogate
  tasks taskid tasktype taskdescription taskowner taskgroup(nogroup by default) taskstatus taskstart taskend taskcomment
  </p>);
}

sub alerts{
  print $g->{CGI}->br(),$g->{CGI}->h3("Alert Notifications");
  if(defined($g->{action})){
    if($g->{action} eq "view"){
      alert_view();
    }
    elsif($g->{action} eq 'edit'){
      alert_edit();
    }
  }
  else{
    alert_view();
  }

  sub alert_edit{
    print qq(<div id="page_effect" style="display:none;">\n);

  }
  sub alert_view{
    print qq(<div id="page_effect" style="display:none;">\n);
    my $tblalert='rcs_notification_alerts';
    my $tblreport='rcs_reports';



    my $query="select $tblalert.id,$tblalert.report_id,$tblreport.name,$tblalert.message,$tblalert.state from $tblalert
               left join $tblreport on $tblalert.report_id=$tblreport.id
               where type not like 'reports'";
    $sth=$g->{dbh}->prepare("$query"); $sth->execute();
    while(my ($id,$rid,$name,$message,$state)=$sth->fetchrow_array()){
      print $g->{CGI}->div({-id=>"record"},
        $g->{CGI}->h4("[$rid] $name state: $state"),
        $g->{CGI}->p("<b>This text is the body of the alert message:</b><br />$message"),
      );
    }
  }
}

sub exclusionary{
  unless(defined($g->{action})){ #view();
    exclusionary_lists();
    #training_types();
  }
  elsif($g->{action} eq "new_exclusionary_list_type" or $g->{action} eq "edit_exclusionary_list_type"){
    exclusionary_list_editor();
  }
  elsif($g->{action} eq "insert_exclusionary_list_type"){
    $g->{dbh}->do("insert into $exclusionary_lists_table values('0',\"$g->{name}\",\"$g->{auth}\",\"$g->{url}\")");
    my($num)=$g->{dbh}->selectrow_array("select id from $exclusionary_lists_table where name=\"$g->{name}\"");
    $g->{dbh}->do("alter table $exclusionary_data_table add ex_$num char(1) null default \"f\"");
    exclusionary_lists();
  }
  elsif($g->{action} eq "update_exclusionary_list_type"){
    $sth=$g->{dbh}->do("update $exclusionary_lists_table set name=\"$g->{name}\",authority=\"$g->{auth}\",url=\"$g->{url}\" where id=\"$g->{id}\"");
    exclusionary_lists();
  }
  elsif($g->{action} eq "delete_exclusionary_list_type"){
    $g->{dbh}->do("delete from $exclusionary_lists_table where id=\"$g->{id}\"");
    $g->{dbh}->do("alter table $exclusionary_data_table drop ex\_$g->{id}");
    exclusionary_lists();
  }
  elsif($g->{action} eq "view_exclusionary_lists"){exclusionary_lists();}
}

sub exclusionary_lists{
  unless(defined($g->{order})){$g->{order}='name';}
  my $alternative='authority'; my $ordertitle;
  if($g->{order} eq 'authority'){$alternative='name';}
  else{$g->{order}='name';}
  my $ordertitle=ucfirst($g->{order});
  my $alternativetitle=ucfirst($alternative);

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=exclusionary&action=new_exclusionary_list_type"},"Add New Exclusionary List Type"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=exclusionary&order=$alternative"},"Sort By $alternativetitle"),
  ),
  $g->{CGI}->h3("Exclusionary List Types");

  print qq(\n<div id="page_effect" style="display:none;">\n);

  $sth=$g->{dbh}->prepare("select id,name,authority,url from $exclusionary_lists_table order by `$g->{order}`"); $sth->execute();
  while(my($id,$name,$auth,$url)=$sth->fetchrow_array()){
    print
    $g->{CGI}->div({-id=>"record"},
    	$g->{CGI}->a({-href=>"$url"},"$name ( $auth )"),
    	$g->{CGI}->div({-id=>"floatright"},
        $g->{CGI}->a({-href=>"$g->{scriptname}?function=exclusionary&action=edit_exclusionary_list_type&id=$id&name=$name&auth=$auth&url=$url"},"edit"),"&nbsp;&#149;&nbsp;",
        $g->{CGI}->a({-href=>"$g->{scriptname}?function=exclusionary&action=delete_exclusionary_list_type&id=$id&name=$name&auth=$auth"},"delete"),
      ),
      $g->{CGI}->br(),
      $g->{CGI}->br(),

    );
  }
}
sub exclusionary_list_editor{
  my $title;
  #print $g->{CGI}->div({-id=>"subnavlink"},$g->{CGI}->a({-href=>"$g->{scriptname}?tab=a"},"Back to Settings"),);

  my($name,$auth,$url);
  if($g->{action} eq "new_exclusionary_list_type"){$g->{action}="insert_exclusionary_list_type"; $title="Adding New Exclusionary List Type";}
  elsif($g->{action} eq "edit_exclusionary_list_type"){
    ($name,$auth,$url)=
      $g->{dbh}->selectrow_array("select name,authority,url from $exclusionary_lists_table where id=\"$g->{id}\"");
    $g->{action}="update_exclusionary_list"; $title="Editing \"$name\" Exclusionary List Type";
  }

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=exclusionary"},"Back To Exclusionary Lists"),
    #$g->{CGI}->a({-href=>"$g->{scriptname}?tab=a&order=$alternative"},"Sort By $alternativetitle"),
  ),
  $g->{CGI}->h3("$title");

  print qq(\n<div id="page_effect" style="display:none;">\n);


  print qq(
    <fieldset>
    <form action="$g->{scriptname}" method="get">
      <div id="floatright"><input type="submit" value="Save"></div>
      <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      Do NOT use <em>spaces</em> in Exclusionary List Name</em><br />
      <input type="hidden" name="id" value="$g->{id}">
      <input type="hidden" name="function" value="exclusionary">
      <input type="hidden" name="action" value="$g->{action}">
      <label for="name">List Name</label>
      <input type="textfield" name="name" value="$name" size="60" override="1" title="Don't use spaces">
      <br />
      <label for="auth">&nbsp;&nbsp;Authority</label>
      <input type="textfield" name="auth" value="$auth" size="60" override="1">
      <br />
      <label for="url">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;URL</label>
      <input type="textfield" name="url" value="$url" size="60" override="1">
    </form>\n</fieldset>);
}

sub training{
  if(defined($g->{action}) and $g->{action} eq 'view'){training_types();}
  elsif($g->{action} eq "new_training_type" or $g->{action} eq "edit_training_type"){training_type_editor();}
  elsif($g->{action} eq "insert_training_type"){
    $sth=$g->{dbh}->do("insert into rcs_trainingtypes values('0',\"$g->{name}\",\"$g->{desc}\",\"$g->{duration}\",\"$g->{template}\",\"$g->{optional}\")");
    # each rcs_trainingrequired entry is associated with an employee...
    # add a rcs_trainingrequired entry for the new training for every employee
    print "\n<!-- inserting training: $g->{name} -->\n";
	my $p=$g->{dbh}->selectcol_arrayref("select uid from rcs_personnel");
	my $optional='required'; if($g->{optional} eq 'true'){$optional='true';}
	foreach $uid(@{$p}){
	  $g->{dbh}->do("insert into rcs_trainingrequired values($uid,'$g->{name}','$optional','0000-00-00')");
	}
    $g->event("settings","added training: '$g->{name}'");
    print $g->{CGI}->h4("Added '$g->{name}' Training");

    training_types();
  }
  elsif($g->{action} eq "update_training_type"){
    my ($oldname,$oldoptional)=$g->{dbh}->selectrow_array("select name,optional from rcs_trainingtypes where tid=$g->{tid}");
    $sth=$g->{dbh}->do("update rcs_trainingtypes set
                        name=\"$g->{name}\", descr=\"$g->{desc}\", duration=\"$g->{duration}\",
                        template=\"$g->{template}\", optional=\"$g->{optional}\"
                        where tid=\"$g->{tid}\"");

    # if name of training has changed, rename all training records having the old name to reflect the new name
    if($g->{name} ne $oldname){
      $g->{dbh}->do("update rcs_trainingrequired set trainingtype='$g->{name}' where trainingname='$oldname'");
      $g->event('settings',"renaming $oldname training to $g->{name} training");
    }

    if($g->{optional} ne $oldoptional){
      if($g->{optional} eq 'true'){
        # set all training records for this type of training to the value 'true' ~this makes it optional but is set to show in notifications
        $g->{dbh}->do("update rcs_trainingrequired set optional='true' where trainingtype='$g->{name}'");
        $g->event('settings',"setting $g->{name} training to be optional");
      }
      elsif($g->{optional} eq 'false' or $g=>{optional} eq ''){
      	# set all training records for this type of training to the value 'mandatory' ~which makes it not optional
      	$g->{dbh}->do("update rcs_trainingrequired set optional='mandatory' where trainingtype='$g->{name}'");
      	$g->event('settings',"settings $g->{name} training to be mandatory");
      }
    }
    training_types();
  }
  elsif($g->{action} eq "delete_training_type"){
    if($g->{validation} eq 'false' or $g->{validation} eq ''){
	  print $g->{CGI}->h4("Are you sure you want to delete the $g->{name} $g->{desc} training?"),
	  $g->{CGI}->div({-id=>"record"},
	 	$g->{CGI}->p("If you delete training it will no longer be referenced within training notifications
	 				  and employees will not be notified if their training has expired."),
	 	$g->{CGI}->start_table({-cols=>2,-border=>0,-width=>"40%",-style=>"border: solid lightgray 0px;"}),
	 	$g->{CGI}->Tr(
	 		$g->{CGI}->td({-style=>"border: solid lightgray 0px;"},
	  			$g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
	  			$g->{CGI}->hidden({-name=>"tid",-value=>"$g->{tid}"}),
	  			$g->{CGI}->hidden({-name=>"validation",-value=>"true"}),
	  			$g->{CGI}->hidden({-name=>"action",-value=>"delete_training_type"}),
	  			$g->{CGI}->hidden({-name=>"function",-value=>"training"}),
	  			$g->{CGI}->submit("Delete"),
	  			$g->{CGI}->end_form(),
	  		),
	  		$g->{CGI}->td({-style=>"border: solid lightgray 0px;"},
	  			$g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
	  			$g->{CGI}->hidden({-name=>"function",-value=>"training"}),
	  			$g->{CGI}->submit("Cancel"),
	  			$g->{CGI}->end_form(),
	  		),
	  	),
	  	$g->{CGI}->end_table(),
	  );
	  }
	elsif($g->{validation} eq 'true'){
      #print "deleting $g->{tid} from rcs_trainingtypes and $g->{name} from training<br />";
      $sth=$g->{dbh}->do("delete from rcs_trainingtypes where tid=\"$g->{tid}\"");
      # deprecated call to defunct table
      #$sth=$g->{dbh}->do("alter table rcs_training drop $g->{name}");
      training_types();
    }
  }
  else{training_types();}
}
sub training_types{
  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=training&action=new_training_type"},"Add New Training"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=training_groups"},"Edit Training Groups"),
  );
  print $g->{CGI}->h3("Training");

  print qq(\n<div id="page_effect" style="display:none;">\n);

  $sth=$g->{dbh}->prepare("select tid,name,descr,duration,template,optional from rcs_trainingtypes order by template,name"); $sth->execute();
  my $temp_template=''; my $highlight='even'; my $count=0;
  while(my($tid,$name,$desc,$duration,$template,$optional)=$sth->fetchrow_array()){
	if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
    if($temp_template ne $template){
    	if($temp_template ne ''){print $g->{CGI}->end_table();}
    	print $g->{CGI}->h4("$template"),
    	$g->{CGI}->start_table({-cols=>4,-width=>"97%"}),
    	$g->{CGI}->Tr(
    		$g->{CGI}->th({-width=>"10%"},"Training Name"),$g->{CGI}->th({-width=>"60%"},"Description"),
    		$g->{CGI}->th({-width=>"10%"},"Group"),$g->{CGI}->th({-width=>"10%"},"Optional"),$g->{CGI}->th({-width=>"10%"},"Action"),
    	);
    	$highlight='odd';
    }

	print $g->{CGI}->Tr({-class=>"$highlight"},
	  $g->{CGI}->td("$name"),
	  $g->{CGI}->td("$desc"),
	  $g->{CGI}->td("$template"),
	  $g->{CGI}->td("$optional"),
	  $g->{CGI}->td(
      	$g->{CGI}->a({-href=>"$g->{scriptname}?function=training&action=edit_training_type&tid=$tid&name=$name"},"edit"),
        $g->{CGI}->a({-href=>"$g->{scriptname}?function=training&action=delete_training_type&tid=$tid&name=$name"},"delete"),
	  ),
	);
	$temp_template=$template; ++$count;
  }
  if($count > 0){print $g->{CGI}->end_table();}
  else{print $g->{CGI}->br(),$g->{CGI}->h4("There is no training configured on this system.");}
}
sub training_type_editor{
  my $title; my($tid,$name,$desc,$duration,$template,$optional);

  # get listing of existing training groups
  $sth=$g->{dbh}->prepare("select distinct(gkey) from rcs_groups where gtype='training' order by gkey"); $sth->execute();
  my @training_groups; while(my $group=$sth->fetchrow_array()){push(@training_groups,"$group");}

  if($g->{action} eq "new_training_type"){$g->{action}="insert_training_type"; $title="Adding New Training";}
  elsif($g->{action} eq "edit_training_type"){
    ($tid,$name,$desc,$duration,$template,$optional)=$g->{dbh}->selectrow_array("select tid,name,descr,duration,template,optional from rcs_trainingtypes where tid=\"$g->{tid}\"");
    $g->{action}="update_training_type"; $title="Editing \"$name\" Training";
  }

  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=training"},"Back To Training"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=training_groups"},"Edit Training Groups"),
  );

  print $g->{CGI}->h3("$title");

  print qq(\n<div id="page_effect" style="display:none;">\n);

  my %options=('false'=>'False','true'=>'True');

  print
  $g->{CGI}->div({-id=>"record"},
  	$g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
  	$g->{CGI}->hidden({-name=>"function",-value=>"training",-override=>"1"}),
  	$g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>"1"}),
  	$g->{CGI}->hidden({-name=>"tid",-value=>"$tid",-override=>"1"}),
  	$g->{CGI}->label({-for=>"name"},"Training Name"),
  	$g->{CGI}->textfield({-name=>"name",-value=>"$name",-override=>"1",-title=>"Don't use spaces"}),"<i>*short name with no spaces</i>",
  	$g->{CGI}->br(),
  	$g->{CGI}->label({-for=>"desc"},"Description<br />"),
  	$g->{CGI}->textarea({-name=>"desc",-value=>"$desc",-override=>"1",-cols=>"50"}),
  	$g->{CGI}->br(),
  	$g->{CGI}->label({-for=>"duration"},"Duration"),
  	$g->{CGI}->textfield({-name=>"duration",-value=>"$duration",-size=>"3",-override=>"1"})," <i>*months until training expiration</i>",
  	$g->{CGI}->br(),
  	$g->{CGI}->label({-for=>"template"},"Training Group"),
  	$g->{CGI}->popup_menu({-name=>"template",-value=>\@training_groups,-default=>"$template",-override=>"1"}),
  	$g->{CGI}->label({-for=>"optional"},"Optional"),
  	$g->{CGI}->popup_menu({-name=>"optional",-default=>"$optional",-values=>\%options,-override=>1}),
  	$g->{CGI}->br(),
  	$g->{CGI}->center(
  		$g->{CGI}->submit("Save"),
  	),
  	$g->{CGI}->end_form(),
  );
}

sub training_groups{
  print $g->{CGI}->div({-id=>"navlinks"},
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=training"},"Back to Training"),
  ),
  $g->{CGI}->br(),$g->{CGI}->h4("Training Groups");

  if($g->{action} eq 'update'){
    $g->{dbh}->do("update rcs_groups set gkey=\"$g->{newname}\" where gtype='training' and gkey like \"$g->{name}\"");
    #$g->{dbh}->do("update rcs_license set type=\"$g->{newname}\" where type=\"$g->{name}\"");
    $g->event("settings","renamed training group: '$g->{name}' to '$g->{newname}'");
    print $g->{CGI}->h4("Changed training group '$g->{name}' to '$g->{newname}'");
  }
  elsif($g->{action} eq 'delete'){
    if($g->{validation} eq 'false'){
      my $count=$g->{dbh}->selectrow_array(
        "select count(*) from rcs_trainingtypes where template='$g->{name}'");
      if($count==0){
        $g->{dbh}->do("delete from rcs_groups where gkey='$g->{name}'");
        $g->event("settings","deleted training group: '$g->{name}'");
        print $g->{CGI}->h4("No training types were in the '$g->{name}' group."),
              $g->{CGI}->p("The '$g->{name}' training group has been safely deleted from this system.");
      }
      else{
        my $count_message="There are ($count) training courses";
        if($count==1){$count_message="There is (1) training course";}
        print $g->{CGI}->h4("$count_message in the system having a training group of '$g->{name}'.");
        $sth=$g->{dbh}->prepare("select name,descr from rcs_trainingtypes where template='$g->{name}'"); $sth->execute();
        print qq(\n<p><center>\n);
        while(my($n,$d)=$sth->fetchrow_array()){print "\n$n - $d<br />";
        }print "\n</center></p>\n";

        print $g->{CGI}->p("<i>*Until all training types having this training group have a different group associated, '$g->{name}' cannot be deleted.</i>");
      }
    }
    else{
      $g->{dbh}->do("delete from rcs_trainingtypes where template='$g->{name}'");
      $g->{dbh}->do("delete from rcs_groups where gtype='training' and gkey='$g->{name}'");
      $g->event("settings","deleted training group: '$g->{name}'");
    }
  }
  elsif($g->{action} eq 'add'){
    # add check to make sure the record doesn't already exist...
    my ($name)=$g->{dbh}->selectrow_array("select gkey from rcs_groups where gtype='training' and gkey='$g->{newtype}'");
    if($name=~m/$g->{newtype}/i){
      print $g->{CGI}->h4("There is already a '$g->{newtype}' training group defined.");
      $g->event("settings","duplicate insertion attempted for training group: '$g->{newtype}'");
    }
    else{
      # each rcs_groups entry is associated with an employee...
      # add a rcs_groups entry for the new group for every employee
      print "\n<!-- inserting training group: $g->{newtype} -->\n";
	  my $p=$g->{dbh}->selectcol_arrayref("select uid from rcs_personnel");
	  foreach $uid(@{$p}){
	    #print "\n<!-- $uid -->\n";
	    $g->{dbh}->do("insert into rcs_groups values($uid,'training','$g->{newtype}','')");
	  }
      $g->event("settings","added training group: '$g->{newtype}'");
      print $g->{CGI}->h4("Added '$g->{newtype}' as a new Training Group.");
    }
  }

  print $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->start_form({-method=>'get',-action=>"$g->{scriptname}"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'function',-value=>'training_groups',-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'add',-override=>1}),
        $g->{CGI}->label({-for=>'newtype'},"New Training Group:"),
        $g->{CGI}->textfield({-name=>'newtype',-size=>50,-value=>"",-override=>1}),
        $g->{CGI}->submit("Add New Group"),
      $g->{CGI}->endform(),
      $g->{CGI}->br(),
  );

  # get listing of existing training groups
  $sth=$g->{dbh}->prepare("select distinct(gkey) from rcs_groups where gtype='training' order by gkey"); $sth->execute();
  my @training_groups; while(my $group=$sth->fetchrow_array()){push(@training_groups,"$group");}

  my $highlight='even';
  print $g->{CGI}->start_table({-cols=>2,-width=>"98%",-border=>0}),
  $g->{CGI}->Tr($g->{CGI}->th("Training Group"),$g->{CGI}->th("Action"));
  foreach my $group (sort @training_groups){
    if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
    print $g->{CGI}->Tr({-class=>"$highlight"},
      $g->{CGI}->td({-width=>"80%"},
        $g->{CGI}->start_form({-method=>'get',-action=>"$g->{scriptname}"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'function',-value=>'training_groups',-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'update',-override=>1}),
        $g->{CGI}->hidden({-name=>'name',-value=>"$group",-override=>1}),
        $g->{CGI}->textfield({-name=>'newname',-size=>50,-value=>"$group",-override=>1}),
      ),
      $g->{CGI}->td(
        $g->{CGI}->submit("Update"),
      $g->{CGI}->endform(),
        $g->{CGI}->start_form({-method=>'post',-action=>"$g->{scriptname}",-style=>"float: right;"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'validation',-value=>'false'}),
        $g->{CGI}->hidden({-name=>'function',-value=>'training_groups',-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'delete',-override=>1}),
        $g->{CGI}->hidden({-name=>'name',-value=>"$group",-override=>1}),
        $g->{CGI}->submit("Delete"),
        $g->{CGI}->endform(),
      ),
    );
  }
  print $g->{CGI}->end_table();
}


sub facilities{
  unless(defined($g->{action})){
    view_facilities();
  }
}
sub view_facilities{
  print $g->{CGI}->div({-id=>"navlinks"},
  	$g->{CGI}->a({-href=>"$g->{scriptname}?function=facilities&action=add"},"Add Facility"),
  );
  print $g->{CGI}->h3("Facility Editor");

  print qq(\n<div id="page_effect" style="display:none;">\n);

  my($id,$stationid,$name,$url,$workaddress1,$workaddress2,$city,$state,$zipcode,$mainphone);
  my $query_fields="id,stationid,name,url,workaddress1,workaddress2,city,state,zipcode,mainphone";
  my $table="rcs_facilities";
  $sth=$g->{dbh}->prepare("select $query_fields from $table"); $sth->execute();
  while(($id,$stationid,$name,$url,$workaddress1,$workaddress2,$city,$state,$zipcode,$mainphone)=$sth->fetchrow_array()){
    print $g->{CGI}->div({-id=>"record"},
      "Station ID:    ",$g->{CGI}->b("$stationid"),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
      "Facility Name: ",$g->{CGI}->b("$name"),
      $g->{CGI}->br(),$g->{CGI}->br(),
      $g->{CGI}->p("$workaddress1 $workaddress2<br />$city, $state $zipcode<br />Phone: $mainphone<br />"),
      $g->{CGI}->center(
        $g->{CGI}->a({-id=>"floatright",-href=>"$g->{scriptname}?function=facilities&action=edit"},"Edit"),
      ),
    );
  }
}

sub licenses{
  print $g->{CGI}->br(),$g->{CGI}->h4({-align=>"center"},"Editing License/Certificate Types");

  if($g->{action} eq 'update'){
    $g->{dbh}->do("update rcs_licensetypes set name=\"$g->{newname}\" where name like \"$g->{name}\"");
    $g->{dbh}->do("update rcs_license set type=\"$g->{newname}\" where type=\"$g->{name}\"");
    $g->event("license","renamed '$g->{name}' to '$g->{newname}'");
    print $g->{CGI}->h4("Changed '$g->{name}' to '$g->{newname}'");
  }
  elsif($g->{action} eq 'delete'){
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
        $g->{CGI}->hidden({-name=>'function',-value=>'licenses',-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'add',-override=>1}),
        $g->{CGI}->label({-for=>'newtype'},"New License/Certificate Type:"),
        $g->{CGI}->textfield({-name=>'newtype',-size=>50,-value=>"",-override=>1}),
        $g->{CGI}->submit("Add New Type"),
      $g->{CGI}->endform(),
      $g->{CGI}->br(),
  );

  $sth=$g->{dbh}->prepare("select name from rcs_licensetypes"); $sth->execute();
  my @license_types; while(my $type=$sth->fetchrow_array()){push(@license_types,"$type");}

  my $highlight='even';
  print $g->{CGI}->start_table({-cols=>2,-width=>"98%",-border=>0}),
  $g->{CGI}->Tr($g->{CGI}->th("License/Certificate Type"),$g->{CGI}->th("Action"));
  foreach my $type (sort @license_types){
    if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
    print $g->{CGI}->Tr({-class=>"$highlight"},
      $g->{CGI}->td({-width=>"80%"},
        $g->{CGI}->start_form({-method=>'get',-action=>"$g->{scriptname}"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'function',-value=>'licenses',-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'update',-override=>1}),
        $g->{CGI}->hidden({-name=>'name',-value=>"$type",-override=>1}),
        $g->{CGI}->textfield({-name=>'newname',-size=>50,-value=>"$type",-override=>1}),
      ),
      $g->{CGI}->td(
        $g->{CGI}->submit("Update"),
      $g->{CGI}->endform(),
        $g->{CGI}->start_form({-method=>'post',-action=>"$g->{scriptname}",-style=>"float: right;"}),
        $g->{CGI}->hidden({-name=>'uid',-value=>"$g->{uid}",-override=>1}),
        $g->{CGI}->hidden({-name=>'validation',-value=>'false'}),
        $g->{CGI}->hidden({-name=>'function',-value=>'licenses',-override=>1}),
        $g->{CGI}->hidden({-name=>'action',-value=>'delete',-override=>1}),
        $g->{CGI}->hidden({-name=>'name',-value=>"$type",-override=>1}),
        $g->{CGI}->submit("Delete"),
        $g->{CGI}->endform(),
      ),
    );
  }
  print $g->{CGI}->end_table();
}

