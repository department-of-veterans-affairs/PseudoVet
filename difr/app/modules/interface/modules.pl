#!/usr/bin/perl
my $script_title="Modules";

## top menu items
#if($g->{my_roles}=~m/add/){
#  print $g->{CGI}->a({-href=>"$g->{scriptname}?action=new"},"Add a new Module");
#}
#unless($g->{action} eq ""){
#  print "&nbsp;&#149;&nbsp;", $g->{CGI}->a({-href=>"$g->{scriptname}"},"Back");
#}
#print $g->{CGI}->h2({-align=>"center"},"$script_title");

print qq(\n<div id="page_effect">\n);

# run function for selected action
unless(defined($g->{action}) ){view();}
  elsif($g->{action} eq "assign"){access_editor();}
  elsif($g->{action} eq "modify_access"){modify_group_access();}
  elsif($g->{action} eq "new"){new();}
  elsif($g->{action} eq "add"){add();}
  elsif($g->{action} eq "edit"){edit();}
  elsif($g->{action} eq "properties"){properties();}
  elsif($g->{action} eq "update"){update();}
  elsif($g->{action}=~m/role/){roles();}
  elsif($g->{action}=~m/group/){groups();}
  elsif($g->{action} eq "delete"){del();}
  else{
    print $g->{CGI}->h2({-align=>"center"},
    "The action you have selected, $g->{action}, does not exist");
}

1; # end module

sub groups{
  print $g->{CGI}->h3({-align=>"center"},"groups for $g->{name} module");
  my $total_groups=$g->{dbh}->selectrow_array("select groups from interface_modules where name='$g->{name}'");
  if($v{action} eq "delete_group"){
    print "deleting '$g->{group}' group from $g->{name} module...<br />";
    $total_groups=~s/$g->{group}//;
    $total_groups=~s/\,\,/\,/;
    $total_groups=~s/^\,+//g; $total_groups=~s/\,+$//g;
    $g->{dbh}->do("update interface_modules set groups=\"$total_groups\" where name='$g->{name}'");
  }
  elsif($g->{action} eq "add_group"){
    # add group
    print "adding '$g->{group}' group to $g->{name} module...<br />";
    if($total_groups ne ""){$total_groups=$total_groups."\,";}
    $total_groups=$total_groups."$g->{group}";
    $g->{dbh}->do("update interface_modules set groups=\"$total_groups\" where name='$g->{name}'");
  }
  # print "&nbsp;&#149;&nbsp;",
  # $g->{CGI}->a({-href=>""},"add a new group");
  # print "roles: $total_groups<br />";
  my @total_groups=split(/\,/,$total_groups); my $bg=$g->{bgcolor};
  print $g->{CGI}->start_table({-cols=>"2",-align=>"center",-width=>"70%"}),
  $g->{CGI}->Tr({-style=>"background-color: $bg"},
    $g->{CGI}->th({-align=>"left"},"groups"),
    $g->{CGI}->th({-align=>"left"},"action"),
  );
  foreach $group(@total_groups){
    if($bg eq $v{bgcolor}){$bg="white";}elsif($bg eq "white"){$bg=$g->{bgcolor};}
    print $g->{CGI}->Tr({-style=>"background-color: $bg"},$g->{CGI}->td(
      "$group "),
      $g->{CGI}->td($g->{CGI}->a({-href=>"$g->{scriptname}?action=delete_group&group=$group&name=$g->{name}"},"delete"),
    ));
  }
  print $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}",-id=>"id"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"add_group",-override=>"1"}),
  $g->{CGI}->hidden({-name=>"name",-value=>"$g->{name}"}),
  $g->{CGI}->Tr(
    $g->{CGI}->td(
      $g->{CGI}->textfield({-name=>"group",-id=>"input-focus"}),
    ),
    $g->{CGI}->td(
      $g->{CGI}->submit("Add Group"),
    ),
  ),
  $g->{CGI}->end_table();
}

