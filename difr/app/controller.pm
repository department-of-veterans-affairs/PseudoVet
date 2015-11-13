package controller;
require Exporter;
require DBI;
use Digest::MD5 qw(md5_hex);
use CGI qw(:all);
use CGI::Carp qw( fatalsToBrowser );
use CGI::Pretty;
use Socket;
#use POSIX;

use vars qw(@ISA @EXPORT $Version);
@ISA=qw(Exporter);
@EXPORT=qw(
  analytic,
  array,
  authenticate,
  call_support,
  controller,
  router,
  connectsql,
  countries,
  event,
  fields,
  filelist,
  header5,
  include,
  login,
  menubuilder,
  menubuilder2,
  menubuilder3,
  moduleloader,
  msg,
  new,
  pretty,
  record_add,
  record_edit,
  sessionquery,
  sessionmaker,
  submenu,
  system_menu,
  system_menu_role_restricted,
  system_menu_unrestricted,
  table_list,
  tc,
  query_list,
);
my $VERSION='1.2';

# total("distinct","uid","where status not like 'I'");
#  my $total_projects=total('Total Projects','',"*",'','rcs_scopeofwork','','');
#  my $projectsActive=total('Active Projects','',"*",'','rcs_scopeofwork',"where status='active'","percentage:$total_projects");
sub analytic{ # distinct or * table null or named field
  my $self=shift;
  my ($title,$link,$count,$field,$table,$constraints,$function)=@_;
  my $query="select count($count $field) from $table";
  if($constraints ne ''){$query.=" $constraints";}
  my $sum=$self->{dbh}->selectrow_array("$query");
  if($function =~m/^percentage/ and $count > 0){
    my ($f,$total)=split(/\:/,$function);
    my $percentage=$sum*100/$total;
    my $display=sprintf("%.2f\%",$percentage);
    $retval="$sum $display";
  }
  else{$retval="$sum";}
  print "<!-- $query -->\n$title: $retval<br />\n";
  return "$retval";
}

#            ARRAY          ***************************************************
# input: takes a delimiter as first parametre followed by a scalar value that is delimited
# output: returns an @array
sub array{
  my $self=shift;
  my ($delimiter,$input)=@_; my @retval=split($delimiter,$input);
  return @retval;
}

# authenticate: performs the authentication of a user by checking username and passwords against the DIFR database
#
# todo: add mechanism to allow accounts to be bound to active directory or standards based LDAP systems
sub authenticate{
  my $self=shift; my $retval="INVALID";

  # see if there is an account on the system for the sys_username provided (this is for local as well as other accounts)
  my ($username,$active,$email)=
  $self->{dbh}->selectrow_array(
    "select interface_users.username, interface_users.active, interface_users.email
    from interface_users where username='$self->{sys_username}'"
  );

  if($username eq ""){
    $self->{msg}="<h2>There is no account for \'$self->{sys_username}\' on this system.</h2>";
    $self->{msg}.="\n<div id='record'>\n<p>\n\tDid you forget your username?";
    $self->{msg}.="<a href='$self->{scriptname}\?action=iforgot'>Click here</a>\n";
    $self->{msg}.="</div> <!-- end record -->\n";
    $self->{msg}.="<br /><hr />\n<p>If you are having problems logging in, please contact us: "; 
    $self->{msg}.="<a href='mailto:support\@etherfeat.com?subject=EtherFeat Account Login Issue $self->{username}&body=<Please enter any information you think may be helpful'>support\@etherfeat.com</a>\n";
    $self->{msg}.="</p>\n";

    print qq(<ul><li><a href="http://$self->{domainname}">Exit Portal</a></li><li><a href="$self->{scriptname}">Back To Login</a></li></ul>);
  }
  elsif($active ne "true"){$self->{msg}="Your account is inactive.  You must contact the system administrator for reactivation."; print "Inactive Account";}

  # authenticate local accounts
  if($self->{sys_domain} eq "LOCAL" and $username ne ''){
    if($username ne ""){ # validate password...
      my $rv=$self->{dbh}->selectrow_array("select username from interface_users where username='$self->{sys_username}' and password=md5('$self->{password}')");
  		if($rv ne ""){$self->{msg}="$self->{sys_username} local login successful";  $retval="VALID";}
      else{
        $self->{msg}="<h2>You have not entered a valid password, $self->{sys_username}.</h2> $rv";
        $self->{msg}.="<p>Make sure that your CAPS LOCK key is not pressed and try again.</p>";
        $self->{msg}.="\n<div id='record'>\n<p>\n\tDid you forget your password? ";
        $self->{msg}.="<a href='$self->{scriptname}\?action=iforgot'>Click here</a>\n";
        $self->{msg}.="</div> <!-- end record -->\n";
        $self->{msg}.="<br /><hr />\n<p>If you are having problems logging in, please contact us: "; 
        $self->{msg}.="<a href='mailto:support\@etherfeat.com?subject=EtherFeat Account Login Issue $self->{username}&body=<Please enter any information you think may be helpful'>support\@etherfeat.com</a>\n";
        $self->{msg}.="</p>\n";

        print qq(<ul><li><a href="http://$self->{domainname}">Exit Portal</a></li><li><a href="$self->{scriptname}">Back To Login</a></li></ul>);
      }
    }
  }

  #if($theme eq ""){$self->{sys_theme}="difr";}

  if($retval eq 'INVALID'){
    $self->event("Login","$self->{msg}");
    $self->{sys_username}=""; $self->{password}="";
  }
  if($retval eq 'VALID'){
    $self->event("Login","$self->{msg}");
    $self->sessionmaker;
  }
  return $retval;
}

