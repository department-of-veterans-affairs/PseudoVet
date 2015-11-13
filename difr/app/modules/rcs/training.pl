#!/usr/bin/perl
# training module for DIFR
# If you don't know the code, don't mess around below -bciv

my $personnel_table="rcs_personnel";
my $training_table="rcs_trainingrequired";

unless(defined($g->{action})){ $g->{action}="update"; view();}
elsif($g->{action} eq "view"){$g->{action}="update"; view();}
elsif($g->{action} eq "edit"){editor();}
elsif($g->{action} eq "update"){
#  print "updating $g->{uid} $g->{trainingtype}...<br />\n";
  $g->{dbh}->do("update $training_table set optional=\"$g->{optional}\", trainingdate=\"$g->{trainingdate}\"
                 where uid=\"$g->{uid}\" and trainingtype=\"$g->{trainingtype}\"");
  $g->event("training","updating $g->{uid} training record");
  view();
}

1; # end module

sub view{
  my $count=0;
  if($g->{action} eq "view" or $g->{action} eq "edit"){$g->{action}="update";}

  # pull employee name data
  my $query_fields="firstname, middle, lastname, suffix, degree";
  my ($first,$middle,$last,$suffix,$degree)=
      $g->{dbh}->selectrow_array("select $query_fields from $personnel_table where uid like \"$g->{uid}\"");

  print
  $g->{CGI}->div({-id=>"navlinks"},
  	$g->{CGI}->a({-href=>"$g->{scriptname}?chmod=rcs_personnel&action=edit&uid=$g->{uid}"},"To Personnel Record"),
  );

  # exit if there are no training records to view
  if($first eq ""){
    print $g->{CGI}->fieldset("There is no employee training record for the user ID you are attempting to view.");
    #---> add routine to create the users employee record
    return;
  }

  # print header identifying whose training record is being viewed
  print $g->{CGI}->h3("training record for: <b>$first $middle $last $suffix</b>"),
  qq(\n<div id="page_effect" style="display:none;">\n);

  # retrieve listing of training templates or 'groups'
  my $c=$g->{dbh}->selectcol_arrayref("select distinct(template) from rcs_trainingtypes order by template");
    
  # update training group membership if necessesary
  if($g->{function} eq 'set'){
    print qq(<!-- setting training group membership -->\n);
    foreach $type (@{$c}){
      my $query="update rcs_groups set value='$g->{$type}' where gtype='training' and gkey='$type' and uid='$g->{uid}'";
      print qq(<!-- $query -->\n);
      $g->{dbh}->do("$query");
    }
    $g->event("training","changed $g->{uid} $firstname $lastname training group membership.")
  }
  
  # present interface to 'set' which training 'groups' employee is assigned to
  print qq(\n<div id='search'>\n),
  $g->{CGI}->br(),$g->{CGI}->p("<b>Training Groups Assigned</b>"),
  $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"POST"}),
  $g->{CGI}->hidden({-name=>"action",-value=>"edit"}),
  $g->{CGI}->hidden({-name=>"function",-value=>"set"}),
  $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}"}),"\n";
  foreach $type (@{$c}){
    my $checked='';
    my $value=$g->{dbh}->selectrow_array("select value from rcs_groups where uid='$g->{uid}' and gtype='training' and gkey='$type'");
    if($value eq 'true'){$checked='checked';}
    print $g->{CGI}->checkbox({-name=>"$type",-value=>"true",-selected=>"$checked",-label=>"$type"});
  }
  print $g->{CGI}->submit("Set"),
  $g->{CGI}->end_form(),
  qq(\n</div>\n);
  
  print $g->{CGI}->p("<em>Enter the date of training completion (if applicable), whether the training type is required for
    	the employee, and then click update for each of the training types listed.</em>");

  # iterate and present class listing relevant to employee for modification
  my $query="select rcs_trainingrequired.trainingtype, rcs_trainingtypes.descr, rcs_trainingtypes.template, 
  			 rcs_trainingrequired.optional, rcs_trainingrequired.trainingdate 
             from rcs_trainingrequired
             left join rcs_groups on rcs_trainingrequired.uid=rcs_groups.uid
             inner join rcs_trainingtypes on rcs_trainingrequired.trainingtype=rcs_trainingtypes.name 
             and rcs_groups.gkey=rcs_trainingtypes.template
             where rcs_groups.value='true' and rcs_groups.uid=$g->{uid} order by rcs_trainingtypes.template,
             rcs_trainingrequired.trainingtype";

  $sth=$g->{dbh}->prepare("$query"); $sth->execute();
  my $template_tmp=''; my $num=1;
  while(my($name,$descr,$template,$optional,$date)=$sth->fetchrow_array()){
    if($template ne $template_tmp){print $g->{CGI}->h4("$template");} 
    print qq(<div id='record'>\n),
      $g->{CGI}->p("<em>$name</em> - <b>$descr</b>"),
      $g->{CGI}->start_form({-action=>"$g->{scriptname}",-method=>"get"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"update",-override=>"1"}),
      $g->{CGI}->hidden({-name=>"uid",-value=>"$g->{uid}",-override=>"1"}),
      $g->{CGI}->hidden({-name=>"trainingtype",-value=>"$name",-override=>"1"}),
      $g->{CGI}->label({-for=>"trainingdate"},"Last Training Date:"),
      $g->{CGI}->textfield({-id=>"datepicker$num",-size=>"11",-name=>"trainingdate",-value=>"$date",-override=>1});
	  # if optional field eq 'mandatory' than it won't be show up or be capable of being set
	  # otherwise it's value is 'true' which means it is required and a checkbox shows
	  # if it is deselected, the value becomes '' ~logic in notifications will look for optional not like ''
      my $checked='';
      if($optional eq 'mandatory'){print $g->{CGI}->hidden({-name=>'optional',-value=>'mandatory'});}
      else{
        if($optional eq 'true'){$checked='checked';}
        print $g->{CGI}->checkbox({-name=>'optional',-value=>'true',-selected=>"$checked",-label=>'Required',-override=>1});
      }
      print $g->{CGI}->submit("Update"),
      $g->{CGI}->end_form(),
    qq(\n</div>\n);
    $template_tmp=$template; ++$num; # this is for jQuery's DatePickerX
  }
  if($num == 1){print $g->{CGI}->div({-id=>"record"},$g->{CGI}->h4("This employee needs to be assigned to a Training Group."));}
  $g->event("training","viewing $g->{uid} $firstname $lastname");
}
