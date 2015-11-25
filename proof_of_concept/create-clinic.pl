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
    $pv->xsend("^^SUPERVISOR MENU\r");
	# iterate through the list of supervisor menus and select [SDSUP]
	$pv->xsend("3\r");
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
    print "\nPatient checked in\n";
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

Select Systems Manager Menu <TEST ACCOUNT> Option: ^^set up a Clinic


Scheduling Version 5.3




Select CLINIC NAME: PRIMARY CARE       PROVIDER,ONE
NAME: PRIMARY CARE// 
ABBREVIATION: PCM// 
CLINIC MEETS AT THIS FACILITY?: YES// 
SERVICE: MEDICINE// 
NON-COUNT CLINIC? (Y OR N): NO// 
DIVISION: VEHU DIVISION// 
STOP CODE NUMBER: PRIMARY CARE/MEDICINE// 
DEFAULT APPOINTMENT TYPE: REGULAR// 
ADMINISTER INPATIENT MEDS?: YES// 
TELEPHONE: 
REQUIRE X-RAY FILMS?: 
REQUIRE ACTION PROFILES?: YES// 
NO SHOW LETTER: 
PRE-APPOINTMENT LETTER: 
CLINIC CANCELLATION LETTER: CLINIC CANCELLED// 
APPT. CANCELLATION LETTER: Pt. Cancellation// 
ASK FOR CHECK IN/OUT TIME: YES// 
Select PROVIDER: PROVIDER,FIVE// 
  PROVIDER: PROVIDER,FIVE// 
  DEFAULT PROVIDER: 
Select PROVIDER: 
DEFAULT TO PC PRACTITIONER?: NO// 
Select DIAGNOSIS: 
WORKLOAD VALIDATION AT CHK OUT: YES// 
ALLOWABLE CONSECUTIVE NO-SHOWS: 99// 
MAX # DAYS FOR FUTURE BOOKING: 367// 
START TIME FOR AUTO REBOOK: 
MAX # DAYS FOR AUTO-REBOOK: 14// 
SCHEDULE ON HOLIDAYS?: 
CREDIT STOP CODE: PRIMARY CARE/MEDICINE// 
PROHIBIT ACCESS TO CLINIC?: 
PHYSICAL LOCATION: PRIMARY CARE CLINIC// 
PRINCIPAL CLINIC: 
OVERBOOKS/DAY MAXIMUM: 2// 
Select SPECIAL INSTRUCTIONS: 
LENGTH OF APP'T: 30// 
VARIABLE APP'NTMENT LENGTH: YES, VARIABLE LENGTH
         // 

AVAILABILITY DATE: t  (NOV 25, 2015)

                                     WEDNESDAY


  TIME: 0800-1630   NO. SLOTS: 1//  18

  TIME: 0830-0900   [ MUST BEGIN AFTER LAST ENDING TIME ]

  TIME:     
[r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] [r] 
...PATTERN OK FOR WEDNESDAYS INDEFINITELY? no  (No)
...FOR NOV 25,2015? No//   (No)
...FOR DEC  2,2015? No//   (No)
...FOR DEC  9,2015? No//   (No)
...FOR DEC 16,2015? No//   (No)
...FOR DEC 23,2015? No//   (No)
...FOR DEC 30,2015? No//   (No)
...FOR JAN  6,2016? No// ^

AVAILABILITY DATE: t  (NOV 25, 2015)

                                     WEDNESDAY


  TIME: 0800-0830   NO. SLOTS: 1//  4

  TIME: 0830-0900   NO. SLOTS: 1//  4

  TIME: 0900-0930   NO. SLOTS: 1//  4

  TIME: 1000-1030   NO. SLOTS: 1//  4

  TIME: 1030-1100   NO. SLOTS: 1//  4

  TIME: 1100-1130   NO. SLOTS: 1//  4

  TIME: 1130-1200   NO. SLOTS: 1//  4

  TIME: 1300-1330   NO. SLOTS: 1//  4

  TIME: 1330-1400   NO. SLOTS: 1//  4

  TIME: 1400-1430   NO. SLOTS: 1//  4

  TIME: 1430-1500   NO. SLOTS: 1//  4

  TIME: 1500-1530   NO. SLOTS: 1//  4

  TIME: 1530-1600   NO. SLOTS: 1//  4

  TIME: 1600-1630   NO. SLOTS: 1//  4

  TIME: 
[4] [4] [4]     [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] 
...PATTERN OK FOR WEDNESDAYS INDEFINITELY? y  (Yes)
...EXCUSE ME, THIS MAY TAKE A FEW MOMENTS...
PATTERN FILED!


AVAILABILITY DATE: t+1  (NOV 26, 2015)

                                     THURSDAY


  TIME: 0800-0830   NO. SLOTS: 1//  4

  TIME: 0830-0900   NO. SLOTS: 1//  4

  TIME: 0900-0930   NO. SLOTS: 1//  4

  TIME: 0930-1000   NO. SLOTS: 1//  4

  TIME: 1000-1030   NO. SLOTS: 1//  4

  TIME: 1030-1100   NO. SLOTS: 1//  4

  TIME: 1100-1130   NO. SLOTS: 1//  4

  TIME: 1130-1200   NO. SLOTS: 1//  4

  TIME: 1300-1330   NO. SLOTS: 1//  4

  TIME: 1330-1400   NO. SLOTS: 1//  4

  TIME: 1400-1430   NO. SLOTS: 1//  4

  TIME: 1430-1500   NO. SLOTS: 1//  4

  TIME: 1500-1530   NO. SLOTS: 1//  4

  TIME: 1530-1600   NO. SLOTS: 1//  4

  TIME: 1600-1630   NO. SLOTS: 1//  4

  TIME: 