#            CONTROLLER      ***************************************************
# input: takes a hash which contains keys: key, default_key, default_function
#        these keys represent what the name, default value, and what function or method is
#        executed based upon of value of the key variable
#        Typically this variable is called 'action' in this system
#        Also, function is a key in this hash with subkeys showing possible key values and their
#        associated function/method names.
#
#  here is an example hash passed to the controller method:
#
#  "key"=>'action',
#  "default_key"=>'view',
#  "default_function"=>'record_view',
#  "function"=>{
#    "add"=>'record_view',
#    "edit"=>'record_edit',
#    "delete"=>'record_delete',
#  },
# output: the output of the controller method is a scalar value of the function that has been
#         chosen by the key value for execution
#         a controller call is followed by an executor statement such as: &$function;
sub controller{
  my $self=shift;
  my(%input)=@_; my $retval;
  if(not defined($self->{"$input{key}"}) or $self->{"$input{key}"} eq '' or
     $self->{"$input{key}"} eq "$input{default_key}"){
    my $function=$input{default_function};
    $retval=$function;
  }
  else{
    foreach $function (keys %{$input{function}}){
      print "<!-- function: $function -->\n";
      if($self->{"$input{key}"} eq "$function"){
        print "<!-- execute function: $function = $input{function}{$function} -->\n";
        my $function=$input{function}{$function};
        $retval=$function;
      }
    }
  }
  $self->event("$self->{sys_mod}","$retval");
  return $retval;
}
# controller should be called router as it 'routes' module request to their respective functions
sub router{
  my $self=shift;
  my(%input)=@_; my $retval;
  if(not defined($self->{"$input{key}"}) or $self->{"$input{key}"} eq '' or
     $self->{"$input{key}"} eq "$input{default_key}"){
    my $function=$input{default_function};
    $retval=$function;
  }
  else{
    foreach $function (keys %{$input{function}}){
      print "<!-- function: $function -->\n";
      if($self->{"$input{key}"} eq "$function"){
        print "<!-- execute function: $function = $input{function}{$function} -->\n";
        my $function=$input{function}{$function};
        $retval=$function;
      }
    }
  }
  $self->event("$self->{sys_mod}","$retval");
  return $retval;
}


# connectsql: establish the connection with a database (typically the DIFR database as ancillary database
#             connections would impact performance to a degree...
#
# example:
#
# connectsql(<server path to file containing sql details>);
#
# when used from a module the form would be:
#
# 	$g->connectsql("/Library/WebServer/model/nameofsqlconnectionfile.conn");
#
# contents of a conn file are: database name,mysql server name or IP,mysql username,mysql password
# the file must have no carriage return at the end of the line and the file must be a one liner
sub connectsql{
  my $self=shift; my $retval=1;
	my($conn)=@_;
	open(FIL,"<$conn") or die "cannot open $conn : $!"; # or err_trap("Content-type: text/html\n\ncannot open $conn : $!");
	my ($d,$h,$u,$p);
  while(my $line=<FIL>){
    chomp($line);
    if($line ne ""){($d,$h,$u,$p)=split(/\,/,$line); next;}
  }
 #      PrintError => 0,   ### Don't report errors via warn(  )
 #      RaiseError => 1    ### Do report errors via die(  )
  $retval=DBI->connect("DBI:mysql:$d:$h","$u","$p",{PrintError=>1,RaiseError=>0}) or
	  die("Cannot connect to database: $DBI::errstr");
  $self->{dbh}=$retval;
	return $retval;
}

sub countries{
  my $self=shift;
  my @retval;
  open(FIL,"<$self->{countryfile}") or die "Cannot open country-codes from $self->{countryfile} $!";
  while(my ($country,$twodigitcode,$threedigitcode)=split(/\,/,<FIL>)){push(@retval,"$country - $twodigitcode");}
  return @retval;
}  

# event: This routine sends events to the interface_events table anytime this Perl module or a DIFR module request
#        an event to be logged.
#
# usage: event(<type>,<description>); ~where type is typically the name of the module and description is the payload
#        of the event being logged.
sub event{
  my $self=shift;
  my($type,$desc)=@_; if($self->{sys_sid} eq ''){$self->{sys_sid}='0';}
  $sth=$self->{dbh}->prepare(
    "insert into interface_events values('0',\"$self->{sys_sid}\",\"$type\",\"$desc\",\"$self->{sys_username}\",\"$self->{sys_hostname}\",\"$self->{sys_user_ip}\",now())"
  );
  $sth->execute;
}

#            FIELDS         ***************************************************
sub fields{
  my $self=shift;
  my ($table)=@_; my $retval='';
  #print qq(Database: $database<br />\n);
  $sth=$self->{dbh}->prepare("show fields from $table"); $sth->execute();
  while(my($f)=$sth->fetchrow_array()){$retval.="$f,";}$retval=~s/\,+$//;
  return $retval;
}

sub filelist{
    my $self=shift;
    my ($document_type,$ref_name,$ref_id,$call_name,$call_value,$subref_name,$subref_id)=@_;
    my $uploaddir="$self->{webroot}$self->{appname}/documents/$document_type/$ref_id";
    print "\n<!-- uploaddir: $uploaddir -->\n";
    unless(-d "$uploaddir"){mkdir "$uploaddir";}
    if($subref_id ne ''){$uploaddir.="/$subref_id"; unless(-d "$uploaddir"){mkdir "$uploaddir";}}

    opendir(DIR,"$uploaddir") or die "Cannot open cache directory<br />";
    print qq(<p><center><i>Right-click on a file to select the option to open in a new window, tab, or download the file.</i></center></p>);
    
    print qq(\n<table border=1 cols=2>\n<tr>\n\t<th>Filename</th><th>Action</th>\n</tr>\n);
    my $check=0; while(my $filename=readdir(DIR)){
      unless($filename=~m/^\./){
        print qq(<tr>\n\t<td style="background: white;"><a href="$uploaddir/$filename">$filename</a></td>\n);
	if($self->{my_roles}=~m/del/){
	  print qq(\t<td style="background: white;"><a href="$self->{scriptname}?action=edit&chdel=$filename&uploaddir=$uploaddir&$ref_name=$ref_id">delete</a></td>\n);
	}
	else{print qq(\t<td> </td>\n);}
        print qq(</tr>\n);
	$check=1;
      }
    }
    closedir(DIR);    
    if($check==0){print qq(\t<td colspan=2 style="background: white;"><center>There are no $document_type documents on file.\n</center></td>\n);}
    print qq(</table><br />\n);
  
    if($self->{my_roles}=~m/edit/){  
      print
      qq(\n<center>
      <div style="background-color: white; border: solid 1px black; width: 500px;">
        <form method ="GET" action="$self->{scriptname}" enctype="multipart/form-data" id="upload">
	  <input type="file" name="uploadfilename" override=1 />
	  <input type="hidden" name="$ref_name" value="$ref_id" />
	  <input type="hidden" name="$call_name" value="$call_value" />
          <input type="hidden" name="uploaddir" value="$uploaddir" />
          <input type='submit' value='Upload' />
        </form>
      </div>
      </center>
      </fieldset>
      );    
    }        
}

