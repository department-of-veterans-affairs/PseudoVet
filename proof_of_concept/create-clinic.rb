#!/usr/bin/ruby

require 'pty'
require 'expect'
# If you don't know the code, don't mess around below -BCIV
# Purpose: programatically create a clinic in  
# The Department of Veterans Affairs VistA EHR
# Written by: Will BC Collins IV {a.k.a., 'BCIV' follow me on GitHub ~ I'm super cool.}
# Email: william.collins@va.gov
# Created: 20160516

PTY.spawn("csession cache -UVISTA '^ZU'") do |r_f,w_f,pid|
  w_f.sync = true
  $expect_verbose = true

  #r_f.expect(/The authenticity of host/) do
  #  w_f.print "y\n"
  #end

  r_f.expect(/^ACCESS CODE: /) do
    w_f.print "innovat3\r"
  end

  r_f.expect(/^VERIFY CODE: /) do
    w_f.print "innovat3.\r"
  end

  r_f.expect(/^Select TERMINAL TYPE NAME: /) do
    w_f.print "C-VT100\r"
  end

  r_f.expect(/Select Systems Manager Menu <TEST ACCOUNT> Option:/) do
    w_f.print "^^SET UP A CLINIC\r"
  end

  r_f.expect(/Select CLINIC NAME:/) do
    # Scheduling Version 5.3
    w_f.print "ALPHA\r"     
  end   

  r_f.expect(/Are you adding \'ALPHA\' as a new HOSPITA/) do
    w_f.print "YES\r"
  end
  
  r_f.expect(/NAME:/) do
    w_f.print "\r" # NAME:
  end
  
  r_f.expect(/ABBREVIATION:/) do
    w_f.print "ALP\r" # ABBREVIATION: PCM//
  end
  
  r_f.expect(/CLINIC MEETS AT THIS FACILITY?:/) do
    w_f.print "YES\r" # CLINIC MEETS AT THIS FACILITY?: YES// 
  end
  
  r_f.expect(/SERVICE:/) do
    w_f.print "MEDICINE\r" # SERVICE: MEDICINE//
  end  
  
  r_f.expect(/NON-COUNT CLINIC\? (Y OR N):/) do
    w_f.print "N\r" # NON-COUNT CLINIC? (Y OR N): NO//
  end  
  
  r_f.expect(/DIVISION:/) do
    w_f.print "\r" # DIVISION: VEHU DIVISION// ~take default
  end  
  
  r_f.expect(/STOP CODE NUMBER:/) do
    w_f.print "PRIMARY CARE\/MEDICINE\r" # STOP CODE NUMBER: PRIMARY CARE/MEDICINE//
  end  
  
  r_f.expect(/DEFAULT APPOINTMENT TYPE:/) do
    w_f.print "REGULAR\r" # DEFAULT APPOINTMENT TYPE: REGULAR//
  end  
  
  r_f.expect(/ADMINISTER INPATIENT MEDS\?:/) do
    w_f.print "YES\r" # ADMINISTER INPATIENT MEDS?: YES//
  end  
  
  r_f.expect(/TELEPHONE:/) do
    w_f.print "\r" # TELEPHONE:
  end  
  
  r_f.expect(/REQUIRE X-RAY FILMS\?:/) do
    w_f.print "\r" # REQUIRE X-RAY FILMS?:
  end  
  
  r_f.expect(/REQUIRE ACTION PROFILES\?:/) do
    w_f.print "YES\r" # REQUIRE ACTION PROFILES?: YES//
  end  
  
  r_f.expect(/NO SHOW LETTER:/) do
    w_f.print "\r" # NO SHOW LETTER:
  end  
  
  r_f.expect(/PRE-APPOINTMENT LETTER:/) do
    w_f.print "\r" # PRE-APPOINTMENT LETTER:
  end  
  
  r_f.expect(/CLINIC CANCELLATION LETTER:/) do
    w_f.print "CLINIC CANCELLED\r" # CLINIC CANCELLATION LETTER: CLINIC CANCELLED//
  end  
  
  r_f.expect(/APPT. CANCELLATION LETTER:/) do
    w_f.print "Pt. Cancellation\r" # APPT. CANCELLATION LETTER: Pt. Cancellation//
  end  
  
  r_f.expect(/ASK FOR CHECK IN\/OUT TIME:/) do
    w_f.print "YES\r" # ASK FOR CHECK IN/OUT TIME: YES//
  end  
  
  r_f.expect(/Select PROVIDER:/) do
    w_f.print "PROVIDER,ONE\r" # Select PROVIDER: PROVIDER,FIVE//
  end  
  
  r_f.expect(/PROVIDER:/) do
    w_f.print "PROVIDER,FIVE\r" # PROVIDER: PROVIDER,FIVE//
  end  
  
  r_f.expect(/DEFAULT PROVIDER:/) do
    w_f.print "PROVIDER,ONE\r" # DEFAULT PROVIDER:
  end  
  
  r_f.expect(/Select PROVIDER:/) do
    w_f.print "\r" # Select PROVIDER:
  end  
  
  r_f.expect(/DEFAULT TO PC PRACTITIONER?:/) do
    w_f.print "NO\r" # DEFAULT TO PC PRACTITIONER?: NO//
  end  
  
  r_f.expect(/Select DIAGNOSIS:/) do
    w_f.print "\r" # Select DIAGNOSIS:
  end  
  
  r_f.expect(/WORKLOAD VALIDATION AT CHK OUT:/) do
    w_f.print "YES\r" # WORKLOAD VALIDATION AT CHK OUT: YES//
  end  
  
  r_f.expect(/ALLOWABLE CONSECUTIVE NO-SHOWS:/) do
    w_f.print "99\r" # ALLOWABLE CONSECUTIVE NO-SHOWS: 99//
  end  
  
  r_f.expect(/MAX # DAYS FOR FUTURE BOOKING:/) do
    w_f.print "367\r" # MAX # DAYS FOR FUTURE BOOKING: 367//
  end  
  
  r_f.expect(/START TIME FOR AUTO REBOOK:/) do
    w_f.print "0800\r" # START TIME FOR AUTO REBOOK: 
  end  
  
  r_f.expect(/MAX \# DAYS FOR AUTO-REBOOK:/) do
    w_f.print "14\r" # MAX # DAYS FOR AUTO-REBOOK: 14// 
  end  
  
  r_f.expect(/SCHEDULE ON HOLIDAYS\?:/) do
    w_f.print "\r" # SCHEDULE ON HOLIDAYS?: 
  end  
  
  r_f.expect(/CREDIT STOP CODE:/) do
    w_f.print "PRIMARY CARE\/MEDICINE\r" # CREDIT STOP CODE: PRIMARY CARE/MEDICINE// 
  end  
  
  r_f.expect(/PROHIBIT ACCESS TO CLINIC?:/) do
    w_f.print "\r" # PROHIBIT ACCESS TO CLINIC?:
  end  
  
  r_f.expect(/PHYSICAL LOCATION:/) do
    w_f.print "PRIMARY CARE CLINIC\r" # PHYSICAL LOCATION: PRIMARY CARE CLINIC//
  end  
  
  r_f.expect(/PRINCIPAL CLINIC:/) do
    w_f.print "\r" # PRINCIPAL CLINIC:
  end  
  
  r_f.expect(/OVERBOOKS\/DAY MAXIMUM:/) do
    w_f.print "2\r" # OVERBOOKS/DAY MAXIMUM: 2//
  end  
  
  r_f.expect(/Select SPECIAL INSTRUCTIONS:/) do
    w_f.print "\r" # Select SPECIAL INSTRUCTIONS:
  end  
  
  r_f.expect(/LENGTH OF APP\'T:/) do
    w_f.print "30\r" # LENGTH OF APP'T: 30//
  end  
  
  r_f.expect(/VARIABLE APP'NTMENT LENGTH:/) do
    w_f.print "YES\r" #VARIABLE APP'NTMENT LENGTH: YES, VARIABLE LENGTH
  end
   
  for num_day in 0..6
    # AVAILABILITY DATE: t  (NOV 25, 2015)
    if num_day == 0
      w_f.print "T\r"
    else
      w_f.print "T+" + num_day.to_s + "\r"
    end
    
    # TIME: and then NO. SLOTS:
    w_f.print "0800-0830\r" 
    w_f.print "4\r"
    w_f.print "0830-0900\r" 
    w_f.print "4\r"
    w_f.print "0900-0930\r" 
    w_f.print "4\r"
    w_f.print "0930-1000\r" 
    w_f.print "4\r"
    w_f.print "1000-1030\r" 
    w_f.print "4\r"
    w_f.print "1030-1100\r" 
    w_f.print "4\r"
    w_f.print "1100-1130\r" 
    w_f.print "4\r"
    w_f.print "1130-1200\r" 
    w_f.print "4\r"
    w_f.print "1300-1330\r" 
    w_f.print "4\r"
    w_f.print "1330-1400\r" 
    w_f.print "4\r"
    w_f.print "1400-1430\r" 
    w_f.print "4\r"
    w_f.print "1430-1500\r" 
    w_f.print "4\r"
    w_f.print "1500-1530\r" 
    w_f.print "4\r"
    w_f.print "1530-1600\r" 
    w_f.print "4\r"
    w_f.print "1600-1630\r" 
    w_f.print "4\r"
    w_f.print "\r"
    # ...PATTERN OK FOR "DAY OF WEEK" INDEFINITELY? no  (No)
    w_f.print "Y\r"
    # AVAILABILITY DATE: t  (NOV 25, 2015)
    w_f.print "T+1\r" 
  end # end for loop

end # end pty csession invocation
