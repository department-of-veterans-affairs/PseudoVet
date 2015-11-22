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
    $pv->xsend("^^APPOINTMENT CHECK-IN\r");
  }],
  [ qr/Select Appointment Check In or Check Out:/=>sub{
    $pv->xsend("CI\r");
  }],
  [ qr/Appointment Date:/=>sub{
    $pv->xsend("TODAY\r");
  }],
  [ qr/Select Clinic:/=>sub{
    $pv->xsend("$pv->{clinic_name}\r");
  }],
  [ qr/Select Patient/=>sub{
    $pv->xsend("$pv->{patient_name}\r");
  }],
  [ qr/CHOOSE/=>sub{
    # let's get fancy and figure out what number is associated with 
    # the patient and choose it...
    my $patient_number=$pv->choose_patient($pv->{exp}->before());    
    print "patient_number: $patient_number\n";
    $pv->xsend("$patient_number\n^\r");
  }],
  [ qr/Do you wish to view active patient record flag details?/=>sub{
    $pv->xsend("No\r");
  }],
  [ qr/CHECKED-IN:/=>sub{
    print "\nPatient already checked in\n";
    exit;
  }],
  # there may be additional inputs when the patient has more than
  # one appointment on a given day ...will deal with that later
  [ qr/Continue?/=>sub{
    $pv->xsend("Y\r");
  }],
  [ qr/Next Patient:/=>sub{
    print "Patient has been checked-in successfully.\n";
    $pv->xsend("\r");
  }],
  [ qr/Next Clinic:/=>sub{
    $pv->xsend("\r");
  }],
  [ qr/Next Appointment Date/=>sub{
    $pv->xsend("^\r^\r");
  }],
);