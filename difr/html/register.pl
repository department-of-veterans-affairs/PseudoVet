#!/usr/bin/perl
# index.pl for DIFR version 2.8
# If you don't know the code, don't mess around below - BCIV
# 11/07/2003~BCIV
# 12/09/2005~BCIV
# 20110125~BCIV
# 20110207~BCIV

use Digest::MD5 qw(md5_hex);
use lib "../../lib";
use Client1; our $g=new Client1;

my $sth; my $rv;

$CGI::POST_MAX = 1024 * 10000;
$CGI::DISABLE_UPLOADS = 0;

$g->{protocol}='http'; # http or https
$g->{domainname}='www.patriotdaycharities.org';
$g->{sitename}='Patriot Day Charities';
$g->{support_email}="webmaster\\\@patriotdaycharities.org";
$g->{support_email_display}="webmaster\@patriotdaycharities.org";
$g->{appname}='app';
$g->{default_theme}="bootstrap";
$g->{modpath}="../../difr/pdc/modules";
$g->{tempfiles}="../../difr/pdc/temp";
$g->{sqlconf}="../../difr/pdc/pdc_app.conn";
$g->{modhome}="interface_preferences";
$g->{scriptname}="register.pl";
$g->{countryfile}="lib/country-codes.txt";
$g->connectsql($g->{sqlconf});

$g->header5;

use constant UPLOAD_DIR => $g->{uploaddir};
use constant MAX_OPEN_TRIES => 100;

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
          <a class="navbar-brand" href="/index.html">Patriot Day Charities</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
	    	    <li><a href="/about.html">About</a></li>
            <li><a href="/charities.html">Charities</a></li>
	    	    <li><a href="/sponsors.html">Sponsors</a></li>
	    	    <li><a href="/packages.html">Packages</a></li>
	    	    <li><a href="/app" target="_blank">Events</a></li>
            <li class="active"><a href="/app/register.pl">Register</a></li>
          </ul>
        </div><!--/.navbar-collapse -->
      </div>
    </nav>
    <div class="container">
    <br /><br /><br />
      <ul>
        <!-- <li>$g->{sys_username}</li> -->
        <!-- <li>Already Registered? <a href="$g->{protocol}://$g->{domainname}/$g->{appname}/">Click here</a></li> -->
        <!-- <li><a href="$g->{protocol}://$g->{domainname}">Exit Registration</a></li></ul> -->
      </ul>
    </div>
);  

  # print message if there is one
  if($g->{msg} ne ''){print $g->{CGI}->h3("$g->{msg}");}

  # load module if there is a session
  if($g->{sys_sid} ne ""){
      #    # print "\n<!-- roles: $g->{my_roles} groups: $g->{my_groups}//-->\n";
    if(-e "$g->{modulepath}"){require "$g->{modulepath}";}
    else{print "<br />the module you are requesting, '$g->{sys_mod}', does not exist<br />";}
  }

  else{
    if($g->{action} eq ''){
      # otherwise they get the registration welcome clap trap
      #require "$g->{modpath}/interface/data.pl";
      my @salutations=(" ","Mr.","Mrs.","Ms.","Dr.","Prof.","Rev","Sir","Dame","Sri");
      my @suffixes=(' ','Jr','Sr','II','III','IV','Esq.');
      my @countries=countries();

      print $g->{CGI}->div({-class=>"container"},
        $g->{CGI}->div({-class=>'row'},
          $g->{CGI}->startform({-name=>"registration_form",-action=>"$g->{scriptname}",-method=>"POST"}),
          $g->{CGI}->hidden({-name=>"action",-value=>"register"}),
          $g->{CGI}->div({-class=>'col-xs-6'},
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"username"},"Desired Username"),
              $g->{CGI}->textfield({-class=>"form-control",-name=>"username",-value=>"$g->{username}",-placeholder=>"Desired Username",-override=>1}),
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"passwordx"},"Password"),
              $g->{CGI}->password_field({-class=>"form-control",-name=>"passwordx",-value=>"$g->{passwordx}",-placeholder=>"Password",-override=>1}),
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"verifypassword"},"Verify Password"), # again
              $g->{CGI}->password_field({-class=>"form-control",-name=>"verifypassword",-value=>"$g->{verifypassword}",-placeholder=>"Password",-override=>1}),
              "<em style='font-size: 10px;'>Type your password again</em>",
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"firstname"},"Firstname"),
              $g->{CGI}->textfield({-class=>"form-control",-name=>"firstname",-value=>"$g->{firstname}",-placeholder=>"Firstname",-override=>1}),
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"middle"},"Middle Initial"),
              $g->{CGI}->textfield({-class=>"form-control",-name=>"middle",-value=>"$g->{middle}",-placeholder=>"Middle Initial",-override=>1}),
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"lastname"},"Lastname"),
              $g->{CGI}->textfield({-class=>"form-control",-name=>"lastname",-value=>"$g->{lastname}",-placeholder=>"Lastname",-override=>1}),
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"email"},"Email"),
              $g->{CGI}->textfield({-class=>"form-control",-name=>"email",-value=>"$g->{email}",-placeholder=>"Email",-override=>1}),
            ),
            $g->{CGI}->div({-class=>'form-group'},
              $g->{CGI}->label({-for=>"verifyemail"},"Verify Email"), 
              $g->{CGI}->textfield({-class=>"form-control",-name=>"verifyemail",-value=>"$g->{verifyemail}",-placeholder=>"Verify Email",-override=>1}),
            ),
            $g->{CGI}->submit({-class=>"btn btn-default",-name=>"Create Account"}),
          ),
        ),
      );