# header: begins writing an html file that is the instance of a request to DIFR
#         the $self->{sys_theme} is obtained from the current users configured theme
sub header{
  my $self=shift;
  my ($state,$status,$sid,$key,$theme);

	# create cookie DIFR_SESSION ~to check whether cookies are enabled
  $status=$self->{CGI}->cookie(-name=>'client_status',-value=>'enabled',-expires=>'+1h',-path=>'/');

  # create session and key cookies if passed
  if(defined($self->{sys_key}) and defined($self->{sys_sid}) and $self->{action} eq 'buildup'){
  	$sid=$self->{CGI}->cookie(-name=>'client_sid',-value=>"$self->{sys_sid}",-expires=>'+1d',-path=>'/');
  	$key=$self->{CGI}->cookie(-name=>'client_key',-value=>"$self->{sys_key}",-expires=>'+1d',-path=>'/');
  	$self->{msg}="\n<div class='container'>\n";
    $self->{msg}.="  <div class='jumbotron'>\n";
    $self->{msg}.="    <h3>Authentication Successful.</h3>\n";
    $self->{msg}.="    <p>Session $self->{sys_sid} created.</p>\n";
    $self->{msg}.="  </div>\n</div>\n";
  }

  # hurl cookies if logout is indicated
	if($self->{action} eq 'logout'){
  	$sid=$self->{CGI}->cookie(-name=>'client_sid',-value=>"$self->{sys_sid}",-expires=>'-1d',-path=>'/');
  	$key=$self->{CGI}->cookie(-name=>'client_sid',-value=>"$self->{sys_key}",-expires=>'-1d',-path=>'/');
  	$self->{msg}=' ';
  	#$self->{dbh}->do("update interface_sessions set expires");
	}

  # deal with themes in a manner to circumvent old way of doing things
  #$self->{sys_theme}=$self->{CGI}->cookie('DIFR_THEME');
  #if($self->{sys_theme} eq ''){$self->{sys_theme}='varesearch';}

  my $check=$self->{CGI}->cookie('client_status');
  if($check eq 'enabled'){
    # get session data and key from cookies
    my $sid=$self->{CGI}->cookie('client_sid');
    my $key=$self->{CGI}->cookie('client_key');
    $self->{sys_theme}=$self->{CGI}->cookie('client_theme');

    # validate session
    $state=$self->sessionquery($sid,$key);

  }else{$self->{msg}="\n<div class='container'><div class='jumbotron'><h3>Cookies must be enabled to access this system.</h3></div></div>\n";}

  if($self->{sys_theme} eq ''){
    $self->{sys_theme}=$self->{dbh}->selectrow_array("select dvalue from difr_settings where setting='DIFR' and dkey='theme'");
    $self->{chtheme}=$self->{sys_theme};
  }
  $theme=$self->{CGI}->cookie(-name=>'client_theme',-value=>"$self->{sys_theme}",-expires=>'+2d',-path=>'/');

  # write cookies
  if($sid ne '' and $key ne ''){print $self->{CGI}->header(-cookie=>[$status,$theme,$sid,$key]);}
  elsif($self->{chtheme} ne ''){
    $self->{sys_theme}=$self->{chtheme};
    $theme=$self->{CGI}->cookie(-name=>'client_theme',-value=>"$self->{chtheme}",-expires=>'+2d',-path=>'/');
    if($sid ne ''){
      $self->{dbh}->do("update interface_users set theme='$self->{chtheme}' where username='$self->{sys_username}'");
      $self->{dbh}->event("Theme","$self->{sys_username} changed theme to '$self->{chtheme}'");
    }
    print $self->{CGI}->header(-cookie=>[$status,$theme]);
  }
  else{print $self->{CGI}->header(-cookie=>$status);}

  $self->include("themes/$self->{sys_theme}/header.html");
  my ($product,$module)=split(/\_/,$self->{sys_mod});
  if(-e "$self->{modpath}/$product/$module.js"){
    print "\n<!-- including jQuery module, $self->{sys_mod}.js -->\n";
    $self->include("$self->{modpath}/$product/$module.js");
  }
  if("$self->{scriptname}" eq "register.pl"){
    $self->include("register.js");
  }
  print qq(\n</head>);

  # set up module path to load
	$self->{modulepath}=$self->{modpath}.'/'.$self->{sys_mod};
	$self->{modulepath}=~s/\_/\//g; $self->{modulepath}.='.pl';
	#($self->{modgroup},$self->{modname})=split(/\_/,$self->{});
}

# header5: begins writing an html file that is the instance of a request to DIFR
#         the $self->{sys_theme} is obtained from the current users configured theme
sub header5{
  my $self=shift;
  my ($state,$status,$sid,$key,$theme);

	# create cookie DIFR_SESSION ~to check whether cookies are enabled
  $status=$self->{CGI}->cookie(-name=>"$self->{appname}_status",-value=>'enabled',-expires=>'+1h',-path=>'/');

  # create session and key cookies if passed
  if(defined($self->{sys_key}) and defined($self->{sys_sid}) and $self->{action} eq 'buildup'){
  	$sid=$self->{CGI}->cookie(-name=>"$self->{appname}_sid",-value=>"$self->{sys_sid}",-expires=>'+1d',-path=>'/');
  	$key=$self->{CGI}->cookie(-name=>"$self->{appname}_key",-value=>"$self->{sys_key}",-expires=>'+1d',-path=>'/');
	$self->{msg}="<div id=full><h3 style='width: 740px;'>Authentication Successful.</h3><p>Session $self->{sys_sid} created.</p>";
        $self->{msg}.="<center><a class=\"continue\" href=\"index.pl\">Continue</a></center>";
        $self->{msg}.="<p>For instructions on how to use this system, you can access the latest documentation here: <a href='http://www.etherfeat.com/difr/latest-manual.pdf'>User Manual</a></p>";
	$self->{msg}.="<p>For support by email: <a href='mailto:support\@etherfeat.com'>support\@etherfeat.com</a></p>";
	$self->{msg}.="<p>For support by phone: Toll-Free (US &amp; Canada) dial: <b><em>888.873.6050</em></b></p>";
	$self->{msg}.="<p>Daily Hours of Operation: <b><em>Monday - Friday 0700 - 1900 HRS GMT -5 (US Eastern Time)</em></b></p></div>";
  }

  # hurl cookies if logout is indicated
	if($self->{action} eq 'logout'){
  	$sid=$self->{CGI}->cookie(-name=>"$self->{appname}_sid",-value=>"$self->{sys_sid}",-expires=>'-1d',-path=>'/');
  	$key=$self->{CGI}->cookie(-name=>"$self->{appname}_sid",-value=>"$self->{sys_key}",-expires=>'-1d',-path=>'/');
  	$self->{msg}=' ';
  	#$self->{dbh}->do("update interface_sessions set expires");
	}

  # deal with themes in a manner to circumvent old way of doing things
  #$self->{sys_theme}=$self->{CGI}->cookie('DIFR_THEME');
  #if($self->{sys_theme} eq ''){$self->{sys_theme}='varesearch';}

  my $check=$self->{CGI}->cookie("$self->{appname}_status");
  if($check eq 'enabled'){
    # get session data and key from cookies
    my $sid=$self->{CGI}->cookie("$self->{appname}_sid");
    my $key=$self->{CGI}->cookie("$self->{appname}_key");
    $self->{sys_theme}=$self->{CGI}->cookie("$self->{appname}_theme");

    # validate session
    $state=$self->sessionquery($sid,$key);

  }else{$self->{msg}='Cookies must be enabled to access this system.';}

  if($self->{sys_theme} eq ''){
    $self->{sys_theme}=$self->{dbh}->selectrow_array("select dvalue from difr_settings where setting='DIFR' and dkey='theme'");
    $self->{chtheme}=$self->{sys_theme};
  }
  $theme=$self->{CGI}->cookie(-name=>"$self->{appname}_theme",-value=>"$self->{sys_theme}",-expires=>'+2d',-path=>'/');

  # write cookies
  if($sid ne '' and $key ne ''){print $self->{CGI}->header(-cookie=>[$status,$theme,$sid,$key]);}
  elsif($self->{chtheme} ne ''){
    $self->{sys_theme}=$self->{chtheme};
    $theme=$self->{CGI}->cookie(-name=>"$self->{appname}_theme",-value=>"$self->{chtheme}",-expires=>'+2d',-path=>'/');
    if($sid ne ''){
      $self->{dbh}->do("update interface_users set theme='$self->{chtheme}' where username='$self->{sys_username}'");
      $self->{dbh}->event("Theme","$self->{sys_username} changed theme to '$self->{chtheme}'");
    }
    print $self->{CGI}->header(-cookie=>[$status,$theme]);
  }
  else{print $self->{CGI}->header(-cookie=>$status);}

  #$self->include("themes/$self->{sys_theme}/header.html");

  print qq(<!DOCTYPE html>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <meta charset="utf-8"> 
  <title>$self->{sitename}</title>
  <meta name="generator" content="Bootply" />
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <!-- Bootstrap core CSS -->
  <link href="bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Custom styles for this template -->
  <link href="themes/bootstrap/extra.css" rel="stylesheet">

  <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
  <meta name="keywords" content="" />
  <meta name="description" content="">
  <meta name="author" content="">
  <link rel="icon" href="../../favicon.ico">
    
  <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
  <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->);


  my ($product,$module)=split(/\_/,$self->{sys_mod});
  $self->{modulename}=$module;
  
  if(-e "$self->{modpath}/$product/$module.js"){ 
    print "\n<!-- including jQuery module, $self->{sys_mod}.js -->\n";
    $self->include("$self->{modpath}/$product/$module.js");
  }
  if("$self->{scriptname}" eq "register.pl"){
    $self->include("register.js");
  }
  print qq(\n</head>);

  # set up module path to load
	$self->{modulepath}=$self->{modpath}.'/'.$self->{sys_mod};
	$self->{modulepath}=~s/\_/\//g; $self->{modulepath}.='.pl';
	#($self->{modgroup},$self->{modname})=split(/\_/,$self->{});
}


