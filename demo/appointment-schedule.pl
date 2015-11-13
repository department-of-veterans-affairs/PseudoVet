#!/usr/bin/perl -w
use Expect;

my $username='bciv';
my $password='atomic!!';
my $servername='pseudovista.vaftl.us';
my $command="ssh $servername";

my $exp=Expect->spawn($command,@params) or die "Cannot spanw $command: $!\n";

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