sub roles{
  print $g->{CGI}->h3({-align=>"center"},"roles for $g->{name} module");
  my $total_roles=$g->{dbh}->selectrow_array("select roles from interface_modules where name='$g->{name}'");
  if($v{action} eq "delete_role"){
    print "deleting '$g->{role}' role from $g->{name} module...<br />";
    $total_roles=~s/$g->{role}//;
    $total_roles=~s/\,\,/\,/;
    $total_roles=~s/^\,+//g; $total_roles=~s/\,+$//g;
    $g->{dbh}->do("update interface_modules set roles=\"$total_roles\" where name='$g->{name}'");
  }
  elsif($g->{action} eq "add_role"){
    # add role
    print "adding '$g->{role}' role to $g->{name} module...<br />";
    if($total_roles ne ""){$total_roles=$total_roles."\,";}
    $total_roles=$total_roles."$g->{role}";
    $g->{dbh}->do("update interface_modules set roles=\"$total_roles\" where name='$g->{name}'");
  }
  # print "&nbsp;&#149;&nbsp;",
  # $g->{CGI}->a({-href=>""},"add a new role");
  # print "roles: $total_roles<br />";
  my @total_roles=split(/\,/,$total_roles); my $bg=$g->{bgcolor};
  print $g->{CGI}->start_table({-cols=>"2",-align=>"center",-width=>"70%"}),
  $g->{CGI}->Tr({-style=>"background-color: $bg"},
    $g->{CGI}->th({-align=>"left"},"roles"),
    $g->{CGI}->th({-align=>"left"},"action"),
  );
  foreach $role(@total_roles){
    if($bg eq $g->{bgcolor}){$bg="white";}elsif($bg eq "white"){$bg=$g->{bgcolor};}
    print $g->{CGI}->Tr({-style=>"background-color: $bg"},$g->{CGI}->td(
      "$role "),
      $g->{CGI}->td($g->{CGI}->a({-href=>"$g->{scriptname}?action=delete_role&role=$role&name=$g->{name}"},"delete"),
    ));
  }
  print $g->{CGI}->start_form({-method=>"get",-action=>"$g->{scriptname}",-id=>"id"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"add_role",-override=>"1"}),
  $g->{CGI}->hidden({-name=>"name",-value=>"$g->{name}"}),
  $g->{CGI}->Tr(
    $g->{CGI}->td(
      $g->{CGI}->textfield({-name=>"role",-id=>"input-focus"}),
    ),
    $g->{CGI}->td(
      $g->{CGI}->submit("Add Role"),
    ),
  ),
  $g->{CGI}->end_table();
}

sub modify_group_access{
  $sth=$g->{dbh}->do("update interface_module_users set $g->{name}=\"false\"");
  print "<br />$g->{name} adding users: ";
  for $usertoadd (sort keys %v){
  if($usertoadd=~m/^u_/){
      $usertoadd=substr($usertoadd,2);
      print "$usertoadd ";
      # sql to add each iterated user to group
      $sth=$g->{dbh}->do("update interface_module_users set $g->{name}=\"true\" where username=\"$usertoadd\"");
    }
  }
  print "<br />";
  access_editor();
}

sub access_editor{
  $sth=$g->{dbh}->prepare("select username,lname,fname,mi,suffix,service from interface_users order by username"); $sth->execute();
  my $modtitle=$v{name}; $modtitle=~s/\_/ /; $modtitle=~s/\_/ /;
  print $g->{CGI}->h4("Checked users have access to the '$modtitle' module."),
  "<div style=\"top: 140; left: 0; width: 50%; height: 300px; overflow: scroll;\">",
  $g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"modify_access",-override=>"1"}),
  $g->{CGI}->hidden({-name=>"name",-value=>"$g->{name}",-override=>1}),
  $g->{CGI}->start_table({-align=>"right",-cols=>2,-cellspacing=>0,-cellpadding=>0,-border=>0,-width=>"100%"});
  my $grey=0;
  while(my($u,$last,$first,$mi,$suffix,$service)=$sth->fetchrow_array()){
    my $access=$g->{dbh}->selectrow_array("select $g->{name} from interface_module_users where username=\"$u\"");
    if($grey==0){print "<Tr bgcolor=\"#fff0ff\">"; ++$grey;}else{print "<Tr>"; --$grey;}
    if($access eq "true"){
      print
      $g->{CGI}->td({-width=>"20%"},"&nbsp;"),
      $g->{CGI}->td("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=checkbox name=\"u_$u\" checked>   ",
        $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=interface_users&action=edit&euname=$u"},"$last, $first $mi $suffix"),
      ); # $u"),
        # $g->{CGI}->td("&nbsp;$last, $first $mi $suffix"),
	# $g->{CGI}->td("$service");
    }
    else{
      print
      $g->{CGI}->td("&nbsp;"),
      $g->{CGI}->td("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=checkbox name=\"u_$u\" unchecked>   ",
        $g->{CGI}->a({-href=>"$g->{scriptname}?chmod=powernet_dev_users&action=edit&euname=$u"},"$last, $first $mi $suffix"),
      ); # $u"),
            # $g->{CGI}->td("&nbsp;$last, $first $mi $suffix"),
	    # $g->{CGI}->td("$service");
    }
    print "</Tr>\n";
  }
  print $g->{CGI}->end_table(),
  "&nbsp;<br /><br /><center>","</div>",
  "<div style=\"position: absolute; top: 140; left: 50%; width: 50%; padding-left: 4px; padding-right: 4px; height: 300px;\">",
  $g->{CGI}->h4({-align=>"left"},"To grant/deny user module access, select a user and then click the 'Update Access List' button."),
  $g->{CGI}->submit("Update Access List"),"</center>",
  $g->{CGI}->end_table(),$g->{CGI}->end_form(),
  "</div>";
  # print "<div style=\"position: absolute; top: 140; left: 50%; width: 50%; height: 300px;\">",
  # $g->{CGI}->h3({-align=>"center"},"To enter a specific user enter username here:"),
  # $g->{CGI}->start_table({-align=>"center",-cols=>1,-cellspacing=>0,-cellpadding=>0,-border=>1}),
  # $g->{CGI}->start_form({-method=>"post",-action=>"$v{scriptname}"}),
  # $g->{CGI}->hidden({-name=>"name",-value=>"$v{name}",-override=>1}),
  # $g->{CGI}->hidden({-name=>"action",-value=>"finduser"}),
  # $g->{CGI}->Tr($g->{CGI}->td(
  #  $g->{CGI}->textfield({-name=>"eusername",-value=>"$v{eusername}",-override=>"1"}),
  #  $g->{CGI}->submit("search"),
  #),),
  #$g->{CGI}->end_form(),
  #$g->{CGI}->end_table(),
  #"</div>";
}

