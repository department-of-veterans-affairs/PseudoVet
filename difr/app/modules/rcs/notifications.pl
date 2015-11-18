#!/usr/bin/perl
# Exclusionary List Expiration module for DIFR
# If you don't know the code, don't mess around below -bciv
use Time::localtime; my $tm=localtime; my $xhour;
my ($mday,$month,$year,$wday,$hour,$min,$sec)=
   ($tm->mday,$tm->mon+1,$tm->year+1900,$tm->wday,$tm->hour,$tm->min,$tm->sec);

my $expires=$year."-".$month."-".$mday;

my $personnel_table="rcs_personnel";
my $exclusionary_data_table="rcs_exclusionary_data";
my $license_table="rcs_license";
my $training_table="rcs_training";
my $trainingtypes_table="rcs_trainingtypes";

my $typetitle=$g->pretty($g->{type});

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'notification',
  'default_function'=>'notification',
  'function'=>{
    'add'=>'editor',
    'edit'=>'editor'
  }
); &$function;

1; # end module

#							NOTIFICATION				***************************************************
sub notification{
	$g->submenu('Notifications');
  if(defined($g->{type})){
  	print $g->{CGI}->div({-id=>"navlinks"},
  		$g->{CGI}->a({-href=>"$g->{scriptname}?action=add&type=$g->{type}"},"Create $typetitle Notification"),
  	);
  }
  print $g->{CGI}->h3("$typetitle Notifications");

  print qq(\n<div id="page_effect" style="none";>\n);
  if (defined($g->{type}) and $g->{type} ne ""){
  	$sth=$g->{dbh}->prepare("select id,name,description,type,query,querynotice,queryaction,fieldtitles,modifiedby,lastmod from rcs_reports where type='$g->{type}' order by name");
  	$sth->execute();

  	while(my($id,$name,$description,$type,$query,$querynotice,$queryaction,$fieldtitles,$modifiedby,$lastmod)=$sth->fetchrow_array()){
  	  # get actions from queryaction field
  	  # print qq(\n\n<!-- begin queryactions defined -->\n); print "<!-- $queryaction -->\n";
  	  my %a; my @actions=split(/\,/,$queryaction);
  	  foreach $ac (@actions){
  	    my ($actiontype,$actiondata)=split(/\-/,$ac); #print qq(\n<!-- $actiontype=$actiondata -->);
  	    $a{$actiontype}=$actiondata;
  	  } #print qq(\n\n<!-- end queryactions defined -->\n);

  	  print $g->{CGI}->br(),$g->{CGI}->start_table({-cols=>"3",-width=>"99%"}),
  	  $g->{CGI}->Tr({-class=>"header"},
  	    $g->{CGI}->td({-colspan=>"3"},$g->{CGI}->h4("$name - $description (last modified: $modifiedby $lastmod)")),
  	  ),
  	  $g->{CGI}->Tr($g->{CGI}->th("Name"),$g->{CGI}->th("Notification"),$g->{CGI}->th("Action"),);

 	  	$ssth=$g->{dbh}->prepare("$query"); $ssth->execute(); my $num=0; my $highlight='even';
 	  	while(my $r=$ssth->fetchrow_hashref()){
				if (defined($a{linkfields}) and $a{linkfields} ne ""){
          if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
				  my @linkfields=split(/\^/,$a{linkfields}); my $newquerynotice='';
				   if (defined($a{link}) and $a{link} ne ""){ # link is printed first...
				    my $linktext; foreach $field (@linkfields){ if($field eq "[comma]"){$linktext.=", ";}else{$linktext.=" $r->{$field}";} }
				    my $link=$a{link};
		        print qq(\n<tr class="$highlight">\n),
		        $g->{CGI}->td({-class=>"$highlight"},$g->{CGI}->a({-href=>"$a{linktarget}&$a{link}=$r->{$link}"},"$linktext"));

				    my @tags=split(/\[/,$querynotice); my $i=0; #print "<!-- $querynotice -->\n";
				    foreach my $tag (@tags){ my $extra;
              if($tag=~m/\]/){
                $tag=~s/\]//; ($tag,$extra)=split(/\s/,$tag); $tag=~s/\s//g;
                $newquerynotice.=" $r->{$tag}";
                if($extra ne ""){$newquerynotice.=" $extra";}
              } #print "<!-- tag: '$tag' -->\n";
				      if($i==0){$newquerynotice="$tag";}
              ++$i;
				    }
				  }

		      print $g->{CGI}->td({-class=>"$highlight"},"$newquerynotice "),
		      qq(<td class="$highlight"> \n);

		      if(defined($a{detaillink}) and $a{detaillink} ne ""){
				    my $detaillink=$a{detaillink};
				    print $g->{CGI}->a({-href=>"$a{detaillinktarget}&$a{detaillink}=$r->{$detaillink}"},"edit");
				  }
				  ++$num;
				  print qq(\n</td>\n</tr>\n);
				}
				else{
				  print $g->{CGI}->Tr({-class=>'odd'},$g->{CGI}->td({-colspan=>"3"},"A 'queryaction order' is not defined for this record data."));
				}
  	  }
  	  if($num eq 0){
  	    print $g->{CGI}->Tr({-class=>'odd'},$g->{CGI}->td({-colspan=>"3"},"No Employees meet this criteria"));
  	  }
  	  print $g->{CGI}->end_table();
  	}
  }
  else{
    print $g->{CGI}->br(),$g->{CGI}->br(),
    $g->{CGI}->h4({-align=>"center"},"Select a notification type (above) to view."); 
  }
}