[4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] 
...PATTERN OK FOR THURSDAYS INDEFINITELY? y  (Yes)
...SORRY, HOLD ON...
PATTERN FILED!


AVAILABILITY DATE: t+3  (NOV 28, 2015)

                                     SATURDAY


  TIME: 
DELETE SATURDAYS INDEFINITELY? y  (Yes)

AVAILABILITY DATE: t+5  (NOV 30, 2015)

                                     MONDAY


  TIME: 0800-0830   NO. SLOTS: 1//  4

  TIME: 0830-0900   NO. SLOTS: 1//  4

  TIME: 0900-0930   NO. SLOTS: 1//  4

  TIME: 0930-1000   NO. SLOTS: 1//  4

  TIME: 1000-1030   NO. SLOTS: 1//  4

  TIME: 1030-1100   NO. SLOTS: 1//  4

  TIME: 1100-1130   NO. SLOTS: 1//  4

  TIME: 1130-1200   NO. SLOTS: 1//  4

  TIME: 1300-1330   NO. SLOTS: 1//  4

  TIME: 1330-1400   NO. SLOTS: 1//  4

  TIME: 1400-1430   NO. SLOTS: 1//  4

  TIME: 1430-1500   NO. SLOTS: 1//  4

  TIME: 1500-1530   NO. SLOTS: 1//  4

  TIME: 1530-1600   NO. SLOTS: 1//  4

  TIME: 1600-1630   NO. SLOTS: 1//  4

  TIME: 
[4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] 
...PATTERN OK FOR MONDAYS INDEFINITELY? y  (Yes)
...EXCUSE ME, THIS MAY TAKE A FEW MOMENTS...
PATTERN FILED!


AVAILABILITY DATE: t+6  (DEC 01, 2015)

                                     TUESDAY


  TIME: 0800-0830   NO. SLOTS: 1//  4

  TIME: 0830-0900   NO. SLOTS: 1//  4

  TIME: 0900-1000   NO. SLOTS: 1//  4

  TIME: 1000-1030   NO. SLOTS: 1//  4

  TIME: 1030-1100   NO. SLOTS: 1//  4

  TIME: 1100-1130   NO. SLOTS: 1//  4

  TIME: 1130-1200   NO. SLOTS: 1//  4

  TIME: 1300-1330   NO. SLOTS: 1//  4

  TIME: 1330-1400   NO. SLOTS: 1//  4

  TIME: 1400-1430   NO. SLOTS: 1//  4

  TIME: 1430-1500   NO. SLOTS: 1//  4

  TIME: 1500-1530   NO. SLOTS: 1//  4

  TIME: 1530-1600   NO. SLOTS: 1//  4

  TIME: 1600-1630   NO. SLOTS: 1//  4

  TIME: 
[4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] 
...PATTERN OK FOR TUESDAYS INDEFINITELY? y  (Yes)
...SORRY, LET ME THINK ABOUT THAT A MOMENT...
PATTERN FILED!


AVAILABILITY DATE: t+7  (DEC 02, 2015)

                                     WEDNESDAY


  TIME: 0800-0830   NO. SLOTS: 1//  4

  TIME: 0830-0900   NO. SLOTS: 1//  4

  TIME: 0900-0930   NO. SLOTS: 1//  4

  TIME: 0930-1000   NO. SLOTS: 1//  4

  TIME: 1000-1030   NO. SLOTS: 1//  4

  TIME: 1030-1100   NO. SLOTS: 1//  4

  TIME: 1100-1130   NO. SLOTS: 1//  4

  TIME: 1130-1200   NO. SLOTS: 1//  4

  TIME: 1300-1330   NO. SLOTS: 1//  4

  TIME: 1330-1400   NO. SLOTS: 1//  4

  TIME: 1400-1430   NO. SLOTS: 1//  4

  TIME: 1430-1500   NO. SLOTS: 1//  4

  TIME: 1500-1530   NO. SLOTS: 1//  4

  TIME: 1530-1600   NO. SLOTS: 1//  4

  TIME: 1600-1630   NO. SLOTS: 1//  4

  TIME: 
[4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] 
...PATTERN OK FOR WEDNESDAYS INDEFINITELY? y  (Yes)
...EXCUSE ME, HOLD ON...
PATTERN FILED!


AVAILABILITY DATE: t  (NOV 25, 2015)

                                     WEDNESDAY


  TIME: 0800-0830   NO. SLOTS: 1//  4

  TIME: 0830-0900   NO. SLOTS: 1//  4

  TIME: 0900-0930   NO. SLOTS: 1//  4

  TIME: 0930-1000   NO. SLOTS: 1//  4

  TIME: 1000-1030   NO. SLOTS: 1//  4

  TIME: 1030-1100   NO. SLOTS: 1//  4

  TIME: 1100-1130   NO. SLOTS: 1//  4

  TIME: 1130-1200   NO. SLOTS: 1//  4

  TIME: 1300-1330   NO. SLOTS: 1//  4

  TIME: 1330-1400   NO. SLOTS: 1//  4

  TIME: 1400-1430   NO. SLOTS: 1//  4

  TIME: 1430-1500   NO. SLOTS: 1//  4

  TIME: 1500-1530   NO. SLOTS: 1//  4

  TIME: 1530-1600   NO. SLOTS: 1//  4

  TIME: 1600-1630   NO. SLOTS: 1//  4

  TIME: 
[4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] 
...PATTERN OK FOR WEDNESDAYS UNTIL DEC  2,2015? y  (Yes)
...SORRY, LET ME THINK ABOUT THAT A MOMENT...
PATTERN FILED!


AVAILABILITY DATE: 

