#!/usr/bin/perl -w
use Expect;
$Expect::Debug = 1; # verbose debug
$Expect::Log_Stdout = 1; # show chatter for debugging
my $prompt = '\$';

my $configuration_file='../config/demo.config';

configure($configuration_file);

my $exp=Expect->spawn($command,@params) or die "Cannot spawn $command: $!\n";

login();
cmd($exp, "csession cache -U bciv \"^ZU\"\n");

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
    exp_continue;}],
  [ qr/Password/i => sub {
    my $exp=shift;
    $exp->send("$password\n");
    exp_continue;
    }],
    -re => $prompt,
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