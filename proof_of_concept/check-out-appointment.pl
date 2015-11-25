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
    $pv->xsend("CO\r");
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
    $pv->xsend("NO\r");
  }],
  [ qr/Continue?/=>sub{$pv->xsend("Y\n");}],
  [ qr/Check out date and time:/=>sub{$pv->xsend("NOW\r");}],
  [ qr/Enter PROVIDER:/=>sub{
    print "matched Enter PROVIDER:\n";
    $pv->xsend("PROVIDER,FIFTEEN\r");
    # Is this the PRIMARY provider for this ENCOUNTER?
    $pv->xsend("YES\r");
    # Enter PROVIDER: (loop if we don't skip additional entry)
    $pv->xsend("\r");
  }],
  [ qr/Select PRIMARY PROVIDER:/=>sub{
    print "matched Select Primary PROVIDER:\n";
    $pv->xsend("$pv->{provider_name}\r");
    # Is this the PRIMARY provider for this ENCOUNTER?
    $pv->xsend("YES\r");
    # Enter PROVIDER: (loop if we don't skip additional entry)
    $pv->xsend("\r");
  }],
  [ qr/Enter ICD-10 Diagnosis/=>sub{
    # EHMP Silver VistA throws ZERROR when entering an ICD_10 diagnosis code
    $pv->xsend("$pv->{icd_10_diagnosis}\r");
    $pv->xsend("YES\r");
    $pv->xsend("\r");
  }],
  [ qr/Select Diagnosis/=>sub{
    $pv->xsend("$pv->{icd_10_diagnosis}\r");
    $pv->xsend("YES\r");
    $pv->xsend("\r");
  }],


#  [ qr/Is this the PRIMARY provider for this ENCOUNTER?/=>sub{
#    $pv->xsend("YES\r");
#    #$pv->xsend("\r");
#  }],
#  [ qr/Do you wish to enter workload data at this time?/=>sub{
#    $pv->xsend("Yes\r");   
#  }],
#  [ qr/Check out data and time:/=>sub{
#    $pv->xsend("NOW\r");
#  }],
#  [ qr/Editing Encounter Data.../=>sub{
#    $pv->xsend("NOW\r");
#  }],
#  [ qr/Press the Enter key to continue./=>sub{$pv->xsend("\r");}],
#  [ qr/Select Procedure/=>sub{
#    $pv->xsend("$pv->{procedure}\r");
#    # Ok? 
#    $pv->xsend("\r");
#    # Select Procedure:
#    $pv->xsend("^\r");
#    # Ok?
#    $pv->xsend("YES\r");
#    # how many times was the procedure performed?
#    $pv->xsend("1\r"); 
#    # Please specify the number of repetitions for this procedure (1-99)
#    $pv->xsend("3\r");
#  }],
#  [ qr/Print this note?/=>sub{ $pv->xsend("No\r");}],
);
