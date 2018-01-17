#!/usr/bin/ruby
# If you don't know the code, don't mess around below -BCIV
# Purpose: programatically create a clinic in the Department of Veterans Affairs VistA EHR
# Written by: Will BC Collins IV {a.k.a., 'BCIV' follow me on GitHub ~ I'm super cool.}
# Email: william.collins@va.gov

require 'pty'
require 'json'

#file = File.read('config.remote.json')
#config=JSON.parse(file)

master, slave = PTY.open
read, write = IO.pipe

def read_config (configurationfile)
  print "reading "+configurationfile+"\n"
  file = File.read(configurationfile)
  retval=JSON.parse(file)
  return retval
end

def ex (ex_read,ex_write)
  expect ex_read do
    print ex_read+ " " + ex_write + "\n"
    send ex_write+"\r"
  end
end

config=read_config('config.remote.json')

#exp=RubyExpect::Expect.spawn(config['command'], :debug=>true)

pid = spawn(config['command'],:in=>read,:out=>slave)
#read.close # don't need
#slave.close # don't need

print master.gets 
print "sending " + config['password'] + "\n"
master.puts config['password']+"\n"

p master.gets


exit 

exp.procedure do
  print "spawned "+config['command']+"...\n"
  each do
    # if command regexp /ssh/
    expect "password:" do
      print "prompted for password..."
      send config['password']+"\n"
    end

    ex("ACCESS CODE:", config['access_code'])
    #expect "ACCESS CODE:" do
    #  print "Promted for Access Code..."
    #  send config['access_code']+"\r"  
    #end

    ex("VERIFY CODE:", config['verify_code'])
    #expect "VERIFY CODE:" do
    #  send config['verify_code']+"\r"
    #end

