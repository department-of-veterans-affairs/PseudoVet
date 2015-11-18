#!/usr/bin/perl -w
use Expect;
# If you don't know the code, don't mess around below -BCIV
# Purpose: programatically create an appointment based on the next available clinic time in
# The Department of Veterans Affairs VistA EHR or whatever the latest buzzword for a system
# that contains patient data.
# Written by: Will BC Collins IV {a.k.a., 'BCIV' follow me on GitHub ~ I'm super cool.}
# Email: william.collins@va.gov
# Last Modified: 20151118 unless I forgot to update this line...
# 
$Expect::Debug = 0; # verbose debug
$Expect::Log_Stdout = 1; # show chatter for debugging
my %month=('Jan'=>'1','Feb'=>'2','Mar'=>'3','Apr'=>'4','May'=>'5','Jun'=>'6','Jul'=>'7','Aug'=>'8','Sep'=>'9','Oct'=>'10','Nov'=>'11','Dec'=>'12');

# see ../config/sample.demo.config for example
my $configuration_file='../config/demo.config';

configure($configuration_file);

my $exp=Expect->spawn($command) or die "Cannot spawn $command: $!\n";

$exp->expect($timeout,
  [ qr/The authenticity of host/ => sub {
    my $exp=shift; $exp->send("y\n"); exp_continue;}],
  [ qr/Password/i => sub {
    my $exp=shift; $exp->send("$password\n"); exp_continue;
  }],
  [ qr/ACCESS CODE:/=>sub{
    my $exp=shift; $exp->send("$access_code\r"); exp_continue;
  }],
  [ qr/VERIFY CODE:/=>sub{
    my $exp=shift; $exp->send("$verify_code\r"); exp_continue;
  }],
  [ qr/Select TERMINAL TYPE NAME:/=>sub{
    my $exp=shift; $exp->send("\r"); exp_continue;
  }],
  [ qr/Select Systems Manager Menu <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("^^MAS MASTER MENU\r"); exp_continue;
  }],
  [ qr/Select MAS MASTER MENU <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("SD\r"); exp_continue;
  }],
  [ qr/Select Scheduling Manager's Menu <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("APPOINTMENT MENU\r"); exp_continue;
  }],
  [ qr/Select Appointment Menu <TEST ACCOUNT> Option:/=>sub{
    my $exp=shift; $exp->send("MAKE APPOINTMENT\r"); exp_continue;
  }],
  [ qr/Select CLINIC:/=>sub{ # next prompt CHOOSE 1-2: had to be entered here...
    my $exp=shift; $exp->send("$clinic_name\r1\r"); exp_continue;
  }],
  [ qr/Select PATIENT NAME:/=>sub{
    my $exp=shift; $exp->send("$patient_name\r"); exp_continue;
  }],
  [ qr/IS THIS APPOINTMENT FOR A SERVICE CONNECTED CONDITION?/=>sub{ # next prompt APPOINTMENT TYPE: REGULAR
    my $exp=shift; $exp->send("N\r"); exp_continue;
  }],
  [ qr/APPOINTMENT TYPE:/=>sub{ # REGULAR
    my $exp=shift; $exp->send("REGULAR\r"); exp_continue;
  }],
  [ qr/Select ETHNICITY:/=>sub{ # who cares
    my $exp=shift; $exp->send("\r"); exp_continue;
  }],
  [ qr/Select RACE:/=>sub{ # who cares
    my $exp=shift; $exp->send("\r"); exp_continue;
  }],  
  [ qr/IS THIS A 'NEXT AVAILABLE' APPOINTMENT REQUEST?/=>sub{
    my $exp=shift; $exp->send("Y\r"); exp_continue;
  }],
  [ qr/DATE\/TIME:/=>sub{
    # This is where we send in the micro managers... 
    # ...okay so I liked the LEGO movie I'm a dork like who cares.
    my $next_available_appointment=get_next_available_appointment($exp->before);
    my $exp=shift; $exp->send("$next_available_appointment\r"); exp_continue;
  }],
  [ qr/LENGTH OF APPOINTMENT \(IN MINUTES\):/=>sub{
    # make it a 30 minute slot...
    my $exp=shift; $exp->send("30\r"); exp_continue;
  }],
  [ qr/ISSUE REQUEST FOR RECORDS?/=>sub{
    # this would be cool but, we won't bother with this right now...
    my $exp=shift; $exp->send("NO\r");
    print "Patient appointment has been scheduled.  Process completed.\n";
  }],
  [ qr/DISPLAY PENDING APPOINTMENTS:/=>sub{
    # I think this means we already made one...
    my $exp=shift; $exp->send("YES\n"); exp_continue;
  }],
  [ qr/DO YOU WANT TO CANCEL IT?/=>sub{
    my $exp=shift; $exp->send("NO\r");
    print "Patient already has appointment scheduled.  Nothing to do.\n";
  }],
);

