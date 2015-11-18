#!/usr/bin/perl -w
# index.pl for DIFR version 3.0
# If you don't know the code, don't mess around below - BCIV
# 11/07/2003~BCIV
# 12/09/2005~BCIV
# 20110125~BCIV
# 20110207~BCIV
# 20150909~BCIV

use lib "../../difr/app";
use controller; our $g=new controller;

my $sth; my $rv;

$CGI::POST_MAX = 1024 * 10000;
$CGI::DISABLE_UPLOADS = 0;

require '../../difr/app/app.config';

$g->connectsql($g->{sqlconf});

$g->header5;

use constant UPLOAD_DIR => $g->{uploaddir};
use constant MAX_OPEN_TRIES => 100;

my $displayname=''; if($g->{sys_username} ne '' and $g->{sys_sid} ne ''){$displayname="Logged in: $g->{sys_username}";}

print qq(\n<body>\n<div class="main">\n);

$g->menubuilder3;

print qq(\n<div class="container">
<br /><br /><br /> 
); # <!-- <div style="float: right;">$displayname&nbsp;&nbsp;</div> -->

# load module only if there is a session
if($g->{sys_sid} ne ""){
  # print "\n<!-- roles: $g->{my_roles} groups: $g->{my_groups}//-->\n";
  print "\n<!-- loading module: $g->{sys_mod} -->\n";
  if(-e "$g->{modulepath}"){
    my ($uname)=$g->{dbh}->selectrow_array("select username from interface_module_access where module='$g->{sys_mod}' and username='$g->{sys_username}'");
    if($g->{sys_mod} eq 'interface_logout'){
      require "$g->{modulepath}";
    }
    elsif($uname eq $g->{sys_username}){
      require "$g->{modulepath}";
    }
    else{
      print "<br />You do not have access to the module you are requesting: $g->{sys_mod}<br />\n";
      print "<p>uname: '$uname' did not match: '$g->{sys_username}'</p>";
      $sth=$g->{dbh}->prepare("select module from interface_module_access where username='$g->{sys_username}'"); $sth->execute();
      print qq(<ul>\n); while(my($module)=$sth->fetchrow_array()){
      print $g->{CGI}->li("$module");
      }
      print qq(</ul>\n);
    }
  }
  else{
    print qq(<div class="container">
              <br /><br /><br />
              <p>The module you are requesting, '$g->{sys_mod}', does not exist.</p><br />
    );         
  }
}
# otherwise they get the main welcome clap trap
else{require "$g->{modpath}/interface/data.pl";}

$g->{dbh}->disconnect;

print qq(
</div>
<br /><br /><br /><div>
<footer class="footer">
  <p>Copyright &copy; <script type=text/javascript>var theDate=new Date(); document.write(theDate.getFullYear());</script> $g->{sitename} &#149 <a mailto:$g->{email_support}>Contact Webmaster</a></p>
</footer>
</div> <!-- end container -->
</div> <!-- end main -->
<!-- js dependencies -->
<script src="bower_components/jquery/dist/jquery.min.js"></script>
<script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
</body>
</html>);
