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
$pv->configure('../config/dev.config');

$pv->csession(); # or $pv->connect(); for ssh connections

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
  [ qr/Do you want to continue with the current list?/=>sub{
    $pv->xsend("Yes\r");
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
    print "patient_number: $patient_number\n";
    $pv->xsend("$patient_number\n^\r");
  }],
  [ qr/Show your current PATIENT list?/=>sub{
    $pv->xsend("YES\r^\r");
  }],
  [ qr/Do you want to remove patients from this list?/=>sub{
    $pv->xsend("No\r");
  }],
  [ qr/Store list for future reference?/=>sub{
    $pv->xsend("YES\r");
  }],
  [ qr/Enter a name for this list:/=>sub{
    $pv->xsend("PseudoList\r");
  }],
  [ qr/Are you adding \'/=>sub{
    $pv->xsend("Yes\r");
  }],
  [ qr/Do you want to overwrite it?/=>sub{
    $pv->xsend("No\r^\r");
  }],
);