# include: used to include a file to be parsed as html
#
# Perl module inclusions ~not using HTML::Template
#
# Example: $g->include("/path/to/include/somefile.html");
sub include{
  my $self=shift;
  my($file)=@_;
  open(FILE,"<$file") or die "Cannot open $file! : $!";
  while(<FILE>){print;}
  close(FILE);
}

# login: presents a site viewer that does not have an active session with the dialog to log into DIFR
#        this includes a username, password, and submit button
sub login{
  my $self=shift;
  if($self->{sys_username} ne ""){$self->authenticate();}
  else{
#    print $self->{CGI}->ul(
    #$self->{CGI}->li($self->{CGI}->a({-href=>"http://$self->{domainname}/"},"Exit Portal")),
   # $self->{CGI}->li(
#    $self->{CGI}->center( 
#    $self->{CGI}->start_form({-method=>"post",-action=>"$self->{scriptname}",-id=>"input"}),
#    $self->{CGI}->label({-for=>"sys_username"},"Username"),
#    $self->{CGI}->textfield({-name=>"sys_username",-value=>"$self->{sys_username}",-size=>"11",-id=>"input-focus",-override=>1}),
#    $self->{CGI}->label({-for=>"password"},"Password"),
#    $self->{CGI}->password_field({-name=>"password",-value=>"$self->{password}",-size=>"11",-override=>1}),
    #$self->{CGI}->label({-for=>"sys_domain"}),
    #$self->{CGI}->popup_menu({-name=>"sys_domain",-size=>"1",-values=>["DOMAIN","LOCAL"],-default=>"LOCAL",-override=>1}),
#    $self->{CGI}->hidden({-name=>"sys_domain",-value=>"LOCAL"}),
#    $self->{CGI}->submit("Login"),
#    $self->{CGI}->end_form(),
#    ),
     #    ), 
#    );
  }
}