#      print
#      $g->{CGI}->h4(),
#      $g->{CGI}->div({-id=>"container"},
#        $g->{CGI}->div({-id=>"listform"},
#          $g->{CGI}->startform({-name=>"registration_form",-action=>"$g->{scriptname}",-method=>"POST"}),
#          $g->{CGI}->hidden({-name=>"action",-value=>"register"}),
#          $g->{CGI}->label({-for=>"username"},"Desired Username"),
#          $g->{CGI}->textfield({-name=>"username",-value=>"$g->{username}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"passwordx"},"Password"), # password
#          $g->{CGI}->password_field({-name=>"passwordx",-value=>"$g->{passwordx}",-override=>1}),
#          "<em style='font-size: 10px;'>At least 6 characters with letters and numbers</em>",
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"verifypassword"},"Verify Password"), # again
#          $g->{CGI}->password_field({-name=>"verifypassword",-value=>"$g->{verifypassword}",-override=>1}),
#          "<em style='font-size: 10px;'>Type your password again</em>",
# X          $g->{CGI}->br(),
# X         $g->{CGI}->label({-for=>"salutation"},"Salutation"), # salutation
# X         #$g->{CGI}->textfield({-name=>"salutation",-value=>"$g->{salutation}",-override=>1}),
# X         $g->{CGI}->popup_menu({-name=>"salutation",-default=>"$g->{salutation}",-values=>\@salutations,-override=>1}),
# X         $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"firstname"},"Firstname"), #firstname
#          $g->{CGI}->textfield({-name=>"firstname",-value=>"$g->{firstname}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"middle"},"Middle Initial"), # middle initial
#          $g->{CGI}->textfield({-name=>"middle",-value=>"$g->{middle}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"lastname"},"Lastname"), # lastname
#          $g->{CGI}->textfield({-name=>"lastname",-value=>"$g->{lastname}",-override=>1}),
# X         $g->{CGI}->br(),
# X         $g->{CGI}->label({-for=>"suffix"},"Suffix"), # suffix
# X         #$g->{CGI}->textfield({-name=>"suffix",-value=>"$g->{suffix}",-override=>1}),
# X         $g->{CGI}->popup_menu({-name=>"suffix",-default=>"$g->{suffix}",-values=>\@suffixes,-override=>1}),
# X         $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"email"},"Email"), # email
#          $g->{CGI}->textfield({-name=>"email",-value=>"$g->{email}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"verifyemail"},"Verify Email"), # email
#          $g->{CGI}->textfield({-name=>"verifyemail",-value=>"$g->{verifyemail}",-override=>1}),
#          #"Type your email address again so we know it isn't mistyped.",
#          $g->{CGI}->br(),
#          # information about where they come from
#          $g->{CGI}->label({-for=>"phone"},"Phone"), # phone
#          $g->{CGI}->textfield({-name=>"phone",-value=>"$g->{phone}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"jobtitle"},"Job Title"), # jobtitle
#          $g->{CGI}->textfield({-name=>"jobtitle",-value=>"$g->{jobtitle}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"company"},"Company"), # company
#          $g->{CGI}->textfield({-name=>"company",-value=>"$g->{company}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"department"},"Department"), # department
#          $g->{CGI}->textfield({-name=>"department",-value=>"$g->{department}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"country"},"Country"), # country
#          $g->{CGI}->popup_menu({-name=>"country",-default=>"$g->{country}",-values=>\@countries,-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"addressline1"},"Address Line 1"), # addressline1
#          $g->{CGI}->textfield({-name=>"addressline1",-value=>"$g->{addressline1}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"addressline2"},"Address Line 2"), # addressline2
#          $g->{CGI}->textfield({-name=>"addressline2",-value=>"$g->{addressline2}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"city"},"City"), # city
#          $g->{CGI}->textfield({-name=>"city",-value=>"$g->{city}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"stateprovince"},"State/Province"), # state/province
#          $g->{CGI}->textfield({-name=>"stateprovince",-value=>"$g->{stateprovince}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"postalcode"},"postalcode"), # postalcode
#          $g->{CGI}->textfield({-name=>"postalcode",-value=>"$g->{postalcode}",-override=>1}),
#          $g->{CGI}->br(),
#          $g->{CGI}->label({-for=>"submit"}," "),
#          $g->{CGI}->submit("Send Registration Request"),
#          $g->{CGI}->endform(),
#        ),
#      );
    }
    elsif($g->{action} eq 'register'){
      # validate form contents...
      my $validation='true';
#      my @vars=('username','passwordx','verifypassword','salutation','firstname','middle','lastname','suffix',
#                'email','verifyemail','phone','jobtitle','company','department','addressline1','addressline2',
#                'city','stateprovince','postalcode','country');

      my @vars=('username','passwordx','verifypassword','salutation','firstname','middle','lastname','suffix',
                'email','verifyemail','phone','jobtitle','company','department','addressline1','addressline2',
                'city','stateprovince','postalcode','country');


      # build a resubmission form for all variables that need adjustment...
      print qq(<div class='row'>),
      $g->{CGI}->startform({-method=>"POST",-action=>"$g->{scriptname}"}),
      $g->{CGI}->hidden({-name=>"action",-value=>"register"});
      my $form='false';
      foreach $var (@vars){
        my $message=""; my $pass='true'; my $type='hidden'; my $label=''; my @values;

        # username
        if($var eq 'username'){
          $label='Username';
          if($g->{$var} eq '' or length($g->{$var}) < 4){$message.='Username should be at least 4 characters long.  '; $type='textfield';}
          my $users=$g->{dbh}->selectcol_arrayref("select username from interface_users");
          foreach $user (@{$users}){
            if($user eq $g->{$var}){$message.="The username, $g->{$var} is already taken.  "; $type='textfield';}
            if($type eq 'textfield'){$form='true';}
          }
        }

        # password
        if($var eq 'passwordx'){
          unless($g->{$var}=~m/\d/ and $g->{$var}=~m/\D/ and length($g->{$var}) > 5){
            $label='Password'; $value=""; $type='textfield'; $message='Password must be at least 6 characters with both letters and numbers.';
            $form='true';
          }
        }

        # verifypassword
        if($var eq 'verifypassword'){
          unless($g->{passwordx}=~m/\d/ and $g->{passwordx}=~m/\D/ and length($g->{passwordx}) > 5){
            if($g->{$var} eq $g->{passwordx}){
              $label='Verify Password'; $value=''; $type='password_field'; $message='';
            }
            else{
              $label='Verify Password'; $value=''; $type='password_field'; $message='Passwords did not match.  Try again or click <a href="register.pl">here</a> to start over.';  $form='true';
        }}}

        # salutation NULL ok if($var eq 'salutation'){}

        # firstname ~not null
        if($var eq 'firstname' and $g->{$var} eq ''){
          $label='Firstname'; $type='textfield'; $message='You must enter your firstname'; $form='true';
        }
#        # middle ~not number 1 character
#        if($var eq 'middle'){
#          if($g->{$var}=~m/\D/i and length($g->{$var}) ne '1'){
#            $label='Middle Initial'; $type='textfield'; $message='Middle initial must be a letter of the alphabet'; $form='true';
#        }}
        # lastname ~not null
        if($var eq 'lastname' and $g->{$var} eq ''){
          $label='Lastname'; $type='textfield'; $message='You must enter your lastname'; $form='true';
        }

        # email & verifyemail match delimited by domain with @
        if($var eq 'email'){
          if($g->{$var} eq ''){
            $label='Email Address'; $type='textfield'; $message='Email address cannot be blank'; $form='true';
          }
          elsif($g->{$var}!~m /[A-Z0-9._+-]+\@[A-Z0-9.-]+\.[A-Z]{2,4}/i){
            $label='Email Address'; $type='textfield'; $message='Enter a valid email address'; $form='true';
        }}
#        # phone not null
#        if($var eq 'phone'){
#          if($g->{$var} eq ''){
#            $label='Phone Number'; $type='textfield'; $message='Phone number cannot be empty'; $form='true';
#          }
#          elsif($g->{$var}!~m /^\+?\d?[-. ]?\(?([2-9][0-8][0-9])\)?[-. ]?([2-9][0-9]{2})[-. ]?([0-9]{4})/
#           or $g->{$var}!~m/[0-9]{10}/
#          ){
#            $label='Phone Number'; $type='textfield'; $message='Enter a valid phone number including country and area code'; $form='true';
#        }}
#        # jobtitle not null
#        if($var eq 'jobtitle' and $g->{$var} eq ''){
#            $label='Job Title'; $type='textfield'; $message='Enter your Job Title'; $form='true';
#        }
#        # company not null
#        if($var eq 'company' and $g->{$var} eq ''){
#            $label='Company'; $type='textfield'; $message='Company cannot be blank'; $form='true';
#        }
#        # department not null
#        if($var eq 'department' and $g->{$var} eq ''){
#          $label='Department'; $type='textfield'; $message='Department cannot be blank'; $form='true';
#        }
#        # addressline1 not null
#        if($var eq 'addressline1' and $g->{$var} eq ''){
#          $label='Address Line 1'; $type='textfield'; $message='Address cannot be blank'; $form='true';
#        }
#        # addressline2 NULL OK
#        # city
#        if($var eq 'city' and $g->{$var} eq ''){
#          $label='City'; $type='textfield'; $message='City cannot be blank'; $form='true';
#        }
#        # stateprovince
#        if($var eq 'stateprovince' and $g->{$var} eq ''){
#          $label='State/Province'; $type='textfield'; $message='State/Province cannot be blank'; $form='true';
#        }
#        # postalcode
#        if($var eq 'postalcode' and $g->{$var} eq ''){
#          $label='Postal Code'; $type='textfield'; $message='ZIP/Postal Code cannot be blank'; $form='true';
#        }
#        # country
#        if($var eq 'country' and $g->{$var} eq ''){
#          $label='Country'; $type='popup_menu'; @values=countries(); $message=''; $form='true';
#        }
#        element("$label",$var,$g->{$var},"$type","$message","@values");
      }

      # show form if needed
      if($form eq 'true'){
        print $g->{CGI}->label({-for=>"submit"}," "),$g->{CGI}->submit("Resubmit Registration Form");
      }
      else{
        print 
        $g->{CGI}->div({-class=>"container"},
          $g->{CGI}->div({-class=>"jumbotron"},
            $g->{CGI}->h3("Your request for an account has been queued."),
            $g->{CGI}->p("The registration process is almost complete."),
            $g->{CGI}->p("You will receive an email confirmation shortly with a link to login to $g->{sitename}"),
            $g->{CGI}->p("If you do not receive an email contact: <a href='mailto:webmaster\@patriotdaycharities.org'>webmaster\@patriotdaycharities.org</a>"),
          ),
        );

        # create disabled account
        $g->{dbh}->do("insert into interface_users values('$g->{username}',NULL,'$g->{email}','bootstrap',3600,md5('$g->{passwordx}'));");
        $g->{dbh}->do("insert into interface_user_demographics values(
          '$g->{username}',NULL,'$g->{firstname}','$g->{middle}','$g->{lastname}',
          NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)");

        # generate a key for validation
        use Time::localtime; my $tm=localtime; my $xhour;
        my ($mday,$month,$year,$wday,$hour,$min,$sec)=
        ($tm->mday,$tm->mon+1,$tm->year+1900,$tm->wday,$tm->hour,$tm->min,$tm->sec);
	      my $md5_data = "$self->{username}$year$month$mday$hour$min$sec";
	      my $md5_hash = md5_hex( $md5_data );
        open(FIL,"+>$g->{tempfiles}/$g->{username}.validation") or die "Cannot create validation key $!";
        print FIL "$md5_hash";
        close(FIL);

        # generate payload for email to confirm account
        # compose email message payload

        my $filename="$g->{username}.message";

        # compose email message payload
        my $message="MIME-Version: 1.0\nContent-Type: text/html\n";
        $message.="Subject:$g->{sitename} Account Registration\n";
        $message.="$g->{salutation} $g->{firstname} $g->{middle} $g->{lastname}\n\n";
        $message.="<img src=\"$g->{protocol}://$->{domainname}/logo.gif\" />";
        $message.="<h3>$g->{sitename} registration is almost complete!</h3>\n\n";
        $message.="<p>Confirm your registration with $g->{sitename} by clicking the following link:<br /><br />\n\n";
        $message.="<a href=\"$g->{protocol}://$g->{domainname}/$g->{appname}/register.pl?action=validate&key=$md5_hash&email=$g->{email}&user=$g->{username}\">$g->{protocol}://$g->{domainname}/$g->{appname}/register.pl?action=validate&key=$md5_hash&email=$g->{email}&user=$g->{username}</a></p>\n\n";
	      $message.="<p>After confirming your registration, you will be able to log into $g->{sitename}.</p>\n\n";
        $message.="<i>If you did not request to create an account on $g->{sitename} you can safely disregard this message.</i>";
        #$message.="<img src=\"$g->{protocol}://www.etherfeat.com/images/etherfeat-web-bg-03.jpg\" />";

        # create file to write the contents of this email alert message
        open(ALRT,"+>$g->{tempfiles}/$filename") or die "Error.  Check permissions of $g->{tempfiles}.\nCannot create $filename : @!\n";
        #print $message;
        print ALRT $message;
        close(ALRT);

        # send an email to the email address on file for the username
        my $emailcmd="/usr/sbin/sendmail -F'$g->{sitename}' -f'$g->{support_email}' -v $g->{email} < $g->{tempfiles}/$filename >> $g->{tempfiles}/mail.log";
        #print "$emailcmd\n";
        system("$emailcmd");

        #unlink "$g->{tempfiles}/$filename";        
      }
      print $g->{CGI}->endform(),
      qq(</div>\n);
    }
    elsif($g->{action} eq 'validate'){
      # if key matches activate account unlock account so user can login
      if(-e "$g->{tempfiles}/$g->{user}.validation"){
        open(FIL,"$g->{tempfiles}/$g->{user}.validation") or die "Cannot read validation key $!";
        my $key=<FIL>;
        close(FIL);
        print "<!-- validation key read from $g->{user}.validation file: $key -->\n";
        if($key eq $g->{key}){
          $g->{dbh}->do("update interface_users set active='true' where username='$g->{user}'");
          $g->{dbh}->do("insert into interface_module_access values('$g->{user}','charity_sponsor',NULL,NULL)");
          $g->{dbh}->do("insert into interface_module_access values('$g->{user}','interface_preferences',NULL,NULL)");
          $g->{dbh}->do("insert into interface_module_access values('$g->{user}','interface_logout',NULL,NULL)");
          $g->{dbh}->do("update interface_users set active='true' where username='$g->{user}'");
          # tell person they have successfully registered and that they can now log in...
          print 
          $g->{CGI}->div({-class=>"jumbotron"},
            $g->{CGI}->h3("Welcome back to $g->{sitename}"),
            $g->{CGI}->p("You now have access to log onto our Portal."),
            $g->{CGI}->p(
              $g->{CGI}->a({-class=>"btn btn-primary btn-lg",-href=>"index.pl",-role=>"button"},"Login"),
            ),
          );
          unlink "$g->{tempfiles}/$g->{user}.validation";
        }
      }
      else{
        if($g->{key} ne '' and $g->{user} ne ''){
          print 
          $g->{CGI}->div({-class=>"jumbotron"},
            $g->{CGI}->h3("You have already confirmed your account creation"),
            $g->{CGI}->div({-class=>"container"},
              $g->{CGI}->p("Click ",$g->{CGI}->a({-href=>"index.pl"},"here")," to access the logon screen to log in now."),
            ),
          ),
          $g->{CGI}->br(),$g->{CGI}->hr(),
          $g->{CGI}->p("If you are having problems logging in, please contact us: ",
            $g->{CGI}->a({-href=>"mailto:$g->{support_email_display}?subject=$g->{sitename} Account Re-Validation Error for: $g->{user}&body=<Please enter any information you think may be helpful>"},"$g->{email_support_display}"),
          );
        }
        else{
          # send email alert
          print $g->{CGI}->div({-class=>"jumbotron"},
            $g->{CGI}->h3("We were unable to process your account request at this time."),
            $g->{CGI}->p("Please try again.  If this problem persists do not hesitate to contact us at:"),
            $g->{CGI}->a({-href=>"mailto:$g->{email_support_display}?subject=$g->{sitename} Account Validation Error for: $g->{user}&body=<Please enter any information you think may be helpful>"},"$g->{email_support_display}"),
            $g->{CGI}->p("We apologize for this inconvenience."),
          );
        }
      }
    }
}
$g->{dbh}->disconnect;

