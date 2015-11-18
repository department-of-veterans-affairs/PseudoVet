#!/usr/bin/perl
# reports module for DIFR
# If you don't know the code, don't mess around below -bciv
use Spreadsheet::WriteExcel;
#
my $query_table="rcs_reports";
my $query_fields="id,name,description,type,query,modifiedby,lastmod";
my ($id,$name,$description,$type,$query,$modifiedby,$lastmod);

print qq(\n<div id="page_effect">);

my $function=$g->controller(
  "key"=>'action',
  "default_key"=>'view',
  "default_function"=>'view',
  "function"=>{
    "query"=>'query',
    "new"=>'editor',
    "edit"=>'editor',
    "update"=>'editor',
    "execute"=>'execute',
    "deletefile"=>'deletefile',
  },
); &$function;

1; # end module

sub execute{
  generate_report();
  view();
}

sub deletefile{
  system("rm \"cache/$g->{file}\"");
  view();
}

sub view{
  print qq(\n<div id="horizontalnav">&nbsp;</div>\n);

  print qq(<div id="navlinks">\n);
  if($g->{my_roles}=~m/new/){print qq(\t<a href="$g->{scriptname}?action=new">Create New Report</a>\n);}
  else{print qq(&nbsp;\n);}
  print qq(\n</div>);

  report_archive();

  print qq(\n<h3>Reports</h3>\n);

  $sth=$g->{dbh}->prepare("select $query_fields from $query_table order by type, name");
  $sth->execute();
  my $records=0;
  my $type_temp=''; my $highlight='even';
  while(($id,$name,$description,$type,$query,$modifiedby,$lastmod)=$sth->fetchrow_array()){
    if($type_temp ne $type){
      if($type_temp ne ''){print $g->{CGI}->end_table();}

      # print header for type of report table being generated
      print $g->{CGI}->h4($g->tc("$type")),
      $g->{CGI}->start_table({-cols=>"",-width=>"98%"}),
      $g->{CGI}->Tr($g->{CGI}->th({-width=>"30%"},"Name"),$g->{CGI}->th("Description"),$g->{CGI}->th({-width=>"20%"},"Action"));
      $highlight='even';
    }
    if($name eq ''){$name='[not set]';}

    if($highlight eq 'even'){$highlight='odd';}elsif($highlight eq 'odd'){$highlight='even';}
    print qq(\n<Tr class="$highlight">\n);
    print $g->{CGI}->td("$name"),$g->{CGI}->td("$description"),
    "<td>",
    $g->{CGI}->a({-href=>"$g->{scriptname}?action=execute&id=$id&name=$name&format=XLS"},"Generate Excel Report");

    if($g->{my_roles}=~m/edit/){
      print $g->{CGI}->a({-href=>"$g->{scriptname}?action=edit&id=$id&name=$name&format=XLS"},"Modify Report");
    }
    print qq(\n</td></Tr>\n);
    ++$records;
    $type_temp=$type;
  }
  print $g->{CGI}->end_table();

  if($records lt "1"){
    print qq(
    <h4>No Reports Defined</h4>
    <p>There are no reports defined in this system.  Please refer to the DIFR User's Manual
    or contact your system administrator.</p>
    );
  }

}

sub editor{
#my $query_table="rcs_reports";
#my $query_fields="id,name,description,type,query,modifiedby,lastmod";
#my ($id,$name,$description,$query,$modifiedby,$lastmod);

print qq(<div id="submenu">&nbsp;</div>\n);
print qq(<div id="navlinks">\n);

    if($g->{action} eq 'update'){
        if($g->{id} eq '0'){
            # this is a new entry...
            $g->{dbh}->do("insert into $query_table values(0,\"$g->{name}\",\"$g->{description}\",
                          \"$g->{type}\",\"$g->{query}\",\"$g->{system_username}\",0)");
            $g->{id}=$g->{dbh}->selectrow_array("select id from $query_table where name=\"$g->{name}\"");
        }
        if($g->{name} eq ''){throw("The name of a report cannot be blank.");}
        if($g->{description} eq ''){throw("You must provide a description for a report.");}
        if($g->{query} eq ''){throw("A report must have query data in order to produce data.");}
        $g->{dbh}->do("update $query_table set name=\"$g->{name}\",description=\"$g->{description}\",
                      type=\"$g->{type}\",query=\"$g->{query}\",modifiedby=\"$g->{sys_username}\",lastmod=0 where id=$g->{id}");
    }
    if($g->{action} eq 'new'){
        $id=0; $name=''; $description=''; $query=''; $lastmod='0000-00-00';
        print qq(<a href="$g->{scriptname}">Cancel New Report Creation</a>);
    }
    else{
        print qq(<a href="$g->{scriptname}">Cancel Edit Report</a>);
        ($id,$name,$description,$type,$query,$modifiedby,$lastmod)=
        $g->{dbh}->selectrow_array("select $query_fields from $query_table where id=\"$g->{id}\"");
    }

    print qq(</div> <!-- end navlinks -->\n);
    print $g->{CGI}->div({-id=>"title"},$g->{CGI}->h3("Report Editor"),);
#    print qq(\n<div id="main">\n);

    print $g->{CGI}->fieldset(
        $g->{CGI}->legend("Define Report Criteria"),
        $g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
        $g->{CGI}->hidden({-name=>"id",-value=>"$id",-override=>1}),
        $g->{CGI}->hidden({-name=>"action",-value=>"update",-override=>1}),
        $g->{CGI}->label({-for=>"name"},"Report Name:"),
        $g->{CGI}->textfield({-name=>"name",-value=>"$name",-size=>"70",-override=>1}),
        $g->{CGI}->br(),
        $g->{CGI}->label({-for=>"description"},"&nbsp;&nbsp;&nbsp;Description:"),
        $g->{CGI}->textfield({-name=>"description",-value=>"$description",-size=>"70",-override=>1}),
        $g->{CGI}->br(),
        $g->{CGI}->label({-for=>"type"},"Type of Report:"),
    		$g->{CGI}->popup_menu({-name=>"type",-default=>"Report",-size=>"1",-value=>['Report','Notification']}),
    		$g->{CGI}->br(),
        $g->{CGI}->fieldset($g->{CGI}->legend("query"),
          $g->{CGI}->textarea({-name=>"query",-cols=>"60",-rows=>"3",-value=>"$query",-override=>1}),
        ),
        $g->{CGI}->br(),
        $g->{CGI}->label({-for=>"modifiedby"},"Modified By:"),
        $g->{CGI}->textfield({-name=>"modifiedby",-value=>"$g->{sys_username}",-override=>1}),
        "&nbsp;&nbsp;<b>Last Modified:</b> $lastmod",
        $g->{CGI}->div({-id=>"floatright"},$g->{CGI}->submit("Save Report"),),
        $g->{CGI}->end_form(),
    );
#    print qq(\n</div> <!-- end main -->\n);
}

