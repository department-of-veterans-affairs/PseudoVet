#!/usr/bin/perl -w

use IPC::Open2;
use Symbol;
my $line;
$WTR=gensym(); # get ref to typeglob
$RDR=gensym(); # another for read

my $process="ssh -t -t vista\@pseudovista.vaftl.us";

open2($RDR, $WTR, "/bin/bash") or die "Cannot open '/bin/bash'\n";

print "opened handle to console...\n";

print $WTR "ls\n";
close($WTR);

# print $WTR "$process\n";
# close($WTR);

while(<$RDR>){
  print "in loop...\n";
  print $_;

  $line=<$RDR>; # read output
  print $line." !!\n";
  if($line =~m/password/i){
    print "sending password...\n";
    print $WTR "vista\n";
  }
  if($line =~m/ACCESS CODE:/){
    print "sending ACCESS CODE...\n";
    print $WTR "vk1234\n";
  }
  if($line =~m/VERIFY CODE:/){
    print "sending VERIFY CODE...\n";
    print $WTR "vk1234!!\n";
  }

}