sub add{
  print "adding $g->{name} $g->{title}<br />";
  my($grp,$scr)=split(/\_/,lc($g->{name}));
  unless(-d "modules/$grp"){
    print "creating path: modules/$grp<br />";
    mkdir "modules/$grp";
  }
  unless(-e "modules/$grp/$scr\.pl"){
    print "creating empty module: modules/$grp/$scr\.pl<br />";
    skeleton($grp,$scr);
  }
  else{
    print "I see your $scr\.pl already exists...<br />";
  }
  $g->{name}=lc($g->{name});
  $g->{dbh}->do("insert into interface_modules values('$g->{name}','$g->{title}',NULL,NULL)");
  $g->{dbh}->do("alter table interface_module_users add column $g->{name} varchar(50)");
  $g->{dbh}->do("update interface_module_users set $g->{name}='true' where username='$g->{sys_username}'");
  view();
}

sub update{
  # actually move module to it's new home...
  if($g->{name} ne $g->{oldname}){
    my ($grp,$opt,$scr)=split(/\_/,lc($g->{oldname}));
    if(-d "modules/$grp/$opt"){
      if(-e "modules/$grp/$opt/$scr\.pl"){
        print "modules/$grp/$opt/$scr\.pl exists...<br />";
        my($ngrp,$nopt,$nscr)=split(/\_/,lc($v{name}));
        system("mkdir modules/$ngrp/$nopt/");
        system("mv modules/$grp/$opt/$scr\.pl modules/$ngrp/$nopt/$nscr\.pl");
        if(-e "modules/$ngrp/$nopt/$nscr\.pl"){
          print "move to $ngrp/$nopt/$nscr successful! :)<br />";
        }
        else{
          print "moving $grp/$opt/$scr to $ngrp/$nopt/$nscr failed! :(<br />";
        }
      }else{print"modules/$grp/$opt/$scr doesn\'t exist...<br />";}
    }else{print"modules/$grp/$opt doesn\'t exist<br />";}
  }
  $g->{dbh}->do("alter table interface_module_users drop column $g->{oldname}");
  $g->{dbh}->do("delete from interface_modules where name=\"$g->{oldname}\"");
  add();
}