sub menubuilder3{
  my $self=shift; my %m;
  if($self->{sys_sid} eq ""){$self->login(); return;}

  # pack modules user has access to into menu hash %m
  my $mods=$self->{dbh}->selectcol_arrayref("
      select name from interface_modules left join interface_module_access
      on interface_modules.name=interface_module_access.module
      where interface_module_access.username='$self->{sys_username}' order by module");
  foreach $mod (@{$mods}){
    my ($modgroup,$modname)=split(/\_/,$mod);
    $m{lc($modgroup)}{lc($modname)}='';
  }
  # inject modules that may not be listed in db into menu hash
  # add ability to log out of interface
  $m{interface}{logout}="";
  $m{interface}{preferences}="";

  # generate menu
  print qq(\n<nav class="navbar navbar-inverse navbar-fixed-top">);
  print qq(\n  <div class="container">);
  print qq(\n    <div class="navbar-header">);
  print qq(\n      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">);
  print qq(\n        <span class="sr-only">Toggle navigation</span>);
  print qq(\n        <span class="icon-bar"></span>);
  print qq(\n        <span class="icon-bar"></span>);
  print qq(\n        <span class="icon-bar"></span>);
  print qq(\n      </button>);
  print qq(\n      <a class="navbar-brand" href="$self->{scriptname}">$self->{sitename}</a>);
  print qq(\n    </div>);
  print qq(\n    <div id="navbar" class="navbar-collapse collapse">);
  print qq(\n      <ul class="nav navbar-nav">);
  foreach my $group (sort keys %m){
    #print qq(  <li><a href=''>$group</a>\n);
    #print qq(    <ul>\n);
    foreach my $mod (sort keys %{ $m{$group} }){
      my $menucssclass=''; if("$group\_$mod" eq $self->{sys_mod}){$menucssclass='active'; $self->{sys_modname}=$mod;}
      print qq(\n        <li class="$menucssclass"><a href="$self->{scriptname}?chmod=$group\_$mod">$mod</a></li>);
    }
    # print qq(    </ul>\n);
    # print qq(  </li>\n);
  }
  print qq(\n      </ul> <!-- end menu generation -->);
  print qq(\n    </div><!-- /.navbar-collapse -->);
  print qq(\n  </div>);
  print qq(\n</nav>\n);
}

sub menubuilder2{
  my $self=shift; my %m;
  if($self->{sys_sid} eq ""){$self->login(); return;}

  # pack modules user has access to into menu hash %m
  my $mods=$self->{dbh}->selectcol_arrayref("
      select name from interface_modules left join interface_module_access
      on interface_modules.name=interface_module_access.module
      where interface_module_access.username='$self->{sys_username}' order by module");
  foreach $mod (@{$mods}){
    my ($modgroup,$modname)=split(/\_/,$mod);
    $m{lc($modgroup)}{lc($modname)}='';
  }
  # inject modules that may not be listed in db into menu hash
  # add ability to log out of interface
  $m{interface}{logout}="";
  $m{interface}{preferences}="";

  # generate menu
  print qq(\n<ul> <!-- begin menu generation -->\n);
  foreach my $group (sort keys %m){
  print qq(  <li><a href=''>$group</a>\n);
  print qq(    <ul>\n);
    foreach my $mod (sort keys %{ $m{$group} }){
      my $menucssclass=''; if("$group\_$mod" eq $self->{sys_mod}){$menucssclass='selected'; $self->{sys_modname}=$mod;}
      print qq(       <li><a class="$menucssclass" href="$self->{scriptname}?chmod=$group\_$mod">$mod</a></li>\n);
    }
   print qq(    </ul>\n);
   print qq(  </li>\n);
  }
  print qq(\n</ul> <!-- end menu generation -->\n);

#  if("$module" eq $self->{sys_mod}){
#    $menucssclass="selected";
#  }
#  print $self->{CGI}->li({-class=>"$menucssclass",-onclick=>"parent.location='$self->{scriptname}?chmod=$module'",-title=>"$m{$module}"},
#    $self->{CGI}->a({-href=>"$self->{scriptname}?chmod=$module",
#                               -onclick=>"parent.location='$self->{scriptname}?chmod=$module'",
#                               -title=>"$m{$module}"},"$m{$module}"),
#      );

}

sub moduleloader{
  my $self=shift;

  # print message if there is one
  if($self->{msg} ne ''){print $self->{CGI}->h3("$self->{msg}");}

  # load module if there is a session
  if($self->{sys_sid} ne ""){
      #    # print "\n<!-- roles: $g->{my_roles} groups: $g->{my_groups}//-->\n";
    if(-e "$self->{modulepath}"){require "$self->{modulepath}";}
    else{print "<br />the module you are requesting, '$self->{sys_mod}', does not exist<br />";}
  }

  # otherwise they get the main welcome clap trap
  else{require "$self->{modpath}/interface/data.pl";}
}

# msg: sends messaged to browser window
# usage: msg("text of message to send to browser window");
#        within a module the format is $g->msg("message text goes here");
sub msg{
  my $self=shift;
  my ($msg)=@_;
  open(OUT,">msg/$self->{sys_user_ip}\^$self->{sys_hostname}\^login") or
    print "msg/$self->{sys_user_ip}\^login : $!";
  print OUT $msg;
  close(OUT);
}

sub new{
  my $invocant=shift;
  my $class=ref($invocant) || $invocant; # object or class name
  my $self= {
    webroot => $ENV{'DOCUMENT_ROOT'},
    CGI => new CGI,
    dbh => "unknown",
    appname => 'portal',
    sys_sid => "",
    sys_key => "",
    sys_username => "",
    sys_vars => "",
    sys_begin => "",
    sys_expire => "",
    sys_firstname => "",
    sys_timeout => "",
    sys_user_ip => $ENV{'REMOTE_ADDR'},
    sys_iphash => inet_aton("$self->{sys_user_ip}"),
    sys_hostname => gethostbyaddr($self->{sys_iphash},AF_INET),
    sys_status => "",
    sys_mod => "interface_entry", # interface_welcome ...
    sys_modname => "",
    @_,
  };

  #sys_theme => "difr",

  #$self->{sys_user_ip}=$ENV{'REMOTE_ADDR'};
  #$self->{sys_iphash}=inet_aton("$self->{sys_user_ip}");
  #$self->{sys_hostname}=gethostbyaddr($self->{sys_iphash},AF_INET);
  $self->{uploaddir}="$self->{webroot}$self->{appname}/upload";
  $self->{cachedir}="$self->{webroot}$self->{appname}/cache";
  $self->{themes}="$self->{webroot}$self->{appname}/themes";

  if(not defined($self->{sys_hostname})){$self->{sys_hostname}=$self->{sys_user_ip};}

  ## get all params...
  #$self->{CGI}=new CGI;
  my @p=$self->{CGI}->param();
  foreach $var(@p){$self->{$var}=$self->{CGI}->param($var);}
  return bless $self, $class;
}

#           PRETTY          ****************************************************************
# input: elementname from difr_elements table
# output: prettyname
sub pretty{
  my $self=shift;
  my($elementname)=@_;
  my $retval=$self->{dbh}->selectrow_array("select prettyname from difr_elements where element_name=\"$elementname\"");
  return $retval;
}

#           RECORD_ADD        ************************************************************

sub record_add{
  my $self=shift;
  my ($table,$ref,%form,$confirm)=@_;
  my $fields=$self->fields($table);
  my @fields=$self->array(',',$fields);

  if($recordtitle ne ''){print $self->{CGI}->h4("Inserting Record");}

  if(defined($self->{$ref}) and $self->{$ref} ne ''){ # confirm record creation
    if(defined($self->{confirm}) and $self->{confirm} eq 'true'){
      print $self->{CGI}->h4("Inserting New Record");

      # perform sql insertion
      my $query="insert into $table values(";
      foreach $element (@fields){
        $query.="\"$self->{$element}\",";
      } $query=~s/\,+$//; $query.=")";
      print "$query<br />";
      my $retval=$self->{dbh}->do("$query");
      return;
    }
    else{
      print $self->{CGI}->h4("Confirm Record Creation"),
      $self->{CGI}->start_table({-cols=>2}),
      $self->{CGI}->Tr(
        $self->{CGI}->th("Field"),$self->{CGI}->th("Value"),
      );

      # form to re record details and submit back and cancel buttons
      foreach $element (@fields){
        print $self->{CGI}->Tr(
          $self->{CGI}->td($self->tc($element)),
          $self->{CGI}->td("$self->{$element}"),
        );
      }
      print $self->{CGI}->end_table();
      return;
    }
  }
  else{
    # create form with fields from table
    print $self->{CGI}->h4("New Record");
    print $self->{CGI}->start_table({-cols=>"2"}),
    $self->{CGI}->Tr(
      $self->{CGI}->th("Field"),
      $self->{CGI}->th("Value"),
    ),
    $self->{CGI}->start_form({-action=>"$self->{scriptname}",-method=>"GET"}),
    $self->{CGI}->div({-id=>"floatright"},$self->{CGI}->submit("Save"),);
    foreach $element (@fields){
      if($element eq $ref){$form{$element}{value}='0';}else{$form{$element}{value}='';}
      if($element eq 'description'){$form{$element}{size}='50';}else{$form{$element}{size}='30';}
      my $type=$form{$element}{type};
      my @values; foreach $value (keys %{$form{$element}{value}}){push @values, $value;}
      print qq(<!-- hashref: $form{$element}{type}-->);

      print $self->{CGI}->Tr(
        $self->{CGI}->th("$element"),
        $self->{CGI}->th(
          $self->{CGI}->textfield({-name=>"$element",-size=>"$form{$element}{size}",-value=>"$form{$element}{value}",-override=>1}),
        ),
      );
    }

    print
    $self->{CGI}->hidden({-name=>"type",-value=>"$self->{type}"}),
    $self->{CGI}->hidden({-name=>"action",-value=>"$self->{action}"}),
    $self->{CGI}->hidden({-name=>"confirm",-value=>"true"}),
    $self->{CGI}->endform(),
    $self->{CGI}->end_table();
  }
}

sub record_edit{
  my $self=shift;
  my($table,$ref,%form,$recordtitle)=@_;
  my $fields=$self->fields('difr_'.$self->{type});
  my @fields=$self->array(',',$fields);
  if($recordtitle ne ''){print $self->{CGI}->h4("Editing $recordtitle");}
  if(not defined($self->{id}) or $self->{id} eq ''){
    print $self->{CGI}->h3("Record does not exist.");
    return;
  }
  if(defined($self->{confirm})){
    # update record
    # build query
    my $query="update $table set ";
    foreach $element (@fields){if ($ref ne $element){$query.="$element=\"$self->{$element}\",";}} $query=~s/\,+$//;
    $query.="where $ref=\"$self->{$ref}\"";
    #print "$query<br />";
    $self->{dbh}->do("$query");
  }

  print $self->{CGI}->start_table({-cols=>"2"}),
  $self->{CGI}->Tr(
    $self->{CGI}->th("Field"),
    $self->{CGI}->th("Value"),
  ),
  $self->{CGI}->start_form({-action=>"$self->{scriptname}",-method=>"GET"}),
  $self->{CGI}->div({-id=>"floatright"},$self->{CGI}->submit("Save"),);
  $sth=$self->{dbh}->prepare("select $fields from $table where id=$self->{id}"); $sth->execute();
  my $polarity='odd';
  while(my $f=$sth->fetchrow_hashref()){
    foreach $element (@fields){
      my $type=$form{$element}{type};
      my @values; foreach $value (keys %{$form{$element}{value}}){push @values, $value;}
      print qq(<!-- hashref: $form{$element}{value}-->);
      if($form{$element}{type} ne ''){
        print $self->{CGI}->Tr({-class=>"$polarity"},$self->{CGI}->td({-class=>"$polarity"},"$element"),$self->{CGI}->td({-class=>"$polarity"},
            $self->{CGI}->$type({-size=>"$form{$element}{size}",-name=>"$element",-default=>"$self->{$element}",-value=>\@values,-operride=>'1'}),
        ),);
      }
      else{
        print
        $self->{CGI}->Tr({-class=>"$polarity"},
        $self->{CGI}->td({-class=>"$polarity"},"$element"),
        $self->{CGI}->td({-class=>"$polarity"},
          $self->{CGI}->textfield({-name=>"$element",-value=>"$f->{$element}",-override=>1}),
        ),
      );
      }
    }
    if($polarity eq 'odd'){$polarity='even';}else{$polarity='odd';}
  }

  print
  $self->{CGI}->hidden({-name=>"confirm",-value=>"$self->{confirm}",-override=>1}),
  $self->{CGI}->hidden({-name=>"type",-value=>"$self->{type}",-override=>1}),
  $self->{CGI}->hidden({-name=>"action",-value=>"edit",-override=>1}),
  $self->{CGI}->end_form(),
  $self->{CGI}->end_table();
}


sub sessionquery{
  my $self=shift; my($psid,$pkey)=@_; my $retval='false';
  my($sid,$username,$key,$vars,$begin,$expire)=
  $self->{dbh}->selectrow_array(
    "select interface_sessions.id,interface_sessions.username,interface_sessions.key,interface_sessions.vars,interface_sessions.begin,
    interface_sessions.expire
     from interface_sessions left join interface_users on interface_sessions.username=interface_users.username
     where interface_sessions.id='$psid' and interface_sessions.key='$pkey' and interface_users.active='true'
      and interface_sessions.expire > date_add(now(),interval 0 second)"
  ); #,interface_users.theme
  if($sid ne ""){
    $retval='true';
    $self->{sys_sid}=$sid; $self->{sys_username}=$username; $self->{sys_vars}=$vars;
    $self->{sys_begin}=$begin; $self->{sys_expire}=$expire; $self->{sys_timeout}=$timeout;
    my $var="";
    my $a=0; my @vars=split(/\s/,$vars); my $temp;
    foreach $item(@vars){
      unless($a%2==1){$item=~s/\s+//; $temp=$item;}
      else{
        $self->{$temp}=$item;
        if($self->{var} eq ""){$self->{var}="$temp $item";}
        else{$self->{var}.=" $temp $item";}
      } ++$a;
    }
    # sessions vars
    $self->{dbh}->do("update interface_sessions set expire=date_add(now(),interval 180 minute) where id='$sid'");

    ## change theme if requested
    #if($self->{chtheme} ne ""){
    #  $self->{dbh}->do("update interface_users set theme='$self->{chtheme}' where username='$username'");
    #  $self->{sys_theme}=$self->{chtheme}; $self->{function}="themes";
    #  system("echo update interface_users set theme=$self->{chtheme} where username=$username >> chtheme.log");
    #}

    # change module if requested
    if($self->{chmod} ne ""){
      $self->{dbh}->do("update interface_sessions set vars='sys_mod $self->{chmod}' where id='$sid'");
      $self->event("chmod","$self->{sys_mod} to $self->{chmod}");
      $self->{sys_mod}=$self->{chmod};
    }

    if($self->{chpasswd} ne ""){
      my $msg="";
      if($self->{chpasswd} eq "request"){
        if($self->{new_password} ne ""){
          if($self->{new_password} ne $self->{verify}){
            if(length($self->{new_password}) > 7){
              $self->{dbi}->do("update interface_users set password=md5(\"$self->{new_password}\") where username='$username'");
              $msg="Your password has been changed.";
            }else{$msg="Your new password must be at least 8 characers long.  You must try again to change your password.";}
          }else{$msg="The passwords entered did not match.  You must try again to change your password.";}
        }else{$msg="You must enter a new password.  Your password has not been changed.";}
      }
      #open(OUT,">$www/msg/$self->{user_ip}\^$self->{sys_hostname}\^login");
      #print OUT $msg;
      #close(OUT);
      $self->{msg}="$msg";
    }

    # retrieve a list of roles the user is allowed to have in the module they are accessing
    ($self->{my_roles},$self->{my_groups})=$self->{dbh}->selectrow_array(
      "select roles,groups from interface_module_access where module='$self->{sys_mod}' and username='$self->{sys_username}'"
    );

    # deal with uploaded files...
    #system("echo upload not detected uploadfilename='$self->{uploadfilename}' >> upload.log");
    if($self->{uploadfilename} ne ""){
      system("echo upload detected uploadfilename=$self->{uploadfilename} >> upload.log");
      unless(-e "$self->{uploaddir}/$self->{uploadfilename}"){
        my $file=$self->{uploadfilename};
        my @contents=<$file>; my $line;
        $file=~s/.*[\/\\](.*)/$1/;
	    $file=~s/([^\w.-])/_/g; $file=~s/^[-.]+//;
        # deal with windows full path filename & replace spaces with underscore
        my @tmp=split(/\\/,$self->{uploadfilename});
        foreach $e(@tmp){$self->{uploadfilename}=$e;}
        $self->{uploadfilename}=~s/\s+/\_/g;
        open(OUT,">upload/$self->{uploadfilename}") or
          print "cannot create $self->{uploadfilename} : $!";
        foreach $line(@contents){print OUT $line;}
      }
    }
  }
  else{
    $self->{sys_mod}="interface_entry"; # interface_welcome ...
    #$self->{sys_theme}=$self->{default_theme};
  }
  return $retval;
}

# sessionmaker: creates a user session for authenticated users.  A session is substantiated by inserting session
#                       data into the DIFR sessions database table as well as creating a session cookie
#
sub sessionmaker{
  my $self=shift;
  my($message)=@_;
  print $self->{CGI}->img({-src=>"themes/$self->{sys_theme}/wait30trans.gif"});
  my %vars; $vars{sys_mod}=$self->{modhome}; my @vars=%vars;

  use Time::localtime; my $tm=localtime; my $xhour;
  my ($mday,$month,$year,$wday,$hour,$min,$sec)=
     ($tm->mday,$tm->mon+1,$tm->year+1900,$tm->wday,$tm->hour,$tm->min,$tm->sec);

	my $md5_data = "$self->{sys_username}$year$month$mday";
	my $md5_hash = md5_hex( $md5_data );

  # insert session into table and retrieve id
  my $insert="insert into interface_sessions values('0','$self->{sys_username}','$self->{sys_hostname}','$md5_hash','$self->{sys_user_ip}','@vars',date_add(now(),interval 0 second),date_add(now(),interval 5 minute))";
  $sth=$self->{dbh}->prepare($insert); $sth->execute() or die "cannot execute statement : $self->{dbh}->errstr";
  my $sid=$self->{dbh}->{'mysql_insertid'};
  # set session and key cookies for future validation
  print "<script>window.location=\"$self->{scriptname}?sys_key=$md5_hash&sys_sid=$sid&action=buildup&msg=$self->{msg}\"</script>";
}

#           SUBMENU           ************************************************************
# input: sourcename from difr_sources table
# output: submenu
sub submenu{
  my $self=shift;

  my($sourcename)=@_;
  # get source_id from sourcename input
	my ($source_id)=$self->{dbh}->selectrow_array("select id from difr_sources where sourcename=\"$sourcename\"");

	# this is going to hit difr_elements as relates to the source_id from above
	my $query="select element_name,prettyname,description from difr_elements where source_id=$source_id order by prettyname";
	$sth=$self->{dbh}->prepare("$query"); $sth->execute(); my %tab;

	print qq(\n<ul class="list-inline">\n); # <div id="horizontalmenu">\n id="horizontalmenu"
	while(my $t=$sth->fetchrow_hashref()){
	  my $selected='';
	  if($t->{element_name} eq $self->{type}){$selected='selected'; $typetitle="$t->{prettyname}";}
    print $self->{CGI}->li({-class=>"$selected"},
      $self->{CGI}->a({-class=>"$selected",-href=>"$self->{scriptname}?type=$t->{element_name}",
                    	-title=>"$t->{description}"},"$t->{prettyname}"
      ),
    );
  }
  print qq(</ul>\n <!-- end submenu -->\n\n); # </div>
}

sub system_menu{
  my ($self)=shift;
  my %menuhash=@_;
#  my %menuhash=("Authentication"=>"authentication","Email Settings"=>"email","Alerts"=>"alerts",
#                "Monitoring"=>"monitoring","Recovery"=>"recovery","Power"=>"power","View"=>"view");
  print qq(\n<ul class="list-inline">\n);
  foreach $key( reverse sort keys %menuhash){
    my $selected; if($menuhash{$key} eq $self->{function}){$selected='selected';}
    print $self->{CGI}->li({-id=>"$selected"},$self->{CGI}->a({-class=>"$selected",-href=>"$g->{scriptname}?function=$menuhash{$key}"},"$key"));
  }
  print qq(</ul> <!-- end system menu -->\n\n);
}

#  my %menuhash=("Authentication"=>"authentication","Email Settings"=>"email","Alerts"=>"alerts",
#                "Monitoring"=>"monitoring","Recovery"=>"recovery","Power"=>"power","View"=>"view");

sub system_menu_unrestricted{
  my ($self)=shift;
  my %menuhash=@_;
  print qq(\n<ul class="nav nav-tabs">\n);
  foreach $key( reverse sort keys %menuhash){
    my $selected; if($menuhash{$key} eq $self->{function}){$selected='active';}
    #if($self->{my_roles}=~m/$menuhash{$key}/){
      print $self->{CGI}->li({-role=>"presentation",-class=>"$selected"},$self->{CGI}->a({-class=>"$selected",-href=>"$g->{scriptname}?function=$menuhash{$key}"},"$key"));
    #}
  }
  print qq(</ul> <!-- end system menu -->\n\n);
}


sub system_menu_role_restricted{
  my ($self)=shift;
  my %menuhash=@_;
  print qq(\n<ul class="nav nav-tabs">\n);
  foreach $key( reverse sort keys %menuhash){
    my $selected; if($menuhash{$key} eq $self->{function}){$selected='active';}
    if($self->{my_roles}=~m/$menuhash{$key}/){
      print $self->{CGI}->li({-role=>"presentation",-class=>"$selected"},$self->{CGI}->a({-class=>"$selected",-href=>"$g->{scriptname}?function=$menuhash{$key}"},"$key"));
    }
  }
  print qq(</ul> <!-- end system menu -->\n\n);
}


sub aside_menu{
  my ($self)=shift;
  my %menuhash=@_;
#  my %menuhash=("Authentication"=>"authentication","Email Settings"=>"email","Alerts"=>"alerts",
#                "Monitoring"=>"monitoring","Recovery"=>"recovery","Power"=>"power","View"=>"view");
  print qq(\n<ul class="list-inline">\n);
  $self->{asidemenu}="\n    <aside>\n      <ul>\n";
  foreach $key( reverse sort keys %menuhash){
    my $selected; if($menuhash{$key} eq $self->{function}){$selected='selected';}
    print $self->{CGI}->li({-id=>"$selected"},$self->{CGI}->a({-class=>"$selected",-href=>"$g->{scriptname}?function=$menuhash{$key}"},"$key"));
  }
  print qq(\n</ul> <!-- end aside_menu -->\n);
}

#            TABLE_LIST       ***************************************************]

# input: takes a table name as parameter followed by database name

# output: returns an html table listing of fields with optional elements

sub table_list{
  my $self=shift;
  my($table,$ref,$constraints)=@_;
  my $fields=$self->fields($table);
  my @fields=$self->array(',',$fields);
  my $query="select $fields from $table";
  if($constraints ne ''){$query.=" where $constraints";}

  print "\n<p>query: $query</p>\n";
  print $self->{CGI}->start_table({-cols=>@fields+1});
  print qq(<tr>\n);
  foreach $e (@fields){print $self->{CGI}->th("$e");}
  print $self->{CGI}->th("Action");
  print qq(</tr>\n);
  $sth=$self->{dbh}->prepare("$query"); $sth->execute();
  my $polarity='odd';
  while(my $f=$sth->fetchrow_hashref()){
    print qq(<tr class="$polarity">\n);
    foreach $element (@fields){
      if($element eq 'subtype'){
        print $self->{CGI}->td({-class=>"$polarity"},
          $self->{CGI}->a({-href=>"$self->{scriptname}?type=$f->{$element}&ref=$ref&ref_value=$f->{$ref}"},"$f->{$element}"),
        );
      }
      else{
        print $self->{CGI}->td({-class=>"$polarity"},$f->{$element});
      }
    }

    print $self->{CGI}->td({-class=>"$polarity"},
      $self->{CGI}->a({-href=>"$self->{scriptname}?type=$self->{type}&action=edit&$ref=$f->{$ref}"},"Edit"),
      $self->{CGI}->a({-href=>"$self->{scriptname}?type=$self->{type}&action=delete&$ref=$f->{$ref}"},"Delete"),
    );

    if($polarity eq 'odd'){$polarity='even';}else{$polarity='odd';}
  }
  print $self->{CGI}->end_table();
}

#           TC              ***************************************************
# input:  scalar
# output: returns scalar in titlecase
sub tc {
    my $self=shift;
    #assumes lowercase, space-separated string
    #returns same with first letters of words in caps

    #use local variables
    my ($s) = @_;
    my (@st);

    #split string
    @st = split(/ /, $s);

    #loop over strings
    $n = 0;
    foreach $l (@st) {
        #return with first let. caps
        $l = ucfirst($l);
        #assign back to array
        $st[$n] = $l;
        $n++;
    }

    #join the strings into one
    $s = join(" ", @st);
    return $s;
}

sub query_list{
  my $query_repo='documents/queries';
    my $self=shift;
    my ($document_type,$ref_name,$ref_id,$call_name,$call_value,$subref_name,$subref_id)=@_;
    my $uploaddir="documents/$document_type/$ref_id";
    unless(-d "$uploaddir"){mkdir "$uploaddir";}
    if($subref_id ne ''){$uploaddir.="/$subref_id"; unless(-d "$uploaddir"){mkdir "$uploaddir";}}

    opendir(DIR,"$uploaddir") or die "Cannot open cache directory<br />";
    #print qq(<p><center><i>Right-click on a file to select the option to open in a new window, tab, or download the file.</i></center></p>);
    
    print qq(\n<table border=1 cols=2>\n<tr>\n\t<th>Query</th><th>Action</th>\n</tr>\n);
    my $check=0; while(my $filename=readdir(DIR)){
      unless($filename=~m/^\./){
        print qq(<tr>\n\t<td style="background: white;"><a href="$uploaddir/$filename">$filename</a></td>\n);
	if($self->{my_roles}=~m/del/){
	  print qq(\t<td style="background: white;"><a href="$self->{scriptname}?action=edit&chdel=$filename&uploaddir=$uploaddir&$ref_name=$ref_id">delete</a></td>\n);
	}
	print qq(\t<td><a href="$self->{scriptname}?$call_name=$call_value&$ref_name=$ref_value">Execute</a></td>\n);
        print qq(</tr>\n);
	$check=1;
      }
    }
    closedir(DIR);    
    if($check==0){print qq(\t<td colspan=2 style="background: white;"><center>There are no $document_type documents on file.\n</center></td>\n);}
    print qq(</table><br />\n);
  
    #if($self->{my_roles}=~m/edit/){  
    #  print
    #  qq(\n<center>
    #  <div style="background-color: white; border: solid 1px black; width: 500px;">
    #    <form method ="GET" action="$self->{scriptname}" enctype="multipart/form-data" id="upload">
    #  	  <input type="file" name="uploadfilename" override=1 />
    #	  <input type="hidden" name="$ref_name" value="$ref_id" />
    #	  <input type="hidden" name="$call_name" value="$call_value" />
    #      <input type="hidden" name="uploaddir" value="$uploaddir" />
    #      <input type='submit' value='Upload' />
    #    </form>
    #  </div>
    #  </center>
    #  </fieldset>
    #  );    
    #}          
}

sub call_support{
	my $self=shift;
	my ($error,$payload)=@_;
	my $message="Instance: $self->{appname}\n Module: $self->{sys_mod}\n Username: $self->{sys_username}\n Error Text: $error\n Details: $payload\n";
	print qq(
	<h4 align='center'>An Error Has Occured</h4>
	<div id='error'>
		<h3>$error
		<br /><br />
		Click <a href="mailto:$self->{email_support}?Subject=$self->{email_support} Error&Body=$message">here</a>
		to report this issue to support.\n
		</h3>
	</div>\n)
	and return;
	return;
}

1;
