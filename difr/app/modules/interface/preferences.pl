# will add "Modules"=>"modules", in 2.9 hopefully...
#$g->system_menu("Contact"=>"contact","Password"=>"password"); # ,"Themes"=>"themes"
$g->system_menu_unrestricted("Contact"=>"contact","Password"=>"password");


my $function=$g->controller(
  "key"=>'function',
  "default_key"=>'Contact',
  'default_function'=>'contact',
  'function'=>{
    'contact'=>'contact',
    'themes'=>'themes',
    'modules'=>'modules',
    'password'=>'password',
  }
); &$function;
1;

sub contact{
  my @salutations=(" ","Mr.","Mrs.","Ms.","Dr.","Prof.","Rev","Sir","Dame","Sri");
  my @suffixes=(' ','Jr','Sr','II','III','IV','Esq.');
  my @countries=countries();
  
  if($g->{action} eq 'update'){
    my @fields=('salutation','firstname','middle','lastname','suffix','jobtitle','company','department','phone','addressline1','addressline2','city','stateprovince','postalcode','country');
    foreach my $field (@fields){
      $g->{dbh}->do("update interface_user_demographics set $field='$g->{$field}' where username='$g->{sys_username}'");
    }
    $g->event("Preferences","$g->{sys_username} updated contact information");
  }

  # get information from db
  my($salutation,$firstname, $middle, $lastname, $suffix, $jobtitle, $company, $department, $phone, $addressline1, $addressline2, $city, $stateprovince, $postalcode, $country)=
    $g->{dbh}->selectrow_array("select salutation, firstname, middle, lastname, suffix, jobtitle, company, department, phone, addressline1, addressline2, city, stateprovince, postalcode, country from interface_user_demographics where username='$g->{sys_username}'");
    
  print $g->{CGI}->h3("Contact Information"),
  $g->{CGI}->div({-container=>"container"},
    $g->{CGI}->p("*Your email address cannot be modified here at this time."),
    $g->{CGI}->div({-class=>'row'},
      $g->{CGI}->start_form({-method=>"POST",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"function",-value=>"contact"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"update"}),
      $g->{CGI}->div({-class=>'col-xs-6'},
        $g->{CGI}->div({-class=>'form-group'},
          $g->{CGI}->label({-for=>"salutation"},"Salutation"),
          $g->{CGI}->popup_menu({-name=>"salutation",-default=>"$salutation",-values=>\@salutations,-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
          $g->{CGI}->label({-for=>"firstname"},"First Name"),
          $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'First Name',-name=>"firstname",-value=>"$firstname",-override=>1,-size=>30}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
          $g->{CGI}->label({-for=>"middle"},"Middle Initial"),
          $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Middle Initial',-name=>"middle",-value=>"$middle",-override=>1,-size=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"lastname"},"Last Name"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Last Name',-name=>"lastname",-value=>"$lastname",-override=>1,-size=>30}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"suffix"},"Suffix"),
        $g->{CGI}->popup_menu({-class=>'form-control',-placeholder=>'Suffix',-name=>"suffix",-default=>"$suffix",-values=>\@suffixes,-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"jobtitle"},"Job Title"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Job Title',-name=>"jobtitle",-value=>"$jobtitle",-override=>1,-size=>40}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"company"},"Company"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Company',-name=>"company",-value=>"$company",-override=>1,-size=>28}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"department"},"Department"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Department',-name=>"department",-value=>"$department",-override=>1,-size=>29}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"phone"},"Phone"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Phone',-name=>"phone",-value=>"$phone",-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"addressline1"},"Address Line 1"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Address Line 1',-name=>"addressline1",-value=>"$addressline1",-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"addressline2"},"Address Line 2"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Address Line 2',-name=>"addressline2",-value=>"$addressline2",-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"city"},"City"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'City',-name=>"city",-value=>"$city",-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"stateprovince"},"State/Province"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'State/Province',-name=>"stateprovince",-value=>"$stateprovince",-override=>1}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"postalcode"},"Postal Code"),
        $g->{CGI}->textfield({-class=>'form-control',-placeholder=>'Postal Code',-name=>"postalcode",-value=>"$postalcode",-override=>1}),    
        ),
        $g->{CGI}->div({-class=>'form-group'},
        $g->{CGI}->label({-for=>"country"},"Country"), 
        $g->{CGI}->popup_menu({-class=>'form-control',-placeholder=>'Country',-name=>"country",-default=>"$country",-values=>\@countries,-override=>1}),
        ),
      ),
    ),
    $g->{CGI}->submit("Update My Contact Information"),
    $g->{CGI}->end_form(),
  );
  
  sub countries{
    my @retval;
    open(FIL,"<$g->{countryfile}") or die "Cannot open country-codes from $g->{countryfile} $!";
    while(my ($country,$twodigitcode,$threedigitcode)=split(/\,/,<FIL>)){push(@retval,"$country - $twodigitcode");}
    return @retval;
  }  
}
sub themes{
  print $g->{CGI}->h3("Themes"),
  $g->{CGI}->p("Click on a theme to change the appearance of DIFR for your account.<br />\n
  <i>*This will revert to the system default if you clear your browser cookies or have not logged into DIFR in a few weeks.</i>
  ");
  my @themes;
  opendir(DIR,"$g->{themes}") or die "Cannot open $g->{themes} $!";
  while(defined($themedir=readdir(DIR))){
    if(-d "$g->{themes}/$themedir" and $themedir !~/^\./){push(@themes,$themedir);}
  }
  closedir(DIR);
  foreach $theme (@themes){
    my $selected=""; my $selectedtext=""; if($g->{sys_theme} eq $theme){$selected='selected'; $selectedtext=" [selected]";}
    print $g->{CGI}->div({-id=>"listform",-class=>"$selected"},
      $g->{CGI}->center(
        $g->{CGI}->h3("$theme $selectedtext"),
        $g->{CGI}->a({-href=>"$g->{scriptname}?function=themes&chtheme=$theme"},
          $g->{CGI}->img({-src=>"/$g->{appname}/themes/$theme/screenshot.png",-width=>"550",-border=>1}),
        ),
      ),
    );
  }
}
sub modules{
  print $g->{CGI}->h3("Modules"),
  $g->{CGI}->div({-id=>"listform"},
    $g->{CGI}->p("Module Preference include personalized settings such as collapsing work details when viewing an employee record so it won't be seen."),
  );
}
sub password{

  my $check='pass';
  if($g->{action} eq 'set'){
    if($g->{password} eq ''){
      print $g->{CGI}->p({-style=>"color: red;"},"Your password cannot be blank.  Please provide a new password that is at least 6 characters long.");
      $check='fail';
    }
    if($g->{password} ne $g->{verify}){
      print $g->{CGI}->p({-style=>"color: red;"},"You did not enter the same password twice.");
      $check='fail';
    }
    if($g->{password} !~ m/[0-9]/){
      print $g->{CGI}->p({-style=>"color: red;"},"You did not enter a number.  Your password must contain at least one number.");
      $check='fail';
    }
    if($g->{password} !~ m/[A-Za-z]/){
      print $g->{CGI}->p({-style=>"color: red;"},"You did not enter any characters from the alphabet.  Your password must contain at least one letter of the alphabet.");
      $check='fail';
    }
    if( length($g->{password}) < 6){
      print $g->{CGI}->p({-style=>"color: red;"},"You did not type enough characters.  Your password must at least be 6 characters long.");
      $check='fail';
    }
    if($check eq 'pass'){
      $g->{dbh}->do("update interface_users set password=md5('$g->{password}') where username='$g->{sys_username}'");
      $g->event("Preferences","$g->{sys_username} changed password");
      print 
      $g->{CGI}->p("Your password has been changed.  Please make sure you don't forget it!!!");
    }
  }

  # get information from db
  #my($fname,$mi,$lname,$suffix,$title,$service,$section,$ext,$pager,$cell,$email)=
  #$g->{dbh}->selectrow_array("select fname, mi, lname, suffix, title, service, section, ext, pager, cell, email from interface_users where username='$g->{sys_username}'");

  print $g->{CGI}->div({-class=>"container"},
    $g->{CGI}->h3("Change your password"),
    $g->{CGI}->p("Your password must contain at least one number, one special character, and be at least 6 characters long."),
    $g->{CGI}->div({-class=>'row'},
      $g->{CGI}->start_form({-method=>"POST",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"function",-value=>"password"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"set"}),
      $g->{CGI}->div({-class=>'col-xs-6'},
        $g->{CGI}->div({-class=>'form-group'},
          $g->{CGI}->label({-for=>"password"},"Password"),
          $g->{CGI}->password_field({-class=>'form-control',-placeholder=>'Password',-name=>"password",-value=>"",-override=>1,-size=>30}),
        ),
        $g->{CGI}->div({-class=>'form-group'},
          $g->{CGI}->label({-for=>"verify"},"Verify"),
          $g->{CGI}->password_field({-class=>'form-control',-placeholder=>'Verify',-name=>"verify",-value=>"",-override=>1,-size=>30}),
        ),
      ),
    ),
    $g->{CGI}->submit({-class=>'btn btn-default',-name=>"Set Password"}),
    $g->{CGI}->end_form(),
  );
}