sub del{
  unless($g->{confirmation} eq "true"){
    $g->msg("Module Deletion Confirmation");
    print $g->{CGI}->p("Are you sure you want to delete the '<b><em>$g->{name}</em></b>' module?"),
    $g->{CGI}->br,
    $g->{CGI}->p("If you click 'Yes', the module will be expunged and will no longer be present on this system."),
    $g->{CGI}->br,
    $g->{CGI}->start_form(),
    $g->{CGI}->hidden({-name=>"action", -value=>"delete",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"confirmation", -value=>"true",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"name", -value=>"$g->{name}",-override=>"1"}),
    $g->{CGI}->h2({-align=>"center"},
      $g->{CGI}->submit("Delete '$g->{name}' module"),
      $g->{CGI}->button({-value=>"Cancel",-onClick=>"history.go(-2);"}),
    ),
    $g->{CGI}->end_form;
  }
  else{
    msg("Module Deletion Confirmed");
    my($grp,$scr)=split(/\_/,lc($g->{name}));
    msg("deleting modules/$grp/$scr\.pl...");
    system("rm modules/$grp/$scr\.pl");
    unless(-e "modules/$grp/$scr\.pl"){print "successful.";}
    else{print"failed.<br />";}
    $sth=$g->{dbh}->do("delete from interface_modules where name=\"$g->{name}\"");
    $sth=$g->{dbh}->do("alter table interface_module_users drop column $g->{name}");
    $sth=$g->{dbh}->do("delete from interface_module_access where module=\"$g->{name}\"");

    print $g->{CGI}->p("The '<b><em>$g->{name}</em></b>' module has been deleted from this system."),
    $g->{CGI}->br,
    $g->{CGI}->p("All of the associated database entries relating to this module have been expunged and it will no longer be available."),
    $g->{CGI}->h2({-align=>"center"},
      $g->{CGI}->button({-value=>"Continue",-onClick=>"location.href='$g->{scriptname}'"}),
    );
  }
}


