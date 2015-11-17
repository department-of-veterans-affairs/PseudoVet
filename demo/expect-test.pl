#!/usr/bin/perl -w
use Expect;
$Expect::Debug = 0; # verbose debug
$Expect::Log_Stdout = 1; # show chatter for debugging
my $prompt = '\$';

my $configuration_file='../config/demo.config';

configure($configuration_file);

my $exp=Expect->spawn("/bin/bash") or die "Cannot spawn $command: $!\n";

$exp->expect($timeout,-re, qw/\$/);
print "<<<matched prompt>>>\n";
my @arr=$exp->send("ls\n");
print $exp->before();

#foreach my $line (@arr){
#  print "$line"; 
#}

#if($exp->expect($timeout,-re, "\$")){
#  print "<<<matched prompt>>>\n";
#  $exp->print('pwd','\n');
#}

#if($exp->expect($timeout,-re, "\$")){
#  print "<<<matched prompt>>>\n";
#  $exp->print('ls','\n');
#}
  
#login();
#cmd($exp, "csession cache -U bciv \"^ZU\"\n");
#xcall('\$',"csession cache -U bciv \"^ZU\"\n");

#if($exp->expect($timeout,-re, "[Pp]assword")){
#  print "<<<matched assword>>>\n";
#  $exp->print($password,"\n");
#}

#xcall('ACCESS CODE:',"$access_code");
#xcall('VERIFY CODE:',"$verify_code");
#sleep 5;
#$exp->clear_accum();

#if($exp->expect($timeout,-re, "ACCESS CODE")){
#  print "<<<matched ACCESS CODE>>>\n";
#  $exp->print("$access_code",'\r');
#}

#if($exp->expect($timeout, -re, "VERIFY CODE")){
#  print "<<<matched VERIFY CODE>>>\n";
#  $exp->print("$verify_code",'\r');
#}

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