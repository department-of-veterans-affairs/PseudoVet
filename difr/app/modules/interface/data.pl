#!/usr/bin/perl
use Digest::MD5 qw(md5_hex);

print qq(
    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="/index.html">$g->{sitename}</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
	    	<li><a href="/about.html">About</a></li>
        <li><a href="/charities.html">Charities</a></li>
	    	<li><a href="/sponsors.html">Sponsors</a></li>
	    	<li><a href="/packages.html">Packages</a></li>
<!--	    	<li class="active"><a href="/index.html">Back</a></li>
-->          </ul>
        </div><!--/.navbar-collapse -->
      </div>
    </nav>
);

if($g->{action} eq ''){
  print $g->{CGI}->div({-class=>"container"},
    $g->{CGI}->div({-class=>"well well-sm"},
      $g->{CGI}->p("Don't have an account yet?   ", 
        $g->{CGI}->a({-class=>"btn btn-primary btn-sm",-role=>"button",-href=>"http://$g->{domainname}/$g->{appname}/register.pl"},"Create Account"),
      ),
    ),
    $g->{CGI}->div({-class=>"well well-sm"},
      $g->{CGI}->p("Did you forget your username or password?   ", 
        $g->{CGI}->a({-class=>"btn btn-primary btn-sm",-role=>"button",-href=>"$g->{scriptname}?action=iforgot"},"Password Reset"),
      ),
    ),
    $g->{CGI}->div({-class=>"row"},
      $g->{CGI}->div({-class=>"col-sm-6 col-md-4 col-md-offset-4"},
        $g->{CGI}->h1({-class=>"text-center login-title"},"Login"),
        $g->{CGI}->start_form({-class=>"form-signin",-method=>"post",-action=>"$g->{scriptname}",-id=>"input"}),
          $g->{CGI}->textfield({-class=>"form-control",-placeholder=>"Username",-name=>"sys_username",-value=>"$g->{sys_username}",-id=>"input_focus",-override=>1}),
          $g->{CGI}->password_field({-class=>"form-control",-placeholder=>"Password",-name=>"password",-value=>"$g->{password}",-override=>1}),
          $g->{CGI}->hidden({-name=>"sys_domain",-value=>"LOCAL"}),
          $g->{CGI}->submit({-class=>"btn btn-lg btn-primary btn-block",-value=>"Sign in"}),
        $g->{CGI}->end_form(),
      ), # close col-sm-6 ...
    ), # close row
  ), # close container
  $g->{CGI}->br(),$g->{CGI}->hr(),
  $g->{CGI}->p("If you are having problems logging in, please contact us: ",
    $g->{CGI}->a({-href=>"mailto:$g->{email_support_display}?subject=$g->{sitename} Account Login Issue $g->{username}&body=<Please enter any information you think may be helpful>"},"$g->{email_support_display}"),
  );
}
elsif($g->{action} eq 'iforgot'){
  print $g->{CGI}->h3("Can't Login?"),
  #$g->{CGI}->p("We can send you your username and a temporary password if you enter the email address you used to create your EtherFeat account."),
  $g->{CGI}->p("Enter your email address:",
    $g->{CGI}->start_form({-method=>"POST",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"findme",-override=>1}),
      $g->{CGI}->textfield({-name=>"email",-value=>"",-size=>"60",-override=>1}),
      $g->{CGI}->submit("Submit"),
    $g->{CGI}->end_form(),
  ),
  $g->{CGI}->p("If your email address is tied to an account, we will email you your username and a temporary password so you can log back in and change it.");
}
elsif($g->{action} eq 'findme'){
  my $user=$g->{dbh}->selectrow_array("select username from interface_users where email='$g->{email}'");
  if($user ne ''){
    print $g->{CGI}->h3("Account Found"),
    $g->{CGI}->p("We have found your account and are emailing your username and a temporary password so you can log in.");
    # make temporary password ($md5_hash)
    use Time::localtime; my $tm=localtime; my $xhour;
    my ($mday,$month,$year,$wday,$hour,$min,$sec)=
    ($tm->mday,$tm->mon+1,$tm->year+1900,$tm->wday,$tm->hour,$tm->min,$tm->sec);
	  my $md5_data = "$user$year$month$mday$hour$min$sec";
	  my $md5_hash = md5_hex( $md5_data );
    #open(FIL,"+>../../temp/$g->{username}.validation") or die "Cannot create validation key $!";
    #print FIL "$md5_hash";
    #close(FIL);

    # reset account password ... remove md5( ) 
    my $reset_password_cmd="update interface_users set password=md5('$md5_hash') where username='$user' and email='$g->{email}'";
    my $reset_password_msg=$g->{dbh}->do("$reset_password_cmd");
    open(LOGGER,"+>$g->{tempfiles}/password_reset.log") or die "Error.  Check permissions of $g->{tempfiles}.\n";
    print LOGGER $reset_password_cmd;
    print LOGGER $reset_password_msg;
    close(LOGGER);
    
    # pull userdata for email message: salutation firstname middle lastname
    my($salutation,$firstname,$middle,$lastname)=$g->{dbh}->selectrow_array("select salutation,firstname,middle,lastname from interface_user_demographics where username='$user'");

    my $filename="$user.message";

    # compose email message payload
    my $message="MIME-Version: 1.0\nContent-Type: text/html\n";
    $message.="Subject:$g->{sitename} Account Access\n";
    $message.="$salutation $firstname $middle $lastname:<br /><br />\n\n";
	  $message.="Your $g->{sitename} account password has been reset.<br /><br />\n\n";
	  $message.="Your username is: <b>$user</b><br />\n\n";
	  $message.="Your password is: <b>$md5_hash</b><br />\n\n";
    $message.="<p>Please login at <a href='http://$g->{domainname}/$g->{appname}/index.pl'>http://$g->{domainname}/$g->{appname}/index.pl</a></p>\n\n";
#    $message.="<img src=\"http://www.etherfeat.com/images/etherfeat-clear.png\" />";
#    $message.="<img src=\"http://www.etherfeat.com/images/etherfeat_clouds_flip-900.png\" />";

    # create file to write the contents of this email alert message
    open(ALRT,"+>$g->{tempfiles}/$filename") or die "Error.  Check permissions of $g->{tempfiles}.\nCannot create $filename : @!\n";
    #print $message;
    print ALRT $message;
    close(ALRT);

    # send an email to the email address on file for the username
    my $emailcmd="/usr/sbin/sendmail -F'$g->{sitename}' -f'$g->{email_support}' -v $g->{email} < $g->{tempfiles}/$filename >>$g->{tempfiles}/mail.log";
    #print "$emailcmd\n";
    system("$emailcmd");

    unlink "$g->{tempfiles}/$filename";
  }
  else{
    if($g->{email} !~m /[A-Z0-9._+-]+\@[A-Z0-9.-]+\.[A-Z]{2,4}/i){
      print 
      $g->{CGI}->div({-id=>"record"},
        $g->{CGI}->p(
          "You did not enter a valid email address.  Please try enterining it again.<br /><br />",
          "Enter your email address:<br />",
          $g->{CGI}->center(
            $g->{CGI}->start_form({-method=>"POST",-action=>"$g->{scriptname}"}),
            $g->{CGI}->hidden({-name=>"action",-value=>"findme",-override=>1}),
            $g->{CGI}->textfield({-name=>"email",-value=>"",-size=>"60",-override=>1}),
            $g->{CGI}->submit("Submit"),
            $g->{CGI}->end_form(),
          ),
        ),
      );
    }
    else{
    print 
    $g->{CGI}->div({-id=>"record"},
      $g->{CGI}->p("I could not find an account for the email address: $g->{email}<br /><br />",
                 "If you need help contact support <a href='mailto:$g->{email_support}?subject=$g->{sitename} Access Issue'>Click here</a>"),
    );
    }
  }
}
else{
  print $g->{CGI}->h3("You are not logged in"),
  $g->{CGI}->ul(
    $g->{CGI}->center(
    $g->{CGI}->start_form({-method=>"post",-action=>"$g->{scriptname}",-id=>"input",
    -style=>"border: 1px solid black; background: f9f9f9; width: 200px;"}),
    $g->{CGI}->label({-for=>"sys_username"},"Username"),
    $g->{CGI}->textfield({-name=>"sys_username",-value=>"$g->{sys_username}",-size=>"11",-id=>"input-focus",-override=>1}),
    $g->{CGI}->br(),
    $g->{CGI}->label({-for=>"password"},"Password"),
    $g->{CGI}->password_field({-name=>"password",-value=>"$g->{password}",-size=>"11",-override=>1}),
    $g->{CGI}->hidden({-name=>"sys_domain",-value=>"LOCAL"}),
    $g->{CGI}->br(),
    $g->{CGI}->submit("Login"),
    $g->{CGI}->end_form(),
    ),
  ),  
  $g->{CGI}->br();
}
1;