sub edit{

  # set up the page
  print $g->{CGI}->div({-id=>"submenu"},'&nbsp;');
	print $g->{CGI}->div({-id=>"navlinks"},
		$g->{CGI}->a({-href=>"$g->{scriptname}?type=$g->{type}"},"Cancel $actionname ".$g->tc($g->{type})),
	),
	$g->{CGI}->div({-id=>"title"},$g->{CGI}->h3("$script_title"),);

	print $g->{CGI}->div({-id=>"subtitle"},"Editing: $g->{name}");

	print qq(\n<div id="main">\n);


  # initially entering the editor $g->{name} has been passed with the $g->{action} set to 'edit'

  # function is always update so, who cares about it?
  $g->{function}="update";

  # we don't care now but will once we need to revert to an earlier version
  #
  # <insert code>

  # set function globals
  print "\n<!-- edit start editing: $g->{name} -->\n";
  my($name,$version,$source,$state); my $source_exists='false';

  # change 'edit' to 'save' and then get the latest code from the database and load it into the editor.
  my($path,$modname)=split(/\_/,$g->{name});  $modname.='.pl';

  # if source is passed we know that the database needs to be updated with the new revision of code
  if($g->{source} ne ""){
    # increment the version
    if($g->{version} ne ""){
      # backup current version
      print "<!-- backing up current version $g->{modpath}/$path/repo/$modname-$major\.$minor\.$rev-->";
      system("cp $g->{modpath}/$path/$modname $g->{modpath}/$path/repo/$modname-$major\.$minor\.$rev");

      my ($major,$minor,$rev)=split(/\./,$g->{version});
      # major increment
      if($minor==9 and $rev==99){++$major; $minor=0; $rev=0;}
      # minor increment
      if($minor<9 and $rev==99){$rev=0; ++$minor;}else{++$rev;}
      # revision ($rev) increment
      if($minor<9 and $rev<99){++$rev;}
      $rev=sprintf("%d2",$rev);
    }
    else{
      $major=0; $minor=0; $rev='01';
    }
    $g->{version}=sprintf("%d\.%d\.%d2",$major,$minor,$rev);

    # update the datebase based on the modified form that passed data here.
    $sth=$g->{dbh}->prepare(
      "update interface_module_source set version=?,source=?,state=?,timestamp=now(),modifiedby='$g->{sys_username}'
       where name='$g->{name}'");
    $sth->execute($g->{version},$g->{source},$g->{state});

    # update actual file to reflect changes
    print "<!-- modulepath: $g->{modpath}/$path/$modname -->\n";
    open(OUT,">$g->{modpath}/$path/$modname") || die "Cannot open module, $g->{modpath}/$path/$modname for writing :$!";
    print OUT "$g->{source}";
    close(OUT);
  }

  # see if the module is already in the source database
  ($name,$version,$source,$state)=$g->{dbh}->selectrow_array(
    "select name,version,source,state from interface_module_source where name='$g->{name}' and state='active'");
  if($name ne "$g->{name}"){
    print "<!-- There is no source record for '$g->{name}' in the source database. -->\n";
  }
  else{
    $source_exists='true';
  }

  if($source_exists eq 'false'){
    # load source into database with initial revision number
    if(-e "$g->{modpath}/$path/$modname"){
      print $g->{CGI}->p("$g->{modpath}/$path/$modname exists... importing source..."),"\n";
      open(IN,"<$g->{modpath}/$path/$modname") or die "I cannot open $g->{modpath}/$path/$modname : $!";
      while(my $line=<IN>){$source.=$line;} close(IN);
      $name="$g->{name}"; $version="0.0.01"; $state='active';
      $sth=$g->{dbh}->prepare("insert into interface_module_source values(?,?,?,?,'now()','$g->{username}')");
      $sth->execute($name,$version,$source,$state) || die $g->{dbh}->errstr;
    }
    else{
      print $g->{CGI}->p("I cannot load the source from the database, and the module source does not exist."),"\n";
      exit;
    }
  }

  # if($g->{function} eq "upload"){upload();}

  # set webvars from what we get elsewhere if need be.
  if($g->{name} eq ""){$g->{name}=$name;}
  if($g->{version} eq ""){$g->{version}=$version;}
  if($g->{source} eq ""){$g->{source}=$source;}
  if($g->{state} eq ""){$g->{state}=$state;}
  if($g->{stamp} eq ""){$g->{stamp}=$stamp;}
  if($g->{published} eq ""){$g->{published}=$published;}
  if($g->{lastmodified} eq ""){$g->{lastmodified}=$lastmodified;}
  if($g->{modifiedby} eq ""){$g->{modifiedby}=$modifiedby;}

  # put editor up on screen with the latest data...

  print $g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}"}),
    "\n<table comment=\"table for module editor\">\n<tr>\n",
    "<td>",$g->{CGI}->label({-for=>"name"},"name of module"),"<br />\n",
    $g->{CGI}->textfield({-name=>"name",-value=>"$g->{name}",-size=>"20",-override=>"1"}),"</td>\n",
    $g->{CGI}->hidden({-name=>"action",-value=>"$g->{action}",-override=>"1"}),
    $g->{CGI}->hidden({-name=>"function",-value=>"$g->{function}",-override=>"1"}),
    "<td>",$g->{CGI}->label({-for=>"version"},"module version"),"<br />\n",
    $g->{CGI}->textfield({-name=>"version",-value=>"$g->{version}",-override=>"1"}),"</td>\n",
    "<td>",$g->{CGI}->label({-for=>"state"},"state of module"),"<br />\n",
    $g->{CGI}->popup_menu({-name=>"state",-size=>"1",-value=>["","active","debug"],-default=>"$g->{state}",-override=>"1"}),"</td>\n",
    # stamp & modifiedby are automatically updated without any interaction...
    "<td>",$g->{CGI}->submit("$g->{function}"),"</td>\n</tr>\n</table>\n",
    $g->{CGI}->div({-class=>"bespin"},
      $g->{CGI}->textarea({-class=>"editor",-name=>"source",value=>"$g->{source}",-rows=>"50",-override=>"1"}),
    ),
  $g->{CGI}->end_form(),"\n";

  #sub upload{
  #  if($g->{id} eq ""){print "Upload parameters where in an unacceptible format.<hr />\n"; return;}
  #	  my $textdata;
  #	  unless(-d "$docs_upload/$g->{id}"){system("mkdir $docs_upload/$g->{id}"); print "\ncreating $docs_upload/$g->{id} folder...<br />\n";}
  #	  my($fn,$ext)=split(/\./,$g->{uploadfilename}); $ext=lc($ext);
  #	  if($ext=~m/jpg/ or $ext=~m/jpeg/ or $ext=~m/gif/ or $ext=~m/png/){
  #	    system("mv $g->{uploaddir}/$g->{uploadfilename} $docs_upload/$g->{id}/$g->{uploadfilename}");
  #     print "<b>$g->{uploadfilename}</b> has been uploaded to <b>$docs_upload/$g->{id}/$g->{uploadfilename}</b> directory.<br />\n";
  #    if($g->{type} eq "text"){
  #     print "prepared text image insertion token.<br />\n"; $g->{data}.="\n\[image\: \"$g->{uploadfilename}\" caption: \"\" location: \"\" \]\n";
  #  }
  # elsif($g->{type} eq "html"){
  #        print "prepared html image insertion token.<br />\n"; $g->{data}.="\n<img src=\"/docs/$g->{id}/$g->{uploadfilename}\" /><br \/>\n";
  #      }
  #      elsif($g->{type} eq "xml"){
  #        print "prepared xml image insertion token.<br />\n";
  #        print "<p> There is currently no XML tag for this upload type </p>";
  #        $g->{data}.="\n<imagetag><name>$g->{uploadfilename}</name></imagetag>\n";
  #      }
  #      print "inserting image insertion token into database record<br />\n";
  #      $sth=$g->{dbh}->prepare("update system set data=? where id=$g->{id}") || die $g->{dbh}->errstr;
  #      $sth->execute($g->{data}) || die $g->{dbh}->errstr;
  #    }
  #    elsif($ext=~m/txt/){ # uploading a txt file into the editor...
  #      print "inserting text data into database record<br />\n";
  #	    open(IN,"<$g->{uploaddir}/$g->{uploadfilename}")||die"cannot open file for reading : $!";
  #	    while(my $line=<IN>){chomp $line; $textdata.="$line\n";}
  #	    close(IN);
  #	    $g->{data}.=$textdata;
  #	    system("rm $g->{uploaddir}/$g->{uploadfilename}");
  #      # print "$g->{data}<br />\n";
  #      $sth=$g->{dbh}->prepare("update system set data=? where id=$g->{id}") || die $g->{dbh}->errstr;
  #      $sth->execute($g->{data}) || die $g->{dbh}->errstr;
  #    }
  #    else{
  #	    system("rm $g->{uploaddir}/$g->{uploadfilename}");
  #	    print $g->{CGI}->font({-face=>"Arial",-size=>"4",-color=>"red"},"You can only upload .jpeg, .gif, .png image and .txt files.");
  #  } }
  print "\n</div> <!-- end main -->";
  print "\n<!-- edit end -->\n";
}

