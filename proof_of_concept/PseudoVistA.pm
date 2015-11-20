package PseudoVistA;
require Exporter;
require Expect;
#require DBI;
#use Digest::MD5 qw(md5_hex);
#use CGI qw(:all);
#use CGI::Carp qw( fatalsToBrowser );
#use CGI::Pretty;
#use Socket;
#use POSIX;

# The point of this module is to build a library of calls to vista from
# any new scripts and not have to re-invent how to do things like parse
# configuration files, select patients, parse appointment listings, et al.
#
# written by: Will BC Collins IV { GitHub username: bciv }
# email: william.collins@va.gov

use vars qw(@ISA @EXPORT $Version);
no warnings 'qw';
@ISA=qw(Exporter);
@EXPORT=qw(
  configure,
  new,
  get_next_available_appointment,
);
my $VERSION='0.1';

# read configuration variables from file
#
sub configure{
  my $self=shift;
  my ($file)=@_;
  open(IN,$file) or die "Cannot read configuration file, $file : $!";
  while(<IN>){
    my $line=$_;
    unless($line eq '' or $line=~m/^\#/){
      my($key,$value)=split(/=/,$line); 
      $value=~s/\s*+$//; $value=~s/[\'|\"]//g;
      $self->{$key}=$value;
    }
  } close(IN);
}

# connect to vista instance via commandline
#
sub connect{
  my $self=shift;
  my $command="$self->{command} $self->{username}\@$self->{servername}";
  print "$command\n";
  $self->{exp}=Expect->spawn($command) or die "Cannot spawn $command: $!\n";  
}

sub xsend{
  my $self=shift;
  my ($input)=@_;
  $self->{exp}->send($input); exp_continue;
}

sub new{
  my $invocant=shift;
  my $class=ref($invocant) || $invocant; # object or class name
  my $self={
    instance=>"x",
    namespace=>"",
    ipaddress=>"",
    username=>$ENV{'USER'},
    password=>"",
    accesscode=>"",
    verifycode=>"",
    electronic_signature_code=>"",
    patientname=>"",
    patientdob=>"",
    patientssn=>"",
    @_,
  };
  $self->{test}='foo';
  return bless $self, $class;
}

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
  my $self=shift;
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
      my %month=('Jan'=>'1','Feb'=>'2','Mar'=>'3','Apr'=>'4','May'=>'5','Jun'=>'6','Jul'=>'7','Aug'=>'8','Sep'=>'9','Oct'=>'10','Nov'=>'11','Dec'=>'12');
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

1;