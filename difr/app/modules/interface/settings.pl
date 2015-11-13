#!/usr/bin/perl
# exclusion types module for DIFR by BCIV
# If you don't know the code, don't mess around below -bciv

#$g->system_menu("Alerts"=>"alerts","Authentication"=>"authentication","Email Settings"=>"email",
#"Logs"=>"logs","Network"=>"network","Recovery"=>"recovery","Power"=>"power","Updates"=>"updates");

# release "Recovery"=>"recovery", in 2.9 i hope
$g->system_menu("Authentication"=>"authentication","Power"=>"power","Theme"=>"theme","Updates"=>"updates");

print qq(\n<div id="page_effect">\n);

my $function=$g->controller(
  "key"=>'function',
  "default_key"=>'overview',
  "default_function"=>'view',
  "function"=>{
    "alerts"=>'alerts',
    "authentication"=>'authentication',
    "email"=>'email',
    "logs"=>'logs',
    "network"=>'network',
    "overview"=>'view',
    "power"=>'power',
    "recovery"=>'recovery',
    "theme"=>'theme',
    "updates"=>'updates',
  },
); &$function;
1; # end module

sub theme{
  if($g->{action} eq 'set'){
    $g->{dbh}->do("update difr_settings set dvalue='$g->{theme}' where setting='DIFR' and dkey='theme'");
  }
  my($gtheme)=$g->{dbh}->selectrow_array("select dvalue from difr_settings where setting='DIFR' and dkey='theme'");

  print $g->{CGI}->h3("Theme"),
  $g->{CGI}->p("Click on a theme to change the default appearance of this DIFR system.",
  "<br />\n<i>*The theme selected here will only be visible to users that have not chosen a theme, are new to the system, or have cleared their browser cookies.</i>",
  );
  my @themes;
  opendir(DIR,"$g->{themes}") or die "Cannot open $g->{themes} $!";
  while(defined($themedir=readdir(DIR))){
    if(-d "$g->{themes}/$themedir" and $themedir !~/^\./){push(@themes,$themedir);}
  }
  closedir(DIR);
  foreach $theme (@themes){
    my $selected=""; my $selectedtext=""; if($gtheme eq $theme){$selected='selected'; $selectedtext=" [selected]";}
    print $g->{CGI}->h3("$theme $selectedtext"),
    $g->{CGI}->a({-href=>"$g->{scriptname}?function=theme&action=set&theme=$theme"},
      $g->{CGI}->img({-class=>"$selected",-src=>"/$g->{appname}/themes/$theme/screenshot.png",-width=>"620",-border=>1}),
    );
  }
}
sub updates{
  # interface to check for updates and install them
  print $g->{CGI}->br(),$g->{CGI}->h3("Updates"),
  $g->{CGI}->h4("DIFR can check for software updates, security patches, as well as general bug fixes from EtherFeat."),
  $g->{CGI}->p("To see if there are any new updates to apply, you can check them now by clicking this button:"),
  $g->{CGI}->submit("Check Now"),
  $g->{CGI}->br(),
  $g->{CGI}->textarea({-rows=>5,-cols=>"100",-default=>"No updates are available at this time.",-disabled=>"disabled"});
  #> talk to www.etherfeat.com
  #> communicate license information
  #< receive confirmation that license is valid
  #< receive information token to allow update and where to get update from
  #< get version manifest for licensed software
  #= compare to see what versions are latest
  #> request versions that aren't installed
  #< download updates
  #= install updates
  #~ email result of upgrade attempt to system administrator
  #~ email result of upgrade to support@etherfeat.com
}