sub properties{
  print
  $g->{CGI}->h3({-align=>"center"},"Editing properties of \"$g->{name}\" module."),
  $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"post"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"update",-override=>"1"}),
  $g->{CGI}->hidden({-name=>"oldname",-value=>"$g->{name}"}),
  $g->{CGI}->start_table({-cols=>"3",-cellspacing=>0,-cellpadding=>0,-border=>0,-width=>"50%",-align=>"center"}),
  $g->{CGI}->Tr({-bgcolor=>"#fff9ff"},
    $g->{CGI}->td({-align=>"right"},"Module Title&nbsp;&nbsp;"),
    $g->{CGI}->td($g->{CGI}->textfield({-name=>"title",-value=>"$g->{title}",-override=>"1"}),),
  ),
  $g->{CGI}->Tr({-bgcolor=>"#fff9ff"},
    $g->{CGI}->td({-align=>"right"},"Group_Option_Module&nbsp;&nbsp;"),
    $g->{CGI}->td($g->{CGI}->textfield({-name=>"name",-value=>"$g->{name}",-override=>"1"}),),
  ),
  $g->{CGI}->Tr({-bgcolor=>"#fff9ff"},$g->{CGI}->td(" "),$g->{CGI}->td($g->{CGI}->submit("Save"),),),
  $g->{CGI}->end_form,
  $g->{CGI}->end_table();
}

sub new{
  print
  $g->{CGI}->p("To add a new module to DIFR you must define two things; what application group it belongs to and ",
        "the name of the new module."
  ),
  $g->{CGI}->p("<font size=+2>Group:</font> <b><em>interface</em></b> would be the group you would use for a module that would be available to core DIFR administrators while ",
        "<b><em>rcs</em></b> would be the name of the group for existing and new <b><em>rcs</em></b> application modules.",
  ),
  $g->{CGI}->p("<font size=+2>Module:</font> The name of the module is the actual executable name and does not require any extension {i.e., '.pl'}.",
        "The group and name do not contain spaces and are seperated by an underscore character, '_'",
  ),
  $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"add",-override=>"1"}),
  $g->{CGI}->start_table({-cols=>"3",-cellspacing=>0,-cellpadding=>0,-border=>0,-width=>"50%",-align=>"center"}),
  $g->{CGI}->Tr({-bgcolor=>"$g->{bgcolor}"},
    $g->{CGI}->td({-align=>"right"},"Module Title&nbsp;&nbsp;"),
    $g->{CGI}->td($g->{CGI}->textfield({-name=>"title",-value=>"$g->{title}",-override=>"1"}),),
  ),
  $g->{CGI}->Tr({-bgcolor=>"$g->{bgcolor}"},
    $g->{CGI}->td({-align=>"right"},"group_module&nbsp;&nbsp;"),
    $g->{CGI}->td($g->{CGI}->textfield({-name=>"name",-value=>"$g->{name}",-override=>"1"}),),
  ),
  $g->{CGI}->Tr({-bgcolor=>"$g->{bgcolor}"},$g->{CGI}->td(" "),$g->{CGI}->td($g->{CGI}->submit("Save"),),),
  $g->{CGI}->end_form,
  $g->{CGI}->end_table();
}

