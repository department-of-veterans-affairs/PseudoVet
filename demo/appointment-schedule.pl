#!/usr/bin/perl -w
use Expect;

#my $username='bciv';
#my $password='at0mic!!';
#my $servername='pseudovista.vaftl.us';
#my $timeout=1500;
#my $command="ssh $servername";

my $configuration_file='../config/demo.config';

configure($configuration_file);

my $exp=Expect->spawn($command,@params) or die "Cannot spawn $command: $!\n";

$exp->expect($timeout,
  [ qr/The authenticity of host/ => sub {
    my $exp=shift;
    $exp->send("y\n");
    exp_continue;}],
  [ qr/Password/i => sub {
    my $exp=shift;
    $exp->send("$password\n");
    exp_continue;
    }]);

$exp->expect($timeout,
  [qr//=>sub{
    my $exp=shift;
    $exp->send("");
    exp_continue;
  }]);

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

sub xcall{
  my($expression,$response)=@_;
  $exp->expect($timeout,
    [qr/$expression/=>sub{
      my $exp=shift;
      $exp->send("$response\n");
      exp_continue;
    }]);  
}

sub configure{
  my $file=$_[0];
  open(IN,$file) or die "Cannot read configuration file, $file : $!";
  while(<IN>){eval $_;} close(IN);
}