# parse appointment availability table that only makes sense to humans
# takes $exp->before() as input where $exp->before gives you this: ...
#
#                                    PRIMARY CARE
#                                    Nov 2015
#
# TIME  |8      |9      |10     |11     |12     |1      |2      |3      |4      
# DATE  |       |       |       |       |       |       |       |       |
#WE 18  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#TH 19  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#FR 20  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#SA 21  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#SU 22  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#MO 23  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
#TU 24  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
#WE 25  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#   26    Thanksgiving Day
#FR 27  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#SA 28  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#SU 29  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
#MO 30  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
#                                    Dec 2015
#TU 01  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
#
#60 MINUTE APPOINTMENTS (VARIABLE LENGTH)
#DATE/TIME:     
#
sub get_next_available_appointment{
  # ...and all who have entered here have never returned...
  my($table)=@_; my $retval;
  my @out=split(/\n/,$table);
  my $aptmonth; my $aptyear;
  my @hours; # hours of potential available appointments
  for(my $i=0; $i<@out; ++$i){
    my $string=$out[$i];
    # first...
    # match a MON YEAR such as 'Dec 2015' to build YYYYMM portion of appointment slot
    if($string=~m/^\s*\w\w\w\s\d\d\d\d\s*+$/){
      $string=~s/\s*/\^/g; $string=~s/\^\^/,/g; $string=~s/\^//g;
      my($as,$mon,$year)=split(/,/,$string);
      $aptyear=$year; $aptmonth=$month{$mon};
      print "1 $mon $year -> $year$month{$mon}\n";
    }
    # second... match this line for available hours
    # TIME  |8      |9      |10     |11     |12     |1      |2      |3      |4
    if($string=~m/^\sTIME\s\s\|/){
      $string=~s/\sTIME\s\s\|//; $string=~s/\s*//g; #strip out TIME and whitespace
      foreach $hr (split(/\|/,$string)){ push @hours, sprintf("%02d",$hr); }
      my $display_hours; foreach $hr (@hours){ $display_hours.=" $hr"; }
      print "\n2 >>> $display_hours\n";
    }    
    # third... match for slots that are not taken... 
    # we take the first available for the appointment
    # we map it to the corresponding hour based on relation of slot def number
    # such as [4] for 4 appointment slots per hour... if it is [0] or [X] it is taken already.
    # WE 18  [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] [4] 
    # MO 23  [4] [4] [4] [4] [4] [4] [4] [4] |       [4] [4] [4] [4] [4] [4] [4] [4] 
    if($string=~m/^\w\w\s\d\d\s\s\[/){
      my $minutes;
      my $aptday=substr($string,3,2);
      # get rid of the '[]' brackets leaving us with a space delimited string
      $string=~s/^\w\w\s//;
      $string=~s/\[|\]//g;
      # 0 out blocked out hours from assignment
      $string=~s/\|\s\s\s\s\s\s/0 0/g;
      print "\n3 >>> slots: $string\n";
      my @slots=split(/\s/,$string);

      # there are two of these sets of slots per hour if the number of the slot is greater than 0
      # as the slots are iterated they begin with 0 for the first slot which is an even number
      my $myhour=0;
      for(my $i=0; $i<@slots; $i++){
        # Simply alternate between even an odd to see if we are at each whole or half hour
        if(0==$i % 2){ 
          $minutes="00"; 
          # if we are past the first hour increment the hour we are looking at
          if($i>1){++$myhour;} 
        }else{$minutes="30";}
        
        # see if slot is > 0 which would indicate there is an available slot to schedule into
        if($slots[$i]>0){
          # We have found an available appointment slot woo hoo!
          # lets not put it in a log book so we don't get into trouble and end up on the 
          # news for being total jerks and assign an appointment ... okay that really
          # isn't funny is it?  What an atrocity.  :(
          $retval=$aptyear.$aptmonth.$aptday."\@".$hours[$myhour].$minutes;
          print "$retval\n";
          # once we have found a free spot this routine will simply return the next available
          # appointment in the format: YYYYMMDD@HHMM
          print "\n3 >>> day next available slot is: $retval\n";
          return $retval;
        }        
      }
    } # end of loop through ^WE 18 [4] [4...
  } # end of loop through each line of schedule table
  #return $retval;  
}

# read configuration variables from file
#
sub configure{
  my $file=$_[0];
  open(IN,$file) or die "Cannot read configuration file, $file : $!";
  while(<IN>){eval $_;} close(IN);
}