sub view{
  print $g->{CGI}->div({-id=>"submenu"},"&nbsp;");
  print qq(<div id="navlinks">\n);
  # top menu items
  if($g->{my_roles}=~m/add/){
    print $g->{CGI}->a({-href=>"$g->{scriptname}?action=new"},"Add a new Module");
  }
  unless($g->{action} eq ""){
    print "&nbsp;&#149;&nbsp;", $g->{CGI}->a({-href=>"$g->{scriptname}"},"Back");
  }
  print qq(</div>\n);
  #print $g->{CGI}->div({-id=>"title"},$g->{CGI}->h3({-align=>"center"},"$script_title"),),
  #$g->{CGI}->div({-id=>"subtitle"},"&nbsp;");
  print qq(<div id="main">\n);

  #print "roles: $g->{my_roles}<br />";
  print
  $g->{CGI}->start_table({-cols=>"3",-cellspacing=>0,-cellpadding=>0,-border=>0,-width=>"80%",-align=>"center"}),
    $g->{CGI}->Tr({-style=>"background-color: $g->{bgcolor}"},
      $g->{CGI}->th("Group_ModuleName"),
      $g->{CGI}->th("Module Title"),
      $g->{CGI}->th("Action"),
    );
  #$sth=$g->{dbh}->prepare("select name,title from modules where name not regexp \"^PowerNet_Dev\" order by name"); $sth->execute();
  $sth=$g->{dbh}->prepare("select name,title from interface_modules order by name"); $sth->execute();
  my $bg=$g->{bgcolor};
  while(my($name,$title)=$sth->fetchrow_array()){
    if($bg eq $g->{bgcolor}){$bg="white";}elsif($bg eq "white"){$bg=$g->{bgcolor};}
    print "<tr style=\"background-color: $bg\">",
    $g->{CGI}->td("$name"),$g->{CGI}->td("$title"),"<td>";
    my @roles=split(/\,/,$g->{my_roles});
    foreach $role(@roles){
      print $g->{CGI}->a({-href=>"$g->{scriptname}?action=$role&name=$name&title=$title"},"$role"),"&nbsp;";
    }
    print "</td></tr>";
  }
  print $g->{CGI}->end_table();
  print qq(\n</div> <!-- end main -->\n);
}

sub tail{
  #print $g->{CGI}->end_table();
  #$g->{dbh}->disconnect();
}

sub connectsql{
  open(FIL,"</$g->{sql_powernet}")|| die"cannot open $g->{sqlconf} : $!";
  my ($d,$u,$p); while(my $line=<FIL>){chomp($line); if($line ne ""){($d,$u,$p)=split(/\,/,$line); next;}}
  $dbh=DBI->connect("DBI:mysql:$d","$u","$p",{PrintError=>1,RaiseError=>1}) or
    die"Can not connect to database: $DBI::errstr\n";
}