print qq(
    <hr />
    <footer>
      <p>Copyright &copy; 2015 $g->{sitename}</p>
    </footer>
  </body>
</html>);

sub element{
  my($label,$element,$value,$type,$message,@values)=@_;
  if($type eq 'hidden'){
    print $g->{CGI}->hidden({-name=>$element,-value=>$value});
  }
  elsif($type eq 'textfield'){
    print $g->{CGI}->label({-for=>"$element"},"$label"),
    $g->{CGI}->textfield({-name=>$element,-value=>$value,-override=>1}),"$message",
    $g->{CGI}->br();
  }
  elsif($type eq 'password_field'){
    print $g->{CGI}->label({-for=>"$element"},"$label"),
    $g->{CGI}->password_field({-name=>$element,-value=>$value,-override=>1}),"$message",
    $g->{CGI}->br();
  }
  elsif($type eq 'popup_menu'){
    print $g->{CGI}->label({-for=>"$element"},"$label"),
    $g->{CGI}->popup_menu({-name=>$element,-default=>$value,-values=>\@values,-override=>1}),"$message",
    $g->{CGI}->br();
  }
}

sub countries{
  my @retval;
  open(FIL,"<$g->{countryfile}") or die "Cannot open country-codes $!";
  while(my ($country,$twodigitcode,$threedigitcode)=split(/\,/,<FIL>)){push(@retval,"$country - $twodigitcode");}
  return @retval;
}
