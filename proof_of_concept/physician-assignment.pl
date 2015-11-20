#!/usr/bin/perl -w
use PseudoVistA;
# If you don't know the code, don't mess around below -BCIV
# Purpose: programatically assign a patient to a primary care provider in the Department 
# of Veterans Affairs VistA Electronic Health Record System (EHR).
# Written by: Will BC Collins IV {a.k.a., 'BCIV' follow me on GitHub ~ I'm super cool.}
# Email: william.collins@va.gov
# Last Modified: 20151118 unless I forgot to update this line...
#
$Expect::Debug = 0; # verbose debug
$Expect::Log_Stdout = 1; # show chatter for debugging

my $pv=new PseudoVistA;

# see ../config/sample.demo.config for example
$pv->configure('../config/new.demo.config');

print "username: $pv->{username}\n";

$pv->connect();

$pv->{exp}->expect($pv->{timeout},
  [ qr/The authenticity of host/ => sub{
    $pv->xsend("y\n");
  }],
  [ qr/Password/i => sub{
    $pv->xsend("$pv->{password}\n");
  }],
  [ qr/ACCESS CODE:/=>sub{
    $pv->xsend("$pv->{access_code}\r");
  }],
  [ qr/VERIFY CODE:/=>sub{
    $pv->xsend("$pv->{verify_code}\r");
  }],
  [ qr/Select TERMINAL TYPE NAME:/=>sub{
    $pv->xsend("\r");
  }],
  [ qr/Select Systems Manager Menu <TEST ACCOUNT> Option:/=>sub{
    $pv->xsend("^^personal patient list menu\r");
  }],
  [ qr/Select Personal Patient List Menu/=>sub{
    $pv->xsend("ad\r");
  }],
  [ qr/Select Build Patient List Menu/=>sub{
    $pv->xsend("on\r");
  }],
  [ qr/Select PATIENT NAME:/=>sub{
    $pv->xsend("$pv->{patient_name}\r");
  }],
  [ qr/CHOOSE/=>sub{
    # let's get fancy and figure out what number is associated with 
    # the patient and choose it...
    my $patient_number=$pv->choose_patient($pv->{exp}->before());    
    $pv->xsend("$patient_number\n");
  }],
);

sub choose_patient{
  my($input)=@_; my $retval;
  my @out=split(/\n/,$input);
  for(my $i=0; $i<@out; ++$i){
    my $string=$out[$i];
    # first...
    # match a MON YEAR such as 'Dec 2015' to build YYYYMM portion of appointment slot
    if($string=~m/^\s*\w\w\w\s\d\d\d\d\s*+$/){
    }
  }
}