sub throw{
  my $message=@_;
  print qq(
    <fieldset><legend>Error</legend>
    <br />
    <br />
    <em>$message</em>
    <br />
    <p>Please click the back button in your browser and examine the form.
    Make any corrections and then resubmit the form.
    If problems persist, please contact your system administrator.</p>
    <br />
    <br />
    </fieldset>
  );
  return 1;
}

sub generate_report{
    my $stamp=$g->{dbh}->selectrow_array("select now()"); $stamp=~s/\s/\_/i;
    if($g->{format} eq 'CSV'){
        my $query=$g->{dbh}->selectrow_array("select query from $query_table where id=\"$g->{id}\"");
        my $headers=$query; my $junk=''; $headers=~s/^select\s//; ($headers,$junk)=split(/from/,$headers);
        my $outputfilename="$g->{cachedir}/$g->{name}\-$g->{now}\-$g->{sys_username}\.cvs";
        open OUT,">$outputfilename" or die "Cannot Create $outputfilename";
        print OUT "$headers\n";
        $sth=$g->{dbh}->prepare("$query"); $sth->execute();
        while(my (@line)=$sth->fetchrow_array()){
            print OUT "@line\n";
        }
        close OUT;
    }
    elsif($g->{format} eq 'XLS'){
        my $query=$g->{dbh}->selectrow_array("select query from $query_table where id=\"$g->{id}\"");
        if($query=~m/^perl\s*/){
            my $outputfilename="$g->{cachedir}/$g->{name}\-$stamp\-$g->{sys_username}\.xls";
            print "<!-- perl script execution: $query $outputfilename-->\n";
            system("$query \"$outputfilename\"");
            print "<!-- perl script execution completed! -->\n";
        }
        else{
            my $headers=$query; my $junk=''; $headers=~s/^select\s//; ($headers,$junk)=split(/from/,$headers);
            my $outputfilename="$g->{cachedir}/$g->{name}\-$stamp\-$g->{sys_username}\.xls";
            my $outputfile=Spreadsheet::WriteExcel->new("$outputfilename") or
               die "Could not create a new Excel file in $outputfilename $!";
            my $sheet=$outputfile->add_worksheet(); my $row=0; my $col=0;
            # print header row
            my @header_elements=split(/,/,$headers);
            foreach $header_element (@header_elements){
                $sheet->write($row,$col,"$header_element"); ++$col;
            } ++$row; $col=0;

                $sth=$g->{dbh}->prepare("$query"); $sth->execute();
            # print all data
            while(my (@line)=$sth->fetchrow_array()){
                foreach $element (@line){
                    $sheet->write($row,$col,"$element"); ++$col;
                } $col=0; ++$row;
            }
        }
    }
}

sub report_archive{
  #display report listings
  print qq(    <h4>Generated Report Archive</h4><div id="search"><br />\n);
  opendir(CACHEDIR,"cache") or die "Cannot open cache directory<br />";
  my $count=0;
  while(my $filename=readdir(CACHEDIR)){
    #print "$filename";
    unless($filename=~m/^\./){
      print qq(    <a href="cache/$filename">$filename</a>&nbsp;&nbsp;&nbsp;
                   <a href="$g->{scriptname}?action=deletefile&file=$filename">delete</a>
                   <br />);
      $count++;
    }
  }
  closedir(CACHEDIR);
  if($count==0){print $g->{CGI}->center($g->{CGI}->h4("Report Archive is empty"));}
  print qq(    </div> <!-- close search -->\n);
  #print qq(</div> <!-- end main -->\n);
}