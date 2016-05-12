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
$pv->configure('../config/dev.config');

$pv->csession(); # or $pv->connect(); for ssh connections

$pv->{exp}->expect($pv->{timeout},
  [ qr/The authenticity of host/ => sub { $pv->xsend("y\n"); }],
  [ qr/Password/i => sub { $pv->xsend("$pv->{password}\n"); }],
  [ qr/ACCESS CODE:/=>sub{ $pv->xsend("$pv->{access_code}\r"); }],
  [ qr/VERIFY CODE:/=>sub{ $pv->xsend("$pv->{verify_code}\r"); }],
  [ qr/Select TERMINAL TYPE NAME:/=>sub{ $pv->xsend("\r"); }],
  [ qr/Select Systems Manager Menu <TEST ACCOUNT> Option:/=>sub{
    $pv->xsend("^^MAS MASTER MENU\r");
  }],
  [ qr/Select MAS MASTER MENU <TEST ACCOUNT> Option:/=>sub{
    $pv->xsend("SD\r");
  }],
  [ qr/Select Scheduling Manager's Menu <TEST ACCOUNT> Option:/=>sub{
    $pv->xsend("APPOINTMENT MENU\r");
  }],
  [ qr/Select Appointment Menu <TEST ACCOUNT> Option:/=>sub{
    $pv->xsend("MAKE APPOINTMENT\r");
  }],
  [ qr/Select CLINIC:/=>sub{ # next prompt CHOOSE 1-2: had to be entered here...
    $pv->xsend("$pv->{clinic_name}\r1\r");
  }],
  [ qr/Select PATIENT NAME:/=>sub{
    $pv->xsend("$pv->{patient_name}\r");
  }],
  [ qr/Do you wish to view active patient record flag details?/=>sub{ # next prompt APPOINTMENT TYPE: REGULAR
    $pv->xsend("N\r");
  }],
  [ qr/IS THIS APPOINTMENT FOR A SERVICE CONNECTED CONDITION?/=>sub{ # next prompt APPOINTMENT TYPE: REGULAR
    $pv->xsend("N\r");
  }],
  [ qr/APPOINTMENT TYPE:/=>sub{ # REGULAR
    $pv->xsend("REGULAR\r");
  }],
  [ qr/Select ETHNICITY:/=>sub{ # who cares
    $pv->xsend("\r");
  }],
  [ qr/Select RACE:/=>sub{ # who cares
    $pv->xsend("\r");
  }],  
  [ qr/THIS APPOINTMENT IS MARKED AS 'NEXT AVAILABLE', IS THIS CORRECT?/=>sub{
    $pv->xsend("Y\r");
  }],
  [ qr/IS THIS A 'NEXT AVAILABLE' APPOINTMENT REQUEST?/=>sub{
    $pv->xsend("Y\r");
  }],
  [ qr/DATE\/TIME:/=>sub{
    # This is where we send in the micro managers... 
    # ...okay so I liked the LEGO movie I'm a dork like who cares.
    my $next_available_appointment=$pv->get_next_available_appointment($pv->{exp}->before);
    $pv->xsend("$next_available_appointment\r");
  }],
  [ qr/LENGTH OF APPOINTMENT \(IN MINUTES\):/=>sub{
    # make it a 30 minute slot...
    $pv->xsend("30\r");
  }],
  [ qr/ISSUE REQUEST FOR RECORDS?/=>sub{
    # this would be cool but, we won't bother with this right now...
    $pv->xsend("NO\r");
    $pv->xsend("NO\r");
    print "Patient appointment has been scheduled.  Process completed.\n";
  }],
  [ qr/DISPLAY PENDING APPOINTMENTS:/=>sub{
    # This means we already made one...
    $pv->xsend("YES\n");
  }],
  [ qr/DO YOU WANT TO CANCEL IT?/=>sub{
    $pv->xsend("NO\r");
    print "Patient already has appointment scheduled.  Nothing to do.\n";
  }],
);