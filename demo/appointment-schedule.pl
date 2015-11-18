#!/usr/bin/perl -w
use Expect;
$Expect::Debug = 0; # verbose debug
$Expect::Log_Stdout = 1; # show chatter for debugging
my $prompt = '\$';

my $configuration_file='../config/demo.config';

configure($configuration_file);
#,@params
my $exp=Expect->spawn($command) or die "Cannot spawn $command: $!\n";

<<<<<<< HEAD
<<<<<<< HEAD
$exp->expect($timeout,
  [ qr/The authenticity of host/ => sub {
    my $exp=shift; $exp->send("y\n"); exp_continue;}],
  [ qr/Password/i => sub {
    my $exp=shift; $exp->send("$password\n"); exp_continue;
  }],
  [ qr/ACCESS CODE:/=>sub{
    my $exp=shift; $exp->send("$access_code\r"); exp_continue;
  }],
  [ qr/VERIFY CODE:/=>sub{
    my $exp=shift; $exp->send("$verify_code\r"); exp_continue;
  }],
  [ qr/Select TERMINAL TYPE NAME:/=>sub{
    my $exp=shift; $exp->send("\r"); exp_continue;
  }],
  [ qr/Select Systems Manager Menu <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("^^MAS MASTER MENU\r"); exp_continue;
  }],
  [ qr/Select MAS MASTER MENU <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("SD\r"); exp_continue;
  }],
  [ qr/Select Scheduling Manager's Menu <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("APPOINTMENT MENU\r"); exp_continue;
  }],
  [ qr/Select Appointment Menu <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("MAKE APPOINTMENT\r"); exp_continue;
  }],
  [ qr/Select CLINIC:/=>sub{ # next prompt CHOOSE 1-2: had to be entered here...
    my $exp=shift; $exp->send("$clinic_name\r1\r"); exp_continue;
  }],
  [ qr/Select PATIENT NAME:/=>sub{
    my $exp=shift; $exp->send("$patient_name\r"); exp_continue;
  }],
  [ qr/IS THIS APPOINTMENT FOR A SERVICE CONNECTED CONDITION?/=>sub{ # next prompt APPOINTMENT TYPE: REGULAR
    my $exp=shift; $exp->send("N\r"); exp_continue;
  }],
  [ qr/APPOINTMENT TYPE:/=>sub{ # REGULAR
    my $exp=shift; $exp->send("REGULAR\r"); exp_continue;
  }],
  [ qr/Select ETHNICITY:/=>sub{ # who cares
    my $exp=shift; $exp->send("\r"); exp_continue;
  }],
  [ qr/Select RACE:/=>sub{ # who cares
    my $exp=shift; $exp->send("\r"); exp_continue;
  }],  
  [ qr/IS THIS A 'NEXT AVAILABLE' APPOINTMENT REQUEST?/=>sub{
    my $exp=shift; $exp->send("Y\r"); exp_continue;
  }],
  [ qr/$clinic_name/=>sub{
    # ...and all who have entered here have never returned...
    #
    #                                    PRIMARY CARE
    #                                    Nov 2015
    #
    # TIME  |8      |9      |10     |11     |12     |1      |2      |3      |4      
    # DATE  |       |       |       |       |       |       |       |       |
    #WE 18  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #TH 19  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #FR 20  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #SA 21  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #SU 22  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #MO 23  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
    #TU 24  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
    #WE 25  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #   26    Thanksgiving Day
    #FR 27  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #SA 28  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #SU 29  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    #MO 30  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
    #                                    Dec 2015
    #TU 01  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
    #
    #60 MINUTE APPOINTMENTS (VARIABLE LENGTH)
    #DATE/TIME:     

    my $exp=shift; $exp->send("\r"); exp_continue;
  }],

);

$exp->expect($timeout,
  [qr/]\$/=>sub{
    my $exp=shift;
    $exp->send("csession cacheinv -U VISTA \"\^ZU\"\n");
    exp_continue;
  }]);
=======
#login();
#cmd($exp, "csession cache -U bciv \"^ZU\"\n");
#xcall('\$',"csession cache -U bciv \"^ZU\"\n");

if($exp->expect($timeout,-re, "[Pp]assword")){
  print "<<<matched assword>>>\n";
  $exp->print($password,"\n");
}

#xcall('ACCESS CODE:',"$access_code");
#xcall('VERIFY CODE:',"$verify_code");
sleep 5;
#$exp->clear_accum();

if($exp->expect($timeout,-re, "ACCESS CODE")){
  print "<<<matched ACCESS CODE>>>\n";
  $exp->print("$access_code",'\r');
}

if($exp->expect($timeout, -re, "VERIFY CODE")){
  print "<<<matched VERIFY CODE>>>\n";
  $exp->print("$verify_code",'\r');
}
>>>>>>> f171571520b5bedf64f052e13758c8932d8097cb

=======
my $exp=Expect->spawn($command,@params) or die "Cannot spawn $command: $!\n";

#login();
#cmd($exp, "csession cache -U bciv \"^ZU\"\n");
#xcall('\$',"csession cache -U bciv \"^ZU\"\n");

if($exp->expect($timeout,-re, "[Pp]assword")){
  print "<<<matched assword>>>\n";
  $exp->print($password,"\n");
}

#xcall('ACCESS CODE:',"$access_code");
#xcall('VERIFY CODE:',"$verify_code");
sleep 5;
#$exp->clear_accum();

if($exp->expect($timeout,-re, "ACCESS CODE")){
  print "<<<matched ACCESS CODE>>>\n";
  $exp->print("$access_code",'\r');
}

if($exp->expect($timeout, -re, "VERIFY CODE")){
  print "<<<matched VERIFY CODE>>>\n";
  $exp->print("$verify_code",'\r');
}

>>>>>>> f171571520b5bedf64f052e13758c8932d8097cb
#if($exp->before =~ m/ACCESS CODE:/){
#  $exp->print("$access_code^M");
#}
#USER>D ^%CD
#
#Namespace: VISTA
#You're in namespace VISTA
#VISTA> D ^ZU
#ACCESS CODE:  PR12345
#VERIFY CODE: PR12345!!
#Select Systems Manager Menu <TEST ACCOUNT> Option:

#$exp->expect($timeout,
#  [qr//=>sub{
#    my $exp=shift;
#    $exp->send("");
#    exp_continue;
#  }]);

# log into server over SSH
#
sub login {
  my $rc=$exp->expect($timeout,
  [ qr/The authenticity of host/ => sub {
    my $exp=shift;
    $exp->send("yes\n");
    $exp->send("$password\n");
    exp_continue;
    }],
  [ qr/Password/i => sub {
    my $exp=shift;
    $exp->send("$password\n");
    exp_continue;
    }],
    #-re => "",
  );
  return defined($rc) ? $rc : 0;
}



sub xcall{
  my($expression,$response)=@_;
  $exp->expect($timeout,
    [qr/$expression/=>sub{
      my $exp=shift;
      $exp->send("$response\n");
      exp_continue;
    }]);  
}

sub cmd { my ($exp, $cmd) = @_;
 $exp->print($cmd, "\n");
 $exp->expect($timeout, -re => $prompt) or return;
 my $output = $exp->before;
 $output =~ s/\r//g;  # silly telnet line endings
 $output =~ s/^$cmd\n//;  # remove the sent cmd
 return $output;
}

# read configuration variables from file
#
sub configure{
  my $file=$_[0];
  open(IN,$file) or die "Cannot read configuration file, $file : $!";
  while(<IN>){eval $_;} close(IN);
}