sub view{
  print #$g->{CGI}->div({-id=>"navlinks"},$g->{CGI}->a({-href=>"#"},"link"));
  $g->{CGI}->br(),
  $g->{CGI}->h3("Settings Summary");
  # pull information from difr_settings table...
  # which should contain
  # software:
  # 1. manufacturer
  # 2. product
  # 4. version
  # 5. revision
  # 6. module listing
  # hardware:
  # 1. cpu
  # 2. RAM
  # 3. disk info
  # 4. process info
  # 5. uptime
  # bogus info for initial release
  print $g->{CGI}->h4("Software Details"),
  $g->{CGI}->start_table({-cols=>2,-width=>"97%"}),
  $g->{CGI}->Tr($g->{CGI}->th({-width=>"50%"},"Key"),$g->{CGI}->th("Value")),
  $g->{CGI}->Tr({-class=>"odd"},$g->{CGI}->td({-width=>"50%"},"Manufacturer"),$g->{CGI}->td("EtherFeat LLC")),
  $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-width=>"50%"},"Platform"),$g->{CGI}->td("GNU/Linux x86 2.6.22 Kernel")),
  $g->{CGI}->Tr({-class=>"odd"},$g->{CGI}->td({-width=>"50%"},"Product"),$g->{CGI}->td("Dynamic Interface For Records")),
  $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-width=>"50%"},"Version"),$g->{CGI}->td("2.8")),
  $g->{CGI}->Tr({-class=>"odd"},$g->{CGI}->td({-width=>"50%"},"Revision"),$g->{CGI}->td("0")),
  $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-width=>"50%"},"Modules"),$g->{CGI}->td("Research Compliance Suite")),
  $g->{CGI}->Tr({-class=>"odd"},$g->{CGI}->td({-width=>"50%"},"License"),$g->{CGI}->td("0673VATAM")),
  $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-width=>"50%"},"Support"),$g->{CGI}->td("0673VATAM-SUP110331")),
  $g->{CGI}->end_table();

  print $g->{CGI}->h4("Hardware Details"),
  $g->{CGI}->start_table({-cols=>2,-width=>"97%"}),
  $g->{CGI}->Tr($g->{CGI}->th({-width=>"50%"},"Key"),$g->{CGI}->th("Value")),
  $g->{CGI}->Tr({-class=>"odd"},$g->{CGI}->td({-width=>"50%"},"Manufacturer"),$g->{CGI}->td("VMWare Virtual Machine")),
  $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-width=>"50%"},"CPU"),$g->{CGI}->td("1 vCPU")),
  $g->{CGI}->Tr({-class=>"odd"},$g->{CGI}->td({-width=>"50%"},"RAM"),$g->{CGI}->td("512Mb")),
  $g->{CGI}->Tr({-class=>"even"},$g->{CGI}->td({-width=>"50%"},"Drives"),$g->{CGI}->td("1 Volume - 8GB")),
  $g->{CGI}->end_table();

}

