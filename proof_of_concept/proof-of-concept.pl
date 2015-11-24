#!/usr/bin/perl
# This process kicks off the chain of scripts that constitute the
# proof of concept.

print "executing appointment scheduing routine...\n";
system("perl appointment-schedule.pl");

print "executing appointment check-in routine...\n";
system("check-in-appointment.pl");

print "executing progress note creation routine...\n";
system("create-progress-note.pl");

print "executing appointment check-out routine...\n";
system("check-out-appointment.pl");
exit;