#    ex("Select TERMINAL TYPE NAME:","C-VT100")
    #expect "Select TERMINAL TYPE NAME:" do
    #  send "C-VT100\r"
    #end

    ex("Select Systems Manager Menu <TEST ACCOUNT> Option:","^^SET UP A CLINIC")
    #expect "Select Systems Manager Menu <TEST ACCOUNT> Option:" do
    #  send "^^SET UP A CLINIC\r"
    #end

    ex("Select CLINIC NAME:","ALPHA")
    #expect "Select CLINIC NAME:" do
    #  send "ALPHA\r"     
    #end   

    ex("Are you adding 'ALPHA' as a new HOSPITA","YES")
    #expect "Are you adding 'ALPHA' as a new HOSPITA" do
    #  send "YES\r"
    #end
  
    ex("NAME:","")
    #expect "NAME:" do
    #  send "\r" # NAME:
    #end
  
    expect "ABBREVIATION:" do
      send "ALP\r" # ABBREVIATION: PCM//
    end
  
    expect "CLINIC MEETS AT THIS FACILITY?:" do
      send "YES\r" # CLINIC MEETS AT THIS FACILITY?: YES// 
    end
  
    expect "SERVICE:" do
      send "MEDICINE\r" # SERVICE: MEDICINE//
    end  
  
    expect "NON-COUNT CLINIC? (Y OR N):" do
      send "N\r" # NON-COUNT CLINIC? (Y OR N): NO//
    end  
  
    expect "DIVISION:" do
      send "\r" # DIVISION: VEHU DIVISION// ~take default
    end   
  
    expect "STOP CODE NUMBER:" do
      send "PRIMARY CARE/MEDICINE\r" # STOP CODE NUMBER: PRIMARY CARE/MEDICINE//
    end  
  
    expect "DEFAULT APPOINTMENT TYPE:" do
      send "REGULAR\r" # DEFAULT APPOINTMENT TYPE: REGULAR//
    end  
  
    expect "ADMINISTER INPATIENT MEDS?:" do
      send "YES\r" # ADMINISTER INPATIENT MEDS?: YES//
    end  
  
    expect "TELEPHONE:" do
      send "\r" # TELEPHONE:
    end  
  
    expect "REQUIRE X-RAY FILMS?:" do
      send "\r" # REQUIRE X-RAY FILMS?:
    end  
  
    expect "REQUIRE ACTION PROFILES?:" do
      send "YES\r" # REQUIRE ACTION PROFILES?: YES//
    end  
  
    expect "NO SHOW LETTER:" do
      send "\r" # NO SHOW LETTER:
    end  
  
    expect "PRE-APPOINTMENT LETTER:" do
      send "\r" # PRE-APPOINTMENT LETTER:
    end  
  
    expect "CLINIC CANCELLATION LETTER:" do
      send "CLINIC CANCELLED\r" # CLINIC CANCELLATION LETTER: CLINIC CANCELLED//
    end  
  
    expect "APPT. CANCELLATION LETTER:" do
      send "Pt. Cancellation\r" # APPT. CANCELLATION LETTER: Pt. Cancellation//
    end  
  
    expect "ASK FOR CHECK IN/OUT TIME:" do
      send "YES\r" # ASK FOR CHECK IN/OUT TIME: YES//
    end  
  
    expect "Select PROVIDER:" do
      send "PROVIDER,ONE\r" # Select PROVIDER: PROVIDER,FIVE//
    end  
  
    expect "CHOOSE 1-5:" do
      send "1\r" # CHOOSE 1-5:
    end

    expect "Are you adding 'PROVIDER,ONE'" do
      send "Yes\r" # Are you adding 'PROVIDER,ONE'
    end

    expect "DEFAULT PROVIDER:" do
      send "1\r" # DEFAULT PROVIDER:
    end  

    expect "Select PROVIDER:" do
      send "\r" # Select PROVIDER: PROVIDER,ONE//
    end  
  
    expect "DEFAULT TO PC PRACTITIONER?:" do
      send "NO\r" # DEFAULT TO PC PRACTITIONER?: NO//
    end  
  
    expect "Select DIAGNOSIS:" do
      send "\r" # Select DIAGNOSIS:
    end  
  
    expect "WORKLOAD VALIDATION AT CHK OUT:" do
      send "YES\r" # WORKLOAD VALIDATION AT CHK OUT: YES//
    end  
  
    expect "ALLOWABLE CONSECUTIVE NO-SHOWS:" do
      send "99\r" # ALLOWABLE CONSECUTIVE NO-SHOWS: 99//
    end  
  
    expect "MAX # DAYS FOR FUTURE BOOKING:" do
      send "367\r" # MAX # DAYS FOR FUTURE BOOKING: 367//
    end  
 
    expect "HOUR CLINIC DISPLAY BEGINS:" do
      send "8\r"
    end
 
    expect "START TIME FOR AUTO REBOOK:" do
      send "8\r" # START TIME FOR AUTO REBOOK: 
    end  
  
    expect "MAX # DAYS FOR AUTO-REBOOK:" do
      send "14\r" # MAX # DAYS FOR AUTO-REBOOK: 14// 
    end  
  
    expect "SCHEDULE ON HOLIDAYS?:" do
      send "\r" # SCHEDULE ON HOLIDAYS?: 
    end  
  
    expect "CREDIT STOP CODE:" do
      send "PRIMARY CARE/MEDICINE\r" # CREDIT STOP CODE: PRIMARY CARE/MEDICINE// 
    end  
  
    expect "PROHIBIT ACCESS TO CLINIC?:" do
      send "\r" # PROHIBIT ACCESS TO CLINIC?:
    end  
  
    expect "PHYSICAL LOCATION:" do
      send "PRIMARY CARE CLINIC\r" # PHYSICAL LOCATION: PRIMARY CARE CLINIC//
    end  
  
    expect "PRINCIPAL CLINIC:" do
      send "\r" # PRINCIPAL CLINIC:
    end  
  
    expect "OVERBOOKS/DAY MAXIMUM:" do
      send "2\r" # OVERBOOKS/DAY MAXIMUM: 2//
    end  
  
    expect "Select SPECIAL INSTRUCTIONS:" do
      send "\r" # Select SPECIAL INSTRUCTIONS:
    end  
  
    expect "LENGTH OF APP'T:" do
      send "30\r" # LENGTH OF APP'T: 30//
    end  
  
    expect "VARIABLE APP'NTMENT LENGTH:" do
      send "YES\r" #VARIABLE APP'NTMENT LENGTH: YES, VARIABLE LENGTH
    end
   
#  for num_day in 0..6
#    # AVAILABILITY DATE: t  (NOV 25, 2015)
#    if num_day == 0
#        send "T\r"
#    else
#        send "T+" + num_day.to_s + "\r"
#      end
#    
#    # TIME: and then NO. SLOTS:
#      send "0800-0830\r" 
#      send "4\r"
#      send "0830-0900\r" 
#      send "4\r"
#      send "0900-0930\r" 
#      send "4\r"
#      send "0930-1000\r" 
#      send "4\r"
#      send "1000-1030\r" 
#      send "4\r"
#      send "1030-1100\r" 
#      send "4\r"
#      send "1100-1130\r" 
#      send "4\r"
#      send "1130-1200\r" 
#      send "4\r"
#      send "1300-1330\r" 
#      send "4\r"
#      send "1330-1400\r" 
#      send "4\r"
#      send "1400-1430\r" 
#      send "4\r"
#      send "1430-1500\r" 
#      send "4\r"
#      send "1500-1530\r" 
#      send "4\r"
#      send "1530-1600\r" 
#      send "4\r"
#      send "1600-1630\r" 
#      send "4\r"
#      send "\r"
#    # ...PATTERN OK FOR "DAY OF WEEK" INDEFINITELY? no  (No)
#      send "Y\r"
#    # AVAILABILITY DATE: t  (NOV 25, 2015)
#      send "T+1\r" 
#    end # end for loop
  end
end # end pty csession invocation