#							EDITOR				***************************************************
sub editor{
	my $actionname='Adding New';
	my $actiontitle='Creating A New';

	# set up auto title and variables for passing into form
	if($g->{action} eq 'edit'){$actionname='Editing'; $actiontitle='Editing Existing';}

	$g->submenu('Notifications');

	# navlinks
	print	$g->{CGI}->div({-id=>"navlinks"},
		$g->{CGI}->a({-href=>"$g->{scriptname}?type=$g->{type}"},"Cancel $actionname $typetitle Notification"),
	);
  print qq(\n<div id="page_effect">\n);
	# title
	if(not defined($g->{step}) or $g->{step} eq '0'){$g->{step}='1';}
	print $g->{CGI}->div({-id=>"title"},
		$g->{CGI}->h3("$actiontitle $typetitle Notification :: Step $g->{step}"),
	);

	# main div
	# print $g->{CGI}->div({-id=>"subtitle"},"&nbsp;"); -bciv 20101208
	#print qq(\n<div id="main">\n);
	#if($g->{step} eq '1'){ #										Select Table
  require "$g->{modpath}/rcs/notifications-wizard.pl";
	#	# retrieve list of tables that can be selected in a notification (rcs tables only)
	#	my $query="select id,source_id,parent_id,element_name,prettyname,description from difr_elements
	#	           where source_id=1 and parent_id IS NULL and element_name not like 'rcs_reports'";
	#	$sth=$g->{dbh}->prepare($query); $sth->execute(); my %table;
	#	print qq(<!-- Explain Tables and pack them into a hash for use by table -->\n);
	#	print $g->{CGI}->h2("Select one or more tables");
	#	while(my $t=$sth->fetchrow_hashref()){
	#		print $g->{CGI}->p({-class=>"notice"},"<b>$t->{prettyname}</b> - $t->{description}");
	#	  $table{$t->{id}}=$t->{prettyname};
	#	}
	#	print $g->{CGI}->hr(),$g->{CGI}->p("<i><b>Note:</b> By default a second and third table is not selected.",
	#	      "Only select additional tables if you have to create a complex query that uses information from multiple tables.",
	#	      "<b>You will most likely need to have the Personnel Table selected because you will need user information.</b></i>");
	#	my %next_table=%table; $next_table{0}="None";
	#	# editor form
	#	print $g->{CGI}->div({-id=>"record"},
	#		$g->{CGI}->br(),
	#		$g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
	#		$g->{CGI}->hidden({-name=>"action",-value=>"add",-override=>1}),
	#		$g->{CGI}->hidden({-name=>"type",-value=>"$g->{type}"}),
	#		$g->{CGI}->hidden({-name=>"step",-value=>"2",-override=>1}),
  #  	$g->{CGI}->label({-for=>"table1"},"First"),
  #  	$g->{CGI}->popup_menu({-name=>"table1",-default=>"3",-size=>"1",-value=>\%table,-override=>1}),
  #  	$g->{CGI}->label({-for=>"table2"},"Second"),
  #  	$g->{CGI}->popup_menu({-name=>"table2",-default=>"0",-size=>"1",-value=>\%next_table,-override=>1}),
  #  	$g->{CGI}->label({-for=>"table3"},"Third"),
  #  	$g->{CGI}->popup_menu({-name=>"table3",-default=>"0",-size=>"1",-value=>\%next_table,-override=>1}),
  #  	$g->{CGI}->label({-for=>"table4"},"Forth"),
  #  	$g->{CGI}->popup_menu({-name=>"table4",-default=>"0",-size=>"1",-value=>\%next_table,-override=>1}),
  #  	$g->{CGI}->br(), $g->{CGI}->br(),
  #  	$g->{CGI}->center(
  #  	  $g->{CGI}->b("To continue building this $typetitle Notification click "),
  #  		$g->{CGI}->submit({-name=>"Next"}),
  #  	),
	#		$g->{CGI}->end_form(),
	#		$g->{CGI}->br(),
	#	);
	#}
	#elsif($g->{step} eq '2'){ #										Select Fields
	#	# table1:retrive list of fields in selected table that can be selected to show in a notification
	#	#my $query="select id,prettyname,description from difr_elements where parent_id=$g->{table1}";
	#	#$sth=$g->{dbh}->prepare("$query"); $sth->execute(); my %field;
  #  print $g->{CGI}->h3("Select elements to show as well as common elements that each table shares {i.e., 'User ID'}");
	#	# add fields to difr_elements table that references parent_id table
	#	print $g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
	#	$g->{CGI}->hidden({-name=>"action",-value=>"add",-override=>1}),
	#	$g->{CGI}->hidden({-name=>"type",-value=>"$g->{type}"}),
	#	$g->{CGI}->hidden({-name=>"step",-value=>"3",-override=>1}),
	#	$g->{CGI}->hidden({-name=>"table1",-value=>"$g->{table1}"}),
	#	$g->{CGI}->hidden({-name=>"table2",-value=>"$g->{table2}"}),
	#	$g->{CGI}->hidden({-name=>"table3",-value=>"$g->{table3}"}),
	#	$g->{CGI}->hidden({-name=>"table4",-value=>"$g->{table4}"});
  #
	#	# iterate through fields and populate checkboxes with descriptions from each table
	#	fieldcheckbox($g->{table1},'table1_');
	#	fieldcheckbox($g->{table2},'table2_');
	#	fieldcheckbox($g->{table3},'table3_');
	#	fieldcheckbox($g->{table4},'table4_');
  #
	#	print $g->{CGI}->div({-id=>"record"},
  #  	$g->{CGI}->br(), $g->{CGI}->br(),
  #  	$g->{CGI}->center(
  #  	  $g->{CGI}->b("To continue building this $typetitle Notification click "),
  #  		$g->{CGI}->submit({-name=>"Next"}),
  #  	),
	#		$g->{CGI}->end_form(),
	#		$g->{CGI}->br(),
	#	);
  #
	#}
	#elsif($g->{step} eq '3'){ #				Confirm Fields and build select portion of notification SQL
  #
	#	# show user what table fields will be included in the notification
	#	print $g->{CGI}->h3("The following fields will be shown in this notification once it's creation has been completed:");
  #  print qq(\n<div id="record">\n);
  #  # use input to this step to construct the select clause and table joins of this notification
  #  ## get all CGI parameters from Interface object substantiated by DIFR as %g
  #  my @p=$g->{CGI}->param(); foreach $var(@p){$g->{$var}=$g->{CGI}->param($var);}
  #  my %table; my $primary_table; my $secondary_table; my $tertiary_table; my $quardriary_table;
  #  my $ptable_id; my $stable_id; my $ttable_id; my $qtable_id;
  #  my $select_fields=''; my @primary; my @secondary; my $link_element=''; my $new_query="select ";
  #
  #  my $table_name; my $pretty_table_name;
  #  my $table_1; my $table_2; my $table_3; my $table_4;
  #  my $table_1_prettyname; my $table_2_prettyname; my $table_3_prettyname; my $table_4prettyname;
  #  foreach $parameter (@p){
  #    if ($parameter=~/^table\d+$/ and $g->{$parameter} ne '0'){ # if the parameter is a table
  #      # identify what table is primary, secondary, etc...
  #      ($table_name,$pretty_table_name)=$g->{dbh}->selectrow_array("select element_name,prettyname from difr_elements where id=".$g->{$parameter});
  #
	#			# pack primary, secondary, tertiary, and quadriary table names and element_id's into hash
  #      if(substr($parameter,-1,1)==1){
  #        $table{$table_name}{order}='primary';
  #        $table{$table_name}{id}=substr($parameter,-1,1); $ptable_id=$g->{$parameter};
  #        $primary_table=$table_name; $table_1=$table_name; $table_1_prettyname=$pretty_table_name;
  #        #print "primary $table_name from parameter $parameter $primary_table='$g->{$parameter}'";
  #      }
  #      elsif(substr($parameter,-1,1)==2){
  #        $table{$table_name}{order}='secondary';
  #        $table{$table_name}{id}=substr($parameter,-1,1); $stable_id=$g->{$parameter};
  #        $secondary_table=$table_name; $table_2=$table_name; $table_2_prettyname=$pretty_table_name;
  #        #print "secondary $table_name from parameter $parameter $primary_table='$g->{$parameter}'";
  #      }
  #      elsif(substr($parameter,-1,1)==3){
  #        $table{$table_name}{order}='tertiary';
  #        $table{$table_name}{id}=substr($parameter,-1,1); $ttable_id=$g->{$parameter};
  #        $tertiary_table=$table_name; $table_3=$table_name; $table_3_prettyname=$pretty_table_name;
  #        #print "tertiary $table_name from parameter $parameter $primary_table='$g->{$parameter}'";
  #      }
  #      elsif(substr($parameter,-1,1)==2){
  #        $table{$table_name}{order}='quadriary';
  #        $table{$table_name}{id}=substr($parameter,-1,1); $qtable_id=$g->{$parameter};
  #        $quadriary_table=$table_name; $table_4=$table_name; $table_4_prettyname=$pretty_table_name;
  #        #print "quadriary $table_name from parameter $parameter $primary_table='$g->{$parameter}'";
  #      }
  #    }
  #    elsif($parameter=~m/^table\d\_/){ # if the parameter is a table element
	#		  # pack table elements into hash %table under each respective table
  #      my $element_id=$parameter; $element_id=~s/^table\d\_\_//;
  #      my $table_descriptor=substr($parameter,5,1);
  #      my $table_name; $ptable_name;
  #      if($table_descriptor eq '1'){$table_name=$table_1; $ptable_name=$table_1_prettyname;}
  #      elsif($table_descriptor eq '2'){$table_name=$table_2; $ptable_name=$table_2_prettyname;}
  #      elsif($table_descriptor eq '3'){$table_name=$table_3; $ptable_name=$table_3_prettyname;}
  #      elsif($table_descriptor eq '4'){$table_name=$table_4; $ptable_name=$table_4_prettyname;}
  #      my $element_query="select element_name,prettyname from difr_elements where id=$element_id";
  #      my ($element_name,$pretty_element_name)=$g->{dbh}->selectrow_array("$element_query");
	#			$table{$table_name}{elements}{$element_name}=$pretty_element_name;
	#			print $g->{CGI}->p("&nbsp;&#149;&nbsp;<b>$pretty_element_name</b> field from <b>$ptable_name</b> table");
  #    }
  #  }
  #  print qq(\n<br /></div>\n);
  #
  #    if ((keys %table) eq "2"){ move down below table elements into hast %table...
  #
	#		# pack table elements into hash %table under each respective table
  #  foreach $table (keys %table){
  #    # pack elements into an array respective to the table order
  #    foreach $element (keys %{$table{$table}{elements}}){ # print "$element<br />\n";
  #      $select_fields.="$table\.$element, ";
  #      if($table{$table}{order} eq 'primary'){push @primary,"$element";}
  #      if($table{$table}{order} eq 'secondary'){push @secondary,"$element";}
  #      if($table{$table}{order} eq 'tertiary'){push @tertiary,"$element";}
  #      if($table{$table}{order} eq 'quadriary'){push @quadriary,"$element";}
  #    }
  #  }
  #
  #  if ((keys %table) eq "2"){
  #    # find common fields for use in table join
  #    my @common_fields; foreach $pe (@primary){
  #      foreach $se (@secondary){
  #        if($pe eq $se){
  #          push @common_fields, $pe; $link_element=$se;
  #          #print "$pe matches $se and will be used to link tables.<br />\n";
  #        }
  #    } }
  #  }
  #  elsif ((keys %table) eq "3"){
  #    # find common fields for use in 3 way table joins
  #    my @common_fields; foreach $pe (@primary){
  #      foreach $se (@secondary){
  #        if($pe eq $se){
  #          push @common_fields, $pe; $link_element=$se;
  #        }
  #    } }
  #
  #    # this is where I am 20100824 ... absolutely need to be able to link 3 or 4 tables so build
  #    # the logic to do this tonight.  Also need to strip out the id or scopeid from the select
  #    # portion of a query.
  #
  #  }
  #  else{
  #  	print $g->{CGI}->h3("This version of DIFR only allows users to link 3 tables.
  #  	                     The DIFR Version 3.0 Release will allow you to link more than 2 tables.");
  #  }
  #
  #  # set $link_element variable if there is a match of common fields
  #  if(@common_fields==1){$link_element=$common_fields[0];}
  #
  #  if($link_element ne ''){
  #    my $lepname=$g->{dbh}->selectrow_array("select prettyname from difr_elements where element_name=\"$link_element\" limit 1");
  #
	#			# START: strip common_field out of $select_fields string
	#			#
	#			# todo: write code that does this
	#			#
	#			# END: strip common_field out of $select_fields string
  #      $select_fields=~s/\,\s+$//;
  #
  #    print $g->{CGI}->h3("DIFR Source linking information:"),
  #    $g->{CGI}->div({-id=>"record"},
  #    	$g->{CGI}->p("The <b>$lepname</b> element will be used to link the <b>$table_1_prettyname</b> table with the <b>$table_2_prettyname</b> table."),
  #    );
  #
	#		# build select portion insert query
  #    my $payload="select $select_fields from $primary_table left join $secondary_table on $primary_table.$link_element=$secondary_table.$link_element";
  #    #print "$payload<br />";
  #
  #    # Insert select portion of notification and retrieve it's id
	#																									#id,name,description,type,query,querynotice,queryaction,fieldtitles,modifiedby,lastmod
	#		my $insert="insert into rcs_reports values (0,'','','$g->{type}','$payload','','','','$g->{sys_username}',now())";
  #    #print "\n $insert <br />\n";
  #    $sth=$g->{dbh}->prepare($insert); $sth->execute() or die();
  #    my $nid=$g->{dbh}->{'mysql_insertid'}; #print "id: $id<br />\n";
  #
  #    print $g->{CGI}->h3("Name and Describe New Notification");
  #    # need a button to move along to the next step passing tables and id of new notification
	#		print $g->{CGI}->div({-id=>"record"},
  #  		$g->{CGI}->br(), $g->{CGI}->br(),
  #  		$g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
  #  			$g->{CGI}->hidden({-name=>"type",-value=>"$g->{type}"}),
	#		  	$g->{CGI}->hidden({-name=>"action",-value=>"add",-override=>1}),
	#				$g->{CGI}->hidden({-name=>"step",-value=>"4",-override=>1}),
	#				$g->{CGI}->hidden({-name=>"primary",-value=>"$primary_table"}),
	#				$g->{CGI}->hidden({-name=>"secondary",-value=>"$secondary_table"}),
	#				$g->{CGI}->hidden({-name=>"tertiary",-value=>"$tertiary_table"}),
	#				$g->{CGI}->hidden({-name=>"quadriary",-value=>"$quadriary_table"}),
	#				$g->{CGI}->hidden({-name=>"primaryid",-value=>"$ptable_id"}),
	#				$g->{CGI}->hidden({-name=>"secondaryid",-value=>"$stable_id"}),
	#				$g->{CGI}->hidden({-name=>"tertiaryid",-value=>"$ttable_id"}),
	#				$g->{CGI}->hidden({-name=>"quadriaryid",-value=>"$qtable_id"}),
  #  	 		$g->{CGI}->hidden({-name=>"nid",-value=>"$nid"}),
  #  	 		# add name and description text entry here...
  #  	# ),
  #  	# $g->{CGI}->({-div=>"record"},
  #  	   $g->{CGI}->label({-for=>"name"},"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Name of Notification:"),
  #  	 	 $g->{CGI}->textfield({-name=>"name",-value=>"Credentialing - ",-size=>"100",-override=>1}),
  #  	 	 $g->{CGI}->br(),
  #  	 	 $g->{CGI}->label({-for=>"description"},"Description of Notification:"),
  #  	 	 $g->{CGI}->textfield({-name=>"description",-value=>"",-size=>"100",-override=>1}),
  #  		 $g->{CGI}->center(
  #  	 			$g->{CGI}->b("To continue building this $typetitle Notification click "),
  #  				$g->{CGI}->submit({-name=>"Next"}),
	#			 ),
	#		 $g->{CGI}->end_form(),
	#		 $g->{CGI}->br(),
	#		);
  #
  #  }
  #  else{
  #  	print $g->{CGI}->h3("No Common Field for linking selected"),
  #   	$g->{CGI}->p("You will need to hit your browsers 'back' button and check 'User ID' for each
  #   	              table used to create this notification");
  #  }
  #
	#}
	#elsif($g->{step} eq '4'){#								Select Constraints
	#  # append name and description to notification
	#  $g->{dbh}->do("update rcs_reports set name=\"$g->{name}\", description=\"$g->{description}\" where id='$g->{nid}'");
  #
  #  print $g->{CGI}->h3("Constraints"),
  #  $g->{CGI}->p("Check elements that are needed to constrain the results of the notification.
  #                In the textfield, type the data that must be present to generate output.");
  #
	#	# retrieve query 'nid' from previous step
	#	my $query=$g->{dbh}->selectrow_array("select query from rcs_reports where id=$g->{nid}") or die();
  #  if ($query eq ''){
  #    print $g->{CGI}->h3("An error occurred.  No query was saved in the previous step.  Hit the back button and try again.  If you receive this error again contact: support@etherfeat.com");
  #    return;
  #  }
  #
  #  # generate hash containing constraints
  #  my %constraints; my @conval;
  #  $sth=$g->{dbh}->prepare("select id,name,description,operator from difr_constraints"); $sth->execute();
  #  my $default;
  #  while(my $c=$sth->fetchrow_hashref()){
  #    if($default ne 'set'){$constraints{0}="Not Set"; $default='set'; push @conval, '0';}
  #    push @conval, $c->{id};
  #    $constraints{$c->{id}}=$c->{name};
  #    $constraints{$c->{id}}{description}=$c->{description};
  #    $constraints{$c->{id}}{operator}=$c->{operator};
  #  }
  #
  #  # present user with a form with list of table fields to chose for building the where of the
  #  # notifications query
  #  print	$g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"});
  #
  #  print qq(\n<div id='record'>\n);
  #  if(defined($g->{primary}) and $g->{primary} ne ''){
  #  	$sth=$g->{dbh}->prepare("select id,element_name,prettyname,description from difr_elements where parent_id='$g->{primaryid}'"); $sth->execute();
  #  	while(my($id,$ename,$pname,$description)=$sth->fetchrow_array()){
  #    	print $g->{CGI}->p({-class=>""},
	#	    	"<b>$pname</b> - $description<br />",
  #      	$g->{CGI}->checkbox({-name=>"chk$id",-value=>'yes',-selected=>0,-label=>"",-override=>1}),
  #      	$g->{CGI}->hidden({-name=>"fname$id",-value=>"$g->{primary}.$ename",-override=>1}),
  #  	  	$g->{CGI}->popup_menu({-name=>"con$id",-default=>$conval[0],-values=>\%constraints,-override=>1}),
  #  	  	$g->{CGI}->textfield({-name=>"val$id",-value=>"",-size=>"50",-override=>1}),
  #    	);
  #  	}
  #  }
  #  if(defined($g->{secondary}) and $g->{secondary} ne ''){
  #  	$sth=$g->{dbh}->prepare("select id,element_name,prettyname,description from difr_elements where parent_id='$g->{secondaryid}'"); $sth->execute();
  #  	while(my($id,$ename,$pname,$description)=$sth->fetchrow_array()){
  #    	print $g->{CGI}->p({-class=>""},
	#	    	"<b>$pname</b> - $description<br />",
	#	    	$g->{CGI}->checkbox({-name=>"chk$id",-value=>'yes',-selected=>0,-label=>"",-override=>1}),
  #      	$g->{CGI}->hidden({-name=>"fname$id",-value=>"$g->{secondary}.$ename",-override=>1}),
  #  	  	$g->{CGI}->popup_menu({-name=>"con$id",-default=>$conval[0],-values=>\%constraints,-override=>1}),
  #  	  	$g->{CGI}->textfield({-name=>"val$id",-value=>"",-size=>"50",-override=>1}),
  #    	);
  #  	}
  #  }
  #  if(defined($g->{tertiary}) and $g->{tertiary} ne ''){
  #  	$sth=$g->{dbh}->prepare("select id,element_name,prettyname,description from difr_elements where parent_id='$g->{tertiaryid}'"); $sth->execute();
  #  	while(my($id,$ename,$pname,$description)=$sth->fetchrow_array()){
  #    	print $g->{CGI}->p({-class=>""},
	#	    	"<b>$pname</b> - $description<br />",
	#	    	$g->{CGI}->checkbox({-name=>"chk$id",-value=>'yes',-selected=>0,-label=>"",-override=>1}),
  #      	$g->{CGI}->hidden({-name=>"fname$id",-value=>"$g->{tertiary}.$ename",-override=>1}),
  #  	  	$g->{CGI}->popup_menu({-name=>"con$id",-default=>$conval[0],-values=>\%constraints,-override=>1}),
  #  	  	$g->{CGI}->textfield({-name=>"val$id",-value=>"",-size=>"50",-override=>1}),
  #    	);
  #  	}
  #  }
  #  if(defined($g->{quadriary}) and $g->{quadriary} ne ''){
  #  	$sth=$g->{dbh}->prepare("select id,element_name,prettyname,description from difr_elements where parent_id='$g->{quadriaryid}'"); $sth->execute();
  #  	while(my($id,$ename,$pname,$description)=$sth->fetchrow_array()){
  #    	print $g->{CGI}->p({-class=>""},
	#	    	"<b>$pname</b> - $description<br />",
	#	    	$g->{CGI}->checkbox({-name=>"chk$id",-value=>'yes',-selected=>0,-label=>"",-override=>1}),
  #      	$g->{CGI}->hidden({-name=>"fname$id",-value=>"$g->{tertiary}.$ename",-override=>1}),
  #  	  	$g->{CGI}->popup_menu({-name=>"con$id",-default=>$conval[0],-values=>\%constraints,-override=>1}),
  #  	  	$g->{CGI}->textfield({-name=>"val$id",-value=>"",-size=>"50",-override=>1}),
  #    	);
  #  	}
  #  }
  #
  #  print qq(\n</div> <!-- end record -->\n);
  #
  #      # need a button to move along to the next step passing tables and id of new notification
	#	print $g->{CGI}->div({-id=>"record"},
  # 	$g->{CGI}->br(), $g->{CGI}->br(),
  #  	$g->{CGI}->hidden({-name=>"type",-value=>"$g->{type}"}),
	# 		$g->{CGI}->hidden({-name=>"action",-value=>"add",-override=>1}),
	#		$g->{CGI}->hidden({-name=>"step",-value=>"5",-override=>1}),
  #  	$g->{CGI}->hidden({-name=>"nid",-value=>"$g->{nid}"}),
  #  	$g->{CGI}->center(
  #  		$g->{CGI}->b("To continue building this $typetitle Notification click "),
  #  			$g->{CGI}->submit({-name=>"Next"}),
	#			),
	#		$g->{CGI}->end_form(),
	#		$g->{CGI}->br(),
	#	);
  #
	#}
	#elsif($g->{step} eq '5'){ #										Confirm Choices and with Sample
  #  my $where='where ';#
  #
	#	# retrieve query 'nid' from previous step
	#	my $query=$g->{dbh}->selectrow_array("select query from rcs_reports where id=$g->{nid}") or die();
  #  if ($query eq ''){
  #    print $g->{CGI}->h3("An error occurred.  No query was saved in the previous step.  Hit the back button and try again.  If you receive this error again contact: support@etherfeat.com");
  #    return;
  #  }
  #
  #  # generate hash containing constraints
  #  my %constraint; my @conval;
  #  $sth=$g->{dbh}->prepare("select id,name,description,operator from difr_constraints"); $sth->execute();
  #  my $default;
  #  while(my $c=$sth->fetchrow_hashref()){
  #    if($default ne 'set'){$constraint{0}="Not Set"; $default='set'; push @conval, '0';}
  #    push @conval, $c->{id};
  #    $constraint{$c->{id}}=$c->{name};
  #    $constraint{$c->{id}}{description}=$c->{description};
  #    $constraint{$c->{id}}{operator}=$c->{operator};
  #  }#
  #
  #  # use constraint selection from previous step to build query and test it
	#	print $g->{CGI}->h3("The following fields will be shown in this notification once it's creation has been completed:");
  #  print qq(\n<div id="record">\n);
  #  # use input to this step to construct the select clause and table joins of this notification
  #  ## get all CGI parameters from Interface object substantiated by DIFR as %g
  #  my @p=$g->{CGI}->param(); foreach $var(@p){$g->{$var}=$g->{CGI}->param($var);}
  #
  #  # iterate through chk values to retrieve minimal listing of variables to process
  #  foreach $parameter (@p){
  #    if ($parameter=~m/^chk\d+$/ and $g->{$parameter} eq 'yes'){
  #      # build each where clause object P V Q
  #      my $num=$parameter; $num=~s/chk//;
  #      my $operator=$constraint{$g->{"con$num"}}{operator};
  #      my $field=$g->{"fname$num"};
  #      my $value=$g->{"val$num"};
  #      if($operator =~m/\[table\].\[field\]/){
  #        my($start,$end)=split(/\[table\].\[field\]/,$operator);
  #        $operator ="$start".$g->{"fname$num"}."$end";
  #        $field='';
  #      }
  #      if($value ne ''){$value="'$value'";}
  #      print qq(\n$field $operator $value<br />\n);
  #      # chain the objects with 'and' ~further releases will allow the use of complex compound where clauses (v3.0)
  #      $where.="$field $operator $value and ";
  #    }
  #  }
  #  $where=~s/and\s+$//;
  #  print qq(\n</div> <!-- end record -->\n);
  #
  #  print qq(\n<div id="record">\n);
  #  print $g->{CGI}->h4("Sample Query");
  #  my $completed_query="$query $where";
  #  # print the completed query to the browser
  #  print "$completed_query<br />";
  #  # update notification query
  #  $sth=$g->{dbh}->prepare("update rcs_reports set query=\"$completed_query\" where id='$g->{nid}");
  #  $sth->execute();
  #    print qq(\n</div> <!-- end record -->\n);
  #
  #  # test output
  #  $sth=$g->{dbh}->prepare("$completed_query"); $sth->execute();
  #  my $i=0; my $col=0;
  #  while(my (@test)=$sth->fetchrow_array()){
  #    if($i eq '0'){$col=scalar @test;
  #      print qq(\n<table col=$col width=96%>\n);
  #    }
  #    print qq(  <tr>\n);
  #    foreach $el (@test){print qq(    <td>$el</td>\n);}
  #    print qq(  </tr>\n);
  #  }
  #  print qq(</table>\n);
  #
  #  # prompt user to enter field order
  #
  #  #prompt user to enter text to accompany query such as ....'s check for exclusionary data has expired....
  #  # notification text is the verbiage that appears next to a notification entry.  For example, if a report is retrieving
  #  # information the will show that 'Joe Blow's widget certification expired on 2010-09-01', the query text would need to be entered
  #  # as Widget Certification expired on [date]
  #  print $g->{CGI}->div({-id=>"record"},
  #  $g->{CGI}->p("The <b>Query Notice</b> is text that describes what a notification list item means.  For example,
  #                                  if a report is retrieving information that will show that an employee named 'Joe Blow' has a certificate for
  #                                  Widget Processing that expired on a specific date, the Query Notice should be entered as follows:"),
  #  $g->{CGI}->p({-style=>"center"},"Widget Processing Certification expired on [date:W3C]"),
  #  $g->{CGI}->p("The [date:W3C] tag will be populated by the field specified in W3C format."),
  #  $g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
  #    $g->{CGI}->hidden({-name=>"type",-value=>"$g->{type}"}),
	#	  $g->{CGI}->hidden({-name=>"action",-value=>"add",-override=>1}),
	#		$g->{CGI}->hidden({-name=>"step",-value=>"6",-override=>1}),
  #  	$g->{CGI}->hidden({-name=>"nid",-value=>"$g->{nid}"}),
  #    $g->{CGI}->label({-for=>""},""),
  #    $g->{CGI}->textfied({-name=>"",-value=>"",-override=>1,-size=>""}),
  #    $g->{CGI}->label({-for=>""},""),
  #    $g->{CGI}->textfied({-name=>"",-value=>"",-override=>1,-size=>""}),
  #  $g->{CGI}->end_form(),
  #  );
	#}
	#elsif($g->{step} eq '6'){ #										Generate Notification / Report
	#}
  #elsif($g->{step} eq '7'){
  #}
  ##print qq(\n</div> <!-- end main -->\n);
  #print qq(</div> <!-- end page_effect -->\n);
  #
	#sub fieldcheckbox{ # start fieldcheckbox ========================================================
	#  my($table,$tablename)=@_;
	#  if(defined($table) and $table ne '0'){
	#    my $tabletitle=$g->{dbh}->selectrow_array("select prettyname from difr_elements where id=$table");
	#  	my $query="select id,prettyname,description from difr_elements where parent_id=$table";
	#		$sth=$g->{dbh}->prepare("$query"); $sth->execute(); my %field;
	#		print $g->{CGI}->h2("Select fields to display from the $tabletitle table");
	#		while(my $f=$sth->fetchrow_hashref()){
	#			# element id of parent table...
	#	 		print $g->{CGI}->p({-class=>"notice"},
	#	  		$g->{CGI}->checkbox({-name=>"$tablename\_$f->{id}",-value=>'yes',
	#	  	  	-selected=>0,-label=>"$f->{prettyname} "}),"- $f->{description}",
	#	  	);
	#}	}	} # end fieldcheckbox subroutine ============================================================

}

