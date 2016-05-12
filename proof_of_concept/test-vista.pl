#!/usr/bin/perl -w
use PseudoVistA;
# If you don't know the code, don't mess around below -BCIV
# Purpose: programatically create an appointment based on the next available clinic time in
# The Department of Veterans Affairs VistA EHR or whatever the latest buzzword for a system
# that contains patient data.
# Written by: Will BC Collins IV {a.k.a., 'BCIV' follow me on GitHub ~ I'm super cool.}
# Email: william.collins@va.gov
# Last Modified: 20151120 unless I forgot to update this line...

my $pv=new PseudoVistA;
my $connect='false';
# see ../config/sample.demo.config for example
$pv->configure('../config/dev.config');

$pv->csession(); # or $pv->connect(); for ssh connections

$pv->{exp}->expect($pv->{timeout},
  [ qr/The authenticity of host/ => sub { $pv->xsend("y\n"); }],
  [ qr/Password/i => sub { $pv->xsend("$pv->{password}\n"); }],
  [ qr/ACCESS CODE:/=>sub{ $pv->xsend("$pv->{access_code}\r"); }],
  [ qr/VERIFY CODE:/=>sub{ $pv->xsend("$pv->{verify_code}\r"); }],
  [ qr/Select TERMINAL TYPE NAME:/=>sub{ $pv->xsend("\r"); }],
  [ qr/Select Systems Manager Menu <TEST ACCOUNT> Option:/=>sub{
    $connect='true';
    #$pv->xsend("^^MAS MASTER MENU\r");
    $pv->xsend("^\r\r\r");
  }],
);

if($connect eq 'true'){
    print "\n\nSuccessfully connected to VistA!\n\n";
}
else{
    print "\n\nConnection to VistA failed.\n\n";
}