sub authentication{
  my @settings=('authtype','anonymousaccess','username','password','primaryserver','secondaryserver',
                'port','domain','searchbase');

  # update settings if they were set
  if($g->{action} eq 'set'){
    foreach $key (@settings){
      my $query="update difr_settings set dvalue='$g->{$key}' where setting='authentication' and dkey='$key'";
      print "\n<!-- $query -->\n";
      $g->{dbh}->do("$query");
    }
  }

  # retrieve settings from database
  $sth=$g->{dbh}->prepare("select dkey,dvalue from difr_settings where setting='authentication'"); $sth->execute();
  my %r; while(my ($key,$value)=$sth->fetchrow_array()){$r{$key}="$value";}
  if($r{port} eq ''){$r{port}='3389';}
  if($r{searchbase} eq ''){$r{searchbase}="This is needed for LDAP example: ou=People,dc=etherfeat,dc=net";}

  print $g->{CGI}->br(),$g->{CGI}->h3("Authentication");

  if($r{authtype} eq ''){
    print
    $g->{CGI}->p("DIFR can use Local usernames and passwords or an external authentication system such as Active Directory to authenticate users."),
    $g->{CGI}->p("To enable the use of Active Directory or another authentication system, DIFR will need some information about
                  your network's authentication configuration."),
    $g->{CGI}->p("<i>*If you are unsure about these settings or are not an Active Directory Administrator, you will need to contact your IT Department to have someone with the proper level of access configure these settings.</i>");
  }
  # options: active directory / LDAP
  # setting local admin password
  # future: add pam, Radius and NIS as authentication methods
  print qq(
<script type="text/javascript">
function changeText(el){
var txt = el.options[el.selectedIndex].text;
var div = document.getElementById('LDAP');
while (div.firstChild) div.removeChild(div.firstChild);
div.appendChild(document.createTextNode(txt));
}
</script>
  );
  print $g->{CGI}->h4("Authentication System"),
    $g->{CGI}->p("Select the type of Authentication system that DIFR will use for user accounts."),
    $g->{CGI}->div({-id=>"record"},
    # have a div for each authtype that is toggled into view by selecting the authtype
    $g->{CGI}->div({-id=>"LDAP",-style=>"display: none;"},"LDAP",),
    $g->{CGI}->div({-id=>"Local Only",-style=>"display: none;"},"Local Only"),
    $g->{CGI}->div({-id=>"Active Directory",-style=>"display: none;"},"Active Directory"),
    $g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
    $g->{CGI}->hidden({-name=>"function",-value=>"authentication"}),
    $g->{CGI}->hidden({-name=>"action",-value=>"set"}),
    $g->{CGI}->label({-for=>"authtype"},"Authentication System"),
    $g->{CGI}->popup_menu({-size=>"1",-name=>"authtype",-values=>["Local Only","LDAP","Active Directory"],-default=>"$r{authtype}",-override=>1,
    -onChange=>"changeText(this);"}),
    $g->{CGI}->br(),$g->{CGI}->br(),
    "If the authentication system allows anonymous access select 'Yes'.  If it does not, the username and password will be used
     will be used to connect to the authentication system.<br />",
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"anonymousaccess"},"Anonymous Connections?"),
    $g->{CGI}->popup_menu({-size=>"1",-name=>"anonymousaccess",-values=>["Yes","No"],-default=>"$r{anonymousaccess}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"username"},"Username"),
    $g->{CGI}->textfield({-size=>"50",-name=>"username",-value=>"$r{username}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"password"},"Password&nbsp;"),
    $g->{CGI}->textfield({-size=>"50",-name=>"password",-value=>"$r{password}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"primaryserver"},"Primary Authentication Server"),
    $g->{CGI}->textfield({-size=>"50",-name=>"primaryserver",-value=>"$r{primaryserver}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"secondaryserver"},"Secondary Authentication Server"),
    $g->{CGI}->textfield({-size=>"50",-name=>"secondaryserver",-value=>"$r{secondaryserver}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"port"},"Port"),
    $g->{CGI}->textfield({-size=>"10",-name=>"port",-value=>"$r{port}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"domain"},"Domain"),
    $g->{CGI}->textfield({-size=>"100",-name=>"domain",-value=>"$r{domain}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"searchbase"},"SearchBase"),
    $g->{CGI}->textfield({-size=>"100",-name=>"searchbase",-value=>"$r{searchbase}",-override=>1}),
    ),
    #$g->{CGI}->textarea({-cols=>80,-rows=>5,-default=>"Nothing to see here"}),
  # form for SMB, FTP, or SSH protocol
  # server name or IP for backups
  # retention expressed in weeks for backups
  # test button to check connectivity with backup server which will write and delete a file and send a pass or fail admin alert email
    $g->{CGI}->center($g->{CGI}->submit("Save Settings")),
    $g->{CGI}->end_form();
  # form for selection of backup to recover to
  # button to restore system to backup



}

sub recovery{
  # update settings if they were set
  if($g->{action} eq 'set'){
    my @settings=('protocol','path','username','password');
    foreach $key (@settings){
      my $query="update difr_settings set dvalue='$g->{$key}' where setting='recovery' and dkey='$key'";
      print "\n<!-- $query -->\n";
      $g->{dbh}->do("$query");
    }
  }

  # retrieve settings from database
  $sth=$g->{dbh}->prepare("select dkey,dvalue from difr_settings where setting='recovery'"); $sth->execute();
  my %r; while(my ($key,$value)=$sth->fetchrow_array()){$r{$key}="$value";}

  print $g->{CGI}->br(),$g->{CGI}->h3("Recovery");
  print $g->{CGI}->h4("External Backup Repository"),
    $g->{CGI}->p("You can configure DIFR to send backups to an external location via SSH or SMB (Windows Share)"),
    $g->{CGI}->div({-id=>"record"},
    $g->{CGI}->start_form({-method=>"GET",-action=>"$g->{scriptname}"}),
    $g->{CGI}->hidden({-name=>"function",-value=>"recovery"}),
    $g->{CGI}->hidden({-name=>"action",-value=>"set"}),
    $g->{CGI}->label({-for=>"protocol"},"Protocol"),
    $g->{CGI}->popup_menu({-size=>"1",-name=>"protocol",-values=>["SMB","SSH"],-default=>"$r{protocol}",-override=>1}),
    $g->{CGI}->br(),$g->{CGI}->br(),
    "If you are using a SMB Backup Path, enter it like this: <b>//servername/sharename</b><br />",
    "A SSH Backup Path would reflect a unix file path such as: <b>/var/backup/</b><br />",
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"path"},"Backup Path"),
    $g->{CGI}->textfield({-size=>"80",-name=>"path",-value=>"$r{path}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"username"},"Username"),
    $g->{CGI}->textfield({-size=>"20",-name=>"username",-value=>"$r{username}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"password"},"Password&nbsp;"),
    $g->{CGI}->textfield({-size=>"20",-name=>"password",-value=>"$r{password}",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->end_form(),
    ),
    $g->{CGI}->h4("Local Backup Retention"),
    $g->{CGI}->p("Set how long backups stay on this DIFR Server."),
    $g->{CGI}->div({-id=>"record"},
#      $g->{CGI}->start_form(-method),
      $g->{CGI}->label({-for=>"retention"},"Number of weeks to keep backups on this server:"),
      $g->{CGI}->textfield({-size=>3,-name=>"retention",-value=>"$retention",-override=>1}),
    ),
    #$g->{CGI}->textarea({-cols=>80,-rows=>5,-default=>"Nothing to see here"}),
  # form for SMB, FTP, or SSH protocol
  # server name or IP for backups
  # retention expressed in weeks for backups
  # test button to check connectivity with backup server which will write and delete a file and send a pass or fail admin alert email
  $g->{CGI}->h4("Recovery Settings"),
  $g->{CGI}->p("Choose a backup date to recover to."),

      $g->{CGI}->center($g->{CGI}->submit("Save Settings"));
  # form for selection of backup to recover to
  # button to restore system to backup
}

sub email{
  # form for configuring and testing email for the overall system
  print $g->{CGI}->br(),$g->{CGI}->h3("Email");
  # enable | disable email system
  # set smart host
  # set smart host authentication username and password
  # from email address of system
  # system hostname for mail
  # system domain information
  # test email send form
}

sub alerts{
  # form to enable, test, and configure alerts
  print $g->{CGI}->br(),$g->{CGI}->h3("Alerts");

}

sub logs{
  # form for setting up SNMP public and private strings as well as SYSLOG
  print $g->{CGI}->br(),$g->{CGI}->h3("Logs");
}

sub network{
  print $g->{CGI}->br(),$g->{CGI}->h3("Network");

  print $g->{CGI}->div({-id=>"record"},
    $g->{CGI}->start_form({-method=>'POST',-action=>"$g->{scriptname}"}),
    $g->{CGI}->hidden({-name=>"function",-value=>"network"}),
    $g->{CGI}->hidden({-name=>"action",-value=>"set"}),
    $g->{CGI}->label({-for=>"hostname"},"Hostname"),
    $g->{CGI}->textfield({-name=>"hostname",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"ipaddress"},"IP Address"),
    $g->{CGI}->textfield({-name=>"ipaddress",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"netmask"},"Network Mask"),
    $g->{CGI}->textfield({-name=>"netmask",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"gateway"},"Gateway Address"),
    $g->{CGI}->textfield({-name=>"gateway",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"ns1"},"DNS Server - Primary"),
    $g->{CGI}->textfield({-name=>"ns1",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"ns2"},"DNS Server - Secondary"),
    $g->{CGI}->textfield({-name=>"ns2",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"network"},"Network"),
    $g->{CGI}->textfield({-name=>"network",-value=>"",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->submit("Change Settings"),
    $g->{CGI}->br(),
    $g->{CGI}->end_form(),
  );
}

sub power{
  # form for power options: shutdown, restart
  #print qq(\n<div id="main">\n);
  print $g->{CGI}->br(),$g->{CGI}->h3("Power");

  if($g->{action} eq "reboot" and $g->{validate} eq 'true'){
    # reboot code
    $g->include("modules/interface/settings_reboot.html");
    $g->event("personnel","$g->{sys_username} rebooted DIFR from $g->{sys_hostname} [$g->{sys_ip}]");
    system("sudo /sbin/shutdown -r now");
  }
  elsif($g->{action} eq "shutdown" and $g->{validate} eq 'true'){
    # shutdown code
    $g->include("modules/interface/settings_shutdown.html");
    $g->event("personnel","$g->{sys_username} shutdown DIFR from $g->{sys_hostname} [$g->{sys_ip}]");
    system("sudo /sbin/shutdown -h now");
  }
  else{
    $g->include("modules/interface/settings_power.html");
  }
  #print qq(\n</div> <!-- end main -->\n);
}

sub system_menu{
  my %menuhash=("Authentication"=>"authentication","Email Settings"=>"email","Alerts"=>"alerts",
                "Monitoring"=>"monitoring","Recovery"=>"recovery","Power"=>"power","View"=>"view");
  print qq(\n<ul id="horizontalmenu">\n);
  foreach $key(sort keys %menuhash){
    my $selected; if($menuhash{$key} eq $g->{function}){$selected='selected';}
    print $g->{CGI}->li({-id=>"$selected"},$g->{CGI}->a({-id=>"$selected",-href=>"$g->{scriptname}?function=$menuhash{$key}"},"$key"));
  }
  print qq(\n</ul><!-- end modtab -->\n);
}

