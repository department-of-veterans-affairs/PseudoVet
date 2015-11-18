#!/usr/bin/perl

# If you don't know the code, don't mess around below 0.0.03 -bciv

print qq(\n<div id="page_effect">\n);

# controller
my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'view',
  "default_function"=>'record_view',
  "function"=>{
    "add"=>'record_add',
    "edit"=>'record_edit',
    "delete"=>'record_delete',
    "view_subtype"=>'subtype_view'
  },
); &$function;

1;

#            VIEW_SUBTYPE    ***************************************************
sub subtype_view{
	my $actionname=$g->tc($g->{action}.'ing');
	$g->submenu('Alpha');

	print $g->{CGI}->div({-id=>"navlinks"},
		$g->{CGI}->a({-href=>"$g->{scriptname}?type=$g->{type}"},'Cancel Viewing '.$g->tc($g->{subtype}).' Subtype'),
	),
	$g->{CGI}->br(),$g->{CGI}->h3($g->tc($g->{type}).'::'.$g->tc($g->{subtype}));

  $g->table_list('difr_'.$g->{subtype},'id',"source_id=\"$g->{id}\"");
}

#            RECORDADD       ***************************************************
sub record_add{
	my $actionname=$g->tc($g->{action}.'ing');
	my $actiontitle=$actionname;

	# submenu
	$g->submenu('Alpha');

	print $g->{CGI}->div({-id=>"navlinks"},
		$g->{CGI}->a({-href=>"$g->{scriptname}?type=$g->{type}"},"Cancel $actionname ".$g->tc($g->{type})),
	),
	$g->{CGI}->br(),$g->{CGI}->h3($g->tc($g->{type}));

  # $g->{type} contains the type of DIFR resource: sources, elements, etc...
  # need to create a table and form for modifying record contents generically
  # $g->{id} is passed for manipulation

  # generate a hash as input to set the individual form parameters and value options, if needed
  my %form; my @values;

  #my $options=''; my $element=''; my $set='';
  # if type is 'logic' pull base (element_id=0) types to send as option to crudedit_table
  if($g->{type} eq 'logic'){
    my $base_types=$g->{dbh}->selectcol_arrayref("select type from difr_logic order by type");
    foreach $type (@{$base_types}){$form{type}{value}{$type}='';}
    $form{type}{type}='popup_menu';
    $form{type}{size}='1';
  }

  $g->record_add('difr_'.$g->{type},'id',%form,'');
  #if($g->{confirm} eq 'true'){
  #  view();
  #}
}

#            RECORDDELETE       ***************************************************
sub record_delete{
  my($ref)=@_;
  my $actionname='Deleting';
  my $actiontitle='Deleting';
  my $fields=$g->fields('difr_'.$g->{type});
  my @fields=$g->array(',',$fields);

	$g->submenu('Alpha');

	# navlinks & title
	if(not defined($g->{type}) or $g->{type} eq ""){
	  print $g->{CGI}->br(),$g->{CGI}->h3($g->tc("Select an Alpha Type Above"));
	}
	else{
	  print $g->{CGI}->div({-id=>"navlinks"},
		  $g->{CGI}->a({-href=>"$g->{scriptname}"},"Cancel $actionname Record"),
	  ),
	  $g->{CGI}->br(),$g->{CGI}->h3($g->tc($g->{type}));
	}
}

#            RECORDVIEW       ***************************************************
sub record_view{
	my $actionname='Viewing';
	my $actiontitle='Viewing';
	# submenu
	$g->submenu('Alpha');

	# navlinks & title
	if(not defined($g->{type}) or $g->{type} eq ""){
	  print $g->{CGI}->br(),$g->{CGI}->h3($g->tc("Select an Alpha Type Above"));
	}
	else{
	  print $g->{CGI}->div({-id=>"navlinks"},
		  $g->{CGI}->a({-href=>"$g->{scriptname}"},"Cancel $actionname ".$g->tc($g->{type})),
		  $g->{CGI}->a({-href=>"$g->{scriptname}?type=$g->{type}&action=add"},"Add ".$g->tc($g->{type})),
	  ),
	  $g->{CGI}->br(),$g->{CGI}->h3($g->tc($g->{type}));
	}

  if(not defined($g->{type}) or $g->{type} eq ''){}
  else{
    # make sure that the table exists
  	my $table=$g->{dbh}->selectrow_array("show tables where Tables_in_difr28 regexp '^difr_$g->{type}'");
    #my @tables=$g->{dbh}->fetchcol_arrayref("show tables");
    #foreach $table (@tables){print "<!-- table: $table -->\n";}
    print "<!-- table: $table -->\n";
    if($table eq 'difr_'.$g->{type}){print "<!-- table $table exists... -->\n";
      my $query_fields=$g->fields('difr_'.$g->{type});
      $g->table_list('difr_'.$g->{type},'id',"");
    }
    else{
      print $g->{CGI}->h3("Table, difr_$g->{type}, does not exist.");
      # create a table
      #print $g->{CGI}->start_form({-action=>"$g->scriptname",-method=>"GET"}),
      #$g->hidden({-name=>"table_name",-value=>"difr_$g->{type}"});
    }
  }
}

#            RECORDEDIT       ***************************************************
sub record_edit{
	my $actionname=$g->tc($g->{action}.'ing');
	my $actiontitle=$actionname;

	# submenu
	$g->submenu('Alpha');

	print $g->{CGI}->div({-id=>"navlinks"},
		$g->{CGI}->a({-href=>"$g->{scriptname}?type=$g->{type}"},"Cancel $actionname ".$g->tc($g->{type})),
	),
	$g->{CGI}->div({-id=>"title"},$g->{CGI}->h3($g->tc($g->{type})),);

	print $g->{CGI}->div({-id=>"subtitle"},"&nbsp;");

	print qq(\n<div id="main">\n);
  # $g->{type} contains the type of DIFR resource: sources, elements, etc...
  # need to create a table and form for modifying record contents generically
  # $g->{id} is passed for manipulation

  # generate a hash as input to set the individual form parameters and value options, if needed
  my %form; my @values;

  #my $options=''; my $element=''; my $set='';
  # if type is 'logic' pull base (element_id=0) types to send as option to crudedit_table
  if($g->{type} eq 'logic'){
    my $base_types=$g->{dbh}->selectcol_arrayref("select type from difr_logic order by type");
    foreach $type (@{$base_types}){$form{type}{value}{$type}='';}
    $form{type}{type}='popup_menu';
    $form{type}{size}='1';
  }

  $g->record_edit('difr_'.$g->{type},'id',%form,'');

  print qq(\n</div> <!-- end main -->\n);
}
