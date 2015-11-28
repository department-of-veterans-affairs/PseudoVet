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
    $pv->xsend("^^SET UP A CLINIC\r");
  }],
  # Scheduling Version 5.3
  [ qr/Select CLINIC NAME:/=>sub{
    $pv->xsend("ALPHA\r");
  }],
  [ qr/Are you adding 'ALPHA' as a new HOSPITAL LOCATION?/=>sub{
    $pv->xsend("YES\r");
    # NAME:
    $pv->xsend("\r");
    # ABBREVIATION: PCM//
    $pv->xsend("ALP\r");
    # CLINIC MEETS AT THIS FACILITY?: YES// 
    $pv->xsend("YES\r");
    # SERVICE: MEDICINE// 
    $pv->xsend("MEDICINE\r");
    # NON-COUNT CLINIC? (Y OR N): NO// 
    $pv->xsend("N\r");
    # DIVISION: VEHU DIVISION// ~take default
    $pv->xsend("\r");
    # STOP CODE NUMBER: PRIMARY CARE/MEDICINE// 
    $pv->xsend("PRIMARY CARE\/MEDICINE\r");
    # DEFAULT APPOINTMENT TYPE: REGULAR// 
    $pv->xsend("REGULAR\r");
    # ADMINISTER INPATIENT MEDS?: YES// 
    $pv->xsend("YES\r");
    # TELEPHONE: 
    $pv->xsend("\r");
    # REQUIRE X-RAY FILMS?: 
    $pv->xsend("\r");
    # REQUIRE ACTION PROFILES?: YES// 
    $pv->xsend("YES\r");
    # NO SHOW LETTER: 
    $pv->xsend("\r");
    # PRE-APPOINTMENT LETTER: 
    $pv->xsend("\r");
    # CLINIC CANCELLATION LETTER: CLINIC CANCELLED// 
    $pv->xsend("\r");
    # APPT. CANCELLATION LETTER: Pt. Cancellation// 
    $pv->xsend("\r");
    # ASK FOR CHECK IN/OUT TIME: YES// 
    $pv->xsend("YES\r");
    # Select PROVIDER: PROVIDER,FIVE// 
    $pv->xsend("PROVIDER,ONE\r");
    # PROVIDER: PROVIDER,FIVE// 
    $pv->xsend("\r");
    # DEFAULT PROVIDER: 
    $pv->xsend("PROVIDER,ONE\r");
    # Select PROVIDER: 
    $pv->xsend("\r");
    # DEFAULT TO PC PRACTITIONER?: NO// 
    $pv->xsend("NO\r");
    # Select DIAGNOSIS: 
    $pv->xsend("\r");
    # WORKLOAD VALIDATION AT CHK OUT: YES// 
    $pv->xsend("YES\r");
    # ALLOWABLE CONSECUTIVE NO-SHOWS: 99// 
    $pv->xsend("99\r");
    # MAX # DAYS FOR FUTURE BOOKING: 367// 
    $pv->xsend("367\r");
    # START TIME FOR AUTO REBOOK: 
    $pv->xsend("0800\r");
    # MAX # DAYS FOR AUTO-REBOOK: 14// 
    $pv->xsend("14\r");
    # SCHEDULE ON HOLIDAYS?: 
    $pv->xsend("\r");
    # CREDIT STOP CODE: PRIMARY CARE/MEDICINE// 
    $pv->xsend("\r");
    # PROHIBIT ACCESS TO CLINIC?: 
    $pv->xsend("\r");
    # PHYSICAL LOCATION: PRIMARY CARE CLINIC// 
    $pv->xsend("PRIMARY CARE CLINIC\r");
    # PRINCIPAL CLINIC: 
    $pv->xsend("\r");
    # OVERBOOKS/DAY MAXIMUM: 2// 
    $pv->xsend("2\r");
    # Select SPECIAL INSTRUCTIONS: 
    $pv->xsend("\r");
    # LENGTH OF APP'T: 30// 
    $pv->xsend("30\r");
    #VARIABLE APP'NTMENT LENGTH: YES, VARIABLE LENGTH
    $pv->xsend("YES\r");
    
    for(my $day=0; $day<6; $day++){ 
      # AVAILABILITY DATE: t  (NOV 25, 2015)
      if($day==0){
        $pv->xsend("T\r");
      }
      else{
        $pv->xsend("T+$day\r");
      }
      
      # TIME: and then NO. SLOTS:
      $pv->xsend("0800-0830\r"); $pv->xsend("4\r");
      $pv->xsend("0830-0900\r"); $pv->xsend("4\r");
      $pv->xsend("0900-0930\r"); $pv->xsend("4\r");
      $pv->xsend("0930-1000\r"); $pv->xsend("4\r");
      $pv->xsend("1000-1030\r"); $pv->xsend("4\r");
      $pv->xsend("1030-1100\r"); $pv->xsend("4\r");
      $pv->xsend("1100-1130\r"); $pv->xsend("4\r");
      $pv->xsend("1130-1200\r"); $pv->xsend("4\r");
      $pv->xsend("1300-1330\r"); $pv->xsend("4\r");
      $pv->xsend("1330-1400\r"); $pv->xsend("4\r");
      $pv->xsend("1400-1430\r"); $pv->xsend("4\r");
      $pv->xsend("1430-1500\r"); $pv->xsend("4\r");
      $pv->xsend("1500-1530\r"); $pv->xsend("4\r");
      $pv->xsend("1530-1600\r"); $pv->xsend("4\r");
      $pv->xsend("1600-1630\r"); $pv->xsend("4\r");
      $pv->xsend("\r");
      # ...PATTERN OK FOR "DAY OF WEEK" INDEFINITELY? no  (No)
      $pv->xsend("Y\r");
      # AVAILABILITY DATE: t  (NOV 25, 2015)
      $pv->xsend("T+1\r");
    }
        
  }],
);

