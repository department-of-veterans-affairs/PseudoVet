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

# see ../config/sample.demo.config for example
$pv->configure('../config/demo.config');

$pv->connect();

$pv->{exp}->expect($pv->{timeout},
  [ qr/The authenticity of host/ => sub { $pv->xsend("y\n"); }],
  [ qr/Password/i => sub { $pv->xsend("$pv->{password}\n"); }],
  [ qr/ACCESS CODE:/=>sub{ $pv->xsend("$pv->{access_code}\r"); }],
  [ qr/VERIFY CODE:/=>sub{ $pv->xsend("$pv->{verify_code}\r"); }],
  [ qr/Select TERMINAL TYPE NAME:/=>sub{ $pv->xsend("\r"); }],
  [ qr/Select Systems Manager Menu <TEST ACCOUNT> Option:/=>sub{
    $pv->xsend("^^CLINICIAN MENU\r");
  }],
  [ qr/Select Clinician Menu/=>sub{
    $pv->xsend("^^PROGRESS NOTES USER MENU\r");
  }],
  [ qr/Select Progress Notes User Menu/=>sub{
    $pv->xsend("1\r"); # Selects Entry of Progress Note
  }],
  [ qr/Select PATIENT NAME:/=>sub{
    $pv->xsend("$pv->{patient_name}\r");
  }],
  # notes exist for patient
  [ qr/Do you wish to see any of these notes?/=>sub{
    $pv->xsend("NO\r");
  }],
  [ qr/TITLE:/=>sub{
    $pv->xsend("PRIMARY CARE GENERAL NOTE\r"); # will use GENERIC CONSULT NOTE
  }],
  [ qr/Std Title: REFERRAL CONSULT ...OK?/=>sub{
    $pv->xsend("YES\r");
  }],
  [ qr/Is this note for INPATIENT or OUTPATIENT care?/=>sub{
    $pv->xsend("OUTPATIENT\r");
  }],
  [ qr/The following SCHEDULED VISTS are available:/=>sub{
    #my $scheduled_visit=$pv->select_scheduled_visit();
    # just grab latest one for now
    $pv->xsend("1\r");
  }],
  [ qr/Enter\/Edit PROGRESS NOTE.../=>sub{
    $pv->xsend("YES\r");
  }],
  [ qr/1\>/=>sub{
    $pv->xsend("55 YEAR OLD MALE COMPLAINS OF COLD, FEVER, AND CHILLS\r");
  }],
  [ qr/2\>/=>sub{
    $pv->xsend("This is a test.\r");
  }],
  [ qr/3\>/=>sub{
    $pv->xsend("\r");
  }],
  [ qr/EDIT Option:/=>sub{ 
    $pv->xsend("\r");
  }],
  [ qr/Enter your Current Signature Code:/=>sub{
    $pv->xsend("$pv->{electronic_signature_code}\r");
  }],
);