sub skeleton{
  my($grp,$opt,$scr)=@_;
  print "in skeleton...<br />";
  system("webp");
  if(-e "$mod/$grp/$opt/$scr.pl"){}
  if(open(NEW,">>modules/$grp/$opt/$scr.pl")){
    print NEW "#!/usr/bin/perl\n";
    print NEW "# Interface Module Skeleton\n";
    print NEW "# This is an automatically generated skeleton module for Interface -BCIV\n\n";
    print NEW "use DBI; my \$dbh; my \$sth; my \$rv; # This is for database connectivity\n\n";
    print NEW "use CGI; my \$g->{CGI}=new CGI;              # This is for writting object oriented modules\n\n";
    print NEW "my \%v=\@ARGV;                        # This is how http vars are passed a to module\n";
    print NEW "                                      #(as arguments into a hash).\n\n";
    print NEW "# i.e., if you have a post/get variable called fred it will be seen as \$v{fred} to\n";
    print NEW "# the module.\n\n";
    print NEW "my \$script_title=\"$v{title}\";\n\n";
    print NEW "head();\nbody();\ntail();\n\n";
    print NEW "sub body{\n";
    print NEW "  # this is the function that decides what the module is supposed to do when it is called\n";
    print NEW "  # what it does is determined by the \$v{action} variable which is set through forms like\n";
    print NEW "  # the one called view shown below...\n";
    print NEW "  if(defined(\$g->{action})){\n";
    print NEW "    if(\$g->{action} eq \"someaction\"){\n";
    print NEW "      # an action is typically database modification routines or a call to a function\n";
    print NEW "      # view();\n";
    print NEW "      print \$g->{CGI}->h2({-align=>\"center\",-bgcolor=>\"#dddddd\"},\"\message: \$g->{popup}\"),\n";
    print NEW "    }\n";
    print NEW "    else{print\"the action you have chosen doesn\'t exist<br />\";}\n";
    print NEW "  }else{view();}\n";
    print NEW "}\n\n";
    print NEW "sub view{\n";
    print NEW "  print \$g->{CGI}->start_table({-cols=>\"1\",-border=>\"0\",-width=>\"100%\",-align=>\"center\",-cellspacing=>\"0\"}),\n";
    print NEW "  \$g->{CGI}->Tr(\$g->{CGI}->td(\n";
    print NEW "    \$g->{CGI}->start_form({-action=>\"\$g->{scriptname}\",-method=>\"POST\"}),\n";
    print NEW "    \$g->{CGI}->hidden({-name=>\"sid\",-value=>\"\$g->{sid}\",-override=>\"1\"}),\n";
    print NEW "    \$g->{CGI}->hidden({-name=>\"action\",-value=>\"someaction\",-override=>\"1\"}),\n";
    print NEW "    \$g->{CGI}->textfield({-name=>\"example\",-value=>\"\$g->{example}\",-override=>\"1\"}),\n";
    print NEW "    \$g->{CGI}->popup_menu({-name=>\"popup\",-value=>[\"click me\",\"whoopie!\"],-default=>\"\$g->{popup}\",-size=>\"10\",-override=>\"1\"}),\n";
    print NEW "    \$g->{CGI}->submit(\"button text\"),\n";
    print NEW "    \$g->{CGI}->end_form(),\n";
    print NEW "  ),),\n";
    print NEW "  \$g->{CGI}->end_table(),\n";
    print NEW "  \$g->{CGI}->hr(\"This is a skeleton module automatically generated by Interface.\");\n";
    print NEW "}\n\n";
    print NEW "sub head{\n";
    print NEW "  # \$dbh=DBI->connect(\"DBI:mysql:database\",\"user\",\"password\",{PrintError=>1,RaiseError=>1}) or\n";
    print NEW "  #   die \"Cannot connect to database : \$DBI::errstr\";\n";
    print NEW "  print \"&nbsp;&#149;&nbsp;\",\n";
    print NEW "  \$g->{CGI}->a({-href=>\"\$g->{scriptname}?sid=\$g->{sid}&action=YourAction\"},\"Add a new thingy\");\n";
    print NEW "  unless(\$g->{action} eq \"\"){\n";
    print NEW "    print \"&nbsp;&#149;&nbsp;\",\n";
    print NEW "    \$g->{CGI}->a({-href=>\"\$g->{scriptname}?sid=\$g->{sid}\"},\"Back\");\n";
    print NEW "  }\n";
    print NEW "  print \$g->{CGI}->h1({-align=>\"center\"},\"\$script_title\");\n";
    print NEW "}\n\n";
    print NEW "sub tail{\n  print \$g->{CGI}->end_table();\n  #\$g->{dbh}->disconnect(); # This will close your database session\n}\n\n";
    print NEW "sub connectsql{\n";
    print NEW "  open(FIL,\"</\$g->{sql_jahvastat}\")|| die\"cannot open \$g->{sql_jahvastat} : \$!\";\n";
  	print NEW "  my (\$d,\$u,\$p); while(my \$line=<FIL>){chomp(\$line); if(\$line ne \"\"){(\$d,\$u,\$p)=split(/\,/,\$line); next;}}\n";
    print NEW "  \$dbh=DBI->connect(\"DBI:mysql:\$d\",\"\$u\",\"\$p\",\n";
    print NEW "      {PrintError=>1,RaiseError=>1}) or die\"Can not connect to database: \$DBI::errstr\n\";\n";
    print NEW "}\n\n";

    close(NEW);
    system("webp"); # fix permissions on script
    print "finished creating script\n<br />";
  }else{print"could not open : modules/$grp/$opt/$scr for writing : $!<br />";}
}

sub msg{ my ($msg)=@_; print $g->{CGI}->h2({-align=>"center"},"$msg");